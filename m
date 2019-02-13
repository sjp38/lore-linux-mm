Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 765CEC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FEEA222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:54:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FEEA222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D2C8E0002; Wed, 13 Feb 2019 09:54:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA54C8E0001; Wed, 13 Feb 2019 09:54:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F8338E0002; Wed, 13 Feb 2019 09:54:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30D3B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:54:38 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so1125482edh.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:54:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zqUO6nvTY2uPHbpt+a4DthJh9/8UseChE2yKVlxJV3o=;
        b=cKu4u5gcVryDhx4nPbvZcTOsMEeXgVoD/XPtBYyE2Z2X2LBqdzQfCHJhES+EJ9JpYb
         3OKULh9RDAgqo+PjDF2lAx2R9/StpU1tzW/PxRsBg44h5pvgqzwt8HWNFlVINaMhT/x8
         FV9iWzf/w9NaQjzBb19sCMk2JrhtfK1x4FrdiSWRFOWp3S1rlQkwdiHmmbi5OTsU0ILM
         7WHsmcWFYpO4LKQ3eOJkQyM5JnuGZjLJ7k6M+HuUO2YTQHWMNhD4Bi541x/o1R9mHX47
         totPFghYcNQQI42R2gSVhPVEm5ppunjnmoNM5CA4YVh2E1UzbdubPAB922jGDEgA6jkW
         SmJQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZMj1LTRq3hURVjd1296Lf1CRccncRVz3/J4ck2injn8Nk7wyZr
	6xrfMkRCBE/abohOOoiYeYE4CD5QjUVO934KhOTh9o9uGAWQQGs+RbdOvgDAaayzOVfkmRz6HnQ
	4/9K/9TpU9fOeFyA12ZEKVPx7n/ao74BbRUEy8hl1sOYxBoKd+awU1CcGRMJAjlQ=
X-Received: by 2002:a50:d311:: with SMTP id g17mr676644edh.187.1550069677694;
        Wed, 13 Feb 2019 06:54:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia6cel/+AdRyC3aNQ97sx0Aq2utg1MdWZj3gefZij0szbS0D3DAG7k+/ZW8BQ1hequ0fpGi
X-Received: by 2002:a50:d311:: with SMTP id g17mr676585edh.187.1550069676623;
        Wed, 13 Feb 2019 06:54:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550069676; cv=none;
        d=google.com; s=arc-20160816;
        b=rfDDar6owYyfqfCPrDcBq16J8vFqYp/ua7mzjxEuWcG3cmU5Am6Z6IOBM7PP/yy2US
         tG5L5xC8P8VIH/Muga6FAl2HIsBo7woSx8vOCHlyH7xrnhuNsoqH60GGcWZ/MwAOAq1E
         wnqWuwQ8iYLQ5PNXICV3smxwLV9AmpwFaE7AqyWl9oD8s4TYS2OVRFmlioyRJbe1EdI7
         4Nkax22DIAzFbDp6srhKsDN90HPnVk54yDm4UfOucGSa48actQWW5NHf5LrGOUduASsi
         p4APfQIQMWE6TcylDtrYxtytMYFrRaEXOqWQYDa1uNtxcYO+emDmKwEHcO8tj7oelNWN
         I4OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zqUO6nvTY2uPHbpt+a4DthJh9/8UseChE2yKVlxJV3o=;
        b=DUhXU9+Iv4TvCARfjS2IKkRBab8qVt+WUAlhxuLz9BFlseY0lk4indcwN2Wlz0VrMs
         PSa8FPNJVSPlocWFey8m7jxic0MsBhMDvurDjIX2xVdUt/S1rFFa3rNSE5HaxI5Yy8GY
         3haQBTEpPoK4COyT0D/1L314cuFC/IG+04JmJfEyoIf6CiKHejubtVSBmh5eduCi5tjV
         nSS7iUYVFJBKibwKx1C5240EGhC8AKlvn5RzyCj+WRiRbQq3K6RCsEsO/AIHtsBWe1xo
         tGZo4wEQVnDpGVs9xX2C/oIvt+6Mj22ZxiLBB0KQmddRZFXRiIg2cu/CkaZgaoTEDU0q
         ea3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si1085482ejb.57.2019.02.13.06.54.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 06:54:36 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83146AC24;
	Wed, 13 Feb 2019 14:54:35 +0000 (UTC)
