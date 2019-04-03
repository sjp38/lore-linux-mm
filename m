Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B234C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:18:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0CC121473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:18:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0CC121473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FDE16B0008; Wed,  3 Apr 2019 05:18:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC5B6B000A; Wed,  3 Apr 2019 05:18:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB6446B000C; Wed,  3 Apr 2019 05:17:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98F8D6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 05:17:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w3so636368edt.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 02:17:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LpMsNlcIScPv5aEAYVdpKZ4XrgvCSJIyahc+2TCwhHY=;
        b=q/EmRtkw8ttxuWTKzresFb7b39KFVm4mxRTm32xOiomtx7Kpsplt+llID135CmDYyC
         k4sgIMppJ1jwX2HQQeH6Tp9UVroT7PXWFmRC1wKOapaZRHK663TQxwc6uR/7uIwHlbjD
         +ilgO+X3VFB+yinVfrldMPm8Nuyfy1FrwvtnzSI3TrWqnDFNtxomquIqoK/wpB4oLInL
         n7UceshNMGEc0mXUTrgi0g6afwgiV7a3Y3q7p3+Wgaq/fPjThP8Bzc4akEdGZeqCsAfk
         ze97YifeAeTkLnrMNiI322XVYQAc/5kRJFLaYZKagGAH3TpEl/uq3H0WklS5SKyAZ2o6
         6Yjw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVdcPOuIyN3FjfB17RMqi9o1E0pOmAdAM4p0Vhp94ekDTRYAC4m
	3q0YkLi63O2H4qIxuH8Ej2dUcvKxP3ue7fqG6FHaff+uO1Nbpgs9OWAueUeaRZqPlwOOp7lMOkx
	bzMfN1TCuH7Y9KC6IEUsogt0EJKX+WufY45aVVkdyifDx+DvivjTr3f8JcrKcUb4=
X-Received: by 2002:a17:906:f2d6:: with SMTP id gz22mr22775269ejb.38.1554283079151;
        Wed, 03 Apr 2019 02:17:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQQEAvkwp+TpKe5W/MHC94C599eX6zInSVstWTmD/CDg2zUZ7W+Jj8wrM0TtU4qgEWg6AW
X-Received: by 2002:a17:906:f2d6:: with SMTP id gz22mr22775213ejb.38.1554283078030;
        Wed, 03 Apr 2019 02:17:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554283078; cv=none;
        d=google.com; s=arc-20160816;
        b=O2KEqgEJv3C5hWrhcEZUbCeCh6jNf3NcCK3oLO3zbqjXmuJaMVBFiEyRqKheYFwz7G
         YQniYsu1qFFwcfeoBfrOl8wKPWQI3zChJqJ32XJmAriO09bk+50FWJbYs/J2eOpVRSFE
         4uz4+i9EQUax4jkYKFxpMKG/rwMHpHrUYgO9GQ080BlpiB0ltT/N+sb+tZ4bkKIqD9aw
         1BJ7PjhTrgHhjVLLlYq8EegPvgBQFSk8VRwLShOCc4+craJvS15U83Hq7eRbwY3WDtL3
         YscTa6mZtHAQFS4IY8kVx7DsGARP5hWSd9auWiqa3pqCPqJhT1/69PMlpYp6sR09+YG+
         JIiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LpMsNlcIScPv5aEAYVdpKZ4XrgvCSJIyahc+2TCwhHY=;
        b=0zIbUlFlob2g3ibizz+kku47sUSVhJLminDYlm2mRgtpfGXrRd7QtIhMFT91fTPTrQ
         cbL19WdQAP1KquAbfsEnKIEzZEg7nRPp0E4eKhr4PnQPuzjXsj3BFf7uPfEYl21nQ054
         W13tX02u97JyaPJFqArI272nBD4wpR93SidoMiGFLgBSPdhv0RaYDsIKjwDm+C1L6WIz
         EMlHMG9/BUhi8eYeZNo0iwXsZsid57Y22524z39WyI0Bfh/rC7O0ZYjaKRAskFf2c3ZI
         IESkoA3iMHbfASWc1Mua8AEYq6lHQ7naIBRmFmtDk3PrOGjxcdHLn+VFYq/ApgyAKXRv
         cL1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y22si1347794edc.134.2019.04.03.02.17.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 02:17:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B8FE1ADE7;
	Wed,  3 Apr 2019 09:17:56 +0000 (UTC)
Date: Wed, 3 Apr 2019 11:17:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mgorman@techsingularity.net,
	james.morse@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
	cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com,
	pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw
Subject: Re: [PATCH 4/6] mm/hotplug: Reorder arch_remove_memory() call in
 __remove_memory()
Message-ID: <20190403091755.GG15605@dhcp22.suse.cz>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-5-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554265806-11501-5-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-04-19 10:00:04, Anshuman Khandual wrote:
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
> is consistent.

consistent with what? Anyway, I believe you wanted to mention that this
is safe because there is no other memblock (bootmem) allocator user that
late. So nobody is going to allocate from the removed range just to blow
up later. Also nobody should be using the bootmem allocated range else
we wouldn't allow to remove it. So reordering is indeed safe.
 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

With a changelog updated to explain why this is safe
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 0082d69..71d0d79 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1872,11 +1872,10 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> +	arch_remove_memory(nid, start, size, NULL);
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> -	arch_remove_memory(nid, start, size, NULL);
> -
>  	try_offline_node(nid);
>  
>  	mem_hotplug_done();
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

