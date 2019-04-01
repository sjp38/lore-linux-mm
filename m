Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B3E7C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 09:28:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E80E206BA
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 09:28:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="KtOofCLD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E80E206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D37556B0008; Mon,  1 Apr 2019 05:28:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE6A46B000A; Mon,  1 Apr 2019 05:28:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD8266B000C; Mon,  1 Apr 2019 05:28:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 816856B0008
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 05:28:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 33so7017422pgv.17
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 02:28:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yL+xq3Ds6cL7Gguw/EB/2F6pIH1ydFIOdF5y0szr1n0=;
        b=Lbpd3hC3YhNejaFY82IfuNtKFGo2WtT8lO1SE+0p/GDBWLCiDSZ0OOXJ9hZXs0fpM1
         GrnLM+xcZc/o3VBYkYK6EW/+Y6Kr78yO5PMibatH174USWwMKV/9Lee1vbncvNAa6GMk
         it9dw/L2gZ1OADeWDl+dKHzAk9w8Ij1qnpvQvf6Qimu2MGncjZAxrrSuJmJ+euQkDI4H
         hXxQ6/XX4rn46N+W4phWAaJumv187mZ2EIbj/79Jfl6mtsKnuILiN3dkZLQKwy+aTqKl
         3EKJQR0dI5jjhY40BmdHsgHcuBw+GP+HRWUh0cFE+4CR86FGV9CIWW8HV9DQKHGlvL/q
         PbBA==
X-Gm-Message-State: APjAAAVXYVlt6A5D8Qa34ABtHpoF3Dz0OoxDBAUW3ONFXsVkd7+E2BP7
	o3672NFrxFEUOyCIVULjVo7LTwkgN1W92Jhuz2rraDaM5Li8luxr22xKscrpuwzlbfZYHPaRfJ5
	T6/DYRYaysYpU2jTl4gqmPgM/3DuD408oXzjzMysHh7Ow/9wWx08NTCLPflQylyfpzQ==
X-Received: by 2002:a63:1cd:: with SMTP id 196mr60100405pgb.58.1554110891110;
        Mon, 01 Apr 2019 02:28:11 -0700 (PDT)
X-Received: by 2002:a63:1cd:: with SMTP id 196mr60100363pgb.58.1554110890483;
        Mon, 01 Apr 2019 02:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554110890; cv=none;
        d=google.com; s=arc-20160816;
        b=Pe/gRIkWuocj69o5z1COxcs4a6dJO7Z/7FVOzIRWTSGe39d9vXbjN9fbjYmEGAvbMH
         LwKi8L5GyV1wxJsclxW5kAm0G6+zp/lNZwiz9/O6HX1FixvxF2NUFqyQ162gDxr8GgHJ
         u81r+2CuLF2PPeMIRaSkjsKNo9ovN6frHbb36K13ygtsCMoEaCdF0yBZ7oTnSzvp/Xup
         +YzrRK8Beg99vh7S4L3ztxJ2p8ip0HqK7uzlBn2nCZwjleGaFKkTo+amC6DH+AMGh6je
         G53rZJlOc7AJSN+ZubBG5ccJMJpUKX9yvG2TT7xqqP4fNsBK+Z1mTKDMHGq5Te6bbDbF
         zGxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yL+xq3Ds6cL7Gguw/EB/2F6pIH1ydFIOdF5y0szr1n0=;
        b=Vm2XGENx3xZM2WW3oI+A6Zt2RfpnNNSTXprXHfT8h206RBWiz5f/BtiJsz5SOf3WJM
         e4sDtJlgWquI8itb3VRihkq2pTkDpT6xcv6J7SJmKos784VnL7OL8HH9SrzX/+Ek+D3q
         88yZkXMoMUWQqnW+YaAtXGP60mHnaG0Cq4Ne708BBoT/Yfr9Q5mFOum4q9w9RDVIr/WC
         7Bp8GhRF8Xasr0uWjePM+ozTl/DQHyafc5z3f8CUvnrGz3mSmSpbRRruqKSqQJAGyRbc
         h/YkDRlwswxTAg/pDr5wgWtFnvdjnz8KWcUrLa3PT5yfGzCZmlcH58g0V3ubVmOV6DIs
         cW+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=KtOofCLD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor12244491plr.18.2019.04.01.02.28.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 02:28:10 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=KtOofCLD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yL+xq3Ds6cL7Gguw/EB/2F6pIH1ydFIOdF5y0szr1n0=;
        b=KtOofCLDYyY2zckiK40Uu/S+3TmisSGqAVMVieVeAcoMW+gQm5SiARDL3oD7XHkZ8g
         gKYSMZjLM4PUz8t69VKTbNImbq1xgO3om4LZs4e9uCpU7s9JS9UyLbmUfX41eNIkBaW6
         vS2Mu7zRpLR/76htCge2edQkvYF4U7RG1z4VS+xP1qVGmXLVX7sjN1VNz1LBll1Jm/P6
         LY70dJwZNafH/Xxj5bRqj6f8xlgFghtt3aShZ3KjudKPtVN6mgQnEcMpjn7TI4K2HzRM
         3ljOtjapW7MlR4TfCkHkG09EC8ezNcfRN50/lGZoJM2wHgXAO+4lOm2vMuLFzZ8LS3J6
         4TKg==
