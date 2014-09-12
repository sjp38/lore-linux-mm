Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id E6BAE6B003C
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 17:23:39 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so2033401pde.19
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 14:23:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ae8si10065434pad.193.2014.09.12.14.23.38
        for <linux-mm@kvack.org>;
        Fri, 12 Sep 2014 14:23:38 -0700 (PDT)
Message-ID: <54136459.1070700@intel.com>
Date: Fri, 12 Sep 2014 14:23:37 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 00/10] Intel MPX support
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <54124379.5090502@intel.com> <alpine.DEB.2.10.1409121543090.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409121543090.4178@nanos>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/12/2014 12:21 PM, Thomas Gleixner wrote:
> Yes, the most important question is WHY must the kernel handle the
> bound table memory allocation in the first place. The "documentation"
> patch completely fails to tell that.

This will become the description of "patch 04/10".  Feel free to wait
until we repost these to read it, but I'm posting it here because it's
going to be a couple of days before we actually get a new set of patches
out.

Any suggestions for how much of this is appropriate for Documentation/
would be much appreciated.  I don't have a good feel for it.

---

Subject: x86: mpx: on-demand kernel allocation of bounds tables
MPX only has 4 hardware registers for storing bounds information.
If MPX-enabled code needs more than these 4 registers, it needs
to spill them somewhere.  It has two special instructions for
this which allow the bounds to be moved between the bounds
registers and some new "bounds tables".

#BR exceptions are a new class of exceptions just for MPX.  They
are similar conceptually to a page fault and will be raised by
the MPX hardware during both bounds violations or when the tables
are not present.  This patch handles those #BR exceptions for
not-present tables by carving the space out of the normal
processes address space (essentially calling mmap() from inside
the kernel) and then pointing the bounds-directory over to it.

The tables *need* to be accessed and controlled by userspace
because the instructions for moving bounds in and out of them are
extremely frequent.  They potentially happen every time a
register points to memory.  Any direct kernel involvement (like a
syscall) to access the tables would obviously destroy
performance.

==== Why not do this in userspace? ====

This patch is obviously doing this allocation in the kernel.
However, MPX does not strictly *require* anything in the kernel.
It can theoretically be done completely from userspace.  Here are
a few ways this *could* be done.  I don't think any of them are
practical in the real-world, but here they are.

Q: Can virtual space simply be reserved for the bounds tables so
   that we never have to allocate them?
A: As noted earlier, these tables are *HUGE*.  An X-GB virtual
   area needs 4*X GB of virtual space, plus 2GB for the bounds
   directory.  If we were to preallocate them for the 128TB of
   user virtual address space, we would need to reserve 512TB+2GB,
   which is larger than the entire virtual address space today.
   This means they can not be reserved ahead of time.  Also, a
   single process's pre-popualated bounds directory consumes 2GB
   of virtual *AND* physical memory.  IOW, it's completely
   infeasible to prepopulate bounds directories.

Q: Can we preallocate bounds table space at the same time memory
   is allocated which might contain pointers that might eventually
   need bounds tables?
A: This would work if we could hook the site of each and every
   memory allocation syscall.  This can be done for small,
   constrained applications.  But, it isn't practical at a larger
   scale since a given app has no way of controlling how all the
   parts of the app migth allocate memory (think libraries).  The
   kernel is really the only place to intercept these calls.

Q: Could a bounds fault be handed to userspace and the tables
   allocated there in a signal handler intead of in the kernel?
A: (thanks to tglx) mmap() is not on the list of safe async
   handler functions and even if mmap() would work it still
   requires locking or nasty tricks to keep track of the
   allocation state there.

Having ruled out all of the userspace-only approaches for managing
bounds tables that we could think of, we create them on demand
in the kernel.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
