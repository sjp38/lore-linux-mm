Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 025D56B0032
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 00:30:57 -0400 (EDT)
Received: by wghl18 with SMTP id l18so24928809wgh.5
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 21:30:56 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id q7si29036304wjq.201.2015.03.08.21.30.54
        for <linux-mm@kvack.org>;
        Sun, 08 Mar 2015 21:30:55 -0700 (PDT)
Date: Mon, 9 Mar 2015 06:30:51 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch] mm, hugetlb: abort __get_user_pages if current has been
 oom killed
Message-ID: <20150309043051.GA13380@node.dhcp.inet.fi>
References: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503081611290.15536@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 08, 2015 at 04:12:12PM -0700, David Rientjes wrote:
> If __get_user_pages() is faulting a significant number of hugetlb pages,
> usually as the result of mmap(MAP_LOCKED), it can potentially allocate a
> very large amount of memory.
> 
> If the process has been oom killed, this will cause a lot of memory to
> be overcharged to its memcg since it has access to memory reserves or
> could potentially deplete all system memory reserves.
> 
> In the same way that commit 4779280d1ea4 ("mm: make get_user_pages() 
> interruptible") aborted for pending SIGKILLs when faulting non-hugetlb
> memory, based on the premise of commit 462e00cc7151 ("oom: stop
> allocating user memory if TIF_MEMDIE is set"), hugetlb page faults now
> terminate when the process has been oom killed.
> 
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/gup.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -457,6 +457,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			if (!vma || check_vma_flags(vma, gup_flags))
>  				return i ? : -EFAULT;
>  			if (is_vm_hugetlb_page(vma)) {
> +				if (unlikely(fatal_signal_pending(current)))
> +					return i ? : -ERESTARTSYS;
>  				i = follow_hugetlb_page(mm, vma, pages, vmas,
>  						&start, &nr_pages, i,
>  						gup_flags);

Shouldn't the check be inside loop in follow_hugetlb_page()?
IIUC, it wouldn't help much if nr_pages and hugetlb vma are big enough.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
