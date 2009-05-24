Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5374D6B005D
	for <linux-mm@kvack.org>; Sun, 24 May 2009 09:44:34 -0400 (EDT)
Date: Sun, 24 May 2009 22:44:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process with hugepage shared memory segments attached
In-Reply-To: <20090522164101.GA9196@csn.ul.ie>
References: <20090521094057.63B8.A69D9226@jp.fujitsu.com> <20090522164101.GA9196@csn.ul.ie>
Message-Id: <20090524213838.084C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com, hugh.dickins@tiscali.co.uk, kenchen@google.com
List-ID: <linux-mm.kvack.org>

> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> --- 
>  arch/x86/mm/hugetlbpage.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 8f307d9..16e4bcc 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -26,12 +26,16 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
>  	unsigned long sbase = saddr & PUD_MASK;
>  	unsigned long s_end = sbase + PUD_SIZE;
>  
> +	/* Allow segments to share if only one is locked */
> +	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
> +	unsigned long svm_flags = vma->vm_flags & ~VM_LOCKED;
                                  svma?

 - kosaki

> +
>  	/*
>  	 * match the virtual addresses, permission and the alignment of the
>  	 * page table page.
>  	 */
>  	if (pmd_index(addr) != pmd_index(saddr) ||
> -	    vma->vm_flags != svma->vm_flags ||
> +	    vm_flags != svm_flags ||
>  	    sbase < svma->vm_start || svma->vm_end < s_end)
>  		return 0;
>  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
