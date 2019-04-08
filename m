Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41AADC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 09:52:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E9A5220870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 09:52:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9A5220870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 658B06B0005; Mon,  8 Apr 2019 05:52:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 608956B0006; Mon,  8 Apr 2019 05:52:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51F2D6B0008; Mon,  8 Apr 2019 05:52:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04B7B6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 05:52:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 41so6657386edq.0
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 02:52:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2cR0ZRuDYpk/c4TkK7NYVQi/deaGtPIjt528UU4ieLk=;
        b=JjZSgxuBNShDy+hKRI8ZEc7VMrtukbXoDfmEvQmo9qvkIKCQWMZ6DPubxqpfpoRrLW
         kA7iTtPg/d6BL1Ol3lBY7U24X1BZG8PvioznBEgex/wIJUXrlmPh0m9m5T3EtGBIqUxo
         6lV2oVxfqbijf+T++n5pFIcvoaAo+wU0KEMv9cqOApFt9fSoeiBkLc+9vYuE4eyJ34OL
         CRCxXNh8JMxSAHmoigt1SzaVQhxRpevSE75g4MFJoVsqcYqQFUMSAeQUKU+ftlPJ5cO5
         BPqc6rMy2rVjvego7DFSCAEjbKDf8/iKzWMxxucAXRU89JzHn6gAsGS9X9iqH1BReq0Z
         DxIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWMaY5HUhUTLDrca6t84vs3T4UT7wLrE9ZP1o0NsxmLUOBLZJg3
	cBM0Rz4hu0mz4ULjhR30RB9biz1wEWGuC5hpgjlVN5pX/Brh/lXxWpRfcJSlx4sr8BHn4zW9aFH
	xk8MquQrIgYhBD/6MlqhT0hQ4Tluwr1THTSzXO/Y8Ed1pRhXYlDjUxpcZK7pOYNktMA==
X-Received: by 2002:a50:e610:: with SMTP id y16mr17471322edm.67.1554717150571;
        Mon, 08 Apr 2019 02:52:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZEaC6OGFaHBDYfhvyST5lxgn9esbJlgNq/I1DCDFokJ17ozkGV4B89PppMuaG9AjU1S+T
X-Received: by 2002:a50:e610:: with SMTP id y16mr17471272edm.67.1554717149387;
        Mon, 08 Apr 2019 02:52:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554717149; cv=none;
        d=google.com; s=arc-20160816;
        b=UaJH00QFV5Wvk+W9hELJclLPJt6IRrzkKugHVoNwrxrY81Qexs+Ovq9IsBP8TJFq1U
         7LbzjOH5RIqo4pWCIZC/c/o4EQlc8rABaZi0gdgBdEkskTBFibOdxadI+5w8oaAcFl2C
         I9j0JxwKmVZYb/Tga0yw4WVjz0L3VwZjQPdmh7qaPf84ca703GkKL0NFMSgkUv9xMOBz
         qZDu+8u4ym6Sb5VyfXju7l0hgbaLSc+Q2dQ+LUuNJGGhtTCm5XlyevLM3dfY03iChWTQ
         YLP1G8MXH9JdYPdJrVhbxLLcbauNEfJtUgrKFYUTY31kLvwZ3tjGzvFT6tXO+VvQSFRf
         vyvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2cR0ZRuDYpk/c4TkK7NYVQi/deaGtPIjt528UU4ieLk=;
        b=qCTDPDOozeNgQdw7B3iHi3Gx0/cZxh1uU+COvCilBLSoUNdi40lfPEfdOJhTVu4Jr9
         Ff7PKtnSeXjH1GSGKUZILYJkJ390YFoLhmcGo7He9Eds5FKO6DB/xk3+cJoBz3gOxgfC
         hhVpUsPSi4MIT9e8PHhKdKfCBUCk9Pdp+2zdRg8Ij+e2tfxAKP0FoUjEwG28gOlRK86t
         IZfxpfyH2cn1px1NnABL/g5M/Au1IBHIjz4IfXpuSXcEoUszEgtXcRdMZZDJre7hN7yL
         P/PhrsDqcKHBWnfSoR+mzvFDUyeWzYkQ6JmO2E5aa/G4WLX39wp1SLFsCfQdd6Twl6+l
         ozFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp19.blacknight.com (outbound-smtp19.blacknight.com. [46.22.139.246])
        by mx.google.com with ESMTPS id d32si5870680eda.79.2019.04.08.02.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 02:52:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) client-ip=46.22.139.246;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.246 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp19.blacknight.com (Postfix) with ESMTPS id C48491C24D3
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 10:52:28 +0100 (IST)
Received: (qmail 31562 invoked from network); 8 Apr 2019 09:52:28 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 8 Apr 2019 09:52:28 -0000
Date: Mon, 8 Apr 2019 10:52:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>,
	"James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: Memory management broken by "mm: reclaim small amounts of memory
 when an external fragmentation event occurs"
