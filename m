Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A396E6B0201
	for <linux-mm@kvack.org>; Tue, 11 May 2010 12:17:29 -0400 (EDT)
Received: by pzk28 with SMTP id 28so2533105pzk.11
        for <linux-mm@kvack.org>; Tue, 11 May 2010 09:17:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1271943493-12120-1-git-send-email-ebmunson@us.ibm.com>
References: <1271943493-12120-1-git-send-email-ebmunson@us.ibm.com>
Date: Tue, 11 May 2010 09:17:26 -0700
Message-ID: <AANLkTin-BXsUZoKqvgxfG-NS8UhTPucnGo8EnqLM7WDZ@mail.gmail.com>
Subject: Re: [PATCH] ummunotify: Userspace support for MMU notifications V2
From: Sayantan Sur <surs@cse.ohio-state.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org, linux-mm@kvack.org, rolandd@cisco.com, peterz@infradead.org, mingo@elte.hu, pavel@ucw.cz, "Jeff Squyres (jsquyres)" <jsquyres@cisco.com>, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

Hi,

I understand that this patch went through to the -mm tree.
MVAPICH/MVAPICH2 MPI stacks intend to utilize this feature as well.

Thanks.

On Thu, Apr 22, 2010 at 6:38 AM, Eric B Munson <ebmunson@us.ibm.com> wrote:
> From: Roland Dreier <rolandd@cisco.com>
>
> As discussed in <http://article.gmane.org/gmane.linux.drivers.openib/6192=
5>
> and follow-up messages, libraries using RDMA would like to track
> precisely when application code changes memory mapping via free(),
> munmap(), etc.=A0 Current pure-userspace solutions using malloc hooks
> and other tricks are not robust, and the feeling among experts is that
> the issue is unfixable without kernel help.
>
> We solve this not by implementing the full API proposed in the email
> linked above but rather with a simpler and more generic interface,
> which may be useful in other contexts.=A0 Specifically, we implement a
> new character device driver, ummunotify, that creates a /dev/ummunotify
> node.=A0 A userspace process can open this node read-only and use the fd
> as follows:
>
> =A01. ioctl() to register/unregister an address range to watch in the
> =A0=A0=A0 kernel (cf struct ummunotify_register_ioctl in <linux/ummunotif=
y.h>).
>
> =A02. read() to retrieve events generated when a mapping in a watched
> =A0=A0=A0 address range is invalidated (cf struct ummunotify_event in
> =A0=A0=A0 <linux/ummunotify.h>).=A0 select()/poll()/epoll() and SIGIO are
> =A0=A0=A0 handled for this IO.
>
> =A03. mmap() one page at offset 0 to map a kernel page that contains a
> =A0=A0=A0 generation counter that is incremented each time an event is
> =A0=A0=A0 generated.=A0 This allows userspace to have a fast path that ch=
ecks
> =A0=A0=A0 that no events have occurred without a system call.
>
> Thanks to Jason Gunthorpe <jgunthorpe <at> obsidianresearch.com> for
> suggestions on the interface design.=A0 Also thanks to Jeff Squyres
> <jsquyres <at> cisco.com> for prototyping support for this in Open MPI,
> which
> helped find several bugs during development.
>
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
>
> ---
>
> Changes from V1:
> - Update Kbuild to handle test program build properly
> - Update documentation to cover questions not addressed in previous
> =A0 thread
> ---
> =A0Documentation/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 |=A0=A0=A0 3 +-
> =A0Documentation/ummunotify/Makefile=A0=A0=A0=A0=A0=A0 |=A0=A0=A0 7 +
> =A0Documentation/ummunotify/ummunotify.txt |=A0 162 +++++++++
> =A0Documentation/ummunotify/umn-test.c=A0=A0=A0=A0 |=A0 200 +++++++++++
> =A0drivers/char/Kconfig=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 |=A0=A0 12 +
> =A0drivers/char/Makefile=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 |=A0=A0=A0 1 +
> =A0drivers/char/ummunotify.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 |=
=A0 567
> +++++++++++++++++++++++++++++++
> =A0include/linux/Kbuild=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 |=A0=A0=A0 1 +
> =A0include/linux/ummunotify.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=
 121 +++++++
> =A09 files changed, 1073 insertions(+), 1 deletions(-)
> =A0create mode 100644 Documentation/ummunotify/Makefile
> =A0create mode 100644 Documentation/ummunotify/ummunotify.txt
> =A0create mode 100644 Documentation/ummunotify/umn-test.c
> =A0create mode 100644 drivers/char/ummunotify.c
> =A0create mode 100644 include/linux/ummunotify.h
>
> diff --git a/Documentation/Makefile b/Documentation/Makefile
> index 6fc7ea1..27ba76a 100644
> --- a/Documentation/Makefile
> +++ b/Documentation/Makefile
> @@ -1,3 +1,4 @@
> =A0obj-m :=3D DocBook/ accounting/ auxdisplay/ connector/ \
> =A0=A0=A0=A0=A0=A0=A0 filesystems/ filesystems/configfs/ ia64/ laptops/ n=
etworking/ \
> -=A0=A0=A0=A0=A0=A0 pcmcia/ spi/ timers/ video4linux/ vm/ watchdog/src/
> +=A0=A0=A0=A0=A0=A0 pcmcia/ spi/ timers/ video4linux/ vm/ ummunotify/ \
> +=A0=A0=A0=A0=A0=A0 watchdog/src/
> diff --git a/Documentation/ummunotify/Makefile
> b/Documentation/ummunotify/Makefile
> new file mode 100644
> index 0000000..89f31a0
> --- /dev/null
> +++ b/Documentation/ummunotify/Makefile
> @@ -0,0 +1,7 @@
> +# List of programs to build
> +hostprogs-y :=3D umn-test
> +
> +# Tell kbuild to always build the programs
> +always :=3D $(hostprogs-y)
> +
> +HOSTCFLAGS_umn-test.o +=3D -I$(objtree)/usr/include
> diff --git a/Documentation/ummunotify/ummunotify.txt
> b/Documentation/ummunotify/ummunotify.txt
> new file mode 100644
> index 0000000..d6c2ccc
> --- /dev/null
> +++ b/Documentation/ummunotify/ummunotify.txt
> @@ -0,0 +1,162 @@
> +UMMUNOTIFY
> +
> +=A0 Ummunotify relays MMU notifier events to userspace.=A0 This is usefu=
l
> +=A0 for libraries that need to track the memory mapping of applications;
> +=A0 for example, MPI implementations using RDMA want to cache memory
> +=A0 registrations for performance, but tracking all possible crazy cases
> +=A0 such as when, say, the FORTRAN runtime frees memory is impossible
> +=A0 without kernel help.
> +
> +Basic Model
> +
> +=A0 A userspace process uses it by opening /dev/ummunotify, which
> +=A0 returns a file descriptor.=A0 Interest in address ranges is register=
ed
> +=A0 using ioctl() and MMU notifier events are retrieved using read(), as
> +=A0 described in more detail below.=A0 Userspace can register multiple
> +=A0 address ranges to watch, and can unregister individual ranges.
> +
> +=A0 Userspace can also mmap() a single read-only page at offset 0 on
> +=A0 this file descriptor.=A0 This page contains (at offest 0) a single
> +=A0 64-bit generation counter that the kernel increments each time an
> +=A0 MMU notifier event occurs.=A0 Userspace can use this to very quickly
> +=A0 check if there are any events to retrieve without needing to do a
> +=A0 system call.
> +
> +Control
> +
> +=A0 To start using ummunotify, a process opens /dev/ummunotify in
> +=A0 read-only mode.=A0 This will attach to current->mm because the curre=
nt
> +=A0 consumers of this functionality do all monitoring in the process
> +=A0 being monitored.=A0 It is currently not possible to use this device =
to
> +=A0 monitor other processes.=A0 Control from userspace is done via ioctl=
().
> +=A0 An ioctl was chosen because the number of files required to register
> +=A0 a new address range in sysfs would be unwieldy and new procfs entrie=
s
> +=A0 are discouraged.=A0 The defined ioctls are:
> +
> +=A0=A0=A0 UMMUNOTIFY_EXCHANGE_FEATURES: This ioctl takes a single 32-bit
> +=A0=A0=A0=A0=A0 word of feature flags as input, and the kernel updates t=
he
> +=A0=A0=A0=A0=A0 features flags word to contain only features requested b=
y
> +=A0=A0=A0=A0=A0 userspace and also supported by the kernel.
> +
> +=A0=A0=A0=A0=A0 This ioctl is only included for forward compatibility; n=
o
> +=A0=A0=A0=A0=A0 feature flags are currently defined, and the kernel will=
 simply