X-Google-Smtp-Source: APXvYqwDA8HA0Nle/hgGNevz47bn9DepnGHLmNGo7BEI1Ph925+JMzZg4DYuYjGQLHsDmRQGhd3wjw==
X-Received: by 2002:a17:902:d24:: with SMTP id 33mr62853503plu.246.1554110890182;
        Mon, 01 Apr 2019 02:28:10 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id r8sm12995955pfd.8.2019.04.01.02.28.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 02:28:09 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id A862F30C74D; Mon,  1 Apr 2019 12:18:58 +0300 (+03)
Date: Mon, 1 Apr 2019 12:18:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>, Huang Ying <ying.huang@intel.com>,
	linux-mm@kvack.org
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190401091858.s7clitbvf46nomjm@kshutemo-mobl1>
References: <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
 <20190329195941.GW10344@bombadil.infradead.org>
 <1553894734.26196.30.camel@lca.pw>
 <20190330030431.GX10344@bombadil.infradead.org>
 <20190330141052.GZ10344@bombadil.infradead.org>
 <20190331032326.GA10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190331032326.GA10344@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 30, 2019 at 08:23:26PM -0700, Matthew Wilcox wrote:
> On Sat, Mar 30, 2019 at 07:10:52AM -0700, Matthew Wilcox wrote:
> > On Fri, Mar 29, 2019 at 08:04:32PM -0700, Matthew Wilcox wrote:
> > > Excellent!  I'm not comfortable with the rule that you have to be holding
> > > the i_pages lock in order to call find_get_page() on a swap address_space.
> > > How does this look to the various smart people who know far more about the
> > > MM than I do?
> > > 
> > > The idea is to ensure that if this race does happen, the page will be
> > > handled the same way as a pagecache page.  If __delete_from_swap_cache()
> > > can be called while the page is still part of a VMA, then this patch
> > > will break page_to_pgoff().  But I don't think that can happen ... ?
> > 
> > Oh, blah, that can totally happen.  reuse_swap_page() calls
> > delete_from_swap_cache().  Need a new plan.
> 
> I don't see a good solution here that doesn't involve withdrawing this
> patch and starting over.  Bad solutions:
> 
>  - Take the i_pages lock around each page lookup call in the swap code
>    (not just the one you found; there are others like mc_handle_swap_pte()
>    in memcontrol.c)
>  - Call synchronize_rcu() in __delete_from_swap_cache()
>  - Swap the roles of ->index and ->private for swap pages, and then don't
>    clear ->index when deleting a page from the swap cache
> 
> The first two would be slow and non-scalable.  The third is still prone
> to a race where the page is looked up on one CPU, while another CPU
> removes it from one swap file then moves it to a different location,
> potentially in a different swap file.  Hard to hit, but not a race we
> want to introduce.
> 
> I believe that the swap code actually never wants to see subpages.  So if
> we start again, introducing APIs (eg find_get_head()) which return the
> head page, then convert the swap code over to use those APIs, we don't
> need to solve the problem of finding the subpage of a swap page while
> not holding the page lock.
> 
> I'm obviously reluctant to withdraw the patch, but I don't see a better
> option.  Your testing has revealed a problem that needs a deeper solution
> than just adding a fix patch.

Hm. Isn't the problem with VM_BUGs themself? I mean find_subpage()
produces right result (or am I wrong here?), but VM_BUGs flags it as wrong.

Maybe we should relax the VM_BUGs?

-- 
 Kirill A. Shutemov