Message-ID: <20190408095224.GA18914@techsingularity.net>
References: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 06, 2019 at 11:20:35AM -0400, Mikulas Patocka wrote:
> Hi
> 
> The patch 1c30844d2dfe272d58c8fc000960b835d13aa2ac ("mm: reclaim small 
> amounts of memory when an external fragmentation event occurs") breaks 
> memory management on parisc.
> 
> I have a parisc machine with 7GiB RAM, the chipset maps the physical 
> memory to three zones:
> 	0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
> 	1) Start 0x0000000100000000 End 0x00000001bfdfffff Size   3070 MB
> 	2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
> (but it is not NUMA)
> 
> With the patch 1c30844d2, the kernel will incorrectly reclaim the first 
> zone when it fills up, ignoring the fact that there are two completely 
> free zones. Basiscally, it limits cache size to 1GiB.
> 
> For example, if I run:
> # dd if=/dev/sda of=/dev/null bs=1M count=2048
> 
> - with the proper kernel, there should be "Buffers - 2GiB" when this 
> command finishes. With the patch 1c30844d2, buffers will consume just 1GiB 
> or slightly more, because the kernel was incorrectly reclaiming them.
> 

I could argue that the feature is behaving as expected for separate
pgdats but that's neither here nor there. The bug is real but I have a
few questions.

First, if pa-risc is !NUMA then why are separate local ranges
represented as separate nodes? Is it because of DISCONTIGMEM or something
else? DISCONTIGMEM is before my time so I'm not familiar with it and
I consider it "essentially dead" but the arch init code seems to setup
pgdats for each physical contiguous range so it's a possibility. The most
likely explanation is pa-risc does not have hardware with addressing
limitations smaller than the CPUs physical address limits and it's
possible to have more ranges than available zones but clarification would
be nice.  By rights, SPARSEMEM would be supported on pa-risc but that
would be a time-consuming and somewhat futile exercise.  Regardless of the
explanation, as pa-risc does not appear to support transparent hugepages,
an option is to special case watermark_boost_factor to be 0 on DISCONTIGMEM
as that commit was primarily about THP with secondary concerns around
SLUB. This is probably the most straight-forward solution but it'd need
a comment obviously. I do not know what the distro configurations for
pa-risc set as I'm not a user of gentoo or debian.

Second, if you set the sysctl vm.watermark_boost_factor=0, does the
problem go away? If so, an option would be to set this sysctl to 0 by
default on distros that support pa-risc. Would that be suitable?

Finally, I'm sure this has been asked before buy why is pa-risc alive?
It appears a new CPU has not been manufactured since 2005. Even Alpha
I can understand being semi-alive since it's an interesting case for
weakly-ordered memory models. pa-risc appears to be supported and active
for debian at least so someone cares. It's not the only feature like this
that is bizarrely alive but it is curious -- 32 bit NUMA support on x86,
I'm looking at you, your machines are all dead since the early 2000's
AFAIK and anyone else using NUMA on 32-bit x86 needs their head examined.

-- 
Mel Gorman
SUSE Labs

