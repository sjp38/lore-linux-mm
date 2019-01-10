Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68414C43612
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 16:26:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F4F520874
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 16:26:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F4F520874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C39238E0003; Thu, 10 Jan 2019 11:26:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE8E68E0001; Thu, 10 Jan 2019 11:26:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B005B8E0003; Thu, 10 Jan 2019 11:26:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 836F68E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 11:26:04 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id j5so11243978qtk.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 08:26:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=OkJsHFUjv1xXlNNOQU8ylwJOBOrlBheNMkAZfOt+LIs=;
        b=VY4n9RdBOJE0QbZoMUpqgYUUKcLQalxFc50WiC9HUO8xInYe4j5uOTo9G1XnwV9bmd
         VSI7hjqYccwMH843+xaW1/XMYH84NpLBwpYVylsQbr2pY0LllSiaj9zpr4nmGZF+nDLT
         Jhv6NoTx5biJIroCDjE8gzhvRzaasCFptZUj6HQS4nX1YPPHGmWuytPrLA7lT+TCtrqv
         niapCi0a/qNrRYCqhmf1LB9XKIWgWi+6cjxNtsYcxPyjk7G84kHRTvxRzvkiBhHadq8X
         +iZY7ZSLChAB1xg/WsPb2kAZPC18quGOwGx4TnHuye6bFDvkmJeBdN+VzX7Nl1xiZwWI
         cVvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukepxDFQOUQpi+ZHCJwLq34OfeuMQ1DrgLDDBHju5z7jOfg+Zc18
	hV/VyVYi7q/ubkz2T2HRH4e08OwaYoyohYU/yMgR3djdVGJxSDQ6sZJ/Zpj9Moha949ocx7f8SQ
	9WAEGUKK0C1SEY/10AmGg2YzNDMbdzCWs5v6AUnABTb35GEvqKWM7i/65QKqCpL/EBQ==
X-Received: by 2002:ac8:668c:: with SMTP id d12mr10001133qtp.242.1547137564232;
        Thu, 10 Jan 2019 08:26:04 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6GSzTFD8AA0YzjVyfMq/VAoESQfMGDavln+JhTVZQ5oRb3cspzox9RQxhM80C8rmpKpPHb
X-Received: by 2002:ac8:668c:: with SMTP id d12mr10001085qtp.242.1547137563514;
        Thu, 10 Jan 2019 08:26:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547137563; cv=none;
        d=google.com; s=arc-20160816;
        b=dUSQCkOnFwFoEgVCI0fKQgSoIOSXRq0YMdcYgNtPnuJ5DZHk53kLKLhKKslZt37C09
         XFnwNFGDC+vOW0exea7Tm4Kl4LS0aPKeJ5S74+utQN1w0FSvo87RkOZscuzeVrnF2ZJg
         GTKDM89gQyRtpr0g2oX1HVYooLoA2i6pFOboXrbRIRHt1Ctq1NNPFfaMvcN9/kuQ9089
         N8QMGIZ92EAc80d++VyvvK+kq9FvmGFV2mjvU1Yrj1eadCTw6gdgmhWVQvKY9FKGs/Y3
         H1wkuAP+CBH9HmZeLoVzDIWSFbM3WgT6XmExRg7izGwSO5n9nvZfg9YPYxs7SFAeHIl/
         XQHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=OkJsHFUjv1xXlNNOQU8ylwJOBOrlBheNMkAZfOt+LIs=;
        b=JsDKgm7bTBJEluB9375snc1LRTro6oUMMBh2tub43im9sOrYV1yIsXdNQPNFSTF4gu
         cYmF7LRP20orwOdI9gB7cOU0a1DoXuj+XR5mfwssvclbzEidAE1ObhDo7x4Oeuxf3PNs
         6Ngw7C58jJKd5/CLZIehfZXPyKno8laHXM/kZFTrFDwZGKGaP4AZCa9a7f+0mwW2wTFT
         ILJQO2r6cbO2KAXnJy7Kf5M15DOeHodPFeCRv5gIwglTxLiwjF63jCCGSOQPywC3Nj4P
         QUikpSN+aUdEmbRs7RBJIGaMYyaMa+PvRG8ct+7oCbr/8CcgwBNBfhI0S5HYDgW8ftP7
         DgnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t23si1045496qtp.212.2019.01.10.08.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 08:26:03 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 27C19C7CA9;
	Thu, 10 Jan 2019 16:26:02 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.215])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5571D60123;
	Thu, 10 Jan 2019 16:25:58 +0000 (UTC)
