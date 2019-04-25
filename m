Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E50B2C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:49:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C876120717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:49:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gAtb+sR0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C876120717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 296BB6B0006; Thu, 25 Apr 2019 16:49:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21DEE6B0008; Thu, 25 Apr 2019 16:49:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BF8D6B000A; Thu, 25 Apr 2019 16:49:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id E05BC6B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:49:25 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u8so1001248ion.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:49:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7ir/Ob87pQ0rs2vZCr2bgKUMytG2Q+GSHuslKkHCMww=;
        b=NZdQ3TfLyYBK1rhGrLPmPEMhfWAhguVMejYIBq1eN7ZgzvWiO7pmFSk+eu5V4cZUgt
         PMSmxXE/DzfAlvsQbhGVRAc1RsNWFpUDyIDwcfT88Y1Y0KXxyN943FeFx8lsMhcAKYMz
         CBWDVjt6RUiDbeSQlJb2Ue7ry09ue6oE5FLPSWiImfk6GpoQ44yolPDXtWu6/UzJ9CVy
         bApEUBtajX624FLbb42hlcSUYeCBr2ct+d/uqZhoLH2b0ddqp/sdIN9y9EmZMXnrSKXE
         4g84vcl7yXuBdVKah1Aa0irlLp5JgyM7QsQc07KMy1qKD9GD9qlkKBbuUdlWyT5kFIUV
         kTOg==
X-Gm-Message-State: APjAAAWqF1ny7Ntk5GHch/MXtIFHYv79Tm6ETMww3DCJHQBP4uNK90XQ
	JxRAO0A+IzpPTCj51BVmUPiQYddkRrcAs4GeMCa4BxvfHmPgOXsYdHQgnKUtH3f0xBKRjzrVGmq
	Xd3EuPEhzGvkcFY+SQgNasheTqf/s85uycyUvDrMEANlps2kbockUBvDswc45/mHnMg==
X-Received: by 2002:a24:220c:: with SMTP id o12mr5579042ito.1.1556225365703;
        Thu, 25 Apr 2019 13:49:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwue4Dsoco35FgaV54Nx27C+7d/oAWxPPDPNXkTZZEbnwW1EDeQrWV8F5tCfGQEhTdcHuyk
X-Received: by 2002:a24:220c:: with SMTP id o12mr5579008ito.1.1556225365121;
        Thu, 25 Apr 2019 13:49:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556225365; cv=none;
        d=google.com; s=arc-20160816;
        b=jx0l7IWxj7l8Q7D7hyY9G+/QKmjD1WrIsG88OAcFGvUArCX6C9uvEQKqJVZjEMHRJZ
         GaYM6HGragso6Fwu0DCAZ9zvoGgf4XovqMKCyABWUVR4zue4duT9oP0LfAkkbg4Lqhn8
         EDotpJ+pQV0DQGmkETGIxS9U5MDcciwr4e6Psk+Omvv4iRCvGJbz7M3b4V2acaBSo3j6
         TFfY9wu4eJFvn724+3nOUGiSr8X9/uluDib7vMM4oCcVsCSAxkKP2y83zOm09awqNTN0
         jKRO9JlYY8OqvgpPZzI389lcVE0GtP9dWw33vvkDGEqA7DggV1CQa4Di3BtKQHVHK2/o
         JH5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7ir/Ob87pQ0rs2vZCr2bgKUMytG2Q+GSHuslKkHCMww=;
        b=PkQntvCoTPhR2U7BynW5pyPtaiaFdUxhrI8C+I3W+GvYFFL4ZQboXbhmdCfxKsebv3
         DInSqa2VL2IaEjpiGVgp6AA4PQg+KOQXuudVjSxh/phtum5+XGzaJwdYEXUSB1zs9Ga3
         4jJiknum+ms9g9+VSMaE7US88JHXShDqUGaz+O6BAXffr08bMCgxZLl/YZZNz1nhSfX5
         ch2EQMGrfvmy53CrE/WH2ioEaY9CiT9VZcB2ijVrHzcnBrVe8Kjskf/KzkVTa3+GAP0s
         xiGdjKmpK6cj/cq+2xVIbpL6L0rAXFHsjERN6WnCR5ysMs+Q7glz5/0VbVOqDR8aqoXD
         69ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=gAtb+sR0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b26si14631935ioj.43.2019.04.25.13.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 13:49:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=gAtb+sR0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=7ir/Ob87pQ0rs2vZCr2bgKUMytG2Q+GSHuslKkHCMww=; b=gAtb+sR0GhWoVlxbYWUeTHc6P
	PZONDwqR012yGTlh8Mhqn2o10SWwc7aCnIRJ/3ftTZWky3667hbF61V/qSaBrU9zPS2FdqCw7ED3G
	yZbDZCXvT5gCjxUbyp3kfz8SSvYWU82KeGi91/FMDL9+7N1ASruM6DZPOPzHjfrfM+GmkmKYnMeRP
	GP8hZmrio3SQ9OFSzdgJwB7u2uHE0RtIbeALfrvi92udEQWTK7o7jOgWDIeTZVsu1lOoud17c6mu1
	M6EKPSqM9iEKQWZDGvoX7mbxMPxPNGSbP19n6VM9r9k66hVrmCX5/PEkuDxo5eE/IQQ+VRYsPMlIs
	AAcWKtCrw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJlIp-0002iZ-2Z; Thu, 25 Apr 2019 20:49:07 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 466D8203C0A58; Thu, 25 Apr 2019 22:49:04 +0200 (CEST)
