Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 884D6C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 12:13:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53564214C6
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 12:13:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53564214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D13EA6B0003; Thu,  8 Aug 2019 08:13:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC4EF6B0006; Thu,  8 Aug 2019 08:13:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8E106B0007; Thu,  8 Aug 2019 08:13:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2C46B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 08:13:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so58099509edr.8
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 05:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mu9wV8m5ld3iEUF8vwSGndeMXfJ5pVPDM/hYYUit6BU=;
        b=baC+o7PBW+m12q9uOmMUex5AjGLi38ptceEBX+G0SkDlbWuLgrfygpqquHP0PeRPA8
         PuSEYULUk6zYdRRoen4KYIJBE0Qiu5DeqgGa8VDNQJx3uUKZ2N2rdsrc0EX/dnpnaa30
         K09bUVOpXjkcfNIb1vvBtYt9iBrm0R6k+YJDa15wej+enclmT5AQ0Qil2f3V8f8iwzhy
         DA9Pl7NWR1Y4fRTam2efSBKYwi3ZPowau3h37jgIg9PJaoABCRf0fUgysVirsvLO/vKG
         NEcdi3soGQ/si+d/sgxoJX2nObos5MDvTBQYKZHJxkkAgvlsZTJUiz0Psd8wKg/HPOkz
         xHkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWd9SWL99uLBc3cQnePLcWBTxsvwxmf3NLYQM6Okc+kVOo4weGY
	VTIz/GYEXKF7Hau7cOQp5MRQb65r3bomZ0Y71YMOPuniUnPBWTBLkTvPKNG+hJxFZvTAXMBCsD8
	dudu80sdAf1T0FUIb5K06QfwmFExcTfRfFjrgtnKr+g01hJ6/rEG+5WWnrILXqH/XGQ==
X-Received: by 2002:a50:a53a:: with SMTP id y55mr15667773edb.147.1565266391977;
        Thu, 08 Aug 2019 05:13:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXCRTWx3wfsZiJysv2DB5J0W/cYmyXXRb58hYvUVNsMpc53RMGPi6kb1g9ulHVkDzekfu5
X-Received: by 2002:a50:a53a:: with SMTP id y55mr15667680edb.147.1565266391072;
        Thu, 08 Aug 2019 05:13:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565266391; cv=none;
        d=google.com; s=arc-20160816;
        b=eNggvSJjkYjIZMuHTEuNgfIsv9tq2nlCbhCP0Lwp+Dcl/aOSX10k3AjdSb23TBWj2V
         WX/IhemZFoXppLz7jlR846RBEgGTmYkj4rdRClXfrahwdbAmG8vIDdp9pYWnJNQUBASC
         2g4jgKXFaAc2SGtEcQCDWeMNy+IZR8aQX2ws7bQa6IRbC36tX7gZXRR6cWdh1SIroIAH
         YWlDYyoFcmnWeBzEDkYicQeHZE4ejLoeuenFiMbgP3YXIv0ul2dcEfXzaiOSJsbI5dr1
         hO9iYxeuXdBuol658tJtLyiTXM6rm/EZy0S3TWzjq2g68QBkqddMj/BfCI3Tl23AjpBX
         y7EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mu9wV8m5ld3iEUF8vwSGndeMXfJ5pVPDM/hYYUit6BU=;
        b=MZQyn+75GiHgXYbFcQpM4CF0dKccC3zSHlEngdZKV0f5czr4vpfuCEKWYj3nVtsUCf
         tRz6o1PfB/otaCFMf/43pY/ZzzF0mdvqdpV9NwUr/c6BjQoABvr7c0fIXs9iAwksjpXu
         6gF2ZBX3Z/F/g3CGB5rYTgMjT5y5cGGLDwGj72Ut1RrXEOFHO0xtrbiQWAvP6tr13Jjq
         VvaJCgXyeH3I6iPpZKocFcAtRwsIgBw2xUaIUjQ3YTzAFHZTGiH3gq2o7BBSdiSKqZwK
         Te8K2O1N4JThhs7iwrDd3Elu7biSpWIAu63BiHJzaLYtuspkP4RRYkGcFsG0EhyT+PuP
         snIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si31400753ejn.27.2019.08.08.05.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 05:13:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5D4FDAF3F;
	Thu,  8 Aug 2019 12:13:10 +0000 (UTC)
Date: Thu, 8 Aug 2019 14:13:09 +0200
From: Michal Hocko <mhocko@suse.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/mmn: prevent unpaired invalidate_start and
 invalidate_end with non-blocking
Message-ID: <20190808121309.GD18351@dhcp22.suse.cz>
References: <20190807191627.GA3008@ziepe.ca>
 <20190808081827.GB18351@dhcp22.suse.cz>
 <20190808120402.GA1975@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808120402.GA1975@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 12:04:07, Jason Gunthorpe wrote:
> On Thu, Aug 08, 2019 at 10:18:27AM +0200, Michal Hocko wrote:
> > On Wed 07-08-19 19:16:32, Jason Gunthorpe wrote:
> > > Many users of the mmu_notifier invalidate_range callbacks maintain
> > > locking/counters/etc on a paired basis and have long expected that
> > > invalidate_range start/end are always paired.
> > > 
> > > The recent change to add non-blocking notifiers breaks this assumption
> > > when multiple notifiers are present in the list as an EAGAIN return from a
> > > later notifier causes all earlier notifiers to get their
> > > invalidate_range_end() skipped.
> > > 
> > > During the development of non-blocking each user was audited to be sure
> > > they can skip their invalidate_range_end() if their start returns -EAGAIN,
> > > so the only place that has a problem is when there are multiple
> > > subscriptions.
> > > 
> > > Due to the RCU locking we can't reliably generate a subset of the linked
> > > list representing the notifiers already called, and generate an
> > > invalidate_range_end() pairing.
> > > 
> > > Rather than design an elaborate fix, for now, just block non-blocking
> > > requests early on if there are multiple subscriptions.
> > 
> > Which means that the oom path cannot really release any memory for
> > ranges covered by these notifiers which is really unfortunate because
> > that might cover a lot of memory. Especially when the particular range
> > might not be tracked at all, right?
> 
> Yes, it is a very big hammer to avoid a bug where the locking schemes
> get corrupted and the impacted drivers deadlock.
> 
> If you really don't like it then we have to push ahead on either an
> rcu-safe undo algorithm or some locking thing. I've been looking at
> the locking thing, so we can wait a bit more and see. 

Well, I do not like it but I understand that an over reaction for OOM is
much less of a pain than a deadlock or similar misbehavior. So go ahead
with this as a stop gap with Cc: stable but please let's do not stop
there and let's come up with something of a less hamery kind.

That being said, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
with a printk_once to explain what is going on and a TODO note that this
is just a stop gap.

Thanks!
-- 
Michal Hocko
SUSE Labs

