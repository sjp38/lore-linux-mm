Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C482B6B0044
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 19:18:57 -0500 (EST)
Date: Wed, 19 Dec 2012 16:18:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] Add the values related to buddy system for filtering
 free pages.
Message-Id: <20121219161856.e6aa984f.akpm@linux-foundation.org>
In-Reply-To: <20121210103913.020858db777e2f48c59713b6@mxc.nes.nec.co.jp>
References: <20121210103913.020858db777e2f48c59713b6@mxc.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: ebiederm@xmission.com, linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org

On Mon, 10 Dec 2012 10:39:13 +0900
Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp> wrote:

> This patch adds the values related to buddy system to vmcoreinfo data
> so that makedumpfile (dump filtering command) can filter out all free
> pages with the new logic.
> It's faster than the current logic because it can distinguish free page
> by analyzing page structure at the same time as filtering for other
> unnecessary pages (e.g. anonymous page).
> OTOH, the current logic has to trace free_list to distinguish free 
> pages while analyzing page structure to filter out other unnecessary
> pages.
> 
> The new logic uses the fact that buddy page is marked by _mapcount == 
> PAGE_BUDDY_MAPCOUNT_VALUE. But, _mapcount shares its memory with other
> fields for SLAB/SLUB when PG_slab is set, so we need to check if PG_slab
> is set or not before looking up _mapcount value.
> And we can get the order of buddy system from private field.
> To sum it up, the values below are required for this logic.
> 
> Required values:
>   - OFFSET(page._mapcount)
>   - OFFSET(page.private)
>   - NUMBER(PG_slab)
>   - NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE)
> 
> Changelog from v1 to v2:
> 1. remove SIZE(pageflags)
>   The new logic was changed after I sent v1 patch.  
>   Accordingly, SIZE(pageflags) has been unnecessary for makedumpfile.
> 
> What's makedumpfile:
>   makedumpfile creates a small dumpfile by excluding unnecessary pages
>   for the analysis. To distinguish unnecessary pages, makedumpfile gets
>   the vmcoreinfo data which has the minimum debugging information only
>   for dump filtering.

Gee, this info is getting highly dependent upon deep internal kernel
behaviour.

> index 5e4bd78..b27efe4 100644
> --- a/kernel/kexec.c
> +++ b/kernel/kexec.c
> @@ -1490,6 +1490,8 @@ static int __init crash_save_vmcoreinfo_init(void)
> 	VMCOREINFO_OFFSET(page, _count);
> 	VMCOREINFO_OFFSET(page, mapping);
> 	VMCOREINFO_OFFSET(page, lru);
> +	VMCOREINFO_OFFSET(page, _mapcount);
> +	VMCOREINFO_OFFSET(page, private);
> 	VMCOREINFO_OFFSET(pglist_data, node_zones);
> 	VMCOREINFO_OFFSET(pglist_data, nr_zones);
>  #ifdef CONFIG_FLAT_NODE_MEM_MAP
> @@ -1512,6 +1514,8 @@ static int __init crash_save_vmcoreinfo_init(void)
> 	VMCOREINFO_NUMBER(PG_lru);
> 	VMCOREINFO_NUMBER(PG_private);
> 	VMCOREINFO_NUMBER(PG_swapcache);
> +	VMCOREINFO_NUMBER(PG_slab);
> +	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);

We might change the PageBuddy() implementation at any time, and
makedumpfile will break.  Or in this case, become less efficient.

Is there any way in which we can move some of this logic into the
kernel?  In this case, add some kernel code which uses PageBuddy() on
behalf of makedumpfile, rather than replicating the PageBuddy() logic
in userspace?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
