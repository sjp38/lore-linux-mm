Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D223F6B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 21:56:09 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so13586164pab.3
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 18:56:09 -0700 (PDT)
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
        by mx.google.com with ESMTPS id c8si472639pdl.420.2014.07.02.18.56.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 18:56:08 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so12856567pdi.41
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 18:56:07 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Message-ID: <53B4B833.9010508@mit.edu>
Date: Wed, 02 Jul 2014 18:56:03 -0700
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] userfaultfd: add new syscall to provide memory
 externalization
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com> <1404319816-30229-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1404319816-30229-9-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\"Dr. David Alan Gilbert\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Linux API <linux-api@vger.kernel.org>

On 07/02/2014 09:50 AM, Andrea Arcangeli wrote:
> Once an userfaultfd is created MADV_USERFAULT regions talks through
> the userfaultfd protocol with the thread responsible for doing the
> memory externalization of the process.
> 
> The protocol starts by userland writing the requested/preferred
> USERFAULT_PROTOCOL version into the userfault fd (64bit write), if
> kernel knows it, it will ack it by allowing userland to read 64bit
> from the userfault fd that will contain the same 64bit
> USERFAULT_PROTOCOL version that userland asked. Otherwise userfault
> will read __u64 value -1ULL (aka USERFAULTFD_UNKNOWN_PROTOCOL) and it
> will have to try again by writing an older protocol version if
> suitable for its usage too, and read it back again until it stops
> reading -1ULL. After that the userfaultfd protocol starts.
> 
> The protocol consists in the userfault fd reads 64bit in size
> providing userland the fault addresses. After a userfault address has
> been read and the fault is resolved by userland, the application must
> write back 128bits in the form of [ start, end ] range (64bit each)
> that will tell the kernel such a range has been mapped. Multiple read
> userfaults can be resolved in a single range write. poll() can be used
> to know when there are new userfaults to read (POLLIN) and when there
> are threads waiting a wakeup through a range write (POLLOUT).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

> +#ifdef CONFIG_PROC_FS
> +static int userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
> +{
> +	struct userfaultfd_ctx *ctx = f->private_data;
> +	int ret;
> +	wait_queue_t *wq;
> +	struct userfaultfd_wait_queue *uwq;
> +	unsigned long pending = 0, total = 0;
> +
> +	spin_lock(&ctx->fault_wqh.lock);
> +	list_for_each_entry(wq, &ctx->fault_wqh.task_list, task_list) {
> +		uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
> +		if (uwq->pending)
> +			pending++;
> +		total++;
> +	}
> +	spin_unlock(&ctx->fault_wqh.lock);
> +
> +	ret = seq_printf(m, "pending:\t%lu\ntotal:\t%lu\n", pending, total);

This should show the protocol version, too.

> +
> +SYSCALL_DEFINE1(userfaultfd, int, flags)
> +{
> +	int fd, error;
> +	struct file *file;

This looks like it can't be used more than once in a process.  That will
be unfortunate for libraries.  Would it be feasible to either have
userfaultfd claim a range of addresses or for a vma to be explicitly
associated with a userfaultfd?  (In the latter case, giant PROT_NONE
MAP_NORESERVE mappings could be used.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
