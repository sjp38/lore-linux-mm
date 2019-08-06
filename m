Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF6ACC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C75FB20717
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:50:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C75FB20717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 613116B0003; Tue,  6 Aug 2019 05:50:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3BA6B0266; Tue,  6 Aug 2019 05:50:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D8E46B0269; Tue,  6 Aug 2019 05:50:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 064126B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:50:32 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f189so19971636wme.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:50:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P7nPpXzGsiVH5tkXU0x+dWDpR9XRTM1TIEwBs3uUpfw=;
        b=H0i8u8E4svdYgyPDllo6ZHHdn8oEF9POeViIOyR6K4KIpyKwv3ZeNqq06n4C7gEwDO
         BXNsjo2wGAIhS0zyfsHt+hEupkRMvHSNVo6x5j3ds87c2W2HAgKRijUl9rcVYGw5YT0U
         PWBam59aYKdpWl/TBkbMMobfocfJLZHllXr8Cvymq4NRL6oJy0BsK2B0/iaD5lLTVr6c
         t3NjvdGnLqxiukEaarGTu9O2dIaMcO8/8aAihpQgn7NxeulXXK6rELNFM8YbmEjLqIiv
         CZbRRYHOjI9U7vtkwoQ9y3OWtBmLN8cNdr3xpx8IOIsPbVJA8FiZ4bv1e0vvfe9C6BHF
         mFlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.61 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXfgOSFl+FL5JpRvS0DCAFTvGOQ7Wrhoj6+MskAo4d30bfmBpOt
	LMQDb7C4J5xD6A9HUyzmLSOAbAs1VHiahoWicjr6ufUY5fYN92iquEukH0PnEdFwudzrHtS34cD
	m4jghndl2D1q14ok+ijaFA9p1piihmaoMti1t0B/+gbyXPJHFrKRWUaB6lAFgVTxbVA==
X-Received: by 2002:a05:600c:212:: with SMTP id 18mr3677146wmi.88.1565085031422;
        Tue, 06 Aug 2019 02:50:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxffbULI9hkAb2p8mReE24u44oL/cqI4Ap7XzeVbMj7J7ddToTWdVVW462vU6L8Ofm7wLnx
X-Received: by 2002:a05:600c:212:: with SMTP id 18mr3677084wmi.88.1565085030711;
        Tue, 06 Aug 2019 02:50:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565085030; cv=none;
        d=google.com; s=arc-20160816;
        b=Blov2qZ9s3BCdU0otVEeXFodj3Ars/2vV75gthWRSmjjCI/tK8UMV2+VI0ZKVfum3S
         F26bsLbKPGCTg2blSPSjaydUhlbQvlKxNnTzuIN4KS6s+qX67Zniue1b7DonJS9q3wjt
         gPhMPkCzvV699sIMJBU3QCfC/YsP2KcSkCXHxXCVhLK3Fn4qOrhgloNl76WS4I92YQBR
         vVAzL/mmf/VOYvh2WcAXs6YMsiQVzMAlRsxvcWm1411jAZy0veDCC+szYx2gOoLmmCht
         IfONtNSaLDhSAREEeCEKufAOWuCjMWqY2Z13mPGHkhjTDZhj7rWkilyYecaCyjjEvOGh
         1R1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P7nPpXzGsiVH5tkXU0x+dWDpR9XRTM1TIEwBs3uUpfw=;
        b=povsVb26oY950DxbRr2fCJ1JHZ/wK1h+oiZ3fWiKjXApWrCuyXhuQ0XMbgO0b6Vkjb
         eKZOFJiXZHmzvWSdqW2jDF/abLLMT1Fp69mVfpDgeRLUPJEmJ79ipGfzWDEVOXM94fBO
         rpRcgv62moWyHIcFKOMkpiy8TwuOx2otaUzyFthEYp8szv3Cs1O/lfn9WWOSr9jGB3De
         xyoHqjBBsz73X/hRQ4dyIWfvcCjwFDIlENzLTjJQneKjnCKL3s3LvRsjaOyRp40dRy0R
         6Mu+U09n6zvmDMRTqyM4SJkHzlAqHNxiEtErJnyLCzJ43itL+D2YiPty66GGK0xzs7V6
         nT2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.61 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp30.blacknight.com (outbound-smtp30.blacknight.com. [81.17.249.61])
        by mx.google.com with ESMTPS id a4si914207wro.235.2019.08.06.02.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 02:50:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.61 as permitted sender) client-ip=81.17.249.61;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.61 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.26])
	by outbound-smtp30.blacknight.com (Postfix) with ESMTPS id 5DAB6D034E
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:50:30 +0100 (IST)
Received: (qmail 4825 invoked from network); 6 Aug 2019 09:50:30 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 6 Aug 2019 09:50:30 -0000
Date: Tue, 6 Aug 2019 10:50:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yafang Shao <laoar.shao@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806095028.GG2739@techsingularity.net>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190806092531.GN11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:25:31AM +0200, Michal Hocko wrote:
> On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > > As you said, the direct reclaim path set it to 1, but the
> > > > __node_reclaim() forgot to process may_shrink_slab.
> > >
> > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > get back to the original behavior by setting may_shrink_slab in that
> > > path as well?
> > 
> > You mean do it as the commit 0ff38490c836 did  before ?
> > I haven't check in which commit the shrink_slab() is removed from
> 
> What I've had in mind was essentially this:
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7889f583ced9..8011288a80e2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
>  		.may_swap = 1,
>  		.reclaim_idx = gfp_zone(gfp_mask),
> +		.may_shrinkslab = 1;
>  	};
>  
>  	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> 
> shrink_node path already does shrink slab when the flag allows that. In
> other words get us back to before 1c30844d2dfe because that has clearly
> changed the long term node reclaim behavior just recently.

I'd be fine with this change. It was not intentional to significantly
change the behaviour of node reclaim in that patch.

-- 
Mel Gorman
SUSE Labs

