Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B78A5C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82B2420B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:25:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82B2420B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 191D06B0278; Tue,  6 Aug 2019 05:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11BC66B027A; Tue,  6 Aug 2019 05:25:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25A46B027B; Tue,  6 Aug 2019 05:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3CBE6B0278
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:25:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so53460983ede.0
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Mcw9OsXFQFdHCeuRMyhRyzWkzPQMy/2C73Y6vvp0Sdc=;
        b=JmRf0VKi+tegzrVTN39T/pJkcMrwZorAvoTCOPiErpPjEfhvDyufXLutvCabCtJZYU
         BGxThw70Ioic+DQYy2o9xfLKipaTJ7CJRBzw9wE1DhGmfNB6XJViFpvKXFVvxfhGxbHd
         1/h/9/ENg7et8oA6YGnZBAu68G4osTLNOkemXBwqEu2r2hYnqitz5rfE7n2NU16PRLPq
         axv0FLoxQJh3TuURNNARDJEyD6s8qHlWV0Q1YyIYgaP8GBelhtJ2vq2iiIQZPN13is89
         aIFroxoA7VzNPZxh++rH4UcQFQLFemMRcughUEWIlYjK9tGE0mAj4r+T4RQtPTnZVB++
         XETQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVVgBR+MtFzFtzMgBPLgHpbE/10qwdSleh9wtqyGIi4moAvQ5kO
	N9xX34EyzCN+hEb80Y2uCL6/moAvoWSB8cxrVqwYoGZ261XnvkWfDP0aQ1cmxfDR/vSJNffHojo
	DENt92iK+rJBl4Lf8V/So7hWBi4dkBzlEpvmJ6fbS/Ed2GHS6XVeTwxnQktRnxFU=
X-Received: by 2002:a50:f5fc:: with SMTP id x57mr2712382edm.105.1565083535208;
        Tue, 06 Aug 2019 02:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTRgoa6ML8cEGOPL4tlcHnfY4krIZBAl07tK/NeTFUueDemqxY/fYdurAajqS1d+OWuTYM
X-Received: by 2002:a50:f5fc:: with SMTP id x57mr2712346edm.105.1565083534491;
        Tue, 06 Aug 2019 02:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565083534; cv=none;
        d=google.com; s=arc-20160816;
        b=Top7yc5f0lI61s78jn49tfDMWVkxgnXtRMuj/7p/V8dfiADnRrk8AeDU60FLIBEhvC
         aXlLUIUOc5hXT5/53dpXFLyWtQ5wq+IJ3Ca0LXJrCeuhT7F5cGOz/TRMq0TPqpYLI7iC
         BR0v7OSGo+fcivXaZ7sVrlULbkCJnGa08RnvGyqRFqpI6qCf8bYMglvIY1+KK98UCuzz
         C4XePDSutM4aWP5OG3GU1pud1bIeQWW9r9HrMu3PPUQmqWmjH+kRrcQNJL4a1aRx5GZz
         xaPIuHNAE0G5ObaAScNf7rDoA4rwN1oXHeXUYkG0D4wjIvZevo3b+2+3fvCPxf+4YKTm
         fMPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Mcw9OsXFQFdHCeuRMyhRyzWkzPQMy/2C73Y6vvp0Sdc=;
        b=I7vBTbTm1IZHuNnXCvli0QYkPEQe03duXZb6oz8peaHGzcmotVTz7MkyTbZ5KvUdBr
         axX1srL0REJ0pXgzff2Hr34eBLHEAxXQT3xwKZQ4EZ27rPipMfJJ9ADdsVByKD4QaNwy
         XMCQe6RA+/M+D2eCRyVW8a1dB1HcH4ePBUqs+15vP5N2z1fBqBJRxwCiisWrMiG9xA5P
         JHRUSodf8h4xRrL3V7m1AE6UZJ2PsbcI1ODvTuxTnUBF/6u3K7WNxtJEvAo198QUDlUh
         /ZFvO1ufiaIo2YurddpW5p33JwusERZrDIXxkp+SVmrGUsDP4vqPc23hlq86Mj7l+rMf
         LDMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z9si30219088edz.403.2019.08.06.02.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 02:25:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 89CECAE6F;
	Tue,  6 Aug 2019 09:25:33 +0000 (UTC)
Date: Tue, 6 Aug 2019 11:25:31 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806092531.GN11812@dhcp22.suse.cz>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > As you said, the direct reclaim path set it to 1, but the
> > > __node_reclaim() forgot to process may_shrink_slab.
> >
> > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > get back to the original behavior by setting may_shrink_slab in that
> > path as well?
> 
> You mean do it as the commit 0ff38490c836 did  before ?
> I haven't check in which commit the shrink_slab() is removed from

What I've had in mind was essentially this:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7889f583ced9..8011288a80e2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
 		.reclaim_idx = gfp_zone(gfp_mask),
+		.may_shrinkslab = 1;
 	};
 
 	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,

shrink_node path already does shrink slab when the flag allows that. In
other words get us back to before 1c30844d2dfe because that has clearly
changed the long term node reclaim behavior just recently.
-- 
Michal Hocko
SUSE Labs

