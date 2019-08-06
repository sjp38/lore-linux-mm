Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D2A2C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:41:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51C582173B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:41:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51C582173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAFC26B0003; Tue,  6 Aug 2019 03:41:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E60C36B0005; Tue,  6 Aug 2019 03:41:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D50A66B0006; Tue,  6 Aug 2019 03:41:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 851606B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:41:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so53256662edu.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:41:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Rwqq0N+iqFpbvPvXRrY5mCcfVueSkIdTfN0iny7azi4=;
        b=XlGJJvcWdoFn13UJaWTt4OYv9s70dZMqSpb0uHXmnA0hPSPnv+n6cPO55A6UUaTuFi
         7lk6Qs+0pH+QVbyxy0pKEZ498neGTOtI3QpJPIgL9Pz6YCTV0hBitBEu+mC9Rgz/AMEy
         we6uuEynzH/rLxuvKV4ZaAG8gCYVAGcloAy5Vc5clKdBa4Jw8qhCJ1kgZ6X+Do85Omdd
         U0DHk9JACGpgjCSnxaq1EchidMI74bYJ7AyemVMlXsRj4OllSt4rkcEj973pklqe+8Ds
         QcZtnOTBtuIVcLr8PdybyMFvvd/I0vvNEIsLgoc1sendr1sV5CLSuzo5tMyuZl58Vswx
         JVzA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUf6UylZ8IHUlC67/ip/kEPM1FFkJW+f/oJMwDZysg5OIchripB
	55UyIOhCZ5dVm501EvJ7IFx2OjQ77g8SyPgr1jkFXTKsOQVNoyTiaLxMtcPYJSeFryIwTDI5/Rl
	+mTfySPb2YoXmOLQQK2J0/f0VyYvMNpk0skpckJusIc1U7sayG+qoxmTf0lFRpiA=
X-Received: by 2002:a17:906:25c5:: with SMTP id n5mr1770000ejb.195.1565077300113;
        Tue, 06 Aug 2019 00:41:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8cwxeEMJfiSfgBBO35VWIfrCRRIvrW7vblqt7ssaqbxCKk9atctFbyOotRfZ6QIgcjghr
X-Received: by 2002:a17:906:25c5:: with SMTP id n5mr1769967ejb.195.1565077299489;
        Tue, 06 Aug 2019 00:41:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565077299; cv=none;
        d=google.com; s=arc-20160816;
        b=Chj3hCMJY5vbXA08UGjW0sVtMXnuftIXJDQyRrby0Mc29LoYofdyNYjF2F4joMm943
         wvh+fHhziB3v6iizZ5nnR1Br5TN0ec40mDrinf8zq72mlSyf7BtEPurixVD6uLm6Igdi
         NWl4c/M9vw7+xV4w1idHYewOTkcXwlycPMtuLywAOV2K6+6Eve9Eps6VGJQIWBArbCwI
         Bcf5BdOhrWUu9u9nPFnwhXvw19I12ObEmoaQqyRMPyg6Ztz9FEdF6R74wgJ9hOMOSl8F
         QybeCE0hzZEgTw9TjTg7LrbE4aC5SzWRyUXZAzucnH+XYFhS1w23m7NiXAgUQx2uM9LT
         xhxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Rwqq0N+iqFpbvPvXRrY5mCcfVueSkIdTfN0iny7azi4=;
        b=mO/m7NJ4+7YsXVJaVjIZ/J8Fe+7yRMKt5JThczyfYFyFjc2vqVjIG4MT3DqdKlta/i
         5d+mgNkkR27XI7PZauf9TLhcRT3R9hdlja8ZdiQDXP4Qe5pm7EC0LGJBGaZVtzjDtEuW
         gksiGxC67RNi+AmFx5n2FqpM5WEwccFl3bRnORBAf0hbRdyh5SIHJ3w6cEYRnxc4CCBK
         Mye4mr6VSfJMMC0PvmmfyD0Q0rPm7py+GrSKtDmq+i8ECLJzw2Ig9ZfxVVp/yg7A3bnx
         q3MccaSqmu0F/4vasOJUq0cDoOVrM/YpxzPDCDplQivxspX1CKPkWqNnxIiQGEfnNElq
         b6Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w22si31667672edd.319.2019.08.06.00.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:41:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A961BAC3F;
	Tue,  6 Aug 2019 07:41:38 +0000 (UTC)
Date: Tue, 6 Aug 2019 09:41:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806074137.GE11812@dhcp22.suse.cz>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806073525.GC11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 09:35:25, Michal Hocko wrote:
> On Tue 06-08-19 03:19:00, Yafang Shao wrote:
> > In the node reclaim, may_shrinkslab is 0 by default,
> > hence shrink_slab will never be performed in it.
> > While shrik_slab should be performed if the relcaimable slab is over
> > min slab limit.
> > 
> > Add scan_control::no_pagecache so shrink_node can decide to reclaim page
> > cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
> > shrink_node will do at least one of the two because otherwise node_reclaim
> > returns early.
> > 
> > __node_reclaim can detect when enough slab has been reclaimed because
> > sc.reclaim_state.reclaimed_slab will tell us how many pages are
> > reclaimed in shrink slab.
> > 
> > This issue is very easy to produce, first you continuously cat a random
> > non-exist file to produce more and more dentry, then you read big file
> > to produce page cache. And finally you will find that the denty will
> > never be shrunk in node reclaim (they can only be shrunk in kswapd until
> > the watermark is reached).
> > 
> > Regarding vm.zone_reclaim_mode, we always set it to zero to disable node
> > reclaim. Someone may prefer to enable it if their different workloads work
> > on different nodes.
> 
> Considering that this is a long term behavior of a rarely used node
> reclaim I would rather not touch it unless some _real_ workload suffers
> from this behavior. Or is there any reason to fix this even though there
> is no evidence of real workloads suffering from the current behavior?

I have only now noticed that you have added
Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")

could you be more specific how that commit introduced a bug in the node
reclaim? It has introduced may_shrink_slab but the direct reclaim seems
to set it to 1.
-- 
Michal Hocko
SUSE Labs

