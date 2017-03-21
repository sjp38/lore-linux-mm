Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 682136B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 09:48:38 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j127so153221516qke.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 06:48:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g17si15691860qtc.257.2017.03.21.06.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 06:48:37 -0700 (PDT)
Date: Tue, 21 Mar 2017 14:48:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] userfaultfd: provide pid in userfault's uffd_msg
Message-ID: <20170321134834.GA32299@redhat.com>
References: <1489850488-5837-1-git-send-email-a.perevalov@samsung.com>
 <CGME20170318152135eucas1p1602bef7c9085a775c08932bf9422cfbd@eucas1p1.samsung.com>
 <1489850488-5837-2-git-send-email-a.perevalov@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489850488-5837-2-git-send-email-a.perevalov@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Perevalov <a.perevalov@samsung.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hello Alexey,

On Sat, Mar 18, 2017 at 06:21:28PM +0300, Alexey Perevalov wrote:
> It could be useful for calculating downtime during
> postcopy live migration per vCPU. Side observer or application itself
> will be informed about proper task's sleep during userfaultfd
> processing.
> 
> Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
> ---
>  fs/userfaultfd.c                 | 1 +
>  include/uapi/linux/userfaultfd.h | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index b5a17e4..722c392 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -206,6 +206,7 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
>  		 * write protect fault.
>  		 */
>  		msg.arg.pagefault.flags |= UFFD_PAGEFAULT_FLAG_WP;
> +		msg.arg.pagefault.ptid = current->pid;

Alignment doesn't look right but the code is correct. It needs to be
rechecked against PID namespaces though, we need to be sure we return
the pid inside the container.

It'd need a feature flag too, otherwise userland won't know beforehand
if the feature is available in the running kernel. Perhaps it should
be conditional to a feature flag being requested by userland too.

The pid for qemu seems useful only for statistical purposes, we cannot
prioritize a vcpu or io thread against the others. In theory if an app
wanted, with this information it would be possible to prioritize
userfaults depending on pid. I cannot exclude some app could want
that, by keeping reading more faults until read() returns -EAGAIN and
then sorting them, but it doesn't look very practical to do that
because handling userfaults is fairly low latency and in most cases
there won't ever be too many queued up to sort by pid (maximum number
of userfaults to read in a row and sort by pid cannot exceed the
number of threads anyway).

> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index fbf2886..bf7d4b5 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -84,6 +84,7 @@ struct uffd_msg {
>  		struct {
>  			__u64	flags;
>  			__u64	address;
> +			pid_t ptid;

I suggest to use __u32 to be sure it's consistent and to put it in a
union of its own in case something else pops up that may also need to
be reported in the uffd_msg pagefault struct. Unless others think we
should always provide the pid to all userfaults unconditionally, in
which case it wouldn't need to go in a union.

Comments welcome, thanks!
Andrea

PS. I think the mailing list in CC on the git send-email wasn't
correct as it was a readonly list, so I'm CC'ing linux-mm instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
