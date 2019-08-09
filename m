Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF666C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:00:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 738B620B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:00:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 738B620B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CA3F6B0006; Fri,  9 Aug 2019 05:00:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 379BD6B0008; Fri,  9 Aug 2019 05:00:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3D86B000E; Fri,  9 Aug 2019 05:00:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C63DE6B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:00:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so59894709eda.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:00:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cIZenNjhcT3PJatqyvA+wCJG/AFZZSYeOgVg7EZztoo=;
        b=e5rCJyWMmLlCqDeAS3NTC54ptqf6qfF2Az/ypCh71WjJBcE/keFRcH4Lw5r5gQd2oN
         +/K6fe5pzfd5kdltznDghmGiWEbJVPHiviU+UbT2XS7nBdv6Z3c604R4ea33Dd5z+2Fy
         Tm5G+HiRRmoEbxTZEOlg4OLC//ZaFStas+oLfSMqAmeugdC90Qs6PNjEhLqBXs3ESXEx
         GYuxQWE6zOdRR7b9Q/p9mDxS6aoTJ0Pdce3Ga44yiUsj6ANX5z0kcInkM6q3giMy3PD3
         zxyrkuFmsa9yZzQDeR6j/hI6o21z0+Pj/y8aPr8bjE6hBQYvZEFrOwbK630Bz3CE4m09
         8GPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXWv0D+I0JVov5zHftn6a3f2Ahu1y2Z6p5lMDdU2FIoi+zN2Nkh
	rsyOadmY8Yh1E/yGeuYQ8oZMW+yFoInE2ruG0Ht+357XH2tFRWBNYdiruX/46yXbvi8XcAFXVV8
	zVWowGK4bZbdyu8L1KtCDg9gvyLuDj/XIzLiERTpLZmtO3CoHmsJj32QoRChZBpmTvg==
X-Received: by 2002:a17:906:340e:: with SMTP id c14mr17807201ejb.170.1565341226368;
        Fri, 09 Aug 2019 02:00:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxx/cKzQ+Pw4eDkKB7bmL5t/h9fu0vTUNKXxmVvlpBFmQh7B7eSB3VYvD9Q24AvtUEJBxms
X-Received: by 2002:a17:906:340e:: with SMTP id c14mr17807138ejb.170.1565341225561;
        Fri, 09 Aug 2019 02:00:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565341225; cv=none;
        d=google.com; s=arc-20160816;
        b=a8giHt/kxWnPvZJrUh4YedibrQnfQFWhPCnZ7OScIQnn+TIeqNNL9z3TiO8mdwFNCc
         40P78Wpp1ZCoePwwGb00YERokThRMLNJQ3LKqzr8fEiLot/p3pHSdztY6jFmTl13xOmO
         Y8c5AbRagT1WbVZh+lro6a/5+uaTeoNr+qLfzjHB8TY4XKg9IR/xkjp57EIKxBF3MNSv
         P7C/AVHbZS3MmyPxfoOHr5O2vTGdrZ5uwJFI+Yf62E/IXDlGYJhe0wvy5mSrabFIXRHa
         FPVmiD92pbsX4hFOw1ySWVZiD811Hl3QwGpExB/zx8W9655lZFej08Ujxpnb17hDvtAs
         HBEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cIZenNjhcT3PJatqyvA+wCJG/AFZZSYeOgVg7EZztoo=;
        b=VcW3gU77XT+nd8liwCmXOTv7gfI2soOcMS6v6hbWu/TJD1oxsExCAEogd++PH1cioR
         uSPbrZzQJ15MpRSq+V/APlyu3/rg73kVGZCWkZwx10DS4fvGNQeH6gb/aKlXvbp2mESS
         j56PBkAK/sEStVvJQyzANl2eJASwJXCdHwXlZQjCJp2a8K5tQ7Pdfp4btLKPycLjbBqH
         5sWMJYtlDrESW3l/owcXgFxsSpZ8WJt1nDZZ8YMJIFHUchYFDaM7PIjqVDrR5ri0Sgv/
         JlBB1kXtju1QSZWMxYzlBEPInGM4b35WqPOU66caanCd+xIBz6k2s2h1ld80LKDVYfqR
         VfMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g4si39423432edg.234.2019.08.09.02.00.25
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 02:00:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5F595344;
	Fri,  9 Aug 2019 02:00:24 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 796343F706;
	Fri,  9 Aug 2019 02:00:19 -0700 (PDT)
Date: Fri, 9 Aug 2019 10:00:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will@kernel.org>, Will Deacon <will.deacon@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	dri-devel@lists.freedesktop.org, Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <20190809090016.GA23083@arrakis.emea.arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
 <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
 <20190724142059.GC21234@fuggles.cambridge.arm.com>
 <20190806171335.4dzjex5asoertaob@willie-the-truck>
 <CAAeHK+zF01mxU+PkEYLkoVu-ZZM6jNfL_OwMJKRwLr-sdU4Myg@mail.gmail.com>
 <201908081410.C16D2BD@keescook>
 <20190808153300.09d3eb80772515f0ea062833@linux-foundation.org>
 <201908081608.A4F6711@keescook>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201908081608.A4F6711@keescook>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 04:09:04PM -0700, Kees Cook wrote:
> On Thu, Aug 08, 2019 at 03:33:00PM -0700, Andrew Morton wrote:
> > On Thu, 8 Aug 2019 14:12:19 -0700 Kees Cook <keescook@chromium.org> wrote:
> > 
> > > > The ones that are left are the mm ones: 4, 5, 6, 7 and 8.
> > > > 
> > > > Andrew, could you take a look and give your Acked-by or pick them up directly?
> > > 
> > > Given the subsystem Acks, it seems like 3-10 and 12 could all just go
> > > via Andrew? I hope he agrees. :)
> > 
> > I'll grab everything that has not yet appeared in linux-next.  If more
> > of these patches appear in linux-next I'll drop those as well.
> > 
> > The review discussion against " [PATCH v19 02/15] arm64: Introduce
> > prctl() options to control the tagged user addresses ABI" has petered
> > out inconclusively.  prctl() vs arch_prctl().
> 
> I've always disliked arch_prctl() existing at all. Given that tagging is
> likely to be a multi-architectural feature, it seems like the controls
> should live in prctl() to me.

It took a bit of grep'ing to figure out what Dave H meant by
arch_prctl(). It's an x86-specific syscall which we do not have on arm64
(and possibly any other architecture). Actually, we don't have any arm64
specific syscalls, only the generic unistd.h, hence the confusion. For
other arm64-specific prctls like SVE we used the generic sys_prctl() and
I can see x86 not being consistent either (PR_MPX_ENABLE_MANAGEMENT).

In general I disagree with adding any arm64-specific syscalls but in
this instance it can't even be justified. I'd rather see some clean-up
similar to arch_ptrace/ptrace_request than introducing new syscall
numbers (but as I suggested in my reply to Dave, that's for another
patch series).

-- 
Catalin

