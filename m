Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77632C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DDD120679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:41:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dUWu615y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DDD120679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3EEB8E0003; Tue, 18 Jun 2019 08:41:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C16DB8E0001; Tue, 18 Jun 2019 08:41:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2CA48E0003; Tue, 18 Jun 2019 08:41:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93EDE8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:41:45 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s83so16028035iod.13
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:41:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tU+uoH636LnLs6tWofoR44x7rXbC9eLZS1/AxRoae2A=;
        b=rF96pw3MFKe9GS6Wa/KVGMo1uf2tnhxGAxeozup/p3ImIfScUnjH5eJ1Z0KbdlkU3E
         cxlh5c97wRyCxrU983yARA1KUlRC3Oy8XS/8SkC2pQPlA++RNzeMFXrRjROpoq3zSYAR
         pAkhYFrqycp5seWt8Nh6HAC03EgblqcD5I5lP7xx2EVlx8anQ8yk8tcll+lunUjxvs51
         NxpW1IneF1f9EkXM9M/ZadPmPyQNsIefmS/PxaCpAmphDNp2YxXb71tqoED2w3a2eYm6
         qHncJeNdudGe/T+tysGtf7sCSs+KgYDirfjcOKekD542n3MsAZ/FBO8MKiYmASLmOzpS
         l7UQ==
X-Gm-Message-State: APjAAAU/1Kxc3h2pxSFPVzrUvMEkj03x2GOVvE8Y57km03fYnKgX3gcT
	0bQZdbmXNKVmN3okXnDqYC9OKBpRbKfFuOmt7ED+MNh6E3jEXa6L8XW62DD1a7w7a3iAqnW0dm+
	5PzcOlqf2jNjOyUmtywpWuL110aMk/KsIflQkgIneKGzcv2NiCsXjP54naMlw42YiLQ==
X-Received: by 2002:a02:ce50:: with SMTP id y16mr89249582jar.75.1560861705004;
        Tue, 18 Jun 2019 05:41:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwSedI8DtLRVgz4isZl8OtagKGzA8oD7IgLMKsTxTz2+ARwIY2EY4oI/HmXtTiUMDUErVe
X-Received: by 2002:a02:ce50:: with SMTP id y16mr89249371jar.75.1560861702573;
        Tue, 18 Jun 2019 05:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560861702; cv=none;
        d=google.com; s=arc-20160816;
        b=PVYu0x7Kuvs57qpcNkK5AHbMpt/2VQNkxOH/S/ReufU1l3OrA1/9ktOWmdsPWfbGIE
         HPVyV42AACENwdJNMF0/u7v5Emy0jVCWR+netTLUaP+wy6EoxOaqLkyxBkYKW1ur1AoD
         F26UPsI/5wS4hxcY0g5nwyLTQxIA0geVun+sy3ZD0vtSm3TinIrxZSrYUfLkHTGK+fa6
         h+03+i9Mm4p+K0hHmgevz8O6ax++sqWNkp3PWrysaKP5xyZgYqSwOP4h5K53W1t8V7Hl
         srsaGvVxrzYamVy8auqvncT1skagyYcPdbKD3g13H9mQqrbu/R55HmtKt5X58IXl/9GW
         1ZVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tU+uoH636LnLs6tWofoR44x7rXbC9eLZS1/AxRoae2A=;
        b=RPAFoESnzipeSIe/O3dmp3cjcWI5VAVwX4ud+VG8V9TRjPcB82s1F5FaxUIONAiD3P
         SVCDU/pdCNmW3FD+NXFvV8n6QrUNj0tHi7b0chQnxLqopfLKg0aFvG5JpqEkLrA0B6rw
         uPkCPzSlnTJm6t/+MwHyNx2RKjymsk8PzwJaCVGq1yXfilgtYoBJivxWkbZYVui/0oD1
         fwj1UG/+CnbBJlbrIHngPXJe06IbKde/4xlk7i2cSejRRnyFqx+FMQt/MqK8QPoc0WKn
         dyHcenujeaS2ohYnxJf+ms28TgsurCtXrAwzKE7CRpeG43TTeLUD5YxtTyi/nYD+ZToB
         Bk4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dUWu615y;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a62si20146687jaa.115.2019.06.18.05.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 05:41:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=dUWu615y;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tU+uoH636LnLs6tWofoR44x7rXbC9eLZS1/AxRoae2A=; b=dUWu615yd4Eq0frSeVJMzBQnr
	c7NZoCsnZO11ofhGx28MfjNFgfdgnq+WNL46xVo1bkwml4T7hWh1kog4kNWUyrbd75WdvkK7nZmlH
	J54e4GW7oZGuunIRilDjhExoD/2oYz/DadDxTnEu4uU7iPv+gZNirnpq1VXc8bgoCxhxmpnNSt96x
	z4GHkSRBLpcc4tRATSGSTlAkXuJJVcLR0OV1zeyBLu9QDskQswnG7ZKZg07d+Xd3D5el6+FGgGOvz
	dla09z4BqHqHrFOoAq5S+/i++Fi390VrVCyimBkasZRwofWz+sZ0y7uEmCfgeodjXhMJN9SKCvJlx
	FXmFJ4xdg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hdDQR-0007Pf-Bh; Tue, 18 Jun 2019 12:41:23 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 22F1F209C88F8; Tue, 18 Jun 2019 14:41:22 +0200 (CEST)
