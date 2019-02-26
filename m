Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E956C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 18:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECDB1218A2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 18:16:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECDB1218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 634C38E0003; Tue, 26 Feb 2019 13:16:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E21F8E0001; Tue, 26 Feb 2019 13:16:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AA378E0003; Tue, 26 Feb 2019 13:16:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E23778E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 13:16:51 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o25so5698630edr.0
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:16:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=btxf0DH2n4iUoZj6eLYRX600U626ReMiS4b+u0Tr/78=;
        b=RBnHEhFOClyZVvWgjKPntaGtewDj2QvVhSwI4aPdj0ClT+x6VbK9sjMglJiNcA3sAZ
         IE9LoWb3iSRL5GhViCHefiG4SdiXXiX/lfuRl+deCoQx8OzsorgsGt0R8mcuhvmszL67
         kXuJUyAAblpvwkB+ZttqAvPkjC6J5rsO+ZHsb5f6fOOHvlupN7TlflSBu9ttBNON9jEb
         BRINc0FUt2ROsJLP+IyBoDtVvBMADVrCxpjpWI0sgE03vnU7KW0rpE/vAq/jcp1JMwne
         wQfej70NQ2T+hsQ2ZGXIHV9oaItnH4g5LXcT3L+t5hmIo8SvInUABv3JBk0BiFrq+9Nm
         0GIA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAua5yLcHWvYbZnmAKa97f8v9t8NMFjIg4P7uYtmxFo7AI3TaGuBi
	sDN1VnVJoOv8kcWGakdPL/Yz8mc+zxYgx1JDK11RZ4XSwOJMnsyF6X164/jNuaKexrB3WN+clif
	1sfHHv5TKNvrONl0FKxhlSlnsTF3YH+ADS2xv2YsxbeS5cUkq0HAcQ7U3rFim6CY=
X-Received: by 2002:a50:9857:: with SMTP id h23mr19719684edb.66.1551205011474;
        Tue, 26 Feb 2019 10:16:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYLSmfuXWQ6tSc7e/g2yjAQ9fF+b8obYT0EyyRTb8uWTgwmHYb7ZR0y3AMrYp/mkzLzeqqf
X-Received: by 2002:a50:9857:: with SMTP id h23mr19719629edb.66.1551205010416;
        Tue, 26 Feb 2019 10:16:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551205010; cv=none;
        d=google.com; s=arc-20160816;
        b=S7lEaSpZVR99TEwFGFB1fPh+qFNpqtrFXvXkBvhpC61WDssoXkonqqGOT0jrmA/2bZ
         l3c9WPpPfx3s65R0aXQplWnOh+MqAYq9QZxKRR3tsaAIZWqhzTBSs3PAsybSJiWfUA7v
         olBxfp0enBStybUHsWshc9PmaAmnrwzHC0xZJEmMQgm8dL2s6yOXWDj9chBjREgTlvYz
         a2ybAHg4MkenQy8ipQLNt3/C7LV+9yOgoYElaThpLLjTPL0h3w8qiR6zXBXOxS2JXlhT
         F/zskIyls3FfyBQlW/Oh2JF/sKejPKOSOp0P3jxFqz1x4ck1WfdBBy/uVqp0ZzrLT35i
         Mxrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=btxf0DH2n4iUoZj6eLYRX600U626ReMiS4b+u0Tr/78=;
        b=ilvWNOrP2SQxUOerVILMDQ4OSAc9nl6KNowKgo4NPQT7mutb/D3HK0t+anKsrbhX+s
         y71TAA7EKvIaD7Wr90J2C8XlwHLWjlofZKN+a00EPakZDqTQ2FHMRIIQzEaoDDo0GS8y
         zNy/WR/cCo+XlpM12A3aYnyo+XEtuitLrvpTSlw+KBY6SehQ7nNkkNMaDqnkXLzWNMm+
         8m4ArGdr0eT4vyiXZHmFbmmRDNj1RubuuIcS/gv15uANHLAwBNgPCmKY1re4UdGuEHub
         VmxU6sGPTUJEbN+J/HHX4PKRVfgEVH4MK+Gf5LQxCB69ybrVCpAEa9seHPC3bIx9DuCL
         oEMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t47si2248376edd.418.2019.02.26.10.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 10:16:50 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0C86AD05;
	Tue, 26 Feb 2019 18:16:49 +0000 (UTC)
Date: Tue, 26 Feb 2019 19:16:48 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-ID: <20190226181648.GG10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
 <20190226123521.GZ10588@dhcp22.suse.cz>
 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
 <20190226142352.GC10588@dhcp22.suse.cz>
 <1551203585.6911.47.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551203585.6911.47.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 12:53:05, Qian Cai wrote:
> On Tue, 2019-02-26 at 15:23 +0100, Michal Hocko wrote:
> > On Tue 26-02-19 09:16:30, Qian Cai wrote:
> > > 
> > > 
> > > On 2/26/19 7:35 AM, Michal Hocko wrote:
> > > > On Mon 25-02-19 14:17:10, Qian Cai wrote:
> > > > > When onlining memory pages, it calls kernel_unmap_linear_page(),
> > > > > However, it does not call kernel_map_linear_page() while offlining
> > > > > memory pages. As the result, it triggers a panic below while onlining on
> > > > > ppc64le as it checks if the pages are mapped before unmapping,
> > > > > Therefore, let it call kernel_map_linear_page() when setting all pages
> > > > > as reserved.
> > > > 
> > > > This really begs for much more explanation. All the pages should be
> > > > unmapped as they get freed AFAIR. So why do we need a special handing
> > > > here when this path only offlines free pages?
> > > > 
> > > 
> > > It sounds like this is exact the point to explain the imbalance. When
> > > offlining,
> > > every page has already been unmapped and marked reserved. When onlining, it
> > > tries to free those reserved pages via __online_page_free(). Since those
> > > pages
> > > are order 0, it goes free_unref_page() which in-turn call
> > > kernel_unmap_linear_page() again without been mapped first.
> > 
> > How is this any different from an initial page being freed to the
> > allocator during the boot?
> > 
> 
> As least for IBM POWER8, it does this during the boot,
> 
> early_setup
>   early_init_mmu
>     harsh__early_init_mmu
>       htab_initialize [1]
>         htab_bolt_mapping [2]
> 
> where it effectively map all memblock regions just like
> kernel_map_linear_page(), so later mem_init() -> memblock_free_all() will unmap
> them just fine.
> 
> [1]
> for_each_memblock(memory, reg) {
> 	base = (unsigned long)__va(reg->base);
> 	size = reg->size;
> 
> 	DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
> 		base, size, prot);
> 
> 	BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
> 		prot, mmu_linear_psize, mmu_kernel_ssize));
> 	}
> 
> [2] linear_map_hash_slots[paddr >> PAGE_SHIFT] = ret | 0x80;

Thanks for the clarification. I would have expected that there is a
generic path to do kernel_map_pages from an appropriate place. I am also
wondering whether blowing up is actually the right thing to do. Is the
ppc specific code correct? Isn't your patch simply working around a
bogus condition?

-- 
Michal Hocko
SUSE Labs

