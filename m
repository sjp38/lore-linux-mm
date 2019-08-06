Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B57C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 03:13:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08A8F20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 03:13:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08A8F20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 937F96B0003; Mon,  5 Aug 2019 23:13:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E93F6B0005; Mon,  5 Aug 2019 23:13:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FEF46B0006; Mon,  5 Aug 2019 23:13:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C04F6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 23:13:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w12so11731553pgo.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 20:13:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=sHPq+pRx/+dTblW9pr6QipciNsC2rS/a9IQw+GuW4FY=;
        b=h80pEg+7IQubkZgL2kXzIZGUYcqRjO3pTrk30yAS/iWPGK4kZQbL0vf3L2j/TBgTIM
         SgcTLDYQwj5K/ebAa++Y6weGXpn4bymfLt3BcMz0Lq1AjqqZKpCreD2BoSBR1ZqaHi3L
         waac1XyffNPH9VN5yVjf2Y2vqRoIy6KFQ+FIkDN2Zk/L82IfeBD6pYpAuWJUmqeKjmoN
         jxnssZ4V+33YKxdcfuP7216vkU83oYSMz1uazpaN51zN20FQQ6ICJCzgG3bQreRLLF5S
         /oap9LD47jTHDM62bJkTAMCm5vjrQqFlGwF2L1g5o7ymFBBAS+J6GgxXyF2j5jgLaGUu
         BS4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXLP6AGlmA8ZEYrEGcXbalrs3w0fqpZOVh+U+4qZkzxuBNULPo9
	GcTFi+dGVc0QsnuQQnWuixCg2Z4VWSgbF/U8vRLvovO25/xhZWtCyBXLW2uHwOsa06iuBewSxUR
	FK+TuuN9U+6r+Ui+2D+Bt1bq+6ZL4eoiI+p8BvrqtfDYMLbV99dEJW3XACDvjY0sPwQ==
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr893304plz.191.1565061190992;
        Mon, 05 Aug 2019 20:13:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNA/mZLxqIdg930j7a6y8kdieKF2R/VGIHD2+x4N4m9qyhdgrDqG+cT9S+Xp5s+tW6Q9JD
X-Received: by 2002:a17:902:f81:: with SMTP id 1mr893270plz.191.1565061190293;
        Mon, 05 Aug 2019 20:13:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565061190; cv=none;
        d=google.com; s=arc-20160816;
        b=HyXxhrBCxixfsLpTQ+mwWQplkzHnzGFkozzow6hkSZIeL9SfgRXkogRPLFsYSGUjwb
         Qlp8t5F0r3QGY52aW2q0Kj5aFdeWJ2RzYJxFSbRRuhcaCLuaJk5WdY+nsTFWaAyaTRHN
         z+PUHtjy6ePCU5e7ys+l17Xz3R+Fdv5yzV5nUnKWC+uPmR/KHkNZyVzqrHwGsEzNEH8G
         3KlgWd+fHm9Xt/pLIBtdXYz+k+nf5BI1QjRBW7BSS5phYd7e7CpEysA5topx+2FS74OI
         eybKFk9i/0Tf2qIxI58kAc8uEf2EBF8xH6xFj0BeVxWV6lYvh2pMEeN60dzv73Vhcg5R
         k5+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=sHPq+pRx/+dTblW9pr6QipciNsC2rS/a9IQw+GuW4FY=;
        b=Kon5vm2FnYniSqAD015T3lQs9CXn0dw1BQvK+AU2CUtyqFd/jCe5srX0x+EjiZkklS
         ghI1h+WbV26pph7qT61OdP7TDz9qvR8yNUhRFDGH+oRdgNTTvhm/Cqllc+A7+LerAOsT
         mjvggUV0OqqCXv5Djt+mH3+8dK2fTRZf1LuUU9Tdzk1bPE2q7bs/YCACwphGc7kgTmNF
         yB7g3DrrQSrX0MFPyp2NA8r/Cghpom5LlHXd/lyMuY1lq/hjIq4ITZVXqtKltuAD/NDN
         p7Uo4eseuhS7IuCPUflFjeN8pXEvGv7jp92WQNHoJ4BagSWXFYdasWqufqmCqUSwS208
         7aMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g13si48817282pgo.274.2019.08.05.20.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 20:13:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 20:13:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,352,1559545200"; 
   d="scan'208";a="202666879"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by fmsmga002.fm.intel.com with ESMTP; 05 Aug 2019 20:13:09 -0700
Message-ID: <1c6a18dd63e6005045034ccc7b04390ab3c605e5.camel@intel.com>
Subject: Re: [PATCH] fork: Improve error message for corrupted page tables
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton
 <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"linux-mm@kvack.org"
	 <linux-mm@kvack.org>, "Hansen, Dave" <dave.hansen@intel.com>, Ingo Molnar
	 <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Date: Mon, 05 Aug 2019 20:09:59 -0700
In-Reply-To: <4236c0c5-9671-b9fe-b5eb-7d1908767905@suse.cz>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
	 <20190731152753.b17d9c4418f4bf6815a27ad8@linux-foundation.org>
	 <a05920e5994fb74af480255471a6c3f090f29b27.camel@intel.com>
	 <20190731212052.5c262ad084cbd6cf475df005@linux-foundation.org>
	 <FFF73D592F13FD46B8700F0A279B802F4F9D61B5@ORSMSX114.amr.corp.intel.com>
	 <4236c0c5-9671-b9fe-b5eb-7d1908767905@suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-05 at 15:28 +0200, Vlastimil Babka wrote:
> On 8/2/19 8:46 AM, Prakhya, Sai Praneeth wrote:
> > > > > > +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> > > > > > +	"MM_FILEPAGES",
> > > > > > +	"MM_ANONPAGES",
> > > > > > +	"MM_SWAPENTS",
> > > > > > +	"MM_SHMEMPAGES",
> > > > > > +};
> > > > > 
> > > > > But please let's not put this in a header file.  We're asking the
> > > > > compiler to put a copy of all of this into every compilation unit
> > > > > which includes the header.  Presumably the compiler is smart enough
> > > > > not to do that, but it's not good practice.
> > > > 
> > > > Thanks for the explanation. Makes sense to me.
> > > > 
> > > > Just wanted to check before sending V2, Is it OK if I add this to
> > > > kernel/fork.c? or do you have something else in mind?
> > > 
> > > I was thinking somewhere like mm/util.c so the array could be used by
> > > other
> > > code.  But it seems there is no such code.  Perhaps it's best to just
> > > leave fork.c as
> > > it is now.
> > 
> > Ok, so does that mean have the struct in header file itself?
> 
> If the struct definition (including the string values) was in mm/util.c,
> there would have to be a declaration in a header. If it's in fork.c with
> the only users, there doesn't need to be separate declaration in a header.

Makes sense.

> 
> > Sorry! for too many questions. I wanted to check with you before changing 
> > because it's *the* fork.c file (I presume random changes will not be
> > encouraged here)
> > 
> > I am not yet clear on what's the right thing to do here :(
> > So, could you please help me in deciding.
> 
> fork.c should be fine, IMHO

I was leaning to add struct definition in fork.c as well but just wanted to
check with Andrew before posting V2.

Thanks for the reply though :)

Regards,
Sai

