Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 792F5C0650F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:15:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37D162087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:15:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37D162087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C80666B0003; Fri,  2 Aug 2019 19:15:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C09746B0005; Fri,  2 Aug 2019 19:15:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD2CB6B0006; Fri,  2 Aug 2019 19:15:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 741606B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 19:15:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 6so49241892pfi.6
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=mKueldX8pj9f2LlmyxFsr2GucykjQg1bovTTwHtY3aE=;
        b=n1m5MR8TTnnZ2nXIN6EvmchB4txOcZ5XpYVW/4eogaJNgugwRtIBMDR7akVk8TWBan
         xrPQ63UTnHnXsAT9tbQt8S3kUIMzuEjxVSnj/x77E7Uy0xqNfWwXimuaCg2Jj87z3Gt0
         pTxN8fM+e7dh2BFiTL5VcGjk7FUxbK3tY2U10oMFGrUSV6WVvlZGe3M+UyLT7TsXr5uc
         5qWf08k4GDfVSvtlOJz/KlCGl4cUzU3GurGmIuq3q+hORJqOdH1SbomfcrTExkZsdvz9
         CmoiyKzB8wK2s9wt+fdYk5LiCLTTgph92Ga82JNE74zzO7LDqtjCnLkpG1tAXcH2/12a
         lDUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWoKZ1k4jR4lJcs9TJVW4DEqgcTdxZSUcDAuz9hh0qQ4SPfIu2M
	glIDp/fAuQAGVUexveaU/ebvUPMIdGiAFuxBCc0mkDi9ojKDK/srdTOB+0SgVAUUQ37TPTx0qiq
	j1PlJ7SAP+LY1wvNb+P4V7GJSgUE+z5KsviOB8Ea7O7fKGZqs1WJLwjOV4l6sg3Wa0w==
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr132945014plo.124.1564787725110;
        Fri, 02 Aug 2019 16:15:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsLQglseZRI1kpKrf0qBtJzz90H34o3U3k1gx9mVSuXPJy3nu+wVISPT1CJb5nHH+7Owtq
X-Received: by 2002:a17:902:8a87:: with SMTP id p7mr132944958plo.124.1564787724227;
        Fri, 02 Aug 2019 16:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564787724; cv=none;
        d=google.com; s=arc-20160816;
        b=tyXa8DYQdBWEn3F+peS5lCV8txN3+yZGi9EbxKrg7LrXe0T5bOGG3hDIkgJHM6pT/L
         5Iu90CQnWxizraiWW45m2w/sMJFaD/B2zpVcABJZ2SbSqgvTUb52hvUkiSaYLN/FlNwg
         kB0qt9/cHm8temCdQ+/Yhq3pSNdqWLj/uirKbNqqei7ZMSvMh6jOjq3BF+pH9Xljy8N6
         ZkCzbY55LjvaUgFUXsQhZ7+DShyZ4mz4ycJhq2NhJ+qclrPwZmdMUp8H+Q7Ga9yf8WS7
         b7gbt1OHz5q11IlQzyznf2oIP0voOAR+kTt2PK6l2uZhhDlrsob8BWRAfOwBaVCTB0SN
         LE5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=mKueldX8pj9f2LlmyxFsr2GucykjQg1bovTTwHtY3aE=;
        b=T3tZts2Q97cI4IV1Fu7vz74Glh2j7ou8FToFDXrvwJjoGMNF3wKMqLSL204rS7lE7y
         esPR0hOEak0EbXKwMVXTVDn51hD44/42n1kCVF5g4YSXRFo8725NLKbDw8xMZ01Ksupo
         0mL4Rho7sfFTgc8l0GXIgDF5hn0Owq1ExMVOz+FsXfc3Nq4rjdP+yYhKGGZoQ7Xn2Cjz
         +OLD7yN2Fcchb73et+dsvuSD0RmDQyrxcwdBUpeJCmPGa76Aen+n5UYK4vPdn7xqpPmF
         bK1GZGl4KdOfeJxprYnPrPXNmP7F68t3p0oNjvok7i53hlBx1IbEUMnu7JYlLroJ3E59
         aw9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h27si32675585pgh.388.2019.08.02.16.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 16:15:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Aug 2019 16:15:23 -0700
