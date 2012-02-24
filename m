Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 614CE6B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 15:55:21 -0500 (EST)
Date: Fri, 24 Feb 2012 12:55:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are
 page-aligned
Message-Id: <20120224125519.89120828.akpm@linux-foundation.org>
In-Reply-To: <87obsoxcn6.fsf@danplanet.com>
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
	<alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com>
	<87zkcm23az.fsf@caffeine.danplanet.com>
	<alpine.DEB.2.00.1202131350500.17296@chino.kir.corp.google.com>
	<87obsoxcn6.fsf@danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com

On Fri, 24 Feb 2012 11:19:25 -0800
Dan Smith <danms@us.ibm.com> wrote:

>
> ...
>
>     The inner function walk_pte_range() increments "addr" by PAGE_SIZE after
>     each pte is processed, and only exits the loop if the result is equal to
>     "end". Current, if either (or both of) the starting or ending addresses
>     passed to walk_page_range() are not page-aligned, then we will never
>     satisfy that exit condition and begin calling the pte_entry handler with
>     bad data.
>     
>     To be sure that we will land in the right spot, this patch checks that
>     both "addr" and "end" are page-aligned in walk_page_range() before starting
>     the traversal.
>     
> ...
>
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -196,6 +196,11 @@ int walk_page_range(unsigned long addr, unsigned long end,
>  	if (addr >= end)
>  		return err;
>  
> +	if (WARN_ONCE((addr & ~PAGE_MASK) || (end & ~PAGE_MASK),
> +		      "address range is not page-aligned")) {
> +		return -EINVAL;
> +	}
> +
>  	if (!walk->mm)
>  		return -EINVAL;

Well...  why should we apply the patch?  Is there some buggy code which
is triggering the problem?  Do you intend to write some buggy code to
trigger the problem?  ;) 

IOW, what benefit is there to this change?

Also, as it's a developer-only thing we should arrange for the overhead
to vanish when CONFIG_DEBUG_VM=n?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
