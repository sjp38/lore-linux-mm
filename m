Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FB82C06508
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:39:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C703321783
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:39:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C703321783
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 646056B0010; Tue, 11 Jun 2019 13:39:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61C956B0269; Tue, 11 Jun 2019 13:39:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E5236B026B; Tue, 11 Jun 2019 13:39:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F351E6B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:39:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so14417473eds.14
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:39:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ftif4O50XVSBJeRR/nR0vQr1LSyuS4iExaNW/LCzwnQ=;
        b=dv7ByQ6e/gdnqHdY+ISns1YPDFnnFqau4WYWSqZas8FXnoFOCAx5wD/MjxOaZ83prT
         xuMjDr4secg5R8/gUE8VJs/kpNS/lrPZfYzUoRR1RoSiDn9B0QfA/jzUVYMtmAvP7O9R
         Nmny4s4dexs+iO0uYA17H2xtlsV10al3LhLH/K4OPz2SOsABxfy99LO029r/C9d1Hvvc
         6b4OYOO6FAzCgCUcoTr8mfI06TyFyao1KEJTZBuBo5mbk75tilIUB8pnwgZe0kjK8Afd
         CJNBtrVb183JM4z30IlSqzvWQ40TvfciokV0Zfp5xJeacSPa0IWhjA43+6bcB9Qcq2OP
         hJKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWYdkWUQc5ouuRCXlsNOed6N1PTxQZiP7uhI3WQxBLCNcOKc9Fu
	M8Mn9eYejUfy8+zCOqfjpT8LsfaoqvmEeloCEKvt1XFPpdrv78RHKWxjM43mR3AiwJvBlV0fXiw
	dBGyhp5zjeFwtJmtY15jFU2rkR7IfrS68PYijAJs/escnDcSOoEBXrJHQPAG4UfHc0A==
X-Received: by 2002:a50:b48f:: with SMTP id w15mr35166728edd.260.1560274753527;
        Tue, 11 Jun 2019 10:39:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJqB7Kex1gsWWY2Q3eYZtSQ1JYoe+o4UvFNJDDydBWjR5VGpkDp9Xxe6NOZfSj/XeQN5xH
X-Received: by 2002:a50:b48f:: with SMTP id w15mr35166672edd.260.1560274752805;
        Tue, 11 Jun 2019 10:39:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560274752; cv=none;
        d=google.com; s=arc-20160816;
        b=riTUO+mvVyyBb9kYuL9SL6AkDh8rA/ct8Bfk3dsFkgALbBTtoMAsl/uejjr+ZD5bK1
         PdNDI6mATudZqI1D5ybrDUPr8BDNd3pd4cqT3dZWVdOMUYj8YfzUZgswL9OTCQenlTO7
         sVBpVpB6imt3mvv6d+Ct7Ptfuf7SX0jYCyEaULcmUIcuXX/bnwuZmDsnzw4gmhdMMhly
         CHesH7hfdkWkwwkm66QhxZ3AZ83HXt4Y0zvCfd9Eq+x7Xa2xgzeuHo82eqpyoiljHKTq
         8WID17IfWbKVcbCyDuS0kofCf70OEA4NpbJk/0SGEdOvirmDdKoCXZEK8n2wJdqNaJdT
         QZxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ftif4O50XVSBJeRR/nR0vQr1LSyuS4iExaNW/LCzwnQ=;
        b=oDlLEpcFeilmi6wmQFddWNYF2ZFldjF4HaGv1dF1gq/DJ4mrMBCuzgEjX73LilwGTG
         jROpcAOUYUcmdZP04qsm5oPTV1IxGyTr/s3a8XpkvyfT7gTuv+gUkE8Wyd3Ic2vZk+FZ
         VkLo9Y0rC+SM4Ca7xJ0ZQsjlXzcl+t1j1nFGKEFfPxMFn7ZKggW8d4ZDWeYR3izmUYgE
         YH7wXiM1egawyHDXKmOr800E9xWY7Zxum9JOfFfesYieGPin2oI0DsIKKtA9+Ak/LvjR
         /3leToZCopi2ynPf/3xGuKI+IW7XNrkhAYsMF6Z+0ioZZr4nlMWwbq61Ix1KEZfcMu0+
         KXkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r11si2139911ejr.157.2019.06.11.10.39.12
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 10:39:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BBF6D337;
	Tue, 11 Jun 2019 10:39:11 -0700 (PDT)
Received: from mbp (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7B7793F73C;
	Tue, 11 Jun 2019 10:39:06 -0700 (PDT)
Date: Tue, 11 Jun 2019 18:39:04 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
Message-ID: <20190611173903.4icrfmoyfvms35cy@mbp>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com>
 <20190611145720.GA63588@arrakis.emea.arm.com>
 <CAAeHK+z5nSOOaGfehETzznNcMq5E5U+Eb1rZE16UVsT8FWT0Vg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+z5nSOOaGfehETzznNcMq5E5U+Eb1rZE16UVsT8FWT0Vg@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 07:09:46PM +0200, Andrey Konovalov wrote:
> On Tue, Jun 11, 2019 at 4:57 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> >
> > On Mon, Jun 10, 2019 at 06:53:27PM +0100, Catalin Marinas wrote:
> > > On Mon, Jun 03, 2019 at 06:55:04PM +0200, Andrey Konovalov wrote:
> > > > diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> > > > index e5d5f31c6d36..9164ecb5feca 100644
> > > > --- a/arch/arm64/include/asm/uaccess.h
> > > > +++ b/arch/arm64/include/asm/uaccess.h
> > > > @@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
> > > >     return ret;
> > > >  }
> > > >
> > > > -#define access_ok(addr, size)      __range_ok(addr, size)
> > > > +#define access_ok(addr, size)      __range_ok(untagged_addr(addr), size)
> > >
> > > I'm going to propose an opt-in method here (RFC for now). We can't have
> > > a check in untagged_addr() since this is already used throughout the
> > > kernel for both user and kernel addresses (khwasan) but we can add one
> > > in __range_ok(). The same prctl() option will be used for controlling
> > > the precise/imprecise mode of MTE later on. We can use a TIF_ flag here
> > > assuming that this will be called early on and any cloned thread will
> > > inherit this.
> >
> > Updated patch, inlining it below. Once we agreed on the approach, I
> > think Andrey can insert in in this series, probably after patch 2. The
> > differences from the one I posted yesterday:
> >
> > - renamed PR_* macros together with get/set variants and the possibility
> >   to disable the relaxed ABI
> >
> > - sysctl option - /proc/sys/abi/tagged_addr to disable the ABI globally
> >   (just the prctl() opt-in, tasks already using it won't be affected)
> >
> > And, of course, it needs more testing.
> 
> Sure, I'll add it to the series.
> 
> Should I drop access_ok() change from my patch, since yours just reverts it?

Not necessary, your patch just relaxes the ABI for all apps, mine
tightens it. You could instead move the untagging to __range_ok() and
rebase my patch accordingly.

-- 
Catalin