X-IronPort-AV: E=Sophos;i="5.64,339,1559545200"; 
   d="scan'208";a="184721864"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga002-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Aug 2019 16:15:23 -0700
Message-ID: <c43723f2acdf257309dca55eac900dc71bca31c3.camel@linux.intel.com>
Subject: Re: [PATCH v3 0/6] mm / virtio: Provide support for unused page
 reporting
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Fri, 02 Aug 2019 16:15:23 -0700
In-Reply-To: <ac434f1cad234920c0e75fe809ac05053395524b.camel@linux.intel.com>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
	 <9cddf98d-e2ce-0f8a-d46c-e15a54bc7391@redhat.com>
	 <3f6c133ec1eabb8f4fd5c0277f8af254b934b14f.camel@linux.intel.com>
	 <291a1259-fd20-1712-0f0f-5abdefdca95f@redhat.com>
	 <ac434f1cad234920c0e75fe809ac05053395524b.camel@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-02 at 10:28 -0700, Alexander Duyck wrote:
> On Fri, 2019-08-02 at 12:19 -0400, Nitesh Narayan Lal wrote:
> > On 8/2/19 11:13 AM, Alexander Duyck wrote:
> > > On Fri, 2019-08-02 at 10:41 -0400, Nitesh Narayan Lal wrote:
> > > > On 8/1/19 6:24 PM, Alexander Duyck wrote:
> > > > > 

<snip>

> > > > > One side effect of these patches is that the guest becomes much more
> > > > > resilient in terms of NUMA locality. With the pages being freed and then
> > > > > reallocated when used it allows for the pages to be much closer to the
> > > > > active thread, and as a result there can be situations where this patch
> > > > > set will out-perform the stock kernel when the guest memory is not local
> > > > > to the guest vCPUs.
> > > > Was this the reason because of which you were seeing better results for
> > > > page_fault1 earlier?
> > > Yes I am thinking so. What I have found is that in the case where the
> > > patches are not applied on the guest it takes a few runs for the numbers
> > > to stabilize. What I think was going on is that I was running memhog to
> > > initially fill the guest and that was placing all the pages on one node or
> > > the other and as such was causing additional variability as the pages were
> > > slowly being migrated over to the other node to rebalance the workload.
> > > One way I tested it was by trying the unpatched case with a direct-
> > > assigned device since that forces it to pin the memory. In that case I was
> > > getting bad results consistently as all the memory was forced to come from
> > > one node during the pre-allocation process.
> > > 
> > 
> > I have also seen that the page_fault1 values take some time to get stabilize on
> > an unmodified kernel.
> > What I am wondering here is that if on a single NUMA guest doing the following
> > will give the right/better idea or not:
> > 
> > 1. Pin the guest to a single NUMA node.
> > 2. Run memhog so that it touches all the guest memory.
> > 3. Run will-it-scale/page_fault1.
> > 
> > Compare/observe the values for the last core (this is considering the other core
> > values doesn't drastically differ).
> 
> I'll rerun the test with qemu affinitized to one specific socket. It will
> cut the core/thread count down to 8/16 on my test system. Also I will try
> with THP and page shuffling enabled.

Okay so results with 8/16 all affinitized to one socket, THP enabled
page_fault1, and shuffling enabled:

With page reporting disabled in the hypervisor there wasn't much
difference. I saw a range of 0.69% to -1.35% versus baseline, and an
average of 0.16% improvement. So effectively no change.

With page reporting enabled I saw a range of -2.10% to -4.50%, with an
average of -3.05% regression. This is much closer to what I would expect
for this patch set as the page faulting, double zeroing (once in host, and
once in guest), and hinting process itself should have some overhead.

