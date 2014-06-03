Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 96C0D6B00AA
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 20:34:38 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id t60so6058404wes.27
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 17:34:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id la3si28846318wjb.23.2014.06.02.17.34.35
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 17:34:36 -0700 (PDT)
Message-ID: <538d181c.4378c20a.412d.ffffee3fSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
Date: Mon,  2 Jun 2014 20:29:22 -0400
In-Reply-To: <538D0D7E.6000405@intel.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com> <538D0D7E.6000405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon, Jun 02, 2014 at 04:49:18PM -0700, Dave Hansen wrote:
> On 02/10/2014 01:44 PM, Naoya Horiguchi wrote:
> > When we try to use multiple callbacks in different levels, skip control is
> > also important. For example we have thp enabled in normal configuration, and
> > we are interested in doing some work for a thp. But sometimes we want to
> > split it and handle as normal pages, and in another time user would handle
> > both at pmd level and pte level.
> > What we need is that when we've done pmd_entry() we want to decide whether
> > to go down to pte level handling based on the pmd_entry()'s result. So this
> > patch introduces a skip control flag in mm_walk.
> > We can't use the returned value for this purpose, because we already
> > defined the meaning of whole range of returned values (>0 is to terminate
> > page table walk in caller's specific manner, =0 is to continue to walk,
> > and <0 is to abort the walk in the general manner.)
> 
> This seems a bit complicated for a case which doesn't exist in practice
> in the kernel today.  We don't even *have* a single ->pte_entry handler.

Following users have their own pte_entry() by latter part of this patchset:
- queue_pages_range()
- mem_cgroup_count_precharge()
- show_numa_map()
- pagemap_read()
- clear_refs_write()
- show_smap()
- or1k_dma_alloc()
- or1k_dma_free()
- subpage_mark_vma_nohuge

>  Everybody just sets ->pmd_entry and does the splitting and handling of
> individual pte entries in there.

Walking over every pte entry under some pmd is common task, so if you don't
have any good reason, we should do it in mm/pagewalk.c side, not in each
pmd_entry() callback. (Callbacks should focus on their own task.)

>  The only reason it's needed is because
> of the later patches in the series, which is kinda goofy.

Most of current users use pte_entry() in the latest linux-mm.
Only few callers (mem_cgroup_move_charge() and force_swapin_readahead())
make their pmd_entry() handle pte-level walk in their own way.

BTW, we have some potential callers of page table walker which currently
does page walk completely in their own way. Here's the list:
- mincore()
- copy_page_range()
- remap_pfn_range()        
- zap_page_range()         
- free_pgtables()          
- vmap_page_range_noflush()
- change_protection_range()
Yes, my work for cleanuping page table walker is still on the way.

> I'm biased, but I think the abstraction here is done in the wrong place.
> 
> Naoya, could you take a looked at the new handler I proposed?  Would
> that help make this simpler?

I'll look through this series later and I'd like to add some of your
patches on top of this patchset.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