> +=A0=A0=A0=A0=A0 update any requested feature mask to 0.=A0 The kernel wi=
ll always
> +=A0=A0=A0=A0=A0 default to a feature mask of 0 if this ioctl is not used=
, so
> +=A0=A0=A0=A0=A0 current userspace does not need to perform this ioctl.
> +
> +=A0=A0=A0 UMMUNOTIFY_REGISTER_REGION: Userspace uses this ioctl to tell =
the
> +=A0=A0=A0=A0=A0 kernel to start delivering events for an address range.=
=A0 The
> +=A0=A0=A0=A0=A0 range is described using struct ummunotify_register_ioct=
l:
> +
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_register_ioctl {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u64=A0=A0 start;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u64=A0=A0 end;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u64=A0=A0 user_cookie;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u32=A0=A0 flags;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u32=A0=A0 reserved;
> +=A0=A0=A0=A0=A0=A0 };
> +
> +=A0=A0=A0=A0=A0 start and end give the range of userspace virtual addres=
ses;
> +=A0=A0=A0=A0=A0 start is included in the range and end is not, so an exa=
mple of
> +=A0=A0=A0=A0=A0 a 4 KB range would be start=3D0x1000, end=3D0x2000.
> +
> +=A0=A0=A0=A0=A0 user_cookie is an opaque 64-bit quantity that is returne=
d by the
> +=A0=A0=A0=A0=A0 kernel in events involving the range, and used by usersp=
ace to
> +=A0=A0=A0=A0=A0 stop watching the range.=A0 Each registered address rang=
e must
> +=A0=A0=A0=A0=A0 have a distinct user_cookie.
> +
> +=A0=A0=A0=A0=A0 It is fine with the kernel if userspace registers multip=
le
> +=A0=A0=A0=A0=A0 overlapping or even duplicate address ranges, as long as=
 a
> +=A0=A0=A0=A0=A0 different cookie is used for each registration.
> +
> +=A0=A0=A0=A0=A0 flags and reserved are included for forward compatibilit=
y;
> +=A0=A0=A0=A0=A0 userspace should simply set them to 0 for the current in=
terface.
> +
> +=A0=A0=A0 UMMUNOTIFY_UNREGISTER_REGION: Userspace passes in the 64-bit
> +=A0=A0=A0=A0=A0 user_cookie used to register a range to tell the kernel =
to stop
> +=A0=A0=A0=A0=A0 watching an address range.=A0 Once this ioctl completes,=
 the
> +=A0=A0=A0=A0=A0 kernel will not deliver any further events for the range=
 that is
