Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E727C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:03:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49FDA20866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:03:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Au7VJqK1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49FDA20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA76E6B0003; Wed, 12 Jun 2019 07:03:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E31C56B0005; Wed, 12 Jun 2019 07:03:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB5986B0006; Wed, 12 Jun 2019 07:03:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5076B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:03:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u10so9587061plq.21
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:03:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=U+WRAXF2ARmkxSGAjp/c6etYCd0hTSbOs0DZi8MzR6Q=;
        b=YxWUUT4IGdodp1w+fhQTMSs3vfI9xRQhbAstYvD1Wtq2M7nCa24RhHh3IFhTfavSpP
         Q5bcg0iwqgISc5UJunUz5j0ewmizhYsRNG9USEkXm7JVROImMT48FYcRQnOitvZTzEDn
         jVS+RqS2MUg6I7OYV8eyeNESBZYOaAc+dWDciugpVt/Ar4Ul88TmNDWrf8BjLzx8ngxu
         UXxyTY80VFbo5+C4kGd9NL9h22oIoYI4kkNvl0nqtHwUyAqNXIcChwlcc888oe19nSFh
         TZfhgt8Anw2CbQwL1PJVCB/J0jJ89duqHw5g2KXRFpy6rk6X2G+RDBpFoQf8hQlfxP3q
         qIvw==
X-Gm-Message-State: APjAAAU+gY+2eJOJnAsLEMIlwtKeWcCgmYg6/CeYtJiDb2b9d3WIVZ3D
	X7Wf+fhEJOCVSNVpKYdJdVMmzE9xcK0tulZMz8fBK8yB/5r1A4YHrW1qV6Ak07CcUnbAbkeGaSI
	im+bnG2+Qwr09Zq76zBFB5ge0wvcWuCRf0WCykgRQ6VXZW/LJUumZAT/XGnswRAXsRg==
X-Received: by 2002:a62:ed09:: with SMTP id u9mr85606836pfh.23.1560337404098;
        Wed, 12 Jun 2019 04:03:24 -0700 (PDT)
X-Received: by 2002:a62:ed09:: with SMTP id u9mr85606741pfh.23.1560337403131;
        Wed, 12 Jun 2019 04:03:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560337403; cv=none;
        d=google.com; s=arc-20160816;
        b=kRca8S9/SYaPrX94uBbR29tZJ8UiTQ8eISTA0WzFTG//SdP30ytHNYk1NN/5AOO47e
         7a/0H5XbfpHlfJ+ezAk2BzcuV9LkFjpMYsz3cTPU64uJFinrveGSluiNUWv3HQ8cVW2a
         zREFZTJnhUihPBk0b2LgZ6hsUx9c/DybF41bAkdXmx/mynfa0S8yo3dyyth6twGrCDAt
         gUcg1KfqOv6vVZvJDiT6QEF0Z0Yfq7THteick7PdN6KO+dIobmS2UHahft1irV7v7Amg
         WZSvpkVPqYrOu8tM6ui843OBORnOCHo2wwtIQmFISI08Gc+5wAZqNh7mj/ASsDPByGH9
         +e8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=U+WRAXF2ARmkxSGAjp/c6etYCd0hTSbOs0DZi8MzR6Q=;
        b=K8sSSIpQ/ifxumBkV7Wna49c8L845bKVPOpDd0mKrlOb9UubXtAxBi+1r+LKERBUW7
         ZMhNpvoHCSMR/LQLgPVjZRbtx4bxBB7EheOs/Sjil4G859PfmRxF//+Bqb6Wrb/hrUHG
         d0Vf4SDWBlhy80I1wxCk8tahv7qMe3o8CfAcAeGXPNW+vr7NfEA+bewrNJAlfd1sGXsw
         1b8sBNhgISBVYdOL/XCNdqaCsXwbSNPWMOXiOjLfJdJOYZ+EKp9C3YFyLOfS45cc2UZv
         8wAgb+ew0MZT7o1JflVEwM5ajfI/AHMCyHs7XXINB1PRkN3CVPXNqyvp9SkYak+738sY
         2JtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Au7VJqK1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u2sor15681605pfm.28.2019.06.12.04.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:03:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Au7VJqK1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=U+WRAXF2ARmkxSGAjp/c6etYCd0hTSbOs0DZi8MzR6Q=;
        b=Au7VJqK1ojAhcfG23jRBnNIRm8KjejR34yLBYxx+tHyOH3UOEnqAeA+8NqPGB0xERC
         iEkWFkgDGC2bVn5/OIaA4Iaj0a8vwuQDB61IL+0H9Fwkx9OFXo7fvyXQ9pDMhbYVG+Nt
         NAfcfgs6HTAivxcJGzmU1GQcMJKjdgGsV4PVoEwVpmDo71FYYp7iRopdo3JqiipS6Pbm
         g0FK+P1R3xn5BU9DYN7tw7p2D7DXBRHK9wtsmdaKDKErjouHvoT1Xsa2liBK45bWDlUw
         nn9WdHLDyGhILUMAD8+oKvlF/Link+W8NA8UTm3/U+VTclr5XHE7a99we7HZ74tOwnVu
         i1TQ==
