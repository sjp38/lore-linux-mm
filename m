Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AC1E36B0083
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 10:16:46 -0400 (EDT)
Subject: Re: [PATCH 1/5] tmpfs: fix oops on mounts with mpol=default
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20100316144810.4C48.A69D9226@jp.fujitsu.com>
References: <201003122353.o2CNrC56015250@imap1.linux-foundation.org>
	 <20100316143406.4C45.A69D9226@jp.fujitsu.com>
	 <20100316144810.4C48.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 17 Mar 2010 10:16:11 -0400
Message-Id: <1268835371.4773.40.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kiran@scalex86.org, cl@linux-foundation.org, hugh.dickins@tiscali.co.uk, mel@csn.ul.ie, stable@kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-16 at 14:49 +0900, KOSAKI Motohiro wrote:
> ChangeLog from Ravikiran's original one
>   - Fix the patch description. the problem is in mount, not only remount.
>   - Skip mpol_new() simply, instead adding NULL check.
> 
> 
> =========================
> From: Ravikiran G Thirumalai <kiran@scalex86.org>
> 
> Fix an 'oops' when a tmpfs mount point is mounted with the mpol=default
> mempolicy.
> 
> Upon remounting a tmpfs mount point with 'mpol=default' option, the
> mount code crashed with a null pointer dereference.  The initial
> problem report was on 2.6.27, but the problem exists in mainline
> 2.6.34-rc as well.  On examining the code, we see that mpol_new returns
> NULL if default mempolicy was requested.  This 'NULL' mempolicy is
> accessed to store the node mask resulting in oops.
> 
> The following patch fixes it.
> 
> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: <stable@kernel.org>

Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

> ---
>  mm/mempolicy.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index bda230e..25a0c0f 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2213,10 +2213,15 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
>  			goto out;
>  		mode = MPOL_PREFERRED;
>  		break;
> -
> +	case MPOL_DEFAULT:
> +		/*
> +		 * Insist on a empty nodelist
> +		 */
> +		if (!nodelist)
> +			err = 0;
> +		goto out;
>  	/*
>  	 * case MPOL_BIND:    mpol_new() enforces non-empty nodemask.
> -	 * case MPOL_DEFAULT: mpol_new() enforces empty nodemask, ignores flags.
>  	 */
>  	}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