Date: Tue, 18 Jun 2019 14:41:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Florian Weimer <fweimer@redhat.com>,
	Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190618124122.GH3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-23-yu-cheng.yu@intel.com>
 <20190607180115.GJ28398@e103592.cambridge.arm.com>
 <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
 <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
 <20190611114109.GN28398@e103592.cambridge.arm.com>
 <031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
 <20190612093238.GQ28398@e103592.cambridge.arm.com>
 <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
 <alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
 <20190618091248.GB2790@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618091248.GB2790@e103592.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:12:50AM +0100, Dave Martin wrote:
> On Mon, Jun 17, 2019 at 02:20:40PM +0200, Thomas Gleixner wrote:
> > On Mon, 17 Jun 2019, Florian Weimer wrote:
> > > * Dave Martin:
> > > > On Tue, Jun 11, 2019 at 12:31:34PM -0700, Yu-cheng Yu wrote:
> > > >> We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
> > > >> version?) to PT_NOTE scanning?
> > > >
> > > > For arm64, we can check for PT_GNU_PROPERTY and then give up
> > > > unconditionally.
> > > >
> > > > For x86, we would fall back to PT_NOTE scanning, but this will add a bit
> > > > of cost to binaries that don't have NT_GNU_PROPERTY_TYPE_0.  The ld.so
> > > > version doesn't tell you what ELF ABI a given executable conforms to.
> > > >
> > > > Since this sounds like it's largely a distro-specific issue, maybe there
> > > > could be a Kconfig option to turn the fallback PT_NOTE scanning on?
> > > 
> > > I'm worried that this causes interop issues similarly to what we see
> > > with VSYSCALL today.  If we need both and a way to disable it, it should
> > > be something like a personality flag which can be configured for each
> > > process tree separately.  Ideally, we'd settle on one correct approach
> > > (i.e., either always process both, or only process PT_GNU_PROPERTY) and
> > > enforce that.
> > 
> > Chose one and only the one which makes technically sense and is not some
> > horrible vehicle.
> > 
> > Everytime we did those 'oh we need to make x fly workarounds' we regretted
> > it sooner than later.
> 
> So I guess that points to keeping PT_NOTE scanning always available as a
> fallback on x86.  This sucks a bit, but if there are binaries already in
> the wild that rely on this, I don't think we have much choice...

I'm not sure I read Thomas' comment like that. In my reading keeping the
PT_NOTE fallback is exactly one of those 'fly workarounds'. By not
supporting PT_NOTE only the 'fine' people already shit^Hpping this out
of tree are affected, and we don't have to care about them at all.

