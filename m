Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 404376B6E6C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 06:22:53 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v74so16287712qkb.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 03:22:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m96si254086qkh.158.2018.12.04.03.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 03:22:52 -0800 (PST)
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
References: <20181203100309.14784-1-mhocko@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <41c010e7-078c-5d50-e851-143355abbcb0@redhat.com>
Date: Tue, 4 Dec 2018 12:22:48 +0100
MIME-Version: 1.0
In-Reply-To: <20181203100309.14784-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oscar Salvador <OSalvador@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

On 03.12.18 11:03, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> We have received a bug report that an injected MCE about faulty memory
> prevents memory offline to succeed. The underlying reason is that the
> HWPoison page has an elevated reference count and the migration keeps
> failing. There are two problems with that. First of all it is dubious
> to migrate the poisoned page because we know that accessing that memory
> is possible to fail. Secondly it doesn't make any sense to migrate a
> potentially broken content and preserve the memory corruption over to a
> new location.
> 
> Oscar has found out that it is the elevated reference count from
> memory_failure that is confusing the offlining path. HWPoisoned pages
> are isolated from the LRU list but __offline_pages might still try to
> migrate them if there is any preceding migrateable pages in the pfn
> range. Such a migration would fail due to the reference count but
> the migration code would put it back on the LRU list. This is quite
> wrong in itself but it would also make scan_movable_pages stumble over
> it again without any way out.
> 
> This means that the hotremove with hwpoisoned pages has never really
> worked (without a luck). HWPoisoning really needs a larger surgery
> but an immediate and backportable fix is to skip over these pages during
> offlining. Even if they are still mapped for some reason then
> try_to_unmap should turn those mappings into hwpoison ptes and cause
> SIGBUS on access. Nobody should be really touching the content of the
> page so it should be safe to ignore them even when there is a pending
> reference count.
> 
> Debugged-by: Oscar Salvador <osalvador@suse.com>
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> I am sending this as an RFC now because I am not fully sure I see all
> the consequences myself yet. This has passed a testing by Oscar but I
> would highly appreciate a review from Naoya about my assumptions about
> hwpoisoning. E.g. it is not entirely clear to me whether there is a
> potential case where the page might be still mapped. I have put
> try_to_unmap just to be sure. It would be really great if I could drop
> that part because then it is not really great which of the TTU flags to
> use to cover all potential cases.
> 
> I have marked the patch for stable but I have no idea how far back it
> should go. Probably everything that already has hotremove and hwpoison
> code.
> 
> Thanks in advance!

This sounds good to me. We treat all HWPoison pages already as movable
in has_unmovable_pages() when isolating pages to migrate pages away (and
as !movable when trying to isolate a contig range for allocation).

If this scenario should not be supported (if HWPoison page that is
mapped cannot be offlined), we would have to bail out on such pages way
earlier (e.g. in has_unmovable_pages()), failing in do_migrate_range()
would be too late.

+1 to "HWPoisoning really needs a larger surgery"

With the comment update

Acked-by: David Hildenbrand <david@redhat.com>


> 
>  mm/memory_hotplug.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c6c42a7425e5..08c576d5a633 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -34,6 +34,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/memblock.h>
>  #include <linux/compaction.h>
> +#include <linux/rmap.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -1366,6 +1367,17 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  			pfn = page_to_pfn(compound_head(page))
>  				+ hpage_nr_pages(page) - 1;
>  
> +		/*
> +		 * HWPoison pages have elevated reference counts so the migration would
> +		 * fail on them. It also doesn't make any sense to migrate them in the
> +		 * first place. Still try to unmap such a page in case it is still mapped.
> +		 */
> +		if (PageHWPoison(page)) {
> +			if (page_mapped(page))
> +				try_to_unmap(page, TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS);
> +			continue;
> +		}
> +
>  		if (!get_page_unless_zero(page))
>  			continue;
>  		/*
> 


-- 

Thanks,

David / dhildenb
