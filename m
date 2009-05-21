Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 13BEE6B0055
	for <linux-mm@kvack.org>; Wed, 20 May 2009 20:41:12 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4L0fm9J016918
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 21 May 2009 09:41:48 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 68CEB45DE51
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:41:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C31045DE50
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:41:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 333B41DB8044
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:41:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DF9FF1DB8038
	for <linux-mm@kvack.org>; Thu, 21 May 2009 09:41:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of process with hugepage shared memory segments attached
In-Reply-To: <20090520154128.GD4409@csn.ul.ie>
References: <1242831915.6194.15.camel@lts-notebook> <20090520154128.GD4409@csn.ul.ie>
Message-Id: <20090521094057.63B8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 21 May 2009 09:41:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, starlight@binnacle.cx, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi

> Basic and in this case, apparently the critical factor. This patch on
> 2.6.27.7 makes the problem disappear as well by never setting VM_LOCKED on
> hugetlb-backed VMAs. Obviously, it's a hachet job and almost certainly the
> wrong fix but it indicates that the handling of VM_LOCKED && VM_HUGETLB
> is wrong somewhere. Now I have a better idea now what to search for on
> Friday. Thanks Lee.
> 
> --- mm/mlock.c	2009-05-20 16:36:08.000000000 +0100
> +++ mm/mlock-new.c	2009-05-20 16:28:17.000000000 +0100
> @@ -64,7 +64,8 @@
>  	 * It's okay if try_to_unmap_one unmaps a page just after we
>  	 * set VM_LOCKED, make_pages_present below will bring it back.
>  	 */
> -	vma->vm_flags = newflags;
> +	if (!(vma->vm_flags & VM_HUGETLB))

this condition meaning isn't so obvious to me. could you please
consider comment adding?


> +		vma->vm_flags = newflags;
>  
>  	/*
>  	 * Keep track of amount of locked VM.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
