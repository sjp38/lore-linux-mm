Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B39FFC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:38:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7885E2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:38:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="USrawQ6/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7885E2067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CEA28E0006; Mon, 29 Jul 2019 11:38:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07FEA8E0002; Mon, 29 Jul 2019 11:38:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0C28E0006; Mon, 29 Jul 2019 11:38:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3BCD8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:38:29 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 145so38715004pfw.16
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:38:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kTRobX83JJeBQVwIveyy0p4dpxyy2pND5viOSWqwu2A=;
        b=PUHDQYArXR2vqIgDEzMOQBgOyr2pteNY1dzBTpsnAVJv2falo10pErtmT1UeC4pYp2
         ebpkmMgYU6hdP+oWCzC8GYK2pWwUENl5LdloGWirf5ya74H1JMU4w1kk4b/wCCniP7P9
         ZJtOHrS7Xwt4pmOBrglNcpGzp+OXmdFW4VqA2ZrW6U24rz+jmNHZS1AKqeZGzQ1YRQQC
         XsABxoIMxO4q0ZVvcKtzQLHJxKZgAoFgz4Q6mRpA7BI+zqShN8uo2OHh6Nnu2YRqc4WX
         EUhnTPvysaud5sOmgTNYufvmUzqX3iECotG0UJear3go3jtAdCvQbz6O0+6HGkQBP+/i
         PTyQ==
X-Gm-Message-State: APjAAAV0MHSgDB+gjK9mEJR8CMLAzqeT8XBxrdXFOWnzFc6m7koF9rrz
	27SIAaH06154KbFT0mpa+9XaBmRh/eqL1Vp15Xf7a88kk6pf/Qsl00ik0BWOFRdneW/AAqY6lmU
	JknLuAuUiJVfiSrSl4fCbEF698ZDJPeqJwt1siGTZI9mg+rgUNs+9DGyiTp4kf6wpjg==
X-Received: by 2002:a63:9e56:: with SMTP id r22mr48037540pgo.221.1564414709137;
        Mon, 29 Jul 2019 08:38:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhakKOEdIx1WRXVNPRkXyc7Kl9pxpBibTLB4PGoTnZ+srZ5441rjZ5sOKtrOI37nKsrhCi
X-Received: by 2002:a63:9e56:: with SMTP id r22mr48037498pgo.221.1564414708476;
        Mon, 29 Jul 2019 08:38:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564414708; cv=none;
        d=google.com; s=arc-20160816;
        b=JZN56eyik1bF/eknUJ6FfMI4cy/oH52fR1mVqLyzOFM/5Q/nJkO7cFXm6ykWjo76QO
         i65RDkaiUVUMSWKvCQt7+aGYjhMapGuR1U3fVly0CowcnfcPed9egWbfX5ZNoJXgx3tn
         5/7WQkOk9tArZbLdcyIfDyFvNn7LeGGmt6/taoszpSUYxo5jK/+QtwijKbTxSReCtdu7
         QuwTKdXwNpLLXQX5Lqr+PUBS3yY5/nA/1RSsXwEKxpr/oSXWjhuDmYuscJTNLsmkp56z
         yeJBmmly9rbVI3IVAce3VmFB3U3Y6XKBg0dts8+yiaF7FixAiHIRFtLA3mJ/mgNRuF76
         v4zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kTRobX83JJeBQVwIveyy0p4dpxyy2pND5viOSWqwu2A=;
        b=DUT/DpU03UOfnDRgU6+WRQVCi+GmHCOADtumVduu89MWciipm0Op4m8Loy8BjrgoC1
         ojF1FBGpDSBvTi3wc28kDCxwIJveLu4VhW3VMscGTo6zTi/BzP1JyMPEOe1imGUXQKQh
         5LTPhkg918LGmkr9Uad9fPBEJQ4I8QKurPQJmkimCYAUiOCcSyQpQZg1iFEys7pszsgn
         fCoG1AOE1wGJpy528zMNCk3AS7n/IyshMLwCiTNY/T2eF6/+da+tZ1zfRTdDPkK+LLzw
         bYFh3zQpT/dhus8aSWOniPeQYw6OGs8NawNj8F+ZPm5z7x+gJEzY4Cv+hHDdJ884XVBQ
         vLEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="USrawQ6/";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l6si3199277pgp.391.2019.07.29.08.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 08:38:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="USrawQ6/";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=kTRobX83JJeBQVwIveyy0p4dpxyy2pND5viOSWqwu2A=; b=USrawQ6/HCifS+n9zc9f7rRgp
	SS5hThycZpx1nxHNxbRjjHd58Mq1C1l4w9QEKwwQNaiogsS9aukVbw35Ie8ufchGdx5QtTCUwFcl3
	FfwbK5zDhfFPOG9/uFIYxpbEjq5att4KMnfsyy6QymNjukfSwlA81zJW06X6fuXkyw7GTf3MgE/kA
	zTAuXCQPr7aW2ZsXCalOGcV2p+X5RugQ0DbW7hKyFEYY5E78e/SGZcaC66r+TSJ8jNyEz/cfCvgHI
	qo6m3Yc0CFtAMw4MfaFMG+zOuLdhKL8rgV3QbYm+hMBMow6/yIR4aMeSHHAm+RQP9Alg2UCMNJ/r6
	cGy0ZFNJQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hs7jH-0001Zh-St; Mon, 29 Jul 2019 15:38:28 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 4705420AFFEAE; Mon, 29 Jul 2019 17:38:25 +0200 (CEST)
Date: Mon, 29 Jul 2019 17:38:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Phil Auld <pauld@redhat.com>, Will Deacon <will.deacon@kernel.org>,
	Rik van Riel <riel@surriel.com>, Andy Lutomirski <luto@kernel.org>
Subject: Re: [PATCH v2] sched/core: Don't use dying mm as active_mm of
 kthreads
Message-ID: <20190729153825.GI31398@hirez.programming.kicks-ass.net>
References: <20190727171047.31610-1-longman@redhat.com>
 <20190729085235.GT31381@hirez.programming.kicks-ass.net>
 <20190729142756.GF31425@hirez.programming.kicks-ass.net>
 <2bc722b9-3eff-6d99-4ee7-1f4cab8b6c21@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2bc722b9-3eff-6d99-4ee7-1f4cab8b6c21@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 11:22:16AM -0400, Waiman Long wrote:
> On 7/29/19 10:27 AM, Peter Zijlstra wrote:

> > Also; why then not key off that owner tracking to free the resources
> > (and leave the struct mm around) and avoid touching this scheduling
> > hot-path ?
> 
> The resources are pinned by the reference count. Making a special case
> will certainly mess up the existing code.
> 
> It is actually a problem for systems that are mostly idle. Only the
> kernel->kernel case needs to be updated. If the CPUs isn't busy running
> user tasks, a little bit more overhead shouldn't really hurt IMHO.

But when you cannot find a new owner; you can start to strip mm_struct.
That is, what's stopping you from freeing swap reservations when that
happens?

That is; I think the moment mm_users drops to 0, you can destroy the
actual addres space. But you have to keep mm_struct around until
mm_count goes to 0.

This is going on the comments with mmget() and mmgrab(); they forever
confuse me.