Date: Thu, 10 Jan 2019 11:25:56 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>,
	Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>,
	Dong Eddie <eddie.dong@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110162556.GC4394@redhat.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
 <20181228195224.GY16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181228195224.GY16738@dhcp22.suse.cz>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 10 Jan 2019 16:26:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110162556.Zsroe_dzWLvVjYjw-_ke9XXn3Q5YPIdJhUryQNAYfTI@z>

On Fri, Dec 28, 2018 at 08:52:24PM +0100, Michal Hocko wrote:
> [Ccing Mel and Andrea]
> 
> On Fri 28-12-18 21:31:11, Wu Fengguang wrote:
> > > > > I haven't looked at the implementation yet but if you are proposing a
> > > > > special cased zone lists then this is something CDM (Coherent Device
> > > > > Memory) was trying to do two years ago and there was quite some
> > > > > skepticism in the approach.
> > > > 
> > > > It looks we are pretty different than CDM. :)
> > > > We creating new NUMA nodes rather than CDM's new ZONE.
> > > > The zonelists modification is just to make PMEM nodes more separated.
> > > 
> > > Yes, this is exactly what CDM was after. Have a zone which is not
> > > reachable without explicit request AFAIR. So no, I do not think you are
> > > too different, you just use a different terminology ;)
> > 
> > Got it. OK.. The fall back zonelists patch does need more thoughts.
> > 
> > In long term POV, Linux should be prepared for multi-level memory.
> > Then there will arise the need to "allocate from this level memory".
> > So it looks good to have separated zonelists for each level of memory.
> 
> Well, I do not have a good answer for you here. We do not have good
> experiences with those systems, I am afraid. NUMA is with us for more
> than a decade yet our APIs are coarse to say the least and broken at so
> many times as well. Starting a new API just based on PMEM sounds like a
> ticket to another disaster to me.
> 
> I would like to see solid arguments why the current model of numa nodes
> with fallback in distances order cannot be used for those new
> technologies in the beginning and develop something better based on our
> experiences that we gain on the way.

I see several issues with distance. First it does fully abstract the
underlying topology and this might be problematic, for instance if
you memory with different characteristic in same node like persistent
memory connected to some CPU then it might be faster for that CPU to
access that persistent memory has it has dedicated link to it than to
access some other remote memory for which the CPU might have to share
the link with other CPUs or devices.

Second distance is no longer easy to compute when you are not trying
to answer what is the fastest memory for CPU-N but rather asking what
is the fastest memory for CPU-N and device-M ie when you are trying to
find the best memory for a group of CPUs/devices. The answer can
changes drasticly depending on members of the groups.


Some advance programmer already do graph matching ie they match the
graph of their program dataset/computation with the topology graph
of the computer they run on to determine what is best placement both
for threads and memory.


> I would be especially interested about a possibility of the memory
> migration idea during a memory pressure and relying on numa balancing to
> resort the locality on demand rather than hiding certain NUMA nodes or
> zones from the allocator and expose them only to the userspace.

For device memory we have more things to think of like:
    - memory not accessible by CPU
    - non cache coherent memory (yet still useful in some case if
      application explicitly ask for it)
    - device driver want to keep full control over memory as older
      application like graphic for GPU, do need contiguous physical
      memory and other tight control over physical memory placement

So if we are talking about something to replace NUMA i would really
like for that to be inclusive of device memory (which can itself be
a hierarchy of different memory with different characteristics).

Note that i do believe the NUMA proposed solution is something useful
now. But for a new API it would be good to allow thing like device
memory.

This is a good topic to discuss during next LSF/MM

Cheers,
Jérôme

