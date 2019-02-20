Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0852EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:47:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C81D82183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:47:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C81D82183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6053F8E001D; Wed, 20 Feb 2019 09:47:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B4348E0002; Wed, 20 Feb 2019 09:47:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 488038E001D; Wed, 20 Feb 2019 09:47:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E18F38E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:47:12 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so10152296edd.2
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:47:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SrI/FJBTs0f7QGuwCzmZ98JDTGTeZ1VjwTrAiXfJXlU=;
        b=dd8vA65W1+sf+sZwheRJqD9wGMGdsOBrxHjFvCdiif7LgQSfbB0vrYs8XX0pWQeC2n
         ZcFR8hjWPR5JWKDGZNytgcwLNxB+TO+2ofK7gyv7AMIFy/MXrEjddDnaC0pLw2xVP4Yp
         PfHd0ohiep69BAeyvHSniG/d8OFsjtYOYlsHLe/9FRghaFT14XPgpwnWitug/mowqIz9
         o9nMNEuk5IRykJCF5RYHEY0M8Kxpe3dk1u6kYyOOajH9MNpjyvXnzXEZYe2xncY2+czy
         cIvPn0BHnLBHD9TI+GNYoN+yHADL/+rpxVCkbk0SPLn5CsFvvaxi5o3e7/J7NbhiVVol
         fcqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAua/i/qvpIfKCHdyNQ/OE1soFj40OUx9VUzAkdBT7384e7t5YnyT
	UBxdhKjk3TfoecVwf7H+j6Arjz0pSvDc8ZmhLLNJe11GJcFkjTDkcBIDswLxjKp0Tn3sl8z6YXI
	5Wb1P79ho6FZwplna/sdwnPrQG2q2PEnnbdSPakqQWiCd69HuDmzJvgM9A5LAH+0zNw==
X-Received: by 2002:a50:ade7:: with SMTP id b36mr26878308edd.215.1550674032373;
        Wed, 20 Feb 2019 06:47:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCGPcX/U7VF1CBRdRDVg+zHrWezq363QU4Bmp+Wdr8366ruiclKV/W4BOAaCFQwLWr9Goz
X-Received: by 2002:a50:ade7:: with SMTP id b36mr26878280edd.215.1550674031597;
        Wed, 20 Feb 2019 06:47:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550674031; cv=none;
        d=google.com; s=arc-20160816;
        b=Rd353bo1DPTNmreyrmOPYZOEnAEcF6+iMX/3Z1t4tqS/z6aa94iZU5f8u5YZM4Umzc
         OuVUTPqOFj1gTeDoOVBati3KH3o8DDQzcZRhEQwIyUClqQY4W3nqdS6x7dsT33qMFQms
         fqsubOEs/jK6YE59S4VZaez8qbfi2U7HPOCeFIH0cJijjohSmCLlpGt+O4vQDNOqn+4/
         U0AoSPmpEfCNBp8BtY0/h3UwiVBhw84w12Bs5uT+VDqT0wGztEntERQ6yETOvKxpUVNn
         a7dI4DhiGgr09lOaB+ctFv7XP1Yu2rAv2lUZy4VJICF2AVzKuuAEZA78zPkBwoSydq1+
         r8hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SrI/FJBTs0f7QGuwCzmZ98JDTGTeZ1VjwTrAiXfJXlU=;
        b=W24kTOUm7pXpuO3QVkzHDfmU9PCVRG5303iKz4Yp/lajmgnk8gUItgyRPtny2XStvk
         gmqsIkH3mSiezcYWLxHojoPJjQ5xHCKTciiHbCCwOo6Zh9CQCqErZBJX9V6Iw0L6XhWI
         PtmyfLK7EOyt5t3s6+1P9QInxqTSPJUOOgcWAxBEiHVjBZ/7hZ9msVTk7COU9nbWnYLN
         SM0jY2J1yLogC9Qh/hM3O5i3K6+jKOGkC7vUK2ofVTkXZ9VJmMJ9Sw3Gl2SYz/H+21FE
         h1+7kg7LlBMRhQ4+bCjqFOAtZohmKtdEAz8vtuWJo2TKBoW6WjgM/+zPBL4ciz0gwCdZ
         kOCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t17si7628247ejz.87.2019.02.20.06.47.11
        for <linux-mm@kvack.org>;
        Wed, 20 Feb 2019 06:47:11 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 17BBB15AB;
	Wed, 20 Feb 2019 06:47:10 -0800 (PST)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2751B3F5C1;
	Wed, 20 Feb 2019 06:47:08 -0800 (PST)
Date: Wed, 20 Feb 2019 14:47:05 +0000
From: Will Deacon <will.deacon@arm.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org,
	npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux@armlinux.org.uk,
	heiko.carstens@de.ibm.com, riel@surriel.com, tony.luck@intel.com
Subject: Re: [PATCH v6 06/18] asm-generic/tlb: Conditionally provide
 tlb_migrate_finish()
Message-ID: <20190220144705.GH7523@fuggles.cambridge.arm.com>
References: <20190219103148.192029670@infradead.org>
 <20190219103233.207580251@infradead.org>
 <20190219124738.GD8501@fuggles.cambridge.arm.com>
 <20190219134147.GZ32494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190219134147.GZ32494@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 02:41:47PM +0100, Peter Zijlstra wrote:
> On Tue, Feb 19, 2019 at 12:47:38PM +0000, Will Deacon wrote:
> > Fine for now, but I agree that we should drop the hook altogether. AFAICT,
> > this only exists to help an ia64 optimisation which looks suspicious to
> > me since it uses:
> > 
> >     mm == current->active_mm && atomic_read(&mm->mm_users) == 1
> > 
> > to identify a "single-threaded fork()" and therefore perform only local TLB
> > invalidation. Even if this was the right thing to do, it's not clear to me
> > that tlb_migrate_finish() is called on the right CPU anyway.
> > 
> > So I'd be keen to remove this hook before it spreads, but in the meantime:
> 
> Agreed :-)
> 
> The obvious slash and kill patch ... untested

I'm also unable to test this, unfortunately. Can we get it into next after
the merge window and see if anybody reports issues?

Will

