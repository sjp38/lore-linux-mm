Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8AD8C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:36:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F1D120B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:36:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="yBSWChLq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F1D120B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E07DD6B0003; Tue,  6 Aug 2019 06:36:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D90876B0005; Tue,  6 Aug 2019 06:36:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE3976B0006; Tue,  6 Aug 2019 06:36:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84B186B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:36:32 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s21so48061734plr.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:36:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q0Wilp6roBIsdQ40Pa0gikkfrKuFSJkj9vHJ430JGZ8=;
        b=bCIBu46Mt+MDugIh2EprhvPr85reTczkH2x2rAdo6Bzq2DXcppZqJpJIgH21697ryy
         ucG1ogZIIE0IJDoE/5hrZWp3U3iznRehz6DPSfaEFf7dOUIONUKUqVpKgf5TQZVGJIwh
         jZK8Dg3/tY3zkIlo6qUC8zAeFJ2EVCANhbHJYG48kYJmnAkjXKt1V6ECl4feHKuEwXTl
         aMvhNFD5gdWWKK3s2Yd+e/drg8l57dIKzjyRY90oOVbp8XLd5WY29HWJKesXFYcp0wI/
         DAeROcL0omHOWPTCrB72MSIzIgBbECEYKyrxV7fo4dYdhGDJ6w4jFh6r80Uej6ODmAM2
         EUXQ==
X-Gm-Message-State: APjAAAWPLMZtC/bpsmzjrkuotBreYwniC83w8j1Jtn3D3Y/NAdrdSQ0w
	nyePFdX/YtZSLNluPauKfldA2fiT6DdhSC07MRP/ZcxHUX+Ua6wTYVYEViLLKiRIkei9dFade27
	UyjqkbMc4z60zCYWtDCt7gHon//MaEt92ut7mqCfz9VaniAhkCCBcp8anGTa9FfZH0g==
X-Received: by 2002:a62:6:: with SMTP id 6mr2884820pfa.159.1565087791997;
        Tue, 06 Aug 2019 03:36:31 -0700 (PDT)
X-Received: by 2002:a62:6:: with SMTP id 6mr2884756pfa.159.1565087790988;
        Tue, 06 Aug 2019 03:36:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565087790; cv=none;
        d=google.com; s=arc-20160816;
        b=nuJtlsaJdPaN9g7dZtGk5FsoCAfZp19uOWJ3Pt0Vx2u6OctcRqVmZ5hLfzkGMkTvJk
         Eva9B8mwPp1eTJBkjF+i8rrMVphrjkL/vUtAesMVj41N9KskbM7Sab6fjy/kaq9gA8SS
         4k8DVF/TjBTbZ8oGKwVERWNEvRy+NPQlqCzQkyrqt8O6h3aHHBJ1+BSVgctlx5LaW+7b
         48gKzSKB0tYoMf7c8xpb/MIGmYz7PrBs9WvxUDQlQaJJKSsd66oYdz13Q/S6pWZ1uEzq
         TodFstK/BVvyXsAaKQiCmG2MIrM3SpCJydMdFCTuGVhW/nL4KaZrfIWshANhGk0R9TqQ
         7Hfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=q0Wilp6roBIsdQ40Pa0gikkfrKuFSJkj9vHJ430JGZ8=;
        b=Ay5Ay7S5XQSN67zxIJTd4OJcMLchrqrG64kPiF8jmTB7hc9BaeD40Y0N8odEltuf+E
         /p1u6OBpmIrdxdGbVOOvEa1YThBplUetJJAUh/D5B3GsGdPXbtSJP4Rh7yF6G1OWxDIc
         7m5P7nxA8HH+lwTxKUvrp9Eu5MwOzfrM8tgYai0nIp2JxoE7dxKJSaCDEpNRVtQPEQwm
         /xtanqeMbjqfL4bZGPAhP7rx5W5x6EAFz0PsY9Mh52BywwsjVSj4pXKDh4MYGYG/ZvrG
         Ni9QO6P+kHhMTQM76zRse+rLXLq/TZSS3oDONoROC515pK/qo9vOtus3cnLOtinqtbo0
         bEaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=yBSWChLq;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj2sor103240245plb.52.2019.08.06.03.36.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 03:36:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=yBSWChLq;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=q0Wilp6roBIsdQ40Pa0gikkfrKuFSJkj9vHJ430JGZ8=;
        b=yBSWChLqbeoq5PRv1NFDpgqkTe+IWZ0NXp3UXkWOdUFbznL4X5s9a4jX9e7zqwGMsP
         7siDaILd0QUW2OiwTs2TBkA2nguDPr7Gw3/0ZiosrM67X3yu5+zmOU8YxJM9GNeOlYRi
         FWNYZppcftyNVxczw/mmMiQOjJeqjapSl9VBI=