X-Google-Smtp-Source: APXvYqzWmxUbLyuGmwxZVdNOTNeaNzhhuMrhwfH+eyIre2cUwA02gvKzU0bgN3Cy01oTn1PiBJVwgb5PwMcG3EUFGXg=
X-Received: by 2002:a65:64d9:: with SMTP id t25mr24706277pgv.130.1560337402181;
 Wed, 12 Jun 2019 04:03:22 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com> <20190611145720.GA63588@arrakis.emea.arm.com>
 <CAAeHK+z5nSOOaGfehETzznNcMq5E5U+Eb1rZE16UVsT8FWT0Vg@mail.gmail.com> <20190611173903.4icrfmoyfvms35cy@mbp>
In-Reply-To: <20190611173903.4icrfmoyfvms35cy@mbp>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 12 Jun 2019 13:03:10 +0200
Message-ID: <CAAeHK+ysoiCSiCNrrvXqffK53WwBMHbc3bk69uU0vY0+R4_JvQ@mail.gmail.com>
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Will Deacon <will.deacon@arm.com>, 
	dri-devel@lists.freedesktop.org, 
	Linux Memory Management List <linux-mm@kvack.org>, Khalid Aziz <khalid.aziz@oracle.com>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>, 
	Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Kees Cook <keescook@chromium.org>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alex Williamson <alex.williamson@redhat.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Yishai Hadas <yishaih@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Morton <akpm@linux-foundation.org>, 
	enh <enh@google.com>, Robin Murphy <robin.murphy@arm.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 7:39 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, Jun 11, 2019 at 07:09:46PM +0200, Andrey Konovalov wrote:
> > On Tue, Jun 11, 2019 at 4:57 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > >
> > > On Mon, Jun 10, 2019 at 06:53:27PM +0100, Catalin Marinas wrote:
> > > > On Mon, Jun 03, 2019 at 06:55:04PM +0200, Andrey Konovalov wrote:
> > > > > diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> > > > > index e5d5f31c6d36..9164ecb5feca 100644
> > > > > --- a/arch/arm64/include/asm/uaccess.h
> > > > > +++ b/arch/arm64/include/asm/uaccess.h
> > > > > @@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
> > > > >     return ret;
> > > > >  }
> > > > >
> > > > > -#define access_ok(addr, size)      __range_ok(addr, size)
> > > > > +#define access_ok(addr, size)      __range_ok(untagged_addr(addr), size)
> > > >
> > > > I'm going to propose an opt-in method here (RFC for now). We can't have
> > > > a check in untagged_addr() since this is already used throughout the
> > > > kernel for both user and kernel addresses (khwasan) but we can add one
> > > > in __range_ok(). The same prctl() option will be used for controlling
> > > > the precise/imprecise mode of MTE later on. We can use a TIF_ flag here
> > > > assuming that this will be called early on and any cloned thread will
> > > > inherit this.
> > >
> > > Updated patch, inlining it below. Once we agreed on the approach, I
> > > think Andrey can insert in in this series, probably after patch 2. The
> > > differences from the one I posted yesterday:
> > >
> > > - renamed PR_* macros together with get/set variants and the possibility
> > >   to disable the relaxed ABI
> > >
> > > - sysctl option - /proc/sys/abi/tagged_addr to disable the ABI globally
> > >   (just the prctl() opt-in, tasks already using it won't be affected)
> > >
> > > And, of course, it needs more testing.
> >
> > Sure, I'll add it to the series.
> >
> > Should I drop access_ok() change from my patch, since yours just reverts it?
>
> Not necessary, your patch just relaxes the ABI for all apps, mine
> tightens it. You could instead move the untagging to __range_ok() and
> rebase my patch accordingly.

OK, will do. I'll also add a comment next to TIF_TAGGED_ADDR as Vincenzo asked.

>
> --
> Catalin