Date: Wed, 13 Feb 2019 15:54:34 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix __dump_page() for poisoned pages
Message-ID: <20190213145434.GR4525@dhcp22.suse.cz>
References: <dbbcd36ca1f045ec81f49c7657928a1cdf24872b.1550065120.git.robin.murphy@arm.com>
 <20190213142308.GQ4525@dhcp22.suse.cz>
 <05a91777-3b95-14a9-c959-a12b25a9b26f@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <05a91777-3b95-14a9-c959-a12b25a9b26f@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 14:38:37, Robin Murphy wrote:
> On 13/02/2019 14:23, Michal Hocko wrote:
> > On Wed 13-02-19 13:40:49, Robin Murphy wrote:
> > > Evaluating page_mapping() on a poisoned page ends up dereferencing junk
> > > and making PF_POISONED_CHECK() considerably crashier than intended. Fix
> > > that by not inspecting the mapping until we've determined that it's
> > > likely to be valid.
> > 
> > Has this ever triggered? I am mainly asking because there is no usage of
> > mapping so I would expect that the compiler wouldn't really call
> > page_mapping until it is really used.
> 
> A function call is a sequence point, so any compiler that did that would be
> totally broken.

Ohh, right I thought this is a static inline.

> The crash looks like this (now from an explicit dump_page() call before it
> happens naturally deep within pfn_to_nid()):

please add this to the changelog.

Acked-by: Michal Hocko <mhocko@suse.com>

