Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFE4AC742BA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72719216C4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:37:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="XWiPp5T3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72719216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDEA58E0144; Fri, 12 Jul 2019 08:37:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8F0A8E00DB; Fri, 12 Jul 2019 08:37:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7E2E8E0144; Fri, 12 Jul 2019 08:37:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 530AB8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:37:11 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id 21so2834004wmj.4
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:37:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PRvJtsiHkVhvqvxWg5gOuLt8FA07mI2n7b2F9lWVt6s=;
        b=shwhd30LsDWiS4QDsInpmU7x9ypK4H9eYKgu+Dy4hF4MwVWEZirox6MAGoDCMak94i
         TIz+XBR9eQ3hWv1H7ExQCRKDJqNSo7/re43mIfyE+PG+A/qg/QKCNsKdWawpk5q2ZRUa
         qZvm4xQWoHSRWieU1Q5MJAqCukFZ1b2H2bKL8SF8fnjYAeXciJp3yq/B+2K9Iju1CJI+
         9YWwKtpPhp9Sl/8QWwCyymhemAA+w3GPeRCh/mgYYoGnsjYlO9sayVsa1PcVYrRhf7pi
         +IeywsIT/t8h58CWlfktp9iWq3dSQtROY9UE8Rwjqkm4ha2kGEjsogHO0eo+qk5bnEnM
         771Q==
X-Gm-Message-State: APjAAAWvRyrRQGiknq/m8k3jvel8FrwDcCjQfKiF3oYzbIx+/FaC6HHH
	9JK5Ba3oEcnWdLxDIJ6UmGYSYBvp9qZShdzJa7/riPIxYHO3pnbePz05QRiEADki5lnWdKyHSrv
	7oYuVaCsLdzQYDwP3VyMVQU1JG2mdU8umUrMFrlll1p2pU30iAE49EsBqXDn64WewCQ==
X-Received: by 2002:adf:f348:: with SMTP id e8mr12084338wrp.76.1562935030689;
        Fri, 12 Jul 2019 05:37:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBRFSjARcFF38G6htlmqEa2vuWwOfsG+IYuqcLFH+P4hBXfbtqffwsve2XgaFZMaoP9dbP
X-Received: by 2002:adf:f348:: with SMTP id e8mr12084286wrp.76.1562935029716;
        Fri, 12 Jul 2019 05:37:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562935029; cv=none;
        d=google.com; s=arc-20160816;
        b=MbCs1d3Zp/AKM+YQEi1qau1wERuKoeLVsap9qqNzQKBil7w1cW5OqZHpdWWizhFWZx
         ix7I7ZaDw751h+2GM7rSIr0BQMKvnSOikQztfszWH7TtS/W2FplghlNYRvVghLnuABTz
         gwq6wQbaw0tAY0aLSj9OwIjy4i4pdF91v/utzAo8iRm7SA2RqnhuQmMtDTNfevFM35Fz
         CADrA1nlBiXE55ttdA8NcPNKbshfDa0Wqfpnc3PD+I1SI+alWwiGTcdk7MshMKZE3Vpx
         ZgkZEKrO4w70TxyxRIPJyP1cjlVlJhNhYfX0lcLq/gdyD/UvdyqorrlPu3oT1AHZqWn8
         J+xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PRvJtsiHkVhvqvxWg5gOuLt8FA07mI2n7b2F9lWVt6s=;
        b=Uiy2s/NFxPT5SC1aCie3b9OFIrzgszJHtG6YMB9bknIWjNef4CTyVn0SKSqHMkNcHL
         Aqb6/T1+z06gBZzzAlONem0306nvfgY1kFIogLd9OwfsbfA6wNY9TyV0DvLxZZwpctGp
         V5GOmmdiGz/Z/Fie2S5fhBSQBXbPxWKPep+kOKsOZeMHCvudJzm8lqLzJvFYSU2Nno6d
         eUUgGcxKaj7BGg7dtCjLlhqi3meqvfWl6KMIz6Ekzf6yr5bDpq+KalHfMeuEgniqyGCN
         CSi7ghG0ZCa8w22GzWwtDVNSYIMwEycmY1+U++Fxi0EF8lwkAhSk3QkQZ36dWeWFPdaI
         S4pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=XWiPp5T3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id w17si8780212wrn.258.2019.07.12.05.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 05:37:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=XWiPp5T3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PRvJtsiHkVhvqvxWg5gOuLt8FA07mI2n7b2F9lWVt6s=; b=XWiPp5T3wZ07wSFz7SP2NGQsi
	SARqMlSa4wSWOALaD9zIg48cd8FkwtQzlyIqn2H/VG3zk8ew8txJuiyK0bOkKModvW1URTSAtHINQ
	BZfWo+f5pIdJEIj7pAAvGEgTpPGjztlFq+c1d86X1AriCw0HX9pAgtl/T5P5ViqzB3YbIpgpshlHU
	P1J4uQYE12VLgjTpHpbC3L2N8BZKengJ4RvrWQRLvD4ZCTcLEujoFj57iE9i92rblgnnWe2dtnErg
	JISh4LW8iD+LzsB0jFgfRy48PCLVuwRGtiiYaxws8B1vrL+LnY4BgsRnlKs2MI4YxasxwKR7M1GTy
	hU+YmR/Kw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlunH-0005Rb-23; Fri, 12 Jul 2019 12:36:56 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 65784209772E6; Fri, 12 Jul 2019 14:36:53 +0200 (CEST)
Date: Fri, 12 Jul 2019 14:36:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
	rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
Message-ID: <20190712123653.GO3419@hirez.programming.kicks-ass.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <20190712114458.GU3402@hirez.programming.kicks-ass.net>
 <1f97f1d9-d209-f2ab-406d-fac765006f91@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f97f1d9-d209-f2ab-406d-fac765006f91@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 02:17:20PM +0200, Alexandre Chartre wrote:
> On 7/12/19 1:44 PM, Peter Zijlstra wrote:

> > AFAIK3 this wants/needs to be combined with core-scheduling to be
> > useful, but not a single mention of that is anywhere.
> 
> No. This is actually an alternative to core-scheduling. Eventually, ASI
> will kick all sibling hyperthreads when exiting isolation and it needs to
> run with the full kernel page-table (note that's currently not in these
> patches).
> 
> So ASI can be seen as an optimization to disabling hyperthreading: instead
> of just disabling hyperthreading you run with ASI, and when ASI can't preserve
> isolation you will basically run with a single thread.

You can't do that without much of the scheduler changes present in the
core-scheduling patches.

