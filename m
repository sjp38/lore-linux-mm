Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 297EBC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFEEF217D7
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:20:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFEEF217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80C596B0008; Fri,  2 Aug 2019 06:20:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BC246B000A; Fri,  2 Aug 2019 06:20:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 682916B000C; Fri,  2 Aug 2019 06:20:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19C236B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 06:20:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so46624125ede.23
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 03:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wqIpUl15KNA5TWIBL3RIm8DVAoOkpFGHBPdsUj2ei7c=;
        b=LuKzmcTlip9Dbz3Gx5bO4mBdl1e/Z/Q3CkRq/+nXGO/M7r1hPhhx70jjRynNDzgE97
         D8+m24aVnZyrsWV35/TrEGx/JJ1TlRlbd0dXR5bQXeZxCqjQG+aXSpimDmmcB+rePdCc
         1XbW/1zOyXh/MVNdynGjZHB1hs1wndZdH4vK86XlsXkGyeI+GjsT1MORcj44p5yzKcgg
         KXgu/lnQdegVp28B0LkAy1BU74Mc+Jm9sdMZ7nUmjwpd+XROZtKr8b9FYWi0xR/+ZSJL
         bwI5me3k8W/dZn9BgszwbmvLQKkvH1prNycFYzsvcyAOjSKxEoNBd2XQ3K/9gjwwSpXn
         L43A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWsSubzEYjC8Jt+7ZMZdzLAwoXhHJeg7hfhDYR0lpEDdIoatbjF
	YUze6Q0IYokROUHtA3kOIAwfqyJhV5gUAtWiMRrJ0ECBwiQ1PHqqG9xUvAM4IUOcdFrTgfBjmSG
	ynEclihNhvIcjaOav7vgMGzL+7aOOPXJHDj7TsbNxdrOj2fvs+TGwCM/jNfCR2T4dSA==
X-Received: by 2002:a17:906:2f0f:: with SMTP id v15mr99852802eji.33.1564741240658;
        Fri, 02 Aug 2019 03:20:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/zEqnGVE0IB++CU2SYSM2SMa363jCjiQcaMPPTZWclVFVVeO1vy+arJbnAGE8/+3nDHlR
X-Received: by 2002:a17:906:2f0f:: with SMTP id v15mr99852752eji.33.1564741239855;
        Fri, 02 Aug 2019 03:20:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564741239; cv=none;
        d=google.com; s=arc-20160816;
        b=iByM0IQ4zZmg4XGdYM7lVhwi+C5wKmYggV5hcvuplyDEVmlGkyOHnnJo7m9mT+8SQb
         qabSL51mO4IsME4JY+A9o219s85+Qvhfsuq/3/lNsHUTRpo1vhLpFkDEFVhszAKDTxpP
         h/ciJiiGmIkea82l2e6qFPHC1q/oaZUQCkpqNJXTHsqRNU5S/cEjs9tq8wZ6nM73Zz6q
         1Y0QnK6KuU29MWPUf3tldP30AJOU4Y3Ln/xCbx62fFRMjpzOexzbL2/pNgzF5P7NyxEl
         bgR1adbEVAuJHpFvmyMrphCMQtyLpBeFaTu3lDNCQLhWOFXrOsIwSYF/SSEKqrf3X7HJ
         OQ6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wqIpUl15KNA5TWIBL3RIm8DVAoOkpFGHBPdsUj2ei7c=;
        b=C21huKaO9ZDgphTWcxP69d2bIon2/gok4Dp2CWPV0bWMrx99Uha3luRe4sNN2wR/nA
         SVigt+TaGdR4M8+aDuOp1GnnO6bwtVEX/Ei2a2qtBRZfoMNFk4mC2f6dzm65/7sCA6cp
         dUOpXjc4Q1DvrghsmR5Ar1P0S7fZqrYAfnzLjde8RdMPt2cjjAA9ruNNYeJXI1OcPtFv
         2bsf2XtcCAYl0lFgu1CJ6VlGVjBRT6BculSCTTLaAgpDL91wU9YEGh6Dv76w1cSFv9qc
         fpdpZ7ReWK09G9yXKlDapqNs96HVD4/ngucClhSEhI97I9GJXdlj+X49L4Hkn1+17vEA
         1vDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id z20si23239165ejk.274.2019.08.02.03.20.39
        for <linux-mm@kvack.org>;
        Fri, 02 Aug 2019 03:20:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E44A3344;
	Fri,  2 Aug 2019 03:20:38 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 26BB63F71F;
	Fri,  2 Aug 2019 03:20:34 -0700 (PDT)
Date: Fri, 2 Aug 2019 11:20:32 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <20190802102031.GB4175@arrakis.emea.arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <8c618cc9-ae68-9769-c5bb-67f1295abc4e@intel.com>
 <13b4cf53-3ecb-f7e7-b504-d77af15d77aa@arm.com>
 <CAAeHK+zTFqsLiB3Wf0bAi5A8ukQX5ZuvfUg4td-=r5UhBsUBOQ@mail.gmail.com>
 <96fd8da4-a912-f6cc-2b32-5791027dbbd5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <96fd8da4-a912-f6cc-2b32-5791027dbbd5@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 08:36:47AM -0700, Dave Hansen wrote:
> On 8/1/19 5:48 AM, Andrey Konovalov wrote:
> > On Thu, Aug 1, 2019 at 2:11 PM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
> >> On 31/07/2019 17:50, Dave Hansen wrote:
> >>> On 7/23/19 10:58 AM, Andrey Konovalov wrote:
> >>>> The mmap and mremap (only new_addr) syscalls do not currently accept
> >>>> tagged addresses. Architectures may interpret the tag as a background
> >>>> colour for the corresponding vma.
> >>>
> >>> What the heck is a "background colour"? :)
> >>
> >> Good point, this is some jargon that we started using for MTE, the idea being that
> >> the kernel could set a tag value (specified during mmap()) as "background colour" for
> >> anonymous pages allocated in that range.
> >>
> >> Anyway, this patch series is not about MTE. Andrey, for v20 (if any), I think it's
> >> best to drop this last sentence to avoid any confusion.

Indeed, the part with the "background colour" and even the "currently"
adverb should be dropped.

Also, if we merge the patches via different trees anyway, I don't think
there is a need for Andrey to integrate them with his series. We can
pick them up directly in the arm64 tree (once the review finished).

> OK, but what does that mean for tagged addresses getting passed to
> mmap/mremap?  That sentence read to me like "architectures might allow
> tags for ...something...".  So do we accept tagged addresses into those
> syscalls?

If mmap() does not return a tagged address, the reasoning is that it
should not accept one as an address hint (with or without MAP_FIXED).
Note that these docs should only describe the top-byte-ignore ABI while
leaving the memory tagging for a future patchset.

In that future patchset, we may want to update the mmap() ABI to allow,
only in conjunction with PROT_MTE, a tagged pointer as an address
argument. In such case mmap() will return a tagged address and the pages
pre-coloured (on fault) with the tag requested by the user. As I said,
that's to be discussed later in the year.

-- 
Catalin

