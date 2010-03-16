Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D369B6001DA
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 01:47:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G5lWEA017006
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Mar 2010 14:47:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DEF145DE4E
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:47:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53FA345DE4D
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:47:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F2B341DB8040
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:47:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 803A9E38004
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:47:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: + tmpfs-fix-oops-on-remounts-with-mpol=default.patch added to -mm tree
In-Reply-To: <201003122353.o2CNrC56015250@imap1.linux-foundation.org>
References: <201003122353.o2CNrC56015250@imap1.linux-foundation.org>
Message-Id: <20100316143406.4C45.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Mar 2010 14:47:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: kiran@scalex86.org
Cc: kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, hugh.dickins@tiscali.co.uk, lee.schermerhorn@hp.com, mel@csn.ul.ie, stable@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> ------------------------------------------------------
> Subject: tmpfs: fix oops on remounts with mpol=default
> From: Ravikiran G Thirumalai <kiran@scalex86.org>
> 
> Fix an 'oops' when a tmpfs mount point is remounted with the 'default'
> mempolicy.
> 
> Upon remounting a tmpfs mount point with 'mpol=default' option, the
> remount code crashed with a null pointer dereference.  The initial problem
> report was on 2.6.27, but the problem exists in mainline 2.6.34-rc as
> well.  On examining the code, we see that mpol_new returns NULL if default
> mempolicy was requested.  This 'NULL' mempolicy is accessed to store the
> node mask resulting in oops.
> 
> The following patch fixes the oops by avoiding dereferencing NULL if the
> new mempolicy is NULL.  The patch also sets 'err' to 0 if MPOL_DEFAULT is
> passed (err is initialized to 1 initially at mpol_parse_str())

Hi Ravikiran,

I'm glad to your contribution. Unfortunately I've found various related
issue in mpol_parse_str() while reviewing your patch.

So, I'll post updated patches.

- kosaki


> 
> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/mempolicy.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff -puN mm/mempolicy.c~tmpfs-fix-oops-on-remounts-with-mpol=default mm/mempolicy.c
> --- a/mm/mempolicy.c~tmpfs-fix-oops-on-remounts-with-mpol=default
> +++ a/mm/mempolicy.c
> @@ -2213,10 +2213,14 @@ int mpol_parse_str(char *str, struct mem
>  			goto out;
>  		mode = MPOL_PREFERRED;
>  		break;
> -
> +	case MPOL_DEFAULT:
> +		/*
> +		 * mpol_new() enforces empty nodemask, ignores flags.
> +		 */
> +		err = 0;
> +		break;
>  	/*
>  	 * case MPOL_BIND:    mpol_new() enforces non-empty nodemask.
> -	 * case MPOL_DEFAULT: mpol_new() enforces empty nodemask, ignores flags.
>  	 */
>  	}
>  
> @@ -2250,7 +2254,7 @@ int mpol_parse_str(char *str, struct mem
>  		if (ret) {
>  			err = 1;
>  			mpol_put(new);
> -		} else if (no_context) {
> +		} else if (no_context && new) {
>  			/* save for contextualization */
>  			new->w.user_nodemask = nodes;
>  		}
> _
> 
> Patches currently in -mm which might be from kiran@scalex86.org are
> 
> tmpfs-fix-oops-on-remounts-with-mpol=default.patch
> slab-leaks3-default-y.patch
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
