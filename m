Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 0C4F96B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 05:16:39 -0400 (EDT)
Subject: Re: [RFC] vmalloc: add warning in __vmalloc
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1335516144-3486-1-git-send-email-minchan@kernel.org>
References: <1335516144-3486-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 27 Apr 2012 10:16:00 +0100
Message-ID: <1335518161.2686.2.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@gmail.com, rientjes@google.com, Neil Brown <neilb@suse.de>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, "David S.
 Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@newdream.net>

Hi,

On Fri, 2012-04-27 at 17:42 +0900, Minchan Kim wrote:
> Now there are several places to use __vmalloc with GFP_ATOMIC,
> GFP_NOIO, GFP_NOFS but unfortunately __vmalloc calls map_vm_area
> which calls alloc_pages with GFP_KERNEL to allocate page tables.
> It means it's possible to happen deadlock.
> I don't know why it doesn't have reported until now.
> 
> Firstly, I tried passing gfp_t to lower functions to support __vmalloc
> with such flags but other mm guys don't want and decided that
> all of caller should be fixed.
> 
> http://marc.info/?l=linux-kernel&m=133517143616544&w=2
> 
> To begin with, let's listen other's opinion whether they can fix it
> by other approach without calling __vmalloc with such flags.
> 
> So this patch adds warning to detect and to be fixed hopely.
> I Cced related maintainers.
> If I miss someone, please Cced them.
> 
That seems ok to me. GFS2 only uses it as a back up in case the kmalloc
call fails, and I suspect that we could easily eliminate it entirely
since I doubt that it does actually ever fail in reality. If it were to
fail then that is handled correctly anyway,

Steve.

> side-note:
>   I added WARN_ON instead of WARN_ONCE to detect all of callers
>   and each WARN_ON for each flag to detect to use any flag easily.
>   After we fix all of caller or reduce such caller, we can merge
>   a warning with WARN_ONCE.
> 
> Cc: Neil Brown <neilb@suse.de>
> Cc: Artem Bityutskiy <dedekind1@gmail.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: Adrian Hunter <adrian.hunter@intel.com>
> Cc: Steven Whitehouse <swhiteho@redhat.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: James Morris <jmorris@namei.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Sage Weil <sage@newdream.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmalloc.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 94dff88..36beccb 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1700,6 +1700,15 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
>  			    gfp_t gfp_mask, pgprot_t prot,
>  			    int node, void *caller)
>  {
> +	/*
> +	 * This function calls map_vm_area so that it allocates
> +	 * page table with GFP_KERNEL so caller should avoid using
> +	 * GFP_NOIO, GFP_NOFS and !__GFP_WAIT.
> +	 */
> +	WARN_ON(!(gfp_mask & __GFP_WAIT));
> +	WARN_ON(!(gfp_mask & __GFP_IO));
> +	WARN_ON(!(gfp_mask & __GFP_FS));
> +
>  	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
>  				gfp_mask, prot, node, caller);
>  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
