Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10773C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:32:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9107B233A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:32:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9107B233A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E586D6B02D9; Thu, 22 Aug 2019 03:32:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E094C6B02DA; Thu, 22 Aug 2019 03:32:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD0506B02DB; Thu, 22 Aug 2019 03:32:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id A26E96B02D9
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:32:57 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4C3E5180ACF9A
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:32:57 +0000 (UTC)
X-FDA: 75849247194.22.fall73_1993d0c485b18
X-HE-Tag: fall73_1993d0c485b18
X-Filterd-Recvd-Size: 16957
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:32:55 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 881EE1918640;
	Thu, 22 Aug 2019 07:32:53 +0000 (UTC)
Received: from [10.36.116.221] (ovpn-116-221.ams2.redhat.com [10.36.116.221])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7681E5D6B0;
	Thu, 22 Aug 2019 07:32:43 +0000 (UTC)
Subject: Re: [PATCH v1 5/5] mm/memory_hotplug: Remove zone parameter from
 __remove_pages()
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik
 <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski
 <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 Mark Rutland <mark.rutland@arm.com>, Steve Capper <steve.capper@arm.com>,
 Mike Rapoport <rppt@linux.ibm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>, Yu Zhao <yuzhao@google.com>,
 Jun Yao <yaojun8558363@gmail.com>, Robin Murphy <robin.murphy@arm.com>,
 Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 Halil Pasic <pasic@linux.ibm.com>, Tom Lendacky <thomas.lendacky@amd.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Dan Williams <dan.j.williams@intel.com>, Wei Yang
 <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 Jason Gunthorpe <jgg@ziepe.ca>, Logan Gunthorpe <logang@deltatee.com>,
 Ira Weiny <ira.weiny@intel.com>, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org
References: <20190821154006.1338-1-david@redhat.com>
 <20190821154006.1338-6-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d912a7e6-0550-7d2f-ddc0-a2e9407f2207@redhat.com>
