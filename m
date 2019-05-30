Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19383C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 10:37:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B60A025762
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 10:37:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B60A025762
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AB9B6B0010; Thu, 30 May 2019 06:37:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15E906B026B; Thu, 30 May 2019 06:37:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023F36B026C; Thu, 30 May 2019 06:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A5FE86B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 06:37:18 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t58so7972449edb.22
        for <linux-mm@kvack.org>; Thu, 30 May 2019 03:37:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Bs8wcxPNxHizyLtBsoD5XxHYj5shBp+pBFscV34NH9Y=;
        b=L8barF+wmE4a6KbO2c+n92PVNysRw4kMekwnT3bH9sgZE1tjb+B5hqEYxNMKs9rhNA
         AGhJpk34a88UKrI3b9WC3lheUZyon2EO0MjwWTQp56NJIF5FaIyIzsEmMV3iV4S4L1f8
         trhaXxcryqrgGxgZjXGIvtvFZh6GmTSKDMXehey2xii8ZIsnRkDgKfSLkayahkyy9el+
         mFV4PL7R0uxOt92F0jQnOlOKN+6J36GkkUmIkPL1Odh2ABEzeH88K9ycPkGi8UEklkYG
         u8lflAijkMW69TYt1XZi0r6ZHrY+QJdsAD03Q/vTmU7Z0rfxTfeuOZQ8ocSlERi8jOto
         VD5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAU5qEejNFRxIfH9+tbwEa0TU5YpTRsWKESGw4uUR6SjnbXCQfwc
	E3+6ckEx1Hmi89+DgrrDW3lWg4ycibP6M2wYnnKD4jueHbg8jJ+OYuoTSGMcdCnKCKnCxeeqdHo
	Hktw0Fxz2o8vkEtImdxSWYTE1y9cjOS8QSnyd3xXhyKgdy5dMt6QXjARbsz/WzWScQw==
X-Received: by 2002:a50:8b90:: with SMTP id m16mr3718229edm.278.1559212638132;
        Thu, 30 May 2019 03:37:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzywsW1vJKkqPCyLrFX75kn0Ir4DoRKvYfnXjOultLV0gwA7cNyACp9PVTJQJfY3QFes4LB
X-Received: by 2002:a50:8b90:: with SMTP id m16mr3718105edm.278.1559212636703;
        Thu, 30 May 2019 03:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559212636; cv=none;
        d=google.com; s=arc-20160816;
        b=cXZejKQkzY8I8n0DHjw4fmi46Qr5cJH3vr3EpMbV3TokQrKPtX6VsnLyrW8l4G/iZ7
         I8C0gg8Ee/ZRZFUwtUn/86l1mIC4+kKMJkSgQJqqo6bGUEvAOYb/pGv7I9yrHx46qK3I
         +aaLegRB+fg4GEz274joKeuWdRoBV6yIZoA0Uov/jmgjyBDQPt3X/hHQoWmPPswf9JV7
         iKAD1CF9K+LfmwwiDQwcAQYn3ovjWI4fOcSGKxkW0ZlkgANH+zbwjEQKu8pJMzf8fWjM
         WMvlNU2e4tYPWBySQ0u3MLWxkytP6URROzY/u8eCVAVhnYa9jImDRKIBVI6hif7kV0Hr
         +RmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Bs8wcxPNxHizyLtBsoD5XxHYj5shBp+pBFscV34NH9Y=;
        b=RvDjGL5ZR+XO8Hq0QdPmfCz7Dn2Rt9yZ9+KiSK9kscCbONp14JNCN5kkNe2v1WWf7J
         yC/mFD6YgKCVw8+4Q5sefQCaAS9w1+zPFYOrcTny0wH3rz9mP0Dtm1b/e0XHob3TTj5g
         BFO1f7DmMI3l0ImwqMCAfxFvxzTIXwLkA8bvucpxkarnGuAWxjDdLCMUSta7saThqImh
         uorbIT4iauFcHLSamFmUVK5sZGx8ZGSR8CMl0+7aEbSot3VlVth4Spn2rWPyYHpOZ2pl
         pAdQ4Wos7qgwbGzVnkm1+nI5NNDcW/twxYDgE0UHzqbau0qsJZ/ASGIq78U1ICN0gV2O
         o25w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z18si1478581ejx.36.2019.05.30.03.37.16
        for <linux-mm@kvack.org>;
        Thu, 30 May 2019 03:37:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 56E97374;
	Thu, 30 May 2019 03:37:15 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3E7C93F5AF;
	Thu, 30 May 2019 03:37:12 -0700 (PDT)