X-Google-Smtp-Source: APXvYqxI32lagxLu9cZ/Ui9N0pJztkq18ietG60iUZs8inFhbhnQnPT6tWK0xEvWGoQOr/kBgINWoQ==
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr2564494plr.198.1565087790447;
        Tue, 06 Aug 2019 03:36:30 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id j15sm99017998pfe.3.2019.08.06.03.36.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 03:36:29 -0700 (PDT)
Date: Tue, 6 Aug 2019 06:36:27 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Robin Murphy <robin.murphy@arm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
	namhyung@google.com, paulmck@linux.ibm.com,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v4 3/5] [RFC] arm64: Add support for idle bit in swap PTE
Message-ID: <20190806103627.GA218260@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
 <20190805170451.26009-3-joel@joelfernandes.org>
 <20190806084203.GJ11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806084203.GJ11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 10:42:03AM +0200, Michal Hocko wrote:
> On Mon 05-08-19 13:04:49, Joel Fernandes (Google) wrote:
> > This bit will be used by idle page tracking code to correctly identify
> > if a page that was swapped out was idle before it got swapped out.
> > Without this PTE bit, we lose information about if a page is idle or not
> > since the page frame gets unmapped.
> 
> And why do we need that? Why cannot we simply assume all swapped out
> pages to be idle? They were certainly idle enough to be reclaimed,
> right? Or what does idle actualy mean here?

Yes, but other than swapping, in Android a page can be forced to be swapped
out as well using the new hints that Minchan is adding?

Also, even if they were idle enough to be swapped, there is a chance that they
were marked as idle and *accessed* before the swapping. Due to swapping, the
"page was accessed since we last marked it as idle" information is lost. I am
able to verify this.

Idle in this context means the same thing as in page idle tracking terms, the
page was not accessed by userspace since we last marked it as idle (using
/proc/<pid>/page_idle).

thanks,

 - Joel


> > In this patch we reuse PTE_DEVMAP bit since idle page tracking only
> > works on user pages in the LRU. Device pages should not consitute those
> > so it should be unused and safe to use.
> > 
> > Cc: Robin Murphy <robin.murphy@arm.com>
> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > ---
> >  arch/arm64/Kconfig                    |  1 +
> >  arch/arm64/include/asm/pgtable-prot.h |  1 +
> >  arch/arm64/include/asm/pgtable.h      | 15 +++++++++++++++
> >  3 files changed, 17 insertions(+)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index 3adcec05b1f6..9d1412c693d7 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -128,6 +128,7 @@ config ARM64
> >  	select HAVE_ARCH_MMAP_RND_BITS
> >  	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
> >  	select HAVE_ARCH_PREL32_RELOCATIONS
> > +	select HAVE_ARCH_PTE_SWP_PGIDLE
> >  	select HAVE_ARCH_SECCOMP_FILTER
> >  	select HAVE_ARCH_STACKLEAK
> >  	select HAVE_ARCH_THREAD_STRUCT_WHITELIST
> > diff --git a/arch/arm64/include/asm/pgtable-prot.h b/arch/arm64/include/asm/pgtable-prot.h
> > index 92d2e9f28f28..917b15c5d63a 100644
> > --- a/arch/arm64/include/asm/pgtable-prot.h
> > +++ b/arch/arm64/include/asm/pgtable-prot.h
> > @@ -18,6 +18,7 @@
> >  #define PTE_SPECIAL		(_AT(pteval_t, 1) << 56)
> >  #define PTE_DEVMAP		(_AT(pteval_t, 1) << 57)
> >  #define PTE_PROT_NONE		(_AT(pteval_t, 1) << 58) /* only when !PTE_VALID */
> > +#define PTE_SWP_PGIDLE		PTE_DEVMAP		 /* for idle page tracking during swapout */
> >  
> >  #ifndef __ASSEMBLY__
> >  
> > diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> > index 3f5461f7b560..558f5ebd81ba 100644
> > --- a/arch/arm64/include/asm/pgtable.h
> > +++ b/arch/arm64/include/asm/pgtable.h
> > @@ -212,6 +212,21 @@ static inline pte_t pte_mkdevmap(pte_t pte)
> >  	return set_pte_bit(pte, __pgprot(PTE_DEVMAP));
> >  }
> >  
> > +static inline int pte_swp_page_idle(pte_t pte)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline pte_t pte_swp_mkpage_idle(pte_t pte)
> > +{
> > +	return set_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
> > +}
> > +
> > +static inline pte_t pte_swp_clear_page_idle(pte_t pte)
> > +{
> > +	return clear_pte_bit(pte, __pgprot(PTE_SWP_PGIDLE));
> > +}
> > +
> >  static inline void set_pte(pte_t *ptep, pte_t pte)
> >  {
> >  	WRITE_ONCE(*ptep, pte);
> > -- 
> > 2.22.0.770.g0f2c4a37fd-goog
> 
> -- 
> Michal Hocko
> SUSE Labs

