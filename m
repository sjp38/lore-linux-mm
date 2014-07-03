Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7FC6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 09:20:11 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so224497wgh.26
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 06:20:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fu18si35460800wjc.113.2014.07.03.06.20.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 06:20:01 -0700 (PDT)
Date: Thu, 3 Jul 2014 15:19:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 08/10] userfaultfd: add new syscall to provide memory
 externalization
Message-ID: <20140703131908.GD21667@redhat.com>
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
 <1404319816-30229-9-git-send-email-aarcange@redhat.com>
 <53B4B833.9010508@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53B4B833.9010508@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "\"Dr. David Alan Gilbert\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Linux API <linux-api@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hi Andy,

thanks for CC'ing linux-api.

On Wed, Jul 02, 2014 at 06:56:03PM -0700, Andy Lutomirski wrote:
> On 07/02/2014 09:50 AM, Andrea Arcangeli wrote:
> > Once an userfaultfd is created MADV_USERFAULT regions talks through
> > the userfaultfd protocol with the thread responsible for doing the
> > memory externalization of the process.
> > 
> > The protocol starts by userland writing the requested/preferred
> > USERFAULT_PROTOCOL version into the userfault fd (64bit write), if
> > kernel knows it, it will ack it by allowing userland to read 64bit
> > from the userfault fd that will contain the same 64bit
> > USERFAULT_PROTOCOL version that userland asked. Otherwise userfault
> > will read __u64 value -1ULL (aka USERFAULTFD_UNKNOWN_PROTOCOL) and it
> > will have to try again by writing an older protocol version if
> > suitable for its usage too, and read it back again until it stops
> > reading -1ULL. After that the userfaultfd protocol starts.
> > 
> > The protocol consists in the userfault fd reads 64bit in size
> > providing userland the fault addresses. After a userfault address has
> > been read and the fault is resolved by userland, the application must
> > write back 128bits in the form of [ start, end ] range (64bit each)
> > that will tell the kernel such a range has been mapped. Multiple read
> > userfaults can be resolved in a single range write. poll() can be used
> > to know when there are new userfaults to read (POLLIN) and when there
> > are threads waiting a wakeup through a range write (POLLOUT).
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> > +#ifdef CONFIG_PROC_FS
> > +static int userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
> > +{
> > +	struct userfaultfd_ctx *ctx = f->private_data;
> > +	int ret;
> > +	wait_queue_t *wq;
> > +	struct userfaultfd_wait_queue *uwq;
> > +	unsigned long pending = 0, total = 0;
> > +
> > +	spin_lock(&ctx->fault_wqh.lock);
> > +	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
> > +		uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
> > +		if (uwq->pending)
> > +			pending++;
> > +		total++;
> > +	}
> > +	spin_unlock(&ctx->fault_wqh.lock);
> > +
> > +	ret = seq_printf(m, "pending:\t%lu\ntotal:\t%lu\n", pending, total);
> 
> This should show the protocol version, too.

Ok, does the below look ok?

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 388553e..f9d3e9f 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -493,7 +493,13 @@ static int userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	}
 	spin_unlock(&ctx->fault_wqh.lock);
 
-	ret = seq_printf(m, "pending:\t%lu\ntotal:\t%lu\n", pending, total);
+	/*
+	 * If more protocols will be added, there will be all shown
+	 * separated by a space. Like this:
+	 *	protocols: 0xaa 0xbb
+	 */
+	ret = seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nprotocols:\t%Lx\n",
+			 pending, total, USERFAULTFD_PROTOCOL);
 
 	return ret;
 }