> -----
> [  107.147056] Unable to handle kernel NULL pointer dereference at virtual
> address 0000000000000006
> [  107.155774] Mem abort info:
> [  107.158546]   ESR = 0x96000005
> [  107.161572]   Exception class = DABT (current EL), IL = 32 bits
> [  107.167437]   SET = 0, FnV = 0
> [  107.170460]   EA = 0, S1PTW = 0
> [  107.173568] Data abort info:
> [  107.176419]   ISV = 0, ISS = 0x00000005
> [  107.180218]   CM = 0, WnR = 0
> [  107.183151] user pgtable: 4k pages, 39-bit VAs, pgdp = 00000000c2f6ac38
> [  107.189702] [0000000000000006] pgd=0000000000000000, pud=0000000000000000
> [  107.196430] Internal error: Oops: 96000005 [#1] PREEMPT SMP
> [  107.201942] Modules linked in:
> [  107.204962] CPU: 2 PID: 491 Comm: bash Not tainted 5.0.0-rc1+ #1
> [  107.210903] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno
> Development Platform, BIOS EDK II Dec 17 2018
> [  107.221576] pstate: 00000005 (nzcv daif -PAN -UAO)
> [  107.226321] pc : page_mapping+0x18/0x118
> [  107.230200] lr : __dump_page+0x1c/0x398
> [  107.233990] sp : ffffff8011a53c30
> [  107.237265] x29: ffffff8011a53c30 x28: ffffffc039b6ec00
> [  107.242520] x27: 0000000000000000 x26: 0000000000000000
> [  107.247775] x25: 0000000056000000 x24: 0000000000000015
> [  107.253029] x23: ffffff80114d8b18 x22: 0000000000000022
> [  107.258283] x21: ffffffc03538ec38 x20: ffffff8011082e78
> [  107.263537] x19: ffffffbf20000000 x18: 0000000000000000
> [  107.268790] x17: 0000000000000000 x16: 0000000000000000
> [  107.274044] x15: 0000000000000000 x14: 0000000000000000
> [  107.279297] x13: 0000000000000000 x12: 0000000000000030
> [  107.284550] x11: 0000000000000030 x10: 0101010101010101
> [  107.289804] x9 : ff7274615e68726c x8 : 7f7f7f7f7f7f7f7f
> [  107.295057] x7 : feff64756e6c6471 x6 : 0000000000008080
> [  107.300310] x5 : 0000000000000000 x4 : 0000000000000000
> [  107.305564] x3 : ffffffc039b6ec00 x2 : fffffffffffffffe
> [  107.310817] x1 : ffffffffffffffff x0 : fffffffffffffffe
> [  107.316072] Process bash (pid: 491, stack limit = 0x000000004ebd4ecd)
> [  107.322442] Call trace:
> [  107.324858]  page_mapping+0x18/0x118
> [  107.328392]  __dump_page+0x1c/0x398
> [  107.331840]  dump_page+0xc/0x18
> [  107.334945]  remove_store+0xbc/0x120
> [  107.338479]  dev_attr_store+0x18/0x28
> [  107.342103]  sysfs_kf_write+0x40/0x50
> [  107.345722]  kernfs_fop_write+0x130/0x1d8
> [  107.349687]  __vfs_write+0x30/0x180
> [  107.353134]  vfs_write+0xb4/0x1a0
> [  107.356410]  ksys_write+0x60/0xd0
> [  107.359686]  __arm64_sys_write+0x18/0x20
> [  107.363565]  el0_svc_common+0x94/0xf8
> [  107.367184]  el0_svc_handler+0x68/0x70
> [  107.370890]  el0_svc+0x8/0xc
> [  107.373737] Code: f9400401 d1000422 f240003f 9a801040 (f9400402)
> [  107.379766] ---[ end trace cdb5eb5bf435cecb ]---
> -----
> 
> While after this patch, DEBUG_VM works as intended:
> -----
> [   46.835963] page:ffffffbf20000000 is uninitialized and poisoned
> [   46.835970] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
> ffffffffffffffff
> [   46.849520] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
> ffffffffffffffff
> [   46.857194] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> [   46.863170] ------------[ cut here ]------------
> [   46.867736] kernel BUG at ./include/linux/mm.h:1006!
> [   46.872646] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> [   46.878071] Modules linked in:
> [   46.881092] CPU: 1 PID: 483 Comm: bash Not tainted 5.0.0-rc1+ #3
> [   46.887032] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno
> Development Platform, BIOS EDK II Dec 17 2018
> [   46.897704] pstate: 40000005 (nZcv daif -PAN -UAO)
> [   46.902449] pc : remove_store+0xbc/0x120
> ...
> -----
> 
> Robin.
> 
> > > Fixes: 1c6fb1d89e73 ("mm: print more information about mapping in __dump_page")
> > > Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> > > ---
> > >   mm/debug.c | 4 +++-
> > >   1 file changed, 3 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/debug.c b/mm/debug.c
> > > index 0abb987dad9b..1611cf00a137 100644
> > > --- a/mm/debug.c
> > > +++ b/mm/debug.c
> > > @@ -44,7 +44,7 @@ const struct trace_print_flags vmaflag_names[] = {
> > >   void __dump_page(struct page *page, const char *reason)
> > >   {
> > > -	struct address_space *mapping = page_mapping(page);
> > > +	struct address_space *mapping;
> > >   	bool page_poisoned = PagePoisoned(page);
> > >   	int mapcount;
> > > @@ -58,6 +58,8 @@ void __dump_page(struct page *page, const char *reason)
> > >   		goto hex_only;
> > >   	}
> > > +	mapping = page_mapping(page);
> > > +
> > >   	/*
> > >   	 * Avoid VM_BUG_ON() in page_mapcount().
> > >   	 * page->_mapcount space in struct page is used by sl[aou]b pages to
> > > -- 
> > > 2.20.1.dirty
> > > 
> > 

-- 
Michal Hocko
SUSE Labs

