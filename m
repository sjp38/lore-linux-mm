Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 642436B0082
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 08:53:34 -0400 (EDT)
Received: by ewy9 with SMTP id 9so1637748ewy.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:53:30 -0700 (PDT)
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC v3 0/5] implement RUNTIME_USER_COPY_CHECKS
Date: Thu, 21 Jul 2011 16:53:26 +0400
Message-Id: <1311252806-6641-1-git-send-email-segoon@openwall.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>

This patch implements 2 additional checks for the data copied from
kernelspace to userspace and vice versa (original PAX_USERCOPY from PaX
patch).  Currently there are some very simple and cheap comparisons of
supplied size and the size of a copied object known at the compile time
in copy_* functions.  This patch enhances these checks to check against
stack frame boundaries and against SL*B object sizes.

More precisely, it checks:

1) if the data touches the stack, checks whether it fully fits in the stack
and whether it fully fits in a single stack frame.  The latter is arch
dependent, currently it is implemented for x86 with CONFIG_FRAME_POINTER=y
only.  It limits infoleaks/overwrites to a single frame and local variables
only, and prevents saved return instruction pointer overwriting.

2) if the data is from the SL*B cache, checks whether it fully fits in a
slab page and whether it overflows a slab object.  E.g. if the memory
was allocated as kmalloc(64, GFP_KERNEL) and one tries to copy 150
bytes, the copy would fail.

The checks are implemented for copy_{to,from}_user() and similar and are
missing for {put,get}_user() and similar because the base pointer might
be a result of any pointer arithmetics, and the correctness of these
arithmetics is almost impossible to check on this stage.  If the
real object size is known at the compile time, the check is reduced to 2
integers comparison.  If the supplied length argument is known at the
compile time, the check is skipped because the only thing that can be
under attacker's control is object pointer and checking for errors as a
result of wrong pointer arithmetic is beyond patch's goals.

/dev/kmem and /dev/mem are fixed to pass this check (e.g. without
STRICT_DEVMEM it should be possible to overflow the stack frame and slab
objects).

The slowdown is negligible - for most cases it is reduced to integer
comparison (in fstat, getrlimit, ipc) for some cases the whole syscall time
and the time of a check are not comparable (in write, path traversal
functions - openat, stat), for programs with not intensive syscalls
usage.  One of the most significant slowdowns is gethostname(), the
penalty is 0,9%.  For 'find /usr', 'git log -Sredirect' in kernel tree,
kernel compilation the slowdown is less than 0,1% (couldn't measure it
more precisely).

The limitations:

The stack check does nothing with local variables overwriting and 
saved registers.  It only limits overflows to a single frame.

The SL*B checks don't validate whether the object is actually allocated.
So, it doesn't prevent infoleaks related to the freed objects.  Also if
the cache's granularity is larger than an actual allocated object size,
an infoleak of padding bytes is possible.  The slob check is missing yet.
Unfortunately, the check for slob would have to (1) walk through the
slob chunks and (2) hold the slob lock, so it would lead to a
significant slowdown.

The patch does nothing with other memory areas like vmalloc'ed areas,
modules' data and code sections, etc.  It can be an area for
improvements.

The patch's goal is similar to StackGuard (-fstack-protector gcc option,
enabled by CONFIG_CC_STACKPROTECTOR): catch buffer oveflows.
However, the design is completely different.  First, SG does nothing
with overreads, it can catch overwrites only.  Second, SG cannot catch
SL*B buffer overflows.  Third, SG checks the canary after a buffer is
overflowed instead of preventing an actual overflow attempt; when an attacker
overflows a stack buffer, he can uncontrolledly wipe some data on the
stack before the function return.  If attacker's actions generate kernel
oops before the return, SG would not get the control and the overflow is
not catched as if SG is disabled.  However, SG can catch oveflows of
memcpy(), strcpy(), sprintf() and other functions working with kernel
data only, which are not caught by RUNTIME_USER_COPY_CHECK.

The checks are implemented for x86, it can be easily extended to other
architectues by including <linux/uaccess-check.h> and adding
kernel_access_ok() checks into {,__}copy_{to,from}_user().

The patch is a forwardport of the PAX_USERCOPY feature from the PaX
patch.  Most code was copied from the PaX patch with minor cosmetic
changes.  Also PaX' version of the patch has additional restrictions:

a) some slab caches has SLAB_USERCOPY flag set and copies to/from the slab
caches without the flag are denied.  Rare cases where some bytes needed
from the caches missing in the white list are handled by copying the
bytes into temporary area on the stack/heap.

b) if a malformed copy request is spotted, the event is logged and
SIGKILL signal is sent to the current task.

Examples of overflows, which become nonexploitable with RUNTIME_USER_COPY_CHECK:
DCCP getsockopt copy_to_user() overflow (fixed in 39ebc0276bada),
L2TP memcpy_fromiovec() overflow (fixed in 253eacc070b),
partly 7182afea8d1afd432a17c18162cc3fd441d0da93


Questions/thoughts:

Should this code put in action some reacting mechanisms?  Probably it
is a job of userspace monitoring daemon (like sigv TODO ), but the kernel's
reaction would be race free and much more timely.

v3 - Simplified addition of new architectures.
   - Define slab_access_ok() only if DEBUG_RUNTIME_USER_COPY_CHECKS=y.
   - Moved "len == 0" check to kernel_access_ok().
   - Now log the copy direction (from/to user) on overflows.
   - Removed (char *) casts.
   - Removed redundant NULL initializers.
   - Simplified addition of new architectures.
   - Used __always_inline.
   - Used #ifdef instead of #if defined().

v2 - Moved the checks to kernel_access_ok().
   - If the object size is known at the compilation time, just compare
     length and object size.
   - Check only if length value is not known at the compilation time.
   - Provided performance results.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 arch/x86/include/asm/uaccess.h    |   49 ++++++++++++++++++++++++++
 arch/x86/include/asm/uaccess_32.h |   32 +++++++++++++++--
 arch/x86/include/asm/uaccess_64.h |   38 +++++++++++++++++++-
 arch/x86/lib/usercopy_32.c        |    2 +-
 drivers/char/mem.c                |    9 +++--
 include/linux/slab.h              |    4 ++
 include/linux/uaccess-check.h     |   70 +++++++++++++++++++++++++++++++++++++
 lib/Kconfig.debug                 |   22 +++++++++++
 mm/maccess.c                      |   48 +++++++++++++++++++++++++
 mm/slab.c                         |   33 +++++++++++++++++
 mm/slob.c                         |   12 ++++++
 mm/slub.c                         |   28 +++++++++++++++
 12 files changed, 337 insertions(+), 10 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