Date: Thu, 30 May 2019 11:37:09 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	catalin.marinas@arm.com, will.deacon@arm.com, mhocko@suse.com,
	ira.weiny@intel.com, david@redhat.com, cai@lca.pw,
	logang@deltatee.com, james.morse@arm.com, cpandya@codeaurora.org,
	arunks@codeaurora.org, dan.j.williams@intel.com,
	mgorman@techsingularity.net, osalvador@suse.de,
	ard.biesheuvel@arm.com
Subject: Re: [PATCH V5 1/3] mm/hotplug: Reorder arch_remove_memory() call in
 __remove_memory()
Message-ID: <20190530103709.GB56046@lakrids.cambridge.arm.com>
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
 <1559121387-674-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559121387-674-2-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:46:25PM +0530, Anshuman Khandual wrote:
> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
> entries between memory block and node. It first checks pfn validity with
> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
> 
> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
> which scans all mapped memblock regions with memblock_is_map_memory(). This
> creates a problem in memory hot remove path which has already removed given
> memory range from memory block with memblock_[remove|free] before arriving
> at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
> skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
> sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
> of existing sysfs entries.
> 
> [   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
> [   62.052517] ------------[ cut here ]------------
> [   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
> [   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> [   62.054589] Modules linked in:
> [   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
> [   62.056274] Hardware name: linux,dummy-virt (DT)
> [   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
> [   62.058083] pc : add_memory_resource+0x1cc/0x1d8
> [   62.058961] lr : add_memory_resource+0x10c/0x1d8
> [   62.059842] sp : ffff0000168b3ce0
> [   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
> [   62.061501] x27: 0000000000000000 x26: 0000000000000000
> [   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
> [   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
> [   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
> [   62.065558] x19: 0000000000680000 x18: 0000000000000024
> [   62.066566] x17: 0000000000000000 x16: 0000000000000000
> [   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
> [   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
> [   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
> [   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
> [   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
> [   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
> [   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
> [   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
> [   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
> [   62.076930] Call trace:
> [   62.077411]  add_memory_resource+0x1cc/0x1d8
> [   62.078227]  __add_memory+0x70/0xa8
> [   62.078901]  probe_store+0xa4/0xc8
> [   62.079561]  dev_attr_store+0x18/0x28
> [   62.080270]  sysfs_kf_write+0x40/0x58
> [   62.080992]  kernfs_fop_write+0xcc/0x1d8
> [   62.081744]  __vfs_write+0x18/0x40
> [   62.082400]  vfs_write+0xa4/0x1b0
> [   62.083037]  ksys_write+0x5c/0xc0
> [   62.083681]  __arm64_sys_write+0x18/0x20
> [   62.084432]  el0_svc_handler+0x88/0x100
> [   62.085177]  el0_svc+0x8/0xc
> 
> Re-ordering arch_remove_memory() with memblock_[free|remove] solves the
> problem on arm64 as pfn_valid() behaves correctly and returns positive
> as memblock for the address range still exists. arch_remove_memory()
> removes applicable memory sections from zone with __remove_pages() and
> tears down kernel linear mapping. Removing memblock regions afterwards
> is safe because there is no other memblock (bootmem) allocator user that
> late. So nobody is going to allocate from the removed range just to blow
> up later. Also nobody should be using the bootmem allocated range else
> we wouldn't allow to remove it. So reordering is indeed safe.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: David Hildenbrand <david@redhat.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

> ---
>  mm/memory_hotplug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e096c98..67dfdb8 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1851,10 +1851,10 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> +	arch_remove_memory(nid, start, size, NULL);
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> -	arch_remove_memory(nid, start, size, NULL);
>  	__release_memory_resource(start, size);
>  
>  	try_offline_node(nid);
> -- 
> 2.7.4
> 