Date: Thu, 25 Apr 2019 22:49:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v4 00/23] Merge text_poke fixes and executable lockdowns
Message-ID: <20190425204904.GE14281@hirez.programming.kicks-ass.net>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
 <20190425204820.GB12232@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425204820.GB12232@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 10:48:20PM +0200, Peter Zijlstra wrote:
> On Mon, Apr 22, 2019 at 11:57:42AM -0700, Rick Edgecombe wrote:
> > Andy Lutomirski (1):
> >   x86/mm: Introduce temporary mm structs
> > 
> > Nadav Amit (15):
> >   Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
> >   x86/jump_label: Use text_poke_early() during early init
> >   x86/mm: Save DRs when loading a temporary mm
> >   fork: Provide a function for copying init_mm
> >   x86/alternative: Initialize temporary mm for patching
> >   x86/alternative: Use temporary mm for text poking
> >   x86/kgdb: Avoid redundant comparison of patched code
> >   x86/ftrace: Set trampoline pages as executable
> >   x86/kprobes: Set instruction page as executable
> >   x86/module: Avoid breaking W^X while loading modules
> >   x86/jump-label: Remove support for custom poker
> >   x86/alternative: Remove the return value of text_poke_*()
> >   x86/alternative: Comment about module removal races
> >   tlb: provide default nmi_uaccess_okay()
> >   bpf: Fail bpf_probe_write_user() while mm is switched
> > 
> > Rick Edgecombe (7):
> >   x86/mm/cpa: Add set_direct_map_ functions
> >   mm: Make hibernate handle unmapped pages
> >   vmalloc: Add flag for free of special permsissions
> >   modules: Use vmalloc special flag
> >   bpf: Use vmalloc special flag
> >   x86/ftrace: Use vmalloc special flag
> >   x86/kprobes: Use vmalloc special flag
> 
> This all looks good to me, I'll queue them tomorrow when I'm awake
> again. I'll move the last two patches to early in the series, since it
> appears to me they're fixes and should be in place before we make the
> situation worse with the temporary mm swizzling for text_poke.
> 
> If you want to post a new version of patch 4 before then, that'd be
> awesome, otherwise I'll see if I can do those few edits myself.

Patch 3 that was, see, I can't even count straight atm :-)

