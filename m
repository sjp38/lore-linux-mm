Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 67FF36B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 08:04:30 -0400 (EDT)
Received: by iecvy18 with SMTP id vy18so38137744iec.1
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 05:04:30 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id kl11si7063874icb.47.2015.03.09.05.04.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Mar 2015 05:04:29 -0700 (PDT)
Received: by igal13 with SMTP id l13so18767354iga.1
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 05:04:29 -0700 (PDT)
References: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com> <20150309043051.GA13380@node.dhcp.inet.fi> <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch v2] mm, hugetlb: abort __get_user_pages if current has been oom killed
In-reply-to: <alpine.DEB.2.10.1503090041120.21058@chino.kir.corp.google.com>
Date: Mon, 09 Mar 2015 05:04:25 -0700
Message-ID: <xr93r3synzqu.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On Mon, Mar 09 2015, David Rientjes wrote:

> If __get_user_pages() is faulting a significant number of hugetlb pages,
> usually as the result of mmap(MAP_LOCKED), it can potentially allocate a
> very large amount of memory.
>
> If the process has been oom killed, this will cause a lot of memory to
> be overcharged to its memcg since it has access to memory reserves or
> could potentially deplete all system memory reserves.

s/memcg/hugetlb_cgroup/ but I don't think hugetlb has any
fatal_signal_pending() based overcharging.  I no objection to the patch,
but this doesn't seems like a cgroup thing, so the commit log could
stand a tweak.

> In the same way that commit 4779280d1ea4 ("mm: make get_user_pages() 
> interruptible") aborted for pending SIGKILLs when faulting non-hugetlb
> memory, based on the premise of commit 462e00cc7151 ("oom: stop
> allocating user memory if TIF_MEMDIE is set"), hugetlb page faults now
> terminate when the process has been oom killed.
>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: check signal inside follow_huegtlb_page() loop per Kirill
>
>  mm/hugetlb.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3276,6 +3276,15 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		struct page *page;
>  
>  		/*
> +		 * If we have a pending SIGKILL, don't keep faulting pages and
> +		 * potentially allocating memory.
> +		 */
> +		if (unlikely(fatal_signal_pending(current))) {
> +			remainder = 0;
> +			break;
> +		}
> +
> +		/*
>  		 * Some archs (sparc64, sh*) have multiple pte_ts to
>  		 * each hugepage.  We have to make sure we get the
>  		 * first, for the page indexing below to work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
