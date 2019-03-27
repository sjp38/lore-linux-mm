Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 426C1C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:17:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07FD02146F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:17:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07FD02146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A67C6B026D; Wed, 27 Mar 2019 09:17:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 855266B026E; Wed, 27 Mar 2019 09:17:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 744916B026F; Wed, 27 Mar 2019 09:17:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 260816B026D
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 09:17:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c41so6673651edb.7
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:17:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KT07iBX+ePSBrgJUe53UkDljHeSdN4ZMov65J4PrubI=;
        b=smEcaIq4ZVX4yPbAIujYRTEbFm8kkOryyW0ZwRB2QC2+ezPsNrPXei0pzv9R4lXxum
         /7Um2cpdETujwg+9Wsnn3cIHYM/OpDBiFKee5tGkwxklOAamGGvrrL+TGFwEylxOkW6s
         cGdvNAOIzf1a35zzgd5VQTQnW2uNlZzwTJor6ChQhXgEui5KzQEn9ySs9y3ygucTuSpK
         bozCTBRxVd6AR7XcsYgoPHRjLPsFg3//Ags6VZUK8LkhkS0uAgTuaiKJ6yIUfAB7VLwI
         WhHV1DE4wdOKOZXkCVyRFA/0oo5jsfLX4t80Xr6mStyUknuFOQtscgVrWEmgBwFyCFTm
         GtHg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWXOZWaM1HfWLJWIANlMTUCXHbu4YPPMQlQKw06lswRoQpAx+VN
	y//QcMri/10dhDAUwsLew4XPsPTmEjXPE6TrohUVUc5wigGcfVLaKf1CAH4dLNl/ktX2o9AEAcV
	mVkDVHuHmNz+jvwpsscexnc4ZctFDp3QelinadWeCpfqv1j4ym1uiD48sR+EY3jQ=
X-Received: by 2002:a50:92da:: with SMTP id l26mr24732462eda.82.1553692641644;
        Wed, 27 Mar 2019 06:17:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoYNUpQkV2TJMNYkUfdGGb9tn041tdex4LMAKJCfE23duzGOOieB4y8zPtOxn00rwXu/rf
X-Received: by 2002:a50:92da:: with SMTP id l26mr24732417eda.82.1553692640650;
        Wed, 27 Mar 2019 06:17:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553692640; cv=none;
        d=google.com; s=arc-20160816;
        b=t493V8+z2os+3oNRE4ISSBwbdvJth/TO5PoeA7o6/YZCA+hnP8j/j6d2iEj48bvQuF
         UCoz5jABsjIW42gJZliqqzAbQE+NRMSt2TcSXqQooXKYPT519c/xUUwxJ093CEOYh68K
         2I+a1VsU3wBBFceU7H0/nhHPuJqZ2kRsRt47DUKFX4xbJjLj9uYA4M2XZkaIk9kbwuc3
         VGiwc9pmcTGZOiezoJ7AuCBEv1KGcahB6Zgik+Tc/ZQd80OVx73M13sAyLQNSRAQFHJT
         xGE/COBJCF4XEBnNZJBPAxK71Ik/8nkM3UYArT6E6ISAjq15rpFV2ATGg3DtmnjFUKdZ
         5Hog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KT07iBX+ePSBrgJUe53UkDljHeSdN4ZMov65J4PrubI=;
        b=trYZsVgdFcNMhSAfRZ5ogOkgASkIskYojHr/oMQHoIrLKhcKJBEmblxOyH/+5xF+IE
         yY8HRpc8LbuH0llhJ20Jp3pgm9b+EaZOdP9G2frWRKcwCp+Q9gGCgjwsiIqNuWi68vZr
         CAFE/c3YzrcGnNT9NQvUPRrzhE8ju75n8o+aXucYeGHFU14HskOJpIfXe85AY2JhBxjD
         Sni4n4StcILrgyTa5HsRYBSZZDJQVuJAnbfKIvjhR8PVroPA2Upj/KILrEGeOKqT8aio
         n57gUTYNkVXHHIimUIoOx57qQueufl1TlbroEjSIoVlglSSXzdJZtp0MDOScP5oLJlq8
         8brQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si855305ejf.139.2019.03.27.06.17.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 06:17:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EF780AFE4;
	Wed, 27 Mar 2019 13:17:19 +0000 (UTC)
Date: Wed, 27 Mar 2019 14:17:18 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, cl@linux.com,
	willy@infradead.org, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190327131718.GJ11927@dhcp22.suse.cz>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <651bd879-c8c0-b162-fee7-1e523904b14e@lca.pw>
 <20190327114458.GF11927@dhcp22.suse.cz>
 <68cff59d-2b0e-5a7b-bca9-36784522059b@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <68cff59d-2b0e-5a7b-bca9-36784522059b@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-03-19 09:05:31, Qian Cai wrote:
> On 3/27/19 7:44 AM, Michal Hocko wrote> What? Normal spin lock implementation
> doesn't disable interrupts. So
> > either I misunderstand what you are saying or you seem to be confused.
> > the thing is that in_atomic relies on preempt_count to work properly and
> > if you have CONFIG_PREEMPT_COUNT=n then you simply never know whether
> > preemption is disabled so you do not know that a spin_lock is held.
> > irqs_disabled on the other hand checks whether arch specific flag for
> > IRQs handling is set (or cleared). So you would only catch irq safe spin
> > locks with the above check.
> 
> Exactly, because kmemleak_alloc() is only called in a few call sites, slab
> allocation, neigh_hash_alloc(), alloc_page_ext(), sg_kmalloc(),
> early_amd_iommu_init() and blk_mq_alloc_rqs(), my review does not yield any of
> those holding irq unsafe spinlocks.

I do not understand. What about a regular kmalloc(GFP_NOWAIT) callers with a simple
spinlock held?

-- 
Michal Hocko
SUSE Labs

