Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 519F5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:30:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB10B206B8
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:30:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB10B206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542456B000E; Fri, 29 Mar 2019 06:30:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F3936B0269; Fri, 29 Mar 2019 06:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BAA46B026A; Fri, 29 Mar 2019 06:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E12126B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:30:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k8so845590edl.22
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 03:30:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yLalvT9qp+I3mb+qZmzfhEHj3FpHFTcgnBAsJnQl8Es=;
        b=B4NH4HOWsp2k20zeZzhcDfmn55nQAR5CT2MIONIVK1poLP9seXhDmHSF4l/p1W/1OJ
         GiQgNVnftRkRzK7zmdxg39o5uHLTKr6GYYBETb9xpG+Nq0KKDYUQDc0k9NiAMg7ajW+Y
         pLd38/4U76ZYcCfISI7/B+YZ7bPwibSwMrIJRKVqLw8X4fLaSmB+vRusnRAYRSrziUsO
         Vflgjbo8zo4L/l8gZnkjAE6b19osrjoM/yZyM2JnS5yGAXtlGZWDtEGAb8hwxGBA7dJ0
         uvNUldQsx3XFN2rQGekL9jD5YxygV2nuYTGm0c1UrJPOfyDVdgpG+JkDsDMAwQE0bDOa
         MclA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWif8HLHTx1k/0fYAdkmZPjT+Xmr3HlvULZoQ58J0qYJbwhvabj
	jyN800PoYd/kH3SEl+RQjr7NyrPrxP8EY5Y8Ldx81x76I2Dp9oEJPWrAu8vE+D+s7zP8ZOXgqio
	fDP2PIQofGzGNR/dooF+vH+8SVlgyMsd2t1lpocTfcCt3Vh2iWWGFDOFtX7piKTG/og==
X-Received: by 2002:a17:906:1347:: with SMTP id x7mr19311856ejb.64.1553855450372;
        Fri, 29 Mar 2019 03:30:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRJ7s+nvdcW8yo8s3XoU8skHKwyweFExUmQBM5VDEj3VyB8MacCFN+yHHclJjmXS4M5pNf
X-Received: by 2002:a17:906:1347:: with SMTP id x7mr19311795ejb.64.1553855449079;
        Fri, 29 Mar 2019 03:30:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553855449; cv=none;
        d=google.com; s=arc-20160816;
        b=Ty/v+knQkaZrPxIGGWXkuhn7NQ44HSMxWDFJ+Z2+jTYHn7zshv7HRn/vtqkOk8+HGK
         JQn1o5V7K5VnmErBoEuqhbK30JvSzyC3t70HG43ptiJnwn+PptcW4s0bm9Lugt+xfbhD
         0r+fCBbvJDy4jirEXLWVzSggtGdIie0j5CG4/Al6glHLSpfIL6frBJ70ZsRhSIQPXiG8
         TBQaNU4zOYItLWRc1LD50HT4tOiZHBBTDdyzA74bl7S0zrmcN6LvKWMOcrSxMfkC1oci
         QUBDAkkPlTX61a4Us8P+Z4vX/WwB7373FvD+mSnnBkrZi1IBz7joZoW86EQsDDszlxQg
         h2PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yLalvT9qp+I3mb+qZmzfhEHj3FpHFTcgnBAsJnQl8Es=;
        b=NQkaMuHdT3V6GNZ7n3SoYFZKC1LruXyHWbb3SCRVSFuljHRxxYkpgVFpPYajgeUNgU
         xGolLSe3Y+xTmS6sx+t6Oe4iVAtC+GWlWtk6OJsxr6YDX4ZCtEQG6sFZUjTPLGXR71l/
         5SKlLVRp55t8agw7GIyLZ/tzP7J/WiMAwdfrS4VmeNiYErzc9gWRUM7pA4bMK0b93oC9
         AfMwL4CJ/rrZVxcngyKcgWw8ekyNDR4KtCBIVl3crWl4Hp7Er9yelK2fg8uzgaa+2xta
         JFPn72Y4IPaBXJOaQXhptUURxti/qmeJWHcY3JjCcQYsxiGjacw5mODktznwcmXfIraz
         dltQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a33si784045ede.173.2019.03.29.03.30.48
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 03:30:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9F756A78;
	Fri, 29 Mar 2019 03:30:47 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 817863F575;
	Fri, 29 Mar 2019 03:30:42 -0700 (PDT)
Date: Fri, 29 Mar 2019 10:30:40 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 04/20] mm, arm64: untag user pointers passed to
 memory syscalls
Message-ID: <20190329103039.GA44339@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
 <20190322114357.GC13384@arrakis.emea.arm.com>
 <CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
 <20190328141934.38960af0@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328141934.38960af0@gandalf.local.home>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(I trimmed down the cc list a bit since it's always bouncing)

On Thu, Mar 28, 2019 at 02:19:34PM -0400, Steven Rostedt wrote:
> On Thu, 28 Mar 2019 19:10:07 +0100
> Andrey Konovalov <andreyknvl@google.com> wrote:
> 
> > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > ---
> > > >  ipc/shm.c      | 2 ++
> > > >  mm/madvise.c   | 2 ++
> > > >  mm/mempolicy.c | 5 +++++
> > > >  mm/migrate.c   | 1 +
> > > >  mm/mincore.c   | 2 ++
> > > >  mm/mlock.c     | 5 +++++
> > > >  mm/mmap.c      | 7 +++++++
> > > >  mm/mprotect.c  | 1 +
> > > >  mm/mremap.c    | 2 ++
> > > >  mm/msync.c     | 2 ++
> > > >  10 files changed, 29 insertions(+)  
> > >
> > > I wonder whether it's better to keep these as wrappers in the arm64
> > > code.  
> > 
> > I don't think I understand what you propose, could you elaborate?
> 
> I believe Catalin is saying that instead of placing things like:
> 
> @@ -1593,6 +1593,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
>  	unsigned long ret;
>  	long err;
>  
> +	shmaddr = untagged_addr(shmaddr);
> 
> To instead have the shmaddr set to the untagged_addr() before calling
> the system call, and passing the untagged addr to the system call, as
> that goes through the arm64 architecture specific code first.

Indeed. For example, we already have a SYSCALL_DEFINE6(mmap, ...) in
arch/arm64/kernel/sys.c, just add the untagging there. We could do
something similar for the other syscalls. I don't mind doing this in the
generic code but if it's only needed for arm64, I'd rather keep the
generic changes to a minimum.

(I had a hack overriding __SC_CAST to do this automatically for pointer
arguments but this wouldn't work on mmap() and friends as the argument
is unsigned long)

-- 
Catalin

