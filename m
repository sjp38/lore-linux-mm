Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EED9C4CEC4
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 01:45:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3352A214DA
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 01:45:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nzjYwpMT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3352A214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 879B16B0005; Sun, 15 Sep 2019 21:45:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 829736B0006; Sun, 15 Sep 2019 21:45:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F1016B0007; Sun, 15 Sep 2019 21:45:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0030.hostedemail.com [216.40.44.30])
	by kanga.kvack.org (Postfix) with ESMTP id 4898F6B0005
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:45:05 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E091E181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 01:45:04 +0000 (UTC)
X-FDA: 75939090528.28.rake06_2c4c26454de4b
X-HE-Tag: rake06_2c4c26454de4b
X-Filterd-Recvd-Size: 9610
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 01:45:04 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id b10so16186428plr.4
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 18:45:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=fNnAnq8pDeljhZQ4pgIKWXaM6E5rsGED87rKuk4gjk8=;
        b=nzjYwpMTP1y7w3N0WhvyyFQQwOr8d8qbDv4YObmyIib7IyAUBcul+5byappQyOVIPS
         Dqq8kh9xySZGdarsR6D1u26oZGnDDUMZi+a+6aZ48GU2jYPbQM3Aj1St0Tq1NoONC3PB
         hyxV+xHcpXHMsLKL+P+l6q6FcTVAya7m7ouCaVwvLNZF/0Rx/ir/MI6o3V84P8aKI+ts
         DJ1q3a2kFi4ktMZp7BCmykYy6NIAzSQsaY2yTNBqwsD526wj6KGKopXBuO3ksZ9eFb3/
         5K78S6grm1nfjSnrpfwR1MfyuoawoNyHhgEK9uHCdOEwV7eDA2RNMeIG8cj1dXAxiHUx
         DRsg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=fNnAnq8pDeljhZQ4pgIKWXaM6E5rsGED87rKuk4gjk8=;
        b=NarjrdS9S4RtiWxcyn0sFNBDX2ed05d432nC/daPv2vpDc8etX61/AoWPuoHCbTa/G
         VLq+dZvmct8CT45VF1LdY7jJWQa4t+Ogx+Kgl56T/NZ5S4US8jjNjztGDV17M6s2eblL
         YD+d1eQnEhlBLOyrZzR38ZsX0epTUzjtkJGhacjzgqZwAVOGYRiEgkrjgAjHs+deySdF
         zABOFB5JxCfT7U/POGRsgd9ZAfRxfHjFiRP4feFWv9ALuNHaxS3uv6j7svuYT6evFzpK
         vxSH/skBiuAQspXfz6MThPVugZlM97WT98fkSOtvNY+DTseUcLv3PuBACLKeb6XXAisA
         XaaA==
X-Gm-Message-State: APjAAAX6ak4+WQnnZOUtwC/5wAiIk/eS7MxmrM+1MDpGlXTih5jT3q39
	WVdg+t/TgCml78CV6pcbajg=
X-Google-Smtp-Source: APXvYqxdgDyg1BgZoFwrA5D2pgqFh+fcaV8rX9gUUp7aqgZghpzjiomJ6OzKYVqhvUmCfXheWT5MQA==
X-Received: by 2002:a17:902:854b:: with SMTP id d11mr57017596plo.146.1568598302555;
        Sun, 15 Sep 2019 18:45:02 -0700 (PDT)
Received: from [192.168.68.119] (220-245-129-191.tpgi.com.au. [220.245.129.191])
        by smtp.gmail.com with ESMTPSA id t13sm3343972pfe.69.2019.09.15.18.44.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Sep 2019 18:45:01 -0700 (PDT)
Subject: Re: [PATCH V7 1/3] mm/hotplug: Reorder memblock_[free|remove]() calls
 in try_remove_memory()
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org
Cc: mark.rutland@arm.com, mhocko@suse.com, ira.weiny@intel.com,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de, ard.biesheuvel@arm.com,
 steve.capper@arm.com, broonie@kernel.org, valentin.schneider@arm.com,
 Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-2-git-send-email-anshuman.khandual@arm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <74bcbd36-3bec-be67-917d-60cd74cbcef0@gmail.com>
Date: Mon, 16 Sep 2019 11:44:50 +1000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567503958-25831-2-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/9/19 7:45 pm, Anshuman Khandual wrote:
> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs

I could not find this path in the code, the only called for get_nid_for_pfn()
was register_mem_sect_under_node() when the system is under boot.

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

This seems like arm64 is not ready for probe_store() via drivers/base/memory.c/ode.c

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
> Re-ordering memblock_[free|remove]() with arch_remove_memory() solves the
> problem on arm64 as pfn_valid() behaves correctly and returns positive
> as memblock for the address range still exists. arch_remove_memory()
> removes applicable memory sections from zone with __remove_pages() and
> tears down kernel linear mapping. Removing memblock regions afterwards
> is safe because there is no other memblock (bootmem) allocator user that
> late. So nobody is going to allocate from the removed range just to blow
> up later. Also nobody should be using the bootmem allocated range else
> we wouldn't allow to remove it. So reordering is indeed safe.
> 
> Reviewed-by: David Hildenbrand <david@redhat.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Acked-by: Mark Rutland <mark.rutland@arm.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---

Honestly, the issue is not clear from the changelog, largely
because I can't find the use of get_nid_for_pfn()  being used
in memory hotunplug. I can see why using pfn_valid() after
memblock_free/remove is bad on the architecture.

I think the checks to pfn_valid() can be avoided from the
remove paths if we did the following

memblock_isolate_regions()
for each isolate_region {
	memblock_free
	memblock_remove
	arch_memory_remove

	# ensure that __remove_memory can avoid calling pfn_valid
}

Having said that, your patch is easier and if your assumption
about not using the memblocks is valid (after arch_memory_remove())
then might be the least resistant way forward

Balbir Singh.


>  mm/memory_hotplug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c73f09913165..355c466e0621 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1770,13 +1770,13 @@ static int __ref try_remove_memory(int nid, u64 start, u64 size)
>  
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> -	memblock_free(start, size);
> -	memblock_remove(start, size);
>  
>  	/* remove memory block devices before removing memory */
>  	remove_memory_block_devices(start, size);
>  
>  	arch_remove_memory(nid, start, size, NULL);
> +	memblock_free(start, size);
> +	memblock_remove(start, size);
>  	__release_memory_resource(start, size);
>  
>  	try_offline_node(nid);
> 

