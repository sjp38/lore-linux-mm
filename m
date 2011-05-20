Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A7B9F8D003B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:02:41 -0400 (EDT)
Subject: Re: [PATCH] kernel buffer overflow kmalloc_slab() fix
From: J Freyensee <james_p_freyensee@linux.intel.com>
Reply-To: james_p_freyensee@linux.intel.com
In-Reply-To: <alpine.DEB.2.00.1105200941260.5610@router.home>
References: <james_p_freyensee@linux.intel.com>
	 <1305834712-27805-2-git-send-email-james_p_freyensee@linux.intel.com>
	 <alpine.DEB.2.00.1105191550001.12530@router.home>
	 <1305892971.2571.16.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105200932340.5610@router.home>
	 <alpine.DEB.2.00.1105200941260.5610@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 20 May 2011 11:02:28 -0700
Message-ID: <1305914548.2400.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm@kvack.org, gregkh@suse.de, hari.k.kanigeri@intel.com, linux-arch@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

Thank you for the collaboration work on the fix.  I like it.

Jay

On Fri, 2011-05-20 at 09:42 -0500, Christoph Lameter wrote:
> Subject: slub: Deal with hyperthetical case of PAGE_SIZE > 2M
> 
> kmalloc_index() currently returns -1 if the PAGE_SIZE is larger than 2M
> which seems to cause some concern since the callers do not check for -1.
> 
> Insert a BUG() and add a comment to the -1 explaining that the code
> cannot be reached.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  include/linux/slub_def.h |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2011-05-20 09:37:02.000000000 -0500
> +++ linux-2.6/include/linux/slub_def.h	2011-05-20 09:39:07.000000000 -0500
> @@ -179,7 +179,8 @@ static __always_inline int kmalloc_index
>  	if (size <=   4 * 1024) return 12;
>  /*
>   * The following is only needed to support architectures with a larger page
> - * size than 4k.
> + * size than 4k. We need to support 2 * PAGE_SIZE here. So for a 64k page
> + * size we would have to go up to 128k.
>   */
>  	if (size <=   8 * 1024) return 13;
>  	if (size <=  16 * 1024) return 14;
> @@ -190,7 +191,8 @@ static __always_inline int kmalloc_index
>  	if (size <= 512 * 1024) return 19;
>  	if (size <= 1024 * 1024) return 20;
>  	if (size <=  2 * 1024 * 1024) return 21;
> -	return -1;
> +	BUG();
> +	return -1; /* Will never be reached */
> 
>  /*
>   * What we really wanted to do and cannot do because of compiler issues is:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
