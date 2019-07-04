Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0787C0650E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 00:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A6F9218A4
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 00:32:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A6F9218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD0736B0003; Wed,  3 Jul 2019 20:32:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A821A8E0003; Wed,  3 Jul 2019 20:32:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 922908E0001; Wed,  3 Jul 2019 20:32:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3776B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 20:32:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g18so146157plj.19
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 17:32:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=+5BRJJ4LKHZcqKCAn0GKIas1O50SyzuCOGqOASmVXtA=;
        b=hdyU9ZbOIpmoHp7Z7fxU6KqswlTy7x5L78Gd1VhYh+In6IbsKRJ1e0X3T97Gdd3QrW
         8Ctrac7cgQuFBIazG7n5t/Rh4S6HLPBXuTma+3mYetRKlQ+sG0WI5L6I1LGtbBREhTSf
         cazToUGmeIpg4ZjBu1Idpg4v57ln39g3vS2XL+UPQvQ04kwo0HYLhuEgZbN+95IalP9j
         SG++fqkuwwj0hwaMi5kC7Jnsd6BNjGNaJKsmAnILdOIkIvm3D2iGLKpRpaMNy978r25c
         rVFzx4dkb83KhUJSMokFhbpxBHgSeURyxB16bAA1BmqhT/GS4nnwRAQsXraKO997PIPW
         1mdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUsjoq36+9Tuf9f6Xo19DJ7c5RgM/jhMIER0Ir0utzGrPrsMvdl
	SteTZpff/RxzkKgM3lgl7kPByGuRdSBGnAIhvLsln3auaslRV+0pCCAYVNYttNrrcQgiR0VNH7u
	nm3otpZP7lNAy7IMPy5OEKQpuuKbnnpH3GO6w1wq/Bem06IgVYXiyAHQKkM3IZJ5IRg==
X-Received: by 2002:a63:1950:: with SMTP id 16mr8998792pgz.312.1562200330994;
        Wed, 03 Jul 2019 17:32:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPCBX2MGPSQ4+HS271kXgeH5WsPuQEOzi1s3UjCSavwiHtsae9DqAtFl0jEcQPibhCZ/NQ
X-Received: by 2002:a63:1950:: with SMTP id 16mr8998733pgz.312.1562200330190;
        Wed, 03 Jul 2019 17:32:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562200330; cv=none;
        d=google.com; s=arc-20160816;
        b=E4HReT2HbtH5O5P9KcjQDv0WDnBSDcbB1WIzHRybIQNmrPb+gg/LjAvjkzxu9mY4VV
         V5cdL11mwAJyVn14ug9HXrUM8lGM1XOY5v60/7v/hqFE9z/OSsb/NEgamOdSv9gy9H1m
         FX/mYnV26eM/O4tpAUHtXNlvT4PIkczlowlTSsLSUUmpNMXnkfFla3r8OQrPwaQak3Ep
         IRqEp3KbaWyOamGuKVaxxCeDUZquOMP3RJTLtSI4mchmJa8kQ9XR4VlQfbqot5pIzwx5
         aQ/aBisbc5lHTVDZOoIKhqgJeAbqw4CMHcQfoGZsexpl4ISbPy4mPHbm2IrprDmbqeHA
         4MbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=+5BRJJ4LKHZcqKCAn0GKIas1O50SyzuCOGqOASmVXtA=;
        b=PoWy4NmSZkqkLHXdrrcYd7acuU+bIEEqs7UQ6tFA8C1KFl88yZYTKKV0xibZA6aGAh
         t/ThuRPcwCXq3x0pTUD/TAnceN/Txk+BdLhor179xEbW+Bz6pP+QNiFJt8VltLVWf/Is
         7NCqRhD074yoUaTM8x05FV+9dZAEd/7EoVWfXEkLhSHmwdkoUXMcAATSfONLSTfgWtVm
         Al6u9FUuXDFv/yhBBuITXRCI2YU2nMhbA+/c/wss/demP8QIyY6h3+42Kxn0tD5Hgyey
         Sl2Qmabg0MRHFZsVjqNoK3MJSLGwn5QXhO4GG83Mf8G5quhHOglRuqcey1mCURZy0U00
         1yzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id y65si3508868pgd.487.2019.07.03.17.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 17:32:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Jul 2019 17:32:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,449,1557212400"; 
   d="scan'208";a="164499846"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga008.fm.intel.com with ESMTP; 03 Jul 2019 17:32:07 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mel Gorman <mgorman@suse.de>
Cc: huang ying <huang.ying.caritas@gmail.com>,  Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  LKML <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  "Peter Zijlstra" <peterz@infradead.org>,  <jhladky@redhat.com>,  <lvenanci@redhat.com>,  Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
References: <20190624025604.30896-1-ying.huang@intel.com>
	<20190624140950.GF2947@suse.de>
	<CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
	<20190703091747.GA13484@suse.de>
Date: Thu, 04 Jul 2019 08:32:06 +0800
In-Reply-To: <20190703091747.GA13484@suse.de> (Mel Gorman's message of "Wed, 3
	Jul 2019 10:17:47 +0100")
Message-ID: <87ef3663nd.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mgorman@suse.de> writes:

> On Tue, Jun 25, 2019 at 09:23:22PM +0800, huang ying wrote:
>> On Mon, Jun 24, 2019 at 10:25 PM Mel Gorman <mgorman@suse.de> wrote:
>> >
>> > On Mon, Jun 24, 2019 at 10:56:04AM +0800, Huang Ying wrote:
>> > > The autonuma scan period should be increased (scanning is slowed down)
>> > > if the majority of the page accesses are shared with other processes.
>> > > But in current code, the scan period will be decreased (scanning is
>> > > speeded up) in that situation.
>> > >
>> > > This patch fixes the code.  And this has been tested via tracing the
>> > > scan period changing and /proc/vmstat numa_pte_updates counter when
>> > > running a multi-threaded memory accessing program (most memory
>> > > areas are accessed by multiple threads).
>> > >
>> >
>> > The patch somewhat flips the logic on whether shared or private is
>> > considered and it's not immediately obvious why that was required. That
>> > aside, other than the impact on numa_pte_updates, what actual
>> > performance difference was measured and on on what workloads?
>> 
>> The original scanning period updating logic doesn't match the original
>> patch description and comments.  I think the original patch
>> description and comments make more sense.  So I fix the code logic to
>> make it match the original patch description and comments.
>> 
>> If my understanding to the original code logic and the original patch
>> description and comments were correct, do you think the original patch
>> description and comments are wrong so we need to fix the comments
>> instead?  Or you think we should prove whether the original patch
>> description and comments are correct?
>> 
>
> I'm about to get knocked offline so cannot answer properly. The code may
> indeed be wrong and I have observed higher than expected NUMA scanning
> behaviour than expected although not enough to cause problems. A comment
> fix is fine but if you're changing the scanning behaviour, it should be
> backed up with data justifying that the change both reduces the observed
> scanning and that it has no adverse performance implications.

Got it!  Thanks for comments!  As for performance testing, do you have
some candidate workloads?

Best Regards,
Huang, Ying