> +=A0=A0=A0=A0=A0 unregistered.
> +
> +Events
> +
> +=A0 When an event occurs that invalidates some of a process's memory
> +=A0 mapping in an address range being watched, ummunotify queues an
> +=A0 event report for that address range.=A0 If more than one event
> +=A0 invalidates parts of the same address range before userspace
> +=A0 retrieves the queued report, then further reports for the same range
> +=A0 will not be queued -- when userspace does read the queue, only a
> +=A0 single report for a given range will be returned.
> +
> +=A0 If multiple ranges being watched are invalidated by a single event
> +=A0 (which is especially likely if userspace registers overlapping
> +=A0 ranges), then an event report structure will be queued for each
> +=A0 address range registration.
> +
> +=A0 It is possible, if a large enough number of overlapping ranges are
> +=A0 registered and the list of invalidated events is busy enough and
> +=A0 ignored long enough, to cause the kernel to run out of memory.
> +=A0 Because this situation is unlikely to occur, the event queue size
> +=A0 is not bounded in order to avoid dropping events if the queue grows
> +=A0 beyond set bounds.
> +
> +=A0 Userspace retrieves queued events via read() on the ummunotify file
> +=A0 descriptor; a buffer that is at least as big as struct
> +=A0 ummunotify_event should be used to retrieve event reports, and if a
> +=A0 larger buffer is passed to read(), multiple reports will be returned
> +=A0 (if available).
> +
> +=A0 If the ummunotify file descriptor is in blocking mode, a read() call
> +=A0 will wait for an event report to be available.=A0 Userspace may also
> +=A0 set the ummunotify file descriptor to non-blocking mode and use all
> +=A0 standard ways of waiting for data to be available on the ummunotify
> +=A0 file descriptor, including epoll/poll()/select() and SIGIO.
> +
> +=A0 The format of event reports is:
> +
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_event {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u32=A0=A0 type;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u32=A0=A0 flags;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u64=A0=A0 hint_start;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u64=A0=A0 hint_end;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 __u64=A0=A0 user_cookie_counter=
;
> +=A0=A0=A0=A0=A0=A0 };
> +
> +=A0 where the type field is either UMMUNOTIFY_EVENT_TYPE_INVAL or
> +=A0 UMMUNOTIFY_EVENT_TYPE_LAST.=A0 Events of type INVAL describe
> +=A0 invalidation events as follows: user_cookie_counter contains the
> +=A0 cookie passed in when userspace registered the range that the event
> +=A0 is for.=A0 hint_start and hint_end contain the start address and end
> +=A0 address that were invalidated.
> +
> +=A0 The flags word contains bit flags, with only UMMUNOTIFY_EVENT_FLAG_H=
INT
> +=A0 defined at the moment.=A0 If HINT is set, then the invalidation even=
t
> +=A0 invalidated less than the full address range and the kernel returns
> +=A0 the exact range invalidated; if HINT is not sent then hint_start and
> +=A0 hint_end are set to the original range registered by userspace.
> +=A0 (HINT will not be set if, for example, multiple events invalidated
> +=A0 disjoint parts of the range and so a single start/end pair cannot
> +=A0 represent the parts of the range that were invalidated)
> +
> +=A0 If the event type is LAST, then the read operation has emptied the
> +=A0 list of invalidated regions, and the flags, hint_start and hint_end
> +=A0 fields are not used.=A0 user_cookie_counter holds the value of the
> +=A0 kernel's generation counter (see below of more details) when the
> +=A0 empty list occurred.
> +
> +Generation Count
> +
> +=A0 Userspace may mmap() a page on a ummunotify file descriptor via
> +
> +=A0=A0=A0=A0=A0=A0 mmap(NULL, sizeof (__u64), PROT_READ, MAP_SHARED, umm=
unotify_fd, 0);
> +
> +=A0 to get a read-only mapping of the kernel's 64-bit generation
> +=A0 counter.=A0 The kernel will increment this generation counter each
> +=A0 time an event report is queued.
> +
> +=A0 Userspace can use the generation counter as a quick check to avoid
> +=A0 system calls; if the value read from the mapped kernel counter is
> +=A0 still equal to the value returned in user_cookie_counter for the
> +=A0 most recent LAST event retrieved, then no further events have been
> +=A0 queued and there is no need to try a read() on the ummunotify file
> +=A0 descriptor.
> diff --git a/Documentation/ummunotify/umn-test.c
> b/Documentation/ummunotify/umn-test.c
> new file mode 100644
> index 0000000..143db2c
> --- /dev/null
> +++ b/Documentation/ummunotify/umn-test.c
> @@ -0,0 +1,200 @@
> +/*
> + * Copyright (c) 2009 Cisco Systems.=A0 All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include <stdint.h>
> +#include <fcntl.h>
> +#include <stdio.h>
> +#include <unistd.h>
> +
> +#include <linux/ummunotify.h>
> +
> +#include <sys/mman.h>
> +#include <sys/stat.h>
> +#include <sys/types.h>
> +#include <sys/ioctl.h>
> +
> +#define UMN_TEST_COOKIE 123
> +
> +static int=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 umn_fd;
> +static volatile __u64=A0 *umn_counter;
> +
> +static int umn_init(void)
> +{
> +=A0=A0=A0=A0=A0=A0 __u32 flags;
> +
> +=A0=A0=A0=A0=A0=A0 umn_fd =3D open("/dev/ummunotify", O_RDONLY);
> +=A0=A0=A0=A0=A0=A0 if (umn_fd < 0) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 perror("open");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 if (ioctl(umn_fd, UMMUNOTIFY_EXCHANGE_FEATURES, &flag=
s)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 perror("exchange ioctl");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 printf("kernel feature flags: 0x%08x\n", flags);
> +
> +=A0=A0=A0=A0=A0=A0 umn_counter =3D mmap(NULL, sizeof *umn_counter, PROT_=
READ,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0 MA=
P_SHARED, umn_fd, 0);
> +=A0=A0=A0=A0=A0=A0 if (umn_counter =3D=3D MAP_FAILED) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 perror("mmap");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> +
> +static int umn_register(void *buf, size_t size, __u64 cookie)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_register_ioctl r =3D {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 .start=A0 =A0=A0=A0=A0=A0=A0=A0=
 =3D (unsigned long) buf,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 .end=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0=A0 =3D (unsigned long) buf + size,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 .user_cookie=A0=A0=A0 =3D cooki=
e,
> +=A0=A0=A0=A0=A0=A0 };
> +
> +=A0=A0=A0=A0=A0=A0 if (ioctl(umn_fd, UMMUNOTIFY_REGISTER_REGION, &r)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 perror("register ioctl");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> +
> +static int umn_unregister(__u64 cookie)
> +{
> +=A0=A0=A0=A0=A0=A0 if (ioctl(umn_fd, UMMUNOTIFY_UNREGISTER_REGION, &cook=
ie)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 perror("unregister ioctl");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +=A0=A0=A0=A0=A0=A0 int=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0=A0 page_size;
> +=A0=A0=A0=A0=A0=A0 __u64=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=
=A0 old_counter;
> +=A0=A0=A0=A0=A0=A0 void=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0 *t;
> +=A0=A0=A0=A0=A0=A0 int=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0=A0 got_it;
> +
> +=A0=A0=A0=A0=A0=A0 if (umn_init())
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +
> +=A0=A0=A0=A0=A0=A0 printf("\n");
> +
> +=A0=A0=A0=A0=A0=A0 old_counter =3D *umn_counter;
> +=A0=A0=A0=A0=A0=A0 if (old_counter !=3D 0) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 fprintf(stderr, "counter =3D %l=
ld (expected 0)\n",
> old_counter);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 page_size =3D sysconf(_SC_PAGESIZE);
> +=A0=A0=A0=A0=A0=A0 t =3D mmap(NULL, 3 * page_size, PROT_READ,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 MAP_PRIVATE | MAP_ANONYMOUS =
| MAP_POPULATE, -1, 0);
> +
> +=A0=A0=A0=A0=A0=A0 if (umn_register(t, 3 * page_size, UMN_TEST_COOKIE))
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +
> +=A0=A0=A0=A0=A0=A0 munmap(t + page_size, page_size);
> +
> +=A0=A0=A0=A0=A0=A0 old_counter =3D *umn_counter;
> +=A0=A0=A0=A0=A0=A0 if (old_counter !=3D 1) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 fprintf(stderr, "counter =3D %l=
ld (expected 1)\n",
> old_counter);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 got_it =3D 0;
> +=A0=A0=A0=A0=A0=A0 while (1) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 struct ummunotify_event ev;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 int=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0=A0 =A0=A0=A0=A0=A0=A0=A0 len;
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 len =3D read(umn_fd, &ev, sizeo=
f ev);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (len < 0) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 perror("r=
ead event");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (len !=3D sizeof ev) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 fprintf(s=
tderr, "Read gave %d bytes (!=3D event size
> %zd)\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 len, sizeof ev);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 switch (ev.type) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 case UMMUNOTIFY_EVENT_TYPE_INVA=
L:
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (got_i=
t) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 fprintf(stderr, "Extra invalidate event\n");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (ev.us=
er_cookie_counter !=3D UMN_TEST_COOKIE) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 fprintf(stderr, "Invalidate event for cookie
> %lld (expected %d)\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ev.user_cookie_counter,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 UMN_TEST_COOKIE);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 printf("I=
nvalidate event:\tcookie %lld\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0 ev.user_cookie_counter);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (!(ev.=
flags & UMMUNOTIFY_EVENT_FLAG_HINT)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 fprintf(stderr, "Hint flag not set\n");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (ev.hi=
nt_start !=3D (uintptr_t) t + page_size ||
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
 ev.hint_end !=3D (uintptr_t) t + page_size * 2) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 fprintf(stderr, "Got hint %llx..%llx,
> expected %p..%p\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ev.hint_start, ev.hint_end,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 t + page_size, t + page_size * 2);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 printf("\=
t\t\thint %llx...%llx\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0 ev.hint_start, ev.hint_end);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 got_it =
=3D 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 break;
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 case UMMUNOTIFY_EVENT_TYPE_LAST=
:
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (!got_=
it) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 fprintf(stderr, "Last event without
> invalidate event\n");
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 printf("E=
mpty event:\t\tcounter %lld\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0 ev.user_cookie_counter);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto done=
;
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 default:
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 fprintf(s=
tderr, "unknown event type %d\n",
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 ev.type);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 }
> +
> +done:
> +=A0=A0=A0=A0=A0=A0 umn_unregister(123);
> +=A0=A0=A0=A0=A0=A0 munmap(t, page_size);
> +
> +=A0=A0=A0=A0=A0=A0 old_counter =3D *umn_counter;
> +=A0=A0=A0=A0=A0=A0 if (old_counter !=3D 1) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 fprintf(stderr, "counter =3D %l=
ld (expected 1)\n",
> old_counter);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
> index 3141dd3..cf26019 100644
> --- a/drivers/char/Kconfig
> +++ b/drivers/char/Kconfig
> @@ -1111,6 +1111,18 @@ config DEVPORT
> =A0=A0=A0=A0=A0=A0=A0 depends on ISA || PCI
> =A0=A0=A0=A0=A0=A0=A0 default y
>
> +config UMMUNOTIFY
> +=A0=A0=A0=A0=A0=A0 tristate "Userspace MMU notifications"
> +=A0=A0=A0=A0=A0=A0 select MMU_NOTIFIER
> +=A0=A0=A0=A0=A0=A0 help
> +=A0=A0=A0=A0=A0=A0=A0=A0 The ummunotify (userspace MMU notification) dri=
ver creates a
> +=A0=A0=A0=A0=A0=A0=A0=A0 character device that can be used by userspace =
libraries to
> +=A0=A0=A0=A0=A0=A0=A0=A0 get notifications when an application's memory =
mapping
> +=A0=A0=A0=A0=A0=A0=A0=A0 changed.=A0 This is used, for example, by RDMA =
libraries to
> +=A0=A0=A0=A0=A0=A0=A0=A0 improve the reliability of memory registration =
caching, since
> +=A0=A0=A0=A0=A0=A0=A0=A0 the kernel's MMU notifications can be used to k=
now precisely
> +=A0=A0=A0=A0=A0=A0=A0=A0 when to shoot down a cached registration.
> +
> =A0source "drivers/s390/char/Kconfig"
>
> =A0endmenu
> diff --git a/drivers/char/Makefile b/drivers/char/Makefile
> index f957edf..521e5de 100644
> --- a/drivers/char/Makefile
> +++ b/drivers/char/Makefile
> @@ -97,6 +97,7 @@ obj-$(CONFIG_NSC_GPIO)=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 +=3D nsc_gpio.o
> =A0obj-$(CONFIG_CS5535_GPIO)=A0=A0=A0=A0=A0 +=3D cs5535_gpio.o
> =A0obj-$(CONFIG_GPIO_TB0219)=A0=A0=A0=A0=A0 +=3D tb0219.o
> =A0obj-$(CONFIG_TELCLOCK) =A0=A0=A0=A0=A0=A0=A0 +=3D tlclk.o
> +obj-$(CONFIG_UMMUNOTIFY)=A0=A0=A0=A0=A0=A0 +=3D ummunotify.o
>
> =A0obj-$(CONFIG_MWAVE)=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 +=3D mwave/
> =A0obj-$(CONFIG_AGP)=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 +=3D agp/
> diff --git a/drivers/char/ummunotify.c b/drivers/char/ummunotify.c
> new file mode 100644
> index 0000000..c14df3f
> --- /dev/null
> +++ b/drivers/char/ummunotify.c
> @@ -0,0 +1,567 @@
> +/*
> + * Copyright (c) 2009 Cisco Systems.=A0 All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include <linux/fs.h>
> +#include <linux/init.h>
> +#include <linux/list.h>
> +#include <linux/miscdevice.h>
> +#include <linux/mm.h>
> +#include <linux/mmu_notifier.h>
> +#include <linux/module.h>
> +#include <linux/poll.h>
> +#include <linux/rbtree.h>
> +#include <linux/sched.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/uaccess.h>
> +#include <linux/ummunotify.h>
> +
> +#include <asm/cacheflush.h>
> +
> +MODULE_AUTHOR("Roland Dreier");
> +MODULE_DESCRIPTION("Userspace MMU notifiers");
> +MODULE_LICENSE("GPL v2");
> +
> +/*
> + * Information about an address range userspace has asked us to watch.
> + *
> + * user_cookie: Opaque cookie given to us when userspace registers the
> + *=A0=A0 address range.
> + *
> + * start, end: Address range; start is inclusive, end is exclusive.
> + *
> + * hint_start, hint_end: If a single MMU notification event
> + *=A0=A0 invalidates the address range, we hold the actual range of
> + *=A0=A0 addresses that were invalidated (and set UMMUNOTIFY_FLAG_HINT).
> + *=A0=A0 If another event hits this range before userspace reads the
> + *=A0=A0 event, we give up and don't try to keep track of which subsets
> + *=A0=A0 got invalidated.
> + *
> + * flags: Holds the INVALID flag for ranges that are on the invalid
> + *=A0=A0 list and/or the HINT flag for ranges where the hint range holds
> + *=A0=A0 good information.
> + *
> + * node: Used to put the range into an rbtree we use to be able to
> + *=A0=A0 scan address ranges in order.
> + *
> + * list: Used to put the range on the invalid list when an MMU
> + *=A0=A0 notification event hits the range.
> + */
> +enum {
> +=A0=A0=A0=A0=A0=A0 UMMUNOTIFY_FLAG_INVALID =3D 1,
> +=A0=A0=A0=A0=A0=A0 UMMUNOTIFY_FLAG_HINT=A0=A0=A0 =3D 2,
> +};
> +
> +struct ummunotify_reg {
> +=A0=A0=A0=A0=A0=A0 u64=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0=A0 user_cookie;
> +=A0=A0=A0=A0=A0=A0 unsigned long=A0=A0 =A0=A0=A0=A0=A0=A0=A0 start;
> +=A0=A0=A0=A0=A0=A0 unsigned long=A0=A0 =A0=A0=A0=A0=A0=A0=A0 end;
> +=A0=A0=A0=A0=A0=A0 unsigned long=A0=A0 =A0=A0=A0=A0=A0=A0=A0 hint_start;
> +=A0=A0=A0=A0=A0=A0 unsigned long=A0=A0 =A0=A0=A0=A0=A0=A0=A0 hint_end;
> +=A0=A0=A0=A0=A0=A0 unsigned long=A0=A0 =A0=A0=A0=A0=A0=A0=A0 flags;
> +=A0=A0=A0=A0=A0=A0 struct rb_node=A0 =A0=A0=A0=A0=A0=A0=A0 node;
> +=A0=A0=A0=A0=A0=A0 struct list_head=A0=A0=A0=A0=A0=A0=A0 list;
> +};
> +
> +/*
> + * Context attached to each file that userspace opens.
> + *
> + * mmu_notifier: MMU notifier registered for this context.
> + *
> + * mm: mm_struct for process that created the context; we use this to
> + *=A0=A0 hold a reference to the mm to make sure it doesn't go away unti=
l
> + *=A0=A0 we're done with it.
> + *
> + * reg_tree: RB tree of address ranges being watched, sorted by start
> + *=A0=A0 address.
> + *
> + * invalid_list: List of address ranges that have been invalidated by
> + *=A0=A0 MMU notification events; as userspace reads events, the address
> + *=A0=A0 range corresponding to the event is removed from the list.
> + *
> + * counter: Page that can be mapped read-only by userspace, which
> + *=A0=A0 holds a generation count that is incremented each time an event
> + *=A0=A0 occurs.
> + *
> + * lock: Spinlock used to protect all context.
> + *
> + * read_wait: Wait queue used to wait for data to become available in
> + *=A0=A0 blocking read()s.
> + *
> + * async_queue: Used to implement fasync().
> + *
> + * need_empty: Set when userspace reads an invalidation event, so that
> + *=A0=A0 read() knows it must generate an "empty" event when userspace
> + *=A0=A0 drains the invalid_list.
> + *
> + * used: Set after userspace does anything with the file, so that the
> + *=A0=A0 "exchange flags" ioctl() knows it's too late to change anything=
.
> + */
> +struct ummunotify_file {
> +=A0=A0=A0=A0=A0=A0 struct mmu_notifier=A0=A0=A0=A0 mmu_notifier;
> +=A0=A0=A0=A0=A0=A0 struct mm_struct=A0=A0=A0=A0=A0=A0 *mm;
> +=A0=A0=A0=A0=A0=A0 struct rb_root=A0 =A0=A0=A0=A0=A0=A0=A0 reg_tree;
> +=A0=A0=A0=A0=A0=A0 struct list_head=A0=A0=A0=A0=A0=A0=A0 invalid_list;
> +=A0=A0=A0=A0=A0=A0 u64=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0 *counter;
> +=A0=A0=A0=A0=A0=A0 spinlock_t=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 lock;
> +=A0=A0=A0=A0=A0=A0 wait_queue_head_t=A0=A0=A0=A0=A0=A0 read_wait;
> +=A0=A0=A0=A0=A0=A0 struct fasync_struct=A0=A0 *async_queue;
> +=A0=A0=A0=A0=A0=A0 int=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0=A0 need_empty;
> +=A0=A0=A0=A0=A0=A0 int=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=
=A0=A0 used;
> +};
> +
> +static void ummunotify_handle_notify(struct mmu_notifier *mn,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0 unsigned long start, unsigned long end)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 container_of(mn, struct ummunot=
ify_file, mmu_notifier);
> +=A0=A0=A0=A0=A0=A0 struct rb_node *n;
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_reg *reg;
> +=A0=A0=A0=A0=A0=A0 unsigned long flags;
> +=A0=A0=A0=A0=A0=A0 int hit =3D 0;
> +
> +=A0=A0=A0=A0=A0=A0 spin_lock_irqsave(&priv->lock, flags);
> +
> +=A0=A0=A0=A0=A0=A0 for (n =3D rb_first(&priv->reg_tree); n; n =3D rb_nex=
t(n)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 reg =3D rb_entry(n, struct ummu=
notify_reg, node);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 /*
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * Ranges overlap if they're =
not disjoint; and they're
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * disjoint if the end of one=
 is before the start of
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * the other one.=A0 So if bo=
th disjointness comparisons
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * fail then the ranges overl=
ap.
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 *
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * Since we keep the tree of =
regions we're watching
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * sorted by start address, w=
e can end this loop as
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * soon as we hit a region th=
at starts past the end of
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * the range for the event we=
're handling.
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 */
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (reg->start >=3D end)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 break;
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 /*
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * Just go to the next region=
 if the start of the
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * range is after the end of =
the region -- there
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * might still be more overla=
pping ranges that have a
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 * greater start.
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 */
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (start >=3D reg->end)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 continue;
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 hit =3D 1;
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (test_and_set_bit(UMMUNOTIFY=
_FLAG_INVALID, &reg->flags))
> {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 /* Alread=
y on invalid list */
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 clear_bit=
(UMMUNOTIFY_FLAG_HINT, &reg->flags);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 } else {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 list_add_=
tail(&reg->list, &priv->invalid_list);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 set_bit(U=
MMUNOTIFY_FLAG_HINT, &reg->flags);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 reg->hint=
_start =3D start;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 reg->hint=
_end=A0=A0 =3D end;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 if (hit) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ++(*priv->counter);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 flush_dcache_page(virt_to_page(=
priv->counter));
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 wake_up_interruptible(&priv->re=
ad_wait);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 kill_fasync(&priv->async_queue,=
 SIGIO, POLL_IN);
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 spin_unlock_irqrestore(&priv->lock, flags);
> +}
> +
> +static void ummunotify_invalidate_page(struct mmu_notifier *mn,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0 struct mm_struct *mm,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0 unsigned long addr)
> +{
> +=A0=A0=A0=A0=A0=A0 ummunotify_handle_notify(mn, addr, addr + PAGE_SIZE);
> +}
> +
> +static void ummunotify_invalidate_range_start(struct mmu_notifier *mn,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0 struct mm_struct *mm,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0 unsigned long start,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0 unsigned long end)
> +{
> +=A0=A0=A0=A0=A0=A0 ummunotify_handle_notify(mn, start, end);
> +}
> +
> +static const struct mmu_notifier_ops ummunotify_mmu_notifier_ops =3D {
> +=A0=A0=A0=A0=A0=A0 .invalidate_page=A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_=
invalidate_page,
> +=A0=A0=A0=A0=A0=A0 .invalidate_range_start =3D ummunotify_invalidate_ran=
ge_start,
> +};
> +
> +static int ummunotify_open(struct inode *inode, struct file *filp)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv;
> +=A0=A0=A0=A0=A0=A0 int ret;
> +
> +=A0=A0=A0=A0=A0=A0 if (filp->f_mode & FMODE_WRITE)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EINVAL;
> +
> +=A0=A0=A0=A0=A0=A0 priv =3D kmalloc(sizeof *priv, GFP_KERNEL);
> +=A0=A0=A0=A0=A0=A0 if (!priv)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -ENOMEM;
> +
> +=A0=A0=A0=A0=A0=A0 priv->counter =3D (void *) get_zeroed_page(GFP_KERNEL=
);
> +=A0=A0=A0=A0=A0=A0 if (!priv->counter) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D -ENOMEM;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto err;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 priv->reg_tree =3D RB_ROOT;
> +=A0=A0=A0=A0=A0=A0 INIT_LIST_HEAD(&priv->invalid_list);
> +=A0=A0=A0=A0=A0=A0 spin_lock_init(&priv->lock);
> +=A0=A0=A0=A0=A0=A0 init_waitqueue_head(&priv->read_wait);
> +=A0=A0=A0=A0=A0=A0 priv->async_queue =3D NULL;
> +=A0=A0=A0=A0=A0=A0 priv->need_empty=A0 =3D 0;
> +=A0=A0=A0=A0=A0=A0 priv->used=A0=A0=A0=A0=A0 =A0 =3D 0;
> +
> +=A0=A0=A0=A0=A0=A0 priv->mmu_notifier.ops =3D &ummunotify_mmu_notifier_o=
ps;
> +=A0=A0=A0=A0=A0=A0 /*
> +=A0=A0=A0=A0=A0=A0=A0 * Register notifier last, since notifications can =
occur as
> +=A0=A0=A0=A0=A0=A0=A0 * soon as we register....
> +=A0=A0=A0=A0=A0=A0=A0 */
> +=A0=A0=A0=A0=A0=A0 ret =3D mmu_notifier_register(&priv->mmu_notifier, cu=
rrent->mm);
> +=A0=A0=A0=A0=A0=A0 if (ret)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto err_page;
> +
> +=A0=A0=A0=A0=A0=A0 priv->mm =3D current->mm;
> +=A0=A0=A0=A0=A0=A0 atomic_inc(&priv->mm->mm_count);
> +
> +=A0=A0=A0=A0=A0=A0 filp->private_data =3D priv;
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +
> +err_page:
> +=A0=A0=A0=A0=A0=A0 free_page((unsigned long) priv->counter);
> +
> +err:
> +=A0=A0=A0=A0=A0=A0 kfree(priv);
> +=A0=A0=A0=A0=A0=A0 return ret;
> +}
> +
> +static int ummunotify_close(struct inode *inode, struct file *filp)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D filp->private_data;
> +=A0=A0=A0=A0=A0=A0 struct rb_node *n;
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_reg *reg;
> +
> +=A0=A0=A0=A0=A0=A0 mmu_notifier_unregister(&priv->mmu_notifier, priv->mm=
);
> +=A0=A0=A0=A0=A0=A0 mmdrop(priv->mm);
> +=A0=A0=A0=A0=A0=A0 free_page((unsigned long) priv->counter);
> +
> +=A0=A0=A0=A0=A0=A0 for (n =3D rb_first(&priv->reg_tree); n; n =3D rb_nex=
t(n)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 reg =3D rb_entry(n, struct ummu=
notify_reg, node);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 kfree(reg);
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 kfree(priv);
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> +
> +static bool ummunotify_readable(struct ummunotify_file *priv)
> +{
> +=A0=A0=A0=A0=A0=A0 return priv->need_empty || !list_empty(&priv->invalid=
_list);
> +}
> +
> +static ssize_t ummunotify_read(struct file *filp, char __user *buf,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0 size_t count, loff_t *pos)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D filp->private_data;
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_reg *reg;
> +=A0=A0=A0=A0=A0=A0 ssize_t ret;
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_event *events;
> +=A0=A0=A0=A0=A0=A0 int max;
> +=A0=A0=A0=A0=A0=A0 int n;
> +
> +=A0=A0=A0=A0=A0=A0 priv->used =3D 1;
> +
> +=A0=A0=A0=A0=A0=A0 events =3D (void *) get_zeroed_page(GFP_KERNEL);
> +=A0=A0=A0=A0=A0=A0 if (!events) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D -ENOMEM;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto out;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 spin_lock_irq(&priv->lock);
> +
> +=A0=A0=A0=A0=A0=A0 while (!ummunotify_readable(priv)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 spin_unlock_irq(&priv->lock);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (filp->f_flags & O_NONBLOCK)=
 {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D -=
EAGAIN;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto out;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (wait_event_interruptible(pr=
iv->read_wait,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0 ummunotify_readable(priv)))=
 {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D -=
ERESTARTSYS;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto out;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 spin_lock_irq(&priv->lock);
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 max =3D min_t(size_t, PAGE_SIZE, count) / sizeof *eve=
nts;
> +
> +=A0=A0=A0=A0=A0=A0 for (n =3D 0; n < max; ++n) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (list_empty(&priv->invalid_l=
ist)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n]=
.type =3D UMMUNOTIFY_EVENT_TYPE_LAST;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n]=
.user_cookie_counter =3D *priv->counter;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ++n;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 priv->nee=
d_empty =3D 0;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 break;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 reg =3D list_first_entry(&priv-=
>invalid_list,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0 struct ummunotify_reg, list);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n].type =3D UMMUNOTIFY_E=
VENT_TYPE_INVAL;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (test_bit(UMMUNOTIFY_FLAG_HI=
NT, &reg->flags)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n]=
.flags =A0=A0=A0=A0 =3D UMMUNOTIFY_EVENT_FLAG_HINT;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n]=
.hint_start =3D max(reg->start,
> reg->hint_start);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n]=
.hint_end=A0=A0 =3D min(reg->end, reg->hint_end);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 } else {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n]=
.hint_start =3D reg->start;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n]=
.hint_end=A0=A0 =3D reg->end;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 events[n].user_cookie_counter =
=3D reg->user_cookie;
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 list_del(&reg->list);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 reg->flags =3D 0;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 priv->need_empty =3D 1;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 spin_unlock_irq(&priv->lock);
> +
> +=A0=A0=A0=A0=A0=A0 if (copy_to_user(buf, events, n * sizeof *events))
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D -EFAULT;
> +=A0=A0=A0=A0=A0=A0 else
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D n * sizeof *events;
> +
> +out:
> +=A0=A0=A0=A0=A0=A0 free_page((unsigned long) events);
> +=A0=A0=A0=A0=A0=A0 return ret;
> +}
> +
> +static unsigned int ummunotify_poll(struct file *filp,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0 struct poll_table_struct *wait)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D filp->private_data;
> +
> +=A0=A0=A0=A0=A0=A0 poll_wait(filp, &priv->read_wait, wait);
> +
> +=A0=A0=A0=A0=A0=A0 return ummunotify_readable(priv) ? (POLLIN | POLLRDNO=
RM) : 0;
> +}
> +
> +static long ummunotify_exchange_features(struct ummunotify_file *priv,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 __u32 __user *arg)
> +{
> +=A0=A0=A0=A0=A0=A0 u32 feature_mask;
> +
> +=A0=A0=A0=A0=A0=A0 if (priv->used)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EINVAL;
> +
> +=A0=A0=A0=A0=A0=A0 priv->used =3D 1;
> +
> +=A0=A0=A0=A0=A0=A0 if (copy_from_user(&feature_mask, arg, sizeof(feature=
_mask)))
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EFAULT;
> +
> +=A0=A0=A0=A0=A0=A0 /* No extensions defined at present. */
> +=A0=A0=A0=A0=A0=A0 feature_mask =3D 0;
> +
> +=A0=A0=A0=A0=A0=A0 if (copy_to_user(arg, &feature_mask, sizeof(feature_m=
ask)))
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EFAULT;
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> +
> +static long ummunotify_register_region(struct ummunotify_file *priv,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0 void __user *arg)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_register_ioctl parm;
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_reg *reg, *treg;
> +=A0=A0=A0=A0=A0=A0 struct rb_node **n =3D &priv->reg_tree.rb_node;
> +=A0=A0=A0=A0=A0=A0 struct rb_node *pn;
> +=A0=A0=A0=A0=A0=A0 int ret =3D 0;
> +
> +=A0=A0=A0=A0=A0=A0 if (copy_from_user(&parm, arg, sizeof parm))
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EFAULT;
> +
> +=A0=A0=A0=A0=A0=A0 priv->used =3D 1;
> +
> +=A0=A0=A0=A0=A0=A0 reg =3D kmalloc(sizeof *reg, GFP_KERNEL);
> +=A0=A0=A0=A0=A0=A0 if (!reg)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -ENOMEM;
> +
> +=A0=A0=A0=A0=A0=A0 reg->user_cookie=A0=A0=A0=A0=A0=A0=A0 =3D parm.user_c=
ookie;
> +=A0=A0=A0=A0=A0=A0 reg->start=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D p=
arm.start;
> +=A0=A0=A0=A0=A0=A0 reg->end=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =
=3D parm.end;
> +=A0=A0=A0=A0=A0=A0 reg->flags=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D 0=
;
> +
> +=A0=A0=A0=A0=A0=A0 spin_lock_irq(&priv->lock);
> +
> +=A0=A0=A0=A0=A0=A0 for (pn =3D rb_first(&priv->reg_tree); pn; pn =3D rb_=
next(pn)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 treg =3D rb_entry(pn, struct um=
munotify_reg, node);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (treg->user_cookie =3D=3D pa=
rm.user_cookie) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 kfree(reg=
);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D -=
EINVAL;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto out;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 pn =3D NULL;
> +=A0=A0=A0=A0=A0=A0 while (*n) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 pn =3D *n;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 treg =3D rb_entry(pn, struct um=
munotify_reg, node);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (reg->start <=3D treg->start=
)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 n =3D &pn=
->rb_left;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 else
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 n =3D &pn=
->rb_right;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 rb_link_node(&reg->node, pn, n);
> +=A0=A0=A0=A0=A0=A0 rb_insert_color(&reg->node, &priv->reg_tree);
> +
> +out:
> +=A0=A0=A0=A0=A0=A0 spin_unlock_irq(&priv->lock);
> +
> +=A0=A0=A0=A0=A0=A0 return ret;
> +}
> +
> +static long ummunotify_unregister_region(struct ummunotify_file *priv,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0 __u64 __user *arg)
> +{
> +=A0=A0=A0=A0=A0=A0 u64 user_cookie;
> +=A0=A0=A0=A0=A0=A0 struct rb_node *n;
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_reg *reg;
> +=A0=A0=A0=A0=A0=A0 int ret =3D -EINVAL;
> +
> +=A0=A0=A0=A0=A0=A0 if (copy_from_user(&user_cookie, arg, sizeof(user_coo=
kie)))
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EFAULT;
> +
> +=A0=A0=A0=A0=A0=A0 spin_lock_irq(&priv->lock);
> +
> +=A0=A0=A0=A0=A0=A0 for (n =3D rb_first(&priv->reg_tree); n; n =3D rb_nex=
t(n)) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 reg =3D rb_entry(n, struct ummu=
notify_reg, node);
> +
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (reg->user_cookie =3D=3D use=
r_cookie) {
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 rb_erase(=
n, &priv->reg_tree);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 if (test_=
bit(UMMUNOTIFY_FLAG_INVALID, &reg->flags))
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 list_del(&reg->list);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 kfree(reg=
);
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 ret =3D 0=
;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 break;
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 spin_unlock_irq(&priv->lock);
> +
> +=A0=A0=A0=A0=A0=A0 return ret;
> +}
> +
> +static long ummunotify_ioctl(struct file *filp, unsigned int cmd,
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0 unsigned long arg)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D filp->private_data;
> +=A0=A0=A0=A0=A0=A0 void __user *argp =3D (void __user *) arg;
> +
> +=A0=A0=A0=A0=A0=A0 switch (cmd) {
> +=A0=A0=A0=A0=A0=A0 case UMMUNOTIFY_EXCHANGE_FEATURES:
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return ummunotify_exchange_feat=
ures(priv, argp);
> +=A0=A0=A0=A0=A0=A0 case UMMUNOTIFY_REGISTER_REGION:
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return ummunotify_register_regi=
on(priv, argp);
> +=A0=A0=A0=A0=A0=A0 case UMMUNOTIFY_UNREGISTER_REGION:
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return ummunotify_unregister_re=
gion(priv, argp);
> +=A0=A0=A0=A0=A0=A0 default:
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -ENOIOCTLCMD;
> +=A0=A0=A0=A0=A0=A0 }
> +}
> +
> +static int ummunotify_fault(struct vm_area_struct *vma, struct vm_fault
> *vmf)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D vma->vm_private_data=
;
> +
> +=A0=A0=A0=A0=A0=A0 if (vmf->pgoff !=3D 0)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return VM_FAULT_SIGBUS;
> +
> +=A0=A0=A0=A0=A0=A0 vmf->page =3D virt_to_page(priv->counter);
> +=A0=A0=A0=A0=A0=A0 get_page(vmf->page);
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +
> +}
> +
> +static struct vm_operations_struct ummunotify_vm_ops =3D {
> +=A0=A0=A0=A0=A0=A0 .fault=A0 =A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_fault,
> +};
> +
> +static int ummunotify_mmap(struct file *filp, struct vm_area_struct *vma=
)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D filp->private_data;
> +
> +=A0=A0=A0=A0=A0=A0 if (vma->vm_end - vma->vm_start !=3D PAGE_SIZE || vma=
->vm_pgoff !=3D 0)
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return -EINVAL;
> +
> +=A0=A0=A0=A0=A0=A0 vma->vm_ops=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D &um=
munotify_vm_ops;
> +=A0=A0=A0=A0=A0=A0 vma->vm_private_data=A0=A0=A0 =3D priv;
> +
> +=A0=A0=A0=A0=A0=A0 return 0;
> +}
> +
> +static int ummunotify_fasync(int fd, struct file *filp, int on)
> +{
> +=A0=A0=A0=A0=A0=A0 struct ummunotify_file *priv =3D filp->private_data;
> +
> +=A0=A0=A0=A0=A0=A0 return fasync_helper(fd, filp, on, &priv->async_queue=
);
> +}
> +
> +static const struct file_operations ummunotify_fops =3D {
> +=A0=A0=A0=A0=A0=A0 .owner=A0 =A0=A0=A0=A0=A0=A0=A0 =3D THIS_MODULE,
> +=A0=A0=A0=A0=A0=A0 .open=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_open=
,
> +=A0=A0=A0=A0=A0=A0 .release=A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_close,
> +=A0=A0=A0=A0=A0=A0 .read=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_read=
,
> +=A0=A0=A0=A0=A0=A0 .poll=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_poll=
,
> +=A0=A0=A0=A0=A0=A0 .unlocked_ioctl =3D ummunotify_ioctl,
> +#ifdef CONFIG_COMPAT
> +=A0=A0=A0=A0=A0=A0 .compat_ioctl=A0=A0 =3D ummunotify_ioctl,
> +#endif
> +=A0=A0=A0=A0=A0=A0 .mmap=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_mmap=
,
> +=A0=A0=A0=A0=A0=A0 .fasync =A0=A0=A0=A0=A0=A0=A0 =3D ummunotify_fasync,
> +};
> +
> +static struct miscdevice ummunotify_misc =3D {
> +=A0=A0=A0=A0=A0=A0 .minor=A0 =3D MISC_DYNAMIC_MINOR,
> +=A0=A0=A0=A0=A0=A0 .name=A0=A0 =3D "ummunotify",
> +=A0=A0=A0=A0=A0=A0 .fops=A0=A0 =3D &ummunotify_fops,
> +};
> +
> +static int __init ummunotify_init(void)
> +{
> +=A0=A0=A0=A0=A0=A0 return misc_register(&ummunotify_misc);
> +}
> +
> +static void __exit ummunotify_cleanup(void)
> +{
> +=A0=A0=A0=A0=A0=A0 misc_deregister(&ummunotify_misc);
> +}
> +
> +module_init(ummunotify_init);
> +module_exit(ummunotify_cleanup);
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index e2ea0b2..e086b39 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -163,6 +163,7 @@ header-y +=3D tipc_config.h
> =A0header-y +=3D toshiba.h
> =A0header-y +=3D udf_fs_i.h
> =A0header-y +=3D ultrasound.h
> +header-y +=3D ummunotify.h
> =A0header-y +=3D un.h
> =A0header-y +=3D utime.h
> =A0header-y +=3D veth.h
> diff --git a/include/linux/ummunotify.h b/include/linux/ummunotify.h
> new file mode 100644
> index 0000000..21b0d03
> --- /dev/null
> +++ b/include/linux/ummunotify.h
> @@ -0,0 +1,121 @@
> +/*
> + * Copyright (c) 2009 Cisco Systems.=A0 All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#ifndef _LINUX_UMMUNOTIFY_H
> +#define _LINUX_UMMUNOTIFY_H
> +
> +#include <linux/types.h>
> +#include <linux/ioctl.h>
> +
> +/*
> + * Ummunotify relays MMU notifier events to userspace.=A0 A userspace
> + * process uses it by opening /dev/ummunotify, which returns a file
> + * descriptor.=A0 Interest in address ranges is registered using ioctl()
> + * and MMU notifier events are retrieved using read(), as described in
> + * more detail below.
> + *
> + * Userspace can also mmap() a single read-only page at offset 0 on
> + * this file descriptor.=A0 This page contains (at offest 0) a single
> + * 64-bit generation counter that the kernel increments each time an
> + * MMU notifier event occurs.=A0 Userspace can use this to very quickly
> + * check if there are any events to retrieve without needing to do a
> + * system call.
> + */
> +
> +/*
> + * struct ummunotify_register_ioctl describes an address range from
> + * start to end (including start but not including end) to be
> + * monitored.=A0 user_cookie is an opaque handle that userspace assigns,
> + * and which is used to unregister.=A0 flags and reserved are currently
> + * unused and should be set to 0 for forward compatibility.
> + */
> +struct ummunotify_register_ioctl {
> +=A0=A0=A0=A0=A0=A0 __u64=A0=A0 start;
> +=A0=A0=A0=A0=A0=A0 __u64=A0=A0 end;
> +=A0=A0=A0=A0=A0=A0 __u64=A0=A0 user_cookie;
> +=A0=A0=A0=A0=A0=A0 __u32=A0=A0 flags;
> +=A0=A0=A0=A0=A0=A0 __u32=A0=A0 reserved;
> +};
> +
> +#define UMMUNOTIFY_MAGIC=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 'U'
> +
> +/*
> + * Forward compatibility: Userspace passes in a 32-bit feature mask
> + * with feature flags set indicating which extensions it wishes to
> + * use.=A0 The kernel will return a feature mask with the bits of
> + * userspace's mask that the kernel implements; from that point on
> + * both userspace and the kernel should behave as described by the
> + * kernel's feature mask.
> + *
> + * If userspace does not perform a UMMUNOTIFY_EXCHANGE_FEATURES ioctl,
> + * then the kernel will use a feature mask of 0.
> + *
> + * No feature flags are currently defined, so the kernel will always
> + * return a feature mask of 0 at present.
> + */
> +#define UMMUNOTIFY_EXCHANGE_FEATURES=A0=A0 _IOWR(UMMUNOTIFY_MAGIC, 1, __=
u32)
> +
> +/*
> + * Register interest in an address range; userspace should pass in a
> + * struct ummunotify_register_ioctl describing the region.
> + */
> +#define UMMUNOTIFY_REGISTER_REGION=A0=A0=A0=A0 _IOW(UMMUNOTIFY_MAGIC, 2,=
 \
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0 struct
> ummunotify_register_ioctl)
> +/*
> + * Unregister interest in an address range; userspace should pass in
> + * the user_cookie value that was used to register the address range.
> + * No events for the address range will be reported once it is
> + * unregistered.
> + */
> +#define UMMUNOTIFY_UNREGISTER_REGION=A0=A0 _IOW(UMMUNOTIFY_MAGIC, 3, __u=
64)
> +
> +/*
> + * Invalidation events are returned whenever the kernel changes the
> + * mapping for a monitored address.=A0 These events are retrieved by
> + * read() on the ummunotify file descriptor, which will fill the
> + * read() buffer with struct ummunotify_event.
> + *
> + * If type field is INVAL, then user_cookie_counter holds the
> + * user_cookie for the region being reported; if the HINT flag is set
> + * then hint_start/hint_end hold the start and end of the mapping that
> + * was invalidated.=A0 (If HINT is not set, then multiple events
> + * invalidated parts of the registered range and hint_start/hint_end
> + * and set to the start/end of the whole registered range)
> + *
> + * If type is LAST, then the read operation has emptied the list of
> + * invalidated regions, and user_cookie_counter holds the value of the
> + * kernel's generation counter when the empty list occurred.=A0 The
> + * other fields are not filled in for this event.
> + */
> +enum {
> +=A0=A0=A0=A0=A0=A0 UMMUNOTIFY_EVENT_TYPE_INVAL=A0=A0=A0=A0 =3D 0,
> +=A0=A0=A0=A0=A0=A0 UMMUNOTIFY_EVENT_TYPE_LAST=A0=A0=A0=A0=A0 =3D 1,
> +};
> +
> +enum {
> +=A0=A0=A0=A0=A0=A0 UMMUNOTIFY_EVENT_FLAG_HINT=A0=A0=A0=A0=A0 =3D 1 << 0,
> +};
> +
> +struct ummunotify_event {
> +=A0=A0=A0=A0=A0=A0 __u32=A0=A0 type;
> +=A0=A0=A0=A0=A0=A0 __u32=A0=A0 flags;
> +=A0=A0=A0=A0=A0=A0 __u64=A0=A0 hint_start;
> +=A0=A0=A0=A0=A0=A0 __u64=A0=A0 hint_end;
> +=A0=A0=A0=A0=A0=A0 __u64=A0=A0 user_cookie_counter;
> +};
> +
> +#endif /* _LINUX_UMMUNOTIFY_H */
> --
> 1.6.3.3
>
>



--=20
Sayantan Sur

Research Scientist
Department of Computer Science
The Ohio State University.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