> > +
> > +SYSCALL_DEFINE1(userfaultfd, int, flags)
> > +{
> > +	int fd, error;
> > +	struct file *file;
> 
> This looks like it can't be used more than once in a process.  That will

It can't be used more than once, correct.

	file = ERR_PTR(-EBUSY);
	if (get_mm_slot(current->mm))
		goto out_free_unlock;

If a userfaultfd is already registered for the current mm the second
one gets -EBUSY.

> be unfortunate for libraries.  Would it be feasible to either have

So you envision two userfaultfd memory managers for the same process?
I assume each one would claim separate ranges of memory?

For that case the demultiplexing of userfaults can be entirely managed
by userland.

One libuserfault library can actually register the userfaultfd, and
then the two libs can register into libuserfault and claim their own
ranges. It could run the code of the two libs in the thread context
that waits on the userfaultfd with zero overhead, or message passing
across threads can be used to run both libs in parallel in their own
thread. The demultiplexing code wouldn't be CPU intensive. The
downside are two schedule event required if they want to run their lib
code in a separate thread. If we'd claim the two different ranges in
the kernel for two different userfaultfd, the kernel would be speaking
directly with each library thread. That'd be the only advantage if
they don't want to run in the context of the thread that waits on the
userfaultfd.

To increase SMP scalability in the future we could also add a
UFFD_LOAD_BALANCE to distribute userfaults to different userfaultfd,
that if used could relax the -EBUSY (but it wouldn't be two different
claimed ranges for two different libs).

If passing UFFD_LOAD_BALANCE to the current code sys_userfaultfd would
return -EINVAL. I haven't implemented it because I'm not sure if such
thing would ever be needed. Compared to distributing the userfaults in
userland to different threads that would only save two context
switches per event. I don't see a problem in adding this later if a
need emerges though.

I think the best model for two libs claiming different userfault
ranges, is to run the userfault code of each lib in the context of the
thread that waits on the userfaultfd, and if there's a need to scale
in SMP we'd add UFFD_LOAD_BALANCE so multiple threads can wait on
different userfaultfd and scale optimally in SMP without any need of
spurious context switches.

With the volatile pages current code, the SIGBUS event would also be
mm-wide and require demultiplexing inside the sigbus handler if two
different libs wants to claim different ranges. Furthermore the sigbus
would run in the context of the faulting thread so it would still need
to context switch to scale (with userfaultfd we let the current thread
continue by triggering a schedule in the guest, if FOLL_NOWAIT fails
and we spawn a kworker thread doing the async page fault, then the
kworker kernel thread stops in the userfault and the migration thread
waiting on the userfaultfd is woken up to resolve the userfault).

Programs like qemu are unlikely to ever need more than one
userfaultfd, so it wouldn't need to use the demultiplexing
library. Currently we don't feel a need for UFFD_LOAD_BALANCE either.

However I'd rather implement UFFD_LOAD_BALANCE now, than claiming
different ranges in kernel that would require to build a lookup
structure that lives on top of the vmas and it wouldn't be less
efficient to write such a thing in userland inside a libuserfaultfd
(that qemu would likely never need).

In short I see no benefit in claiming different ranges for the same mm
in the kernel API (that can be done equally efficient in userland),
but I could see a benefit in a load balancing feature to scale the
load to multiple userfaultfd if passing UFFD_LOAD_BALANCE (it could
also be done by default by just removing the -EBUSY failure and
without new flags, but it sounds safer to keep -EBUSY if
UFFD_LOAD_BALANCE is not passed to userfaultfd through the flags).

> userfaultfd claim a range of addresses or for a vma to be explicitly
> associated with a userfaultfd?  (In the latter case, giant PROT_NONE
> MAP_NORESERVE mappings could be used.)

To claim ranges MADV_USERFAULT is used and the vmas are
mm-wide. Instead of creating another range lookup on top the vmas, I
used the vma itself to tell which ranges are claimed for userfaultfd
(or SIGBUS behavior if userfaultfd isn't open).

This API model with MADV_USERFAULT to claim the userfaultfd ranges is
want fundamentally prevents you to claim different ranges for two
different userfaultfd.

About PROT_NONE, note that if you set the mapping as MADV_USERFAULT
there's no point in setting PROT_NONE too, MAP_NORESERVE instead
should already work just fine and it's orthogonal.

PROT_NONE is kind of an alternative to userfaults without
MADV_USERFAULT. Problem is that PROT_NONE requires to split VMAs (and
take the mmap_sem for writing and mangle and allocate vmas), until you
actually run out of vmas and you get -ENOMEM and the app crashes. The
whole point of postcopy live migration is that it will work with
massively large guests so we cannot risk running out of vmas.

With MADV_USERFAULT you never mangle the vma and you work with a
single gigantic vma that never gets split. You don't need to mremap
over the PROT_NONE to handle the fault.

Even without userfaultfd and just with MADV_USERFAULT+remap_anon_pages
using SIGBUS is a much more efficient and more reliable alternative
than PROT_NONE.

With userfaultfd + remap_anon_pages things are even more efficient
because there are no signals involved at all, and syscalls won't
return weird errors to userland like it would happen with SIGBUS and
without userfaultfd. With userfaultfd the thread stopping in the
userfault won't even exit the kernel, it'll wait a wakeup within the
kernel. And remap_anon_pages that resolves the fault, just updates the
ptes or hugepmds without touching the vma (plus remap_anon_pages is
very strict so the chance of memory corruption going unnoticed is next
to nil, unlike mremap).

Other things that people should comment on is that currently you
cannot set MADV_USERFAULT on filebacked vmas, that sounds like an
issue for volatile pages that should be fixed. Currently -EINVAL is
returned if MADV_USERFAULT is run on non anonymous vmas. I don't think
it's a problem to add it. The do_linear_fault would just trigger an
userfault too. Then it's up to userland how it resolves it before
sending the wakeup to the stopped thread with userfaultfd_write. As
long as it doesn't fault in do_linear_fault again it'll just work.

How you solve the fault before acking it with userfaultfd_write
(remap_file_pages, remap_anon_pages, mremap, mmap, anything) is
entirely up to userland. The only faults the userfault tracks are the
pte_none/pmd_none kind (same as PROT_NONE). As long as you put
something in the pte/pmd and it's not none anymore you can
userfaultfd_write and it'll just work. Clearing VM_USERFAULT would
also work to resolve the fault of course (and then it'd pagein from
disk if it was filebacked or it'd map a zero page if it was an
anonymous vma) but clearing VM_USERFAULT (with MADV_NOUSERFAULT)
would split the vma so it's not recommended...

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
