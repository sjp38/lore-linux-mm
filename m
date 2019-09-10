Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6297C49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:18:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 867AC21479
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 16:18:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 867AC21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D7BF6B026A; Tue, 10 Sep 2019 12:18:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2624B6B026B; Tue, 10 Sep 2019 12:18:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 128B16B026C; Tue, 10 Sep 2019 12:18:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id E05396B026A
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:18:12 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8DAA5181AC9BF
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:18:12 +0000 (UTC)
X-FDA: 75919518024.13.bears66_2a687b7199027
X-HE-Tag: bears66_2a687b7199027
X-Filterd-Recvd-Size: 3820
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:18:11 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0AB911000;
	Tue, 10 Sep 2019 09:18:10 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id ABDE73F71F;
	Tue, 10 Sep 2019 09:18:04 -0700 (PDT)
Date: Tue, 10 Sep 2019 17:17:59 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	will@kernel.org, mark.rutland@arm.com, mhocko@suse.com,
	ira.weiny@intel.com, david@redhat.com, cai@lca.pw,
	logang@deltatee.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, mgorman@techsingularity.net,
	osalvador@suse.de, ard.biesheuvel@arm.com, steve.capper@arm.com,
	broonie@kernel.org, valentin.schneider@arm.com,
	Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
Subject: Re: [PATCH V7 3/3] arm64/mm: Enable memory hot remove
Message-ID: <20190910161759.GI14442@C02TF0J2HF1T.local>
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 03:15:58PM +0530, Anshuman Khandual wrote:
> @@ -770,6 +1022,28 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>  void vmemmap_free(unsigned long start, unsigned long end,
>  		struct vmem_altmap *altmap)
>  {
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +	/*
> +	 * FIXME: We should have called remove_pagetable(start, end, true).
> +	 * vmemmap and vmalloc virtual range might share intermediate kernel
> +	 * page table entries. Removing vmemmap range page table pages here
> +	 * can potentially conflict with a concurrent vmalloc() allocation.
> +	 *
> +	 * This is primarily because vmalloc() does not take init_mm ptl for
> +	 * the entire page table walk and it's modification. Instead it just
> +	 * takes the lock while allocating and installing page table pages
> +	 * via [p4d|pud|pmd|pte]_alloc(). A concurrently vanishing page table
> +	 * entry via memory hot remove can cause vmalloc() kernel page table
> +	 * walk pointers to be invalid on the fly which can cause corruption
> +	 * or worst, a crash.
> +	 *
> +	 * So free_empty_tables() gets called where vmalloc and vmemmap range
> +	 * do not overlap at any intermediate level kernel page table entry.
> +	 */
> +	unmap_hotplug_range(start, end, true);
> +	if (!vmalloc_vmemmap_overlap)
> +		free_empty_tables(start, end);
> +#endif
>  }
>  #endif	/* CONFIG_SPARSEMEM_VMEMMAP */

I wonder whether we could simply ignore the vmemmap freeing altogether,
just leave it around and not unmap it. This way, we could call
unmap_kernel_range() for removing the linear map and we save some code.

For the linear map, I think we use just above 2MB of tables for 1GB of
memory mapped (worst case with 4KB pages we need 512 pte pages). For
vmemmap we'd use slightly above 2MB for a 64GB hotplugged memory. Do we
expect such memory to be re-plugged again in the same range? If we do,
then I shouldn't even bother with removing the vmmemmap.

I don't fully understand the use-case for memory hotremove, so any
additional info would be useful to make a decision here.

-- 
Catalin

