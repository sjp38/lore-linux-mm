Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0899C742C7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:21:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50B79206B8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:21:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LRpvbwuy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50B79206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE5DF8E015A; Fri, 12 Jul 2019 11:21:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E976F8E00DB; Fri, 12 Jul 2019 11:21:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D859E8E015A; Fri, 12 Jul 2019 11:21:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A163A8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 11:21:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so5866976pgg.15
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:21:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uWWyW2YDtC0k6gJbqvGGDtXLIh/dygPNqHBQzuripY4=;
        b=CLJ57OWipxl8rLKq8QvYIWG8VE7DNqhGqKNlr5hS++yNrW7RRhhNTCkqCZ2gkGFTFp
         OJUzBJ8DHjAP/v6/NUYodCVs8Ka6Vb09p2ct69+78cfwQvxmQaDPEZ1sXQNTELQwsod4
         wvqK0uDHPn3YLn0R5G9kNh6cSvc7MUC4J5YgZdv9irKviDCoDdX5S5WOBlxcm74k+oo6
         u5e0Q98P5nvgCUCMI5oQJjZzFshWinx95g1R/ulRfHGWfkwTQIXdKFuWMVWcSdAKw8Qj
         ax1JAhDOESHcJmEsNkPRy5QEp8dc7ncTmSJylD18OLSbgufhSP9wEzVJL+NSN74oZa5R
         GIug==
X-Gm-Message-State: APjAAAXEQ1nCE36tD4gc8l9B5kZCMic1nY4pWLrQGHHk25lCR3kyEUpt
	AzvpywdZmMZzSr9vOIeBb0YCJMr2OxkwB6Cfsv7zeYNYquCATomJEqlLc6sTkt/lgZ7OmAiDvDh
	GUYuyr4dlZRQ8v0xnvNCpKxrpDBZcU7ez31bxAXq2vAW63Iz0M8daPfYV+5t7IyOTjw==
X-Received: by 2002:a17:90a:8591:: with SMTP id m17mr12642652pjn.100.1562944863267;
        Fri, 12 Jul 2019 08:21:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoMsSrNrPENrUPwej0uW9z2R1hMKL8ORh6FXgKR9/kSzrbg+VThWXw1Dy46ZKXyA5SngyK
X-Received: by 2002:a17:90a:8591:: with SMTP id m17mr12642593pjn.100.1562944862529;
        Fri, 12 Jul 2019 08:21:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562944862; cv=none;
        d=google.com; s=arc-20160816;
        b=CK3Oh3ZQxGvVPCrW3Hd6M654ltD948vVpuDmXR7hWuZL5U3PBs7igYeVfsr0g+mejm
         OtRz7E1Cg2ZhABn2C20fP+XNndDBJGSUwXVgaYsvNe7r1xIg8V4z0LBbpva1nekRWnbP
         DZOonK29tkpDPw3WoPGSvuCnOTiDYliBqcYwAM05UZSwFmkZZTYWzubL/PKrK3LBNVLG
         FzV+olHahOBBksl0LPh4dWMwf/1PAiyfhBdQ72fk+7C648IvUlm8QN0lXKuUddEfZ4k5
         Q942VRR/XpWs2tnW/hYs+7sh7R+bLpWXrNZsxF4FuVvI7y3ei9/5x8igV85/r7l6a/C6
         +9BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uWWyW2YDtC0k6gJbqvGGDtXLIh/dygPNqHBQzuripY4=;
        b=CHtkICTp9qLHLbgWEcXDF84w/wbEmJuBAII7C2T9dHwTSjEbI3yS3tis3gAXvfcYu7
         8A0JYFLrHrqSrD0IHgQNHfT0fbjYtUgWkHzF5JRHQ99bYFs8ZD3Pzxw5SRslDjBdgjsx
         MrjpfG2gtvfCZCTCtdaq/PvFi50VlXJEqKFRl35YSO8ugVXuJyOLTrpW0Wg+YdTCjS8B
         5HeKGYbLSsJZRj42q82ESoM9UUWy7Zb83KGww0nzL+X5XvyXOOmG0DrgLfQEKgCv8eDG
         Bcem6jdCuRxe6g8gF00m0BuzZ6eSXOU6Hk5SlHOe9KSyFzzTxJ5mHGRpwd3+ZgYfCXTB
         Wd+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LRpvbwuy;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e123si8551148pfa.252.2019.07.12.08.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 08:21:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LRpvbwuy;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=uWWyW2YDtC0k6gJbqvGGDtXLIh/dygPNqHBQzuripY4=; b=LRpvbwuyvthu0RGBF/kNz9WT4
	TvL6NJFgmKj1YTbH/Q1luwGXROnKib4MoSJRSv36BWnauvOLUIjs4IYaxouYot6WbBAdgj1hGzwzV
	Zhk33bc+ETttOzwYzdkhEDyoYIZHYI8AxkXD+O0QV2M0khTOByI/JtZazzxSVMtWSt5jBFPpm0Gyo
	fipS/Gh/19/eM9Uc5e6dEc11Tz1Mm+DDcAvtfQfB79lcdLherqODj9TUFRVqvOlyRCVMME2XWZ3ri
	RWWywWgE7IGSsa6YH1reuguPfod0XMfoiHdTp37uiPUnwGvUeKrvoUgBqlk3rEotvKmI1X2JXR4FL
	R/HLEg+Gw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlxLy-0002Dw-U3; Fri, 12 Jul 2019 15:20:55 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DE70D209772EE; Fri, 12 Jul 2019 17:20:52 +0200 (CEST)
Date: Fri, 12 Jul 2019 17:20:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
	Thomas Gleixner <tglx@linutronix.de>, pbonzini@redhat.com,
	rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
	rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
Message-ID: <20190712152052.GU3419@hirez.programming.kicks-ass.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <3626998c-509f-b434-1f66-9db2c09c47d4@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3626998c-509f-b434-1f66-9db2c09c47d4@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 06:54:22AM -0700, Dave Hansen wrote:
> On 7/12/19 5:50 AM, Peter Zijlstra wrote:
> > PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
> > ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
> > 
> > See how very similar they are?
> 
> That's an interesting point.
> 
> I'd add that PTI maps a part of kernel space that partially overlaps
> with what ASI wants.

Right, wherever we put the boundary, we need whatever is required to
cross it.

> > But looking at it that way, it makes no sense to retain 3 address
> > spaces, namely:
> > 
> >   user / kernel exposed / kernel private.
> > 
> > Specifically, it makes no sense to expose part of the kernel through MDS
> > but not through Meltdown. Therefore we can merge the user and kernel
> > exposed address spaces.
> > 
> > And then we've fully replaced PTI.
> 
> So, in one address space (PTI/user or ASI), we say, "screw it" and all
> the data mapped is exposed to speculation attacks.  We have to be very
> careful about what we map and expose here.

Yes, which is why, in an earlier email, I've asked for a clear
definition of 'sensitive" :-)

> So, maybe we're not replacing PTI as much as we're growing PTI so that
> we can run more kernel code with the (now inappropriately named) user
> page tables.

Right.