Date: Thu, 22 Aug 2019 09:32:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190821154006.1338-6-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.70]); Thu, 22 Aug 2019 07:32:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21.08.19 17:40, David Hildenbrand wrote:
> No longer in use, let's drop it. We no longer access the zone of
> possibly never onlined memory (and therefore don't read garabage in
> these scenarios).
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will@kernel.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Vasily Gorbik <gor@linux.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Rich Felker <dalias@libc.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Steve Capper <steve.capper@arm.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: Yu Zhao <yuzhao@google.com>
> Cc: Jun Yao <yaojun8558363@gmail.com>
> Cc: Robin Murphy <robin.murphy@arm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: Halil Pasic <pasic@linux.ibm.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-sh@vger.kernel.org
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/arm64/mm/mmu.c            | 4 +---
>  arch/ia64/mm/init.c            | 4 +---
>  arch/powerpc/mm/mem.c          | 3 +--
>  arch/s390/mm/init.c            | 4 +---
>  arch/sh/mm/init.c              | 4 +---
>  arch/x86/mm/init_32.c          | 4 +---
>  arch/x86/mm/init_64.c          | 4 +---
>  include/linux/memory_hotplug.h | 4 ++--
>  mm/memory_hotplug.c            | 6 +++---
>  mm/memremap.c                  | 3 +--
>  10 files changed, 13 insertions(+), 27 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index e67bab4d613e..b3843aff12bf 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -1080,7 +1080,6 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct zone *zone;
>  
>  	/*
>  	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
> @@ -1089,7 +1088,6 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
>  	 * unlocked yet.
>  	 */
> -	zone = page_zone(pfn_to_page(start_pfn));
> -	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	__remove_pages(start_pfn, nr_pages, altmap);
>  }
>  #endif
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index bf9df2625bc8..a6dd80a2c939 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -689,9 +689,7 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct zone *zone;
>  
> -	zone = page_zone(pfn_to_page(start_pfn));
> -	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	__remove_pages(start_pfn, nr_pages, altmap);
>  }
>  #endif
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 9191a66b3bc5..7351c44c435a 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -130,10 +130,9 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct page *page = pfn_to_page(start_pfn) + vmem_altmap_offset(altmap);
>  	int ret;
>  
> -	__remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
> +	__remove_pages(start_pfn, nr_pages, altmap);
>  
>  	/* Remove htab bolted mappings for this section of memory */
>  	start = (unsigned long)__va(start);
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 20340a03ad90..6f13eb66e375 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -296,10 +296,8 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct zone *zone;
>  
> -	zone = page_zone(pfn_to_page(start_pfn));
> -	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	__remove_pages(start_pfn, nr_pages, altmap);
>  	vmem_remove_mapping(start, size);
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index dfdbaa50946e..d1b1ff2be17a 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -434,9 +434,7 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = PFN_DOWN(start);
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct zone *zone;
>  
> -	zone = page_zone(pfn_to_page(start_pfn));
> -	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	__remove_pages(start_pfn, nr_pages, altmap);
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index 4068abb9427f..9d036be27aaa 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -865,10 +865,8 @@ void arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct zone *zone;
>  
> -	zone = page_zone(pfn_to_page(start_pfn));
> -	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	__remove_pages(start_pfn, nr_pages, altmap);
>  }
>  #endif
>  
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index a6b5c653727b..b8541d77452c 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1212,10 +1212,8 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;
>  	unsigned long nr_pages = size >> PAGE_SHIFT;
> -	struct page *page = pfn_to_page(start_pfn) + vmem_altmap_offset(altmap);
> -	struct zone *zone = page_zone(page);
>  
> -	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +	__remove_pages(start_pfn, nr_pages, altmap);
>  	kernel_physical_mapping_remove(start, start + size);
>  }
>  #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index f46ea71b4ffd..f75d9483864f 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -125,8 +125,8 @@ static inline bool movable_node_is_enabled(void)
>  
>  extern void arch_remove_memory(int nid, u64 start, u64 size,
>  			       struct vmem_altmap *altmap);
> -extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
> -			   unsigned long nr_pages, struct vmem_altmap *altmap);
> +extern void __remove_pages(unsigned long start_pfn, unsigned long nr_pages,
> +			   struct vmem_altmap *altmap);
>  
>  /* reasonably generic interface to expand the physical pages */
>  extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e88c96cf9d77..7a9719a762fe 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -532,7 +532,6 @@ static void __remove_section(unsigned long pfn, unsigned long nr_pages,
>  
>  /**
>   * __remove_pages() - remove sections of pages from a zone
> - * @zone: zone from which pages need to be removed
>   * @pfn: starting pageframe (must be aligned to start of a section)
>   * @nr_pages: number of pages to remove (must be multiple of section size)
>   * @altmap: alternative device page map or %NULL if default memmap is used
> @@ -542,12 +541,13 @@ static void __remove_section(unsigned long pfn, unsigned long nr_pages,
>   * sure that pages are marked reserved and zones are adjust properly by
>   * calling offline_pages().
>   */
> -void __remove_pages(struct zone *zone, unsigned long pfn,
> -		    unsigned long nr_pages, struct vmem_altmap *altmap)
> +void __remove_pages(unsigned long pfn, unsigned long nr_pages,
> +		    struct vmem_altmap *altmap)
>  {
>  	const unsigned long end_pfn = pfn + nr_pages;
>  	unsigned long cur_nr_pages;
>  	unsigned long map_offset = 0;
> +	struct zone *zone;
>  
>  	if (check_pfn_span(pfn, nr_pages, "remove"))
>  		return;
> diff --git a/mm/memremap.c b/mm/memremap.c
> index 8a394552b5bd..7e34f42e5f5a 100644
> --- a/mm/memremap.c
> +++ b/mm/memremap.c
> @@ -138,8 +138,7 @@ static void devm_memremap_pages_release(void *data)
>  	mem_hotplug_begin();
>  	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
>  		pfn = PHYS_PFN(res->start);
> -		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
> -				 PHYS_PFN(resource_size(res)), NULL);
> +		__remove_pages(pfn, PHYS_PFN(resource_size(res)), NULL);
>  	} else {
>  		arch_remove_memory(nid, res->start, resource_size(res),
>  				pgmap_altmap(pgmap));
> 

Thinking about it, as outlined in the cover letter, passing the nid
instead of the zone here and using the nid to further reduce the number
of zones to process might make sense. But let's wait for feedback first.

-- 

Thanks,

David / dhildenb

