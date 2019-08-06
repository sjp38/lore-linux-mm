Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FFABC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:15:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C82CD20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:15:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C82CD20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7331D6B0010; Tue,  6 Aug 2019 07:15:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E2EB6B0266; Tue,  6 Aug 2019 07:15:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AACB6B0269; Tue,  6 Aug 2019 07:15:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2816B0010
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:15:02 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i6so41921433wre.1
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:15:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JXREWNjRkHdGvBX35rCser8QFf3UouELVLmMXS31nd8=;
        b=AbX7xRlaNFHsKmtzVQ0pekIZI+nkGJNWG2I6VrRBcfasBYb0NsdppGX0RYrYlVBXqL
         8oPJ8/DmvfAh5tgbj/aMO086bQXH0vVNSEvew+yrv9U7DW8TOQx9026mzSq9gVL5OjOA
         HL5FBX07BHEWWI25iMlQqfEV1rOwi8AlEoT+O55S92TI385AW2sKoVbs2hpIGX/F1Tbo
         paIe36MSQSOgQIaR7NZOyKAt0jlNkVFjjMtWTfRjoD62Z5ZOUPgKU5cGbbWCUGa977JP
         FLJQlQ1hGCKmwE4NDTZcqsGP0KGg+LlzcDV2ii7oPN2tx2hdW7HCf+S4TJbTZUbgEYGS
         x4FQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.253 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXIqEud5Gadt3eqzxN+gXvWrVSvIKbi9zYZTmBGvUbC9W2+MFbx
	kqFoUm8A4bqOYnd9gdFvIlZKc4/FMWoEdu2T7LUs24KwRtRnmNo7eu7h/Px02haip6WBdpuU53w
	sk7qC15FauAtZoImwVSPmSke80I/H5PfqEW+wBddKiHOiLkvskXTyeAzNVU/0rN/pzw==
X-Received: by 2002:a5d:4492:: with SMTP id j18mr1725133wrq.53.1565090101614;
        Tue, 06 Aug 2019 04:15:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw289PGdZAaKw7netOcE5OS0r6+sww22i0RwL1ubv6qiNVUeDuv1Bbd768RPA6LaTs7f/B0
X-Received: by 2002:a5d:4492:: with SMTP id j18mr1725053wrq.53.1565090100843;
        Tue, 06 Aug 2019 04:15:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565090100; cv=none;
        d=google.com; s=arc-20160816;
        b=mYDVIdXeuMEWri0YDp9jMQzrR8n19DuJTTbLufjswd+N+x6qhm/e+zGz4BNvJtx02A
         Hl6nkNksvrhrSId2b7GATLrVYolsLlhDj1h50rV/FFk4zy66j+V7p5iWNjHG5qv61bOI
         jrToHu7uNLbeatE5lGW5h3RN+crKV2Azmn8IF5wFkyLEVHNUHr0yThy+QMDS2Mj1MM9/
         TYrZs8HpdjWbTglYNZBF/5mrG4x/hdlFR5OqTVRgb4Qbe0dwxIMGs8syLe+XOPH3wOd+
         9/4LYHGI5q8mRehsrqGdpoNOAi6La0FEOzTA7JB32Q55QQLlOIAL42Ti3qHTj6yFNKTq
         Vstw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JXREWNjRkHdGvBX35rCser8QFf3UouELVLmMXS31nd8=;
        b=azEfNQOG5gXhw7USSNTCd3+mAWTiVCMCp44qHJHiEqb14ZCyJ29xdx8KR/OObPzAUs
         GJWgcBsEau6rXmT7/B6GDSXAfUhSVb0V0TUc5i8XsfDuN+ztPgK1cvCiQ2UTWWOEwPpC
         bQTx2EiO0IvUTp5YQ1myso+bWiM0+axoXSmua3E6qpZvks3sJJV4VuVylipNhAnLhx1M
         fgv2BmatrexeN75D655qYmN1i75mGTJSv9a2ekiWv1734uER7KJxO6QTEutqia+dAXMb
         dmO9zlGnE4OXOSsJD5eGmdKJvbKcIgL5N3YmbaZjXL9Q9esszrZO86DVojsn4yvSaCV1
         wdWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.253 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp34.blacknight.com (outbound-smtp34.blacknight.com. [46.22.139.253])
        by mx.google.com with ESMTPS id l15si74937393wrm.327.2019.08.06.04.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 04:15:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.253 as permitted sender) client-ip=46.22.139.253;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.253 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.10])
	by outbound-smtp34.blacknight.com (Postfix) with ESMTPS id 76A809FA
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:15:00 +0100 (IST)
Received: (qmail 6100 invoked from network); 6 Aug 2019 11:15:00 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 6 Aug 2019 11:15:00 -0000
Date: Tue, 6 Aug 2019 12:14:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806111459.GH2739@techsingularity.net>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
 <CALOAHbAzRC9m8bw8ounK5GF2Ss-yxvzAvRw10HNj-Y78iEx2Qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALOAHbAzRC9m8bw8ounK5GF2Ss-yxvzAvRw10HNj-Y78iEx2Qg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 05:32:54PM +0800, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 5:25 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > >
> > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > get back to the original behavior by setting may_shrink_slab in that
> > > > path as well?
> > >
> > > You mean do it as the commit 0ff38490c836 did  before ?
> > > I haven't check in which commit the shrink_slab() is removed from
> >
> > What I've had in mind was essentially this:
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 7889f583ced9..8011288a80e2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> >                 .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> >                 .may_swap = 1,
> >                 .reclaim_idx = gfp_zone(gfp_mask),
> > +               .may_shrinkslab = 1;
> >         };
> >
> >         trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> >
> > shrink_node path already does shrink slab when the flag allows that. In
> > other words get us back to before 1c30844d2dfe because that has clearly
> > changed the long term node reclaim behavior just recently.
> > --
> 
> If we do it like this, then vm.min_slab_ratio will not take effect if
> there're enough relcaimable page cache.
> Seems there're bugs in the original behavior as well.
> 

Typically that would be done as a separate patch with a standalone
justification for it. The first patch should simply restore expected
behaviour with a Fixes: tag noting that the change in behaviour was
unintentional.

-- 
Mel Gorman
SUSE Labs

