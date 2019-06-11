Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94A63C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47FC42086D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47FC42086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C08C96B000A; Tue, 11 Jun 2019 13:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB9866B000D; Tue, 11 Jun 2019 13:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA92A6B0010; Tue, 11 Jun 2019 13:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6D56B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:50:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so21779221edo.5
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VK15js9rOdFA81YfbRsGdiGRUgzc1A6qWvdMkzL0GsU=;
        b=gn8DYASqvHGZu8jFfFOT/ohC2rly54FPW6XpcmPpQXhlfIwpGG96d9k79mUA3Yg5AW
         NmtIuWWw3Jjr5Oi7WboJyKGBgJTzffEC/PN7ihllTxRxQirAtdEAEou5oRYCOGkXDqBs
         MX8pKzolR07QR8skxU6Gy4oCbM0zmXki7K8SmrcTp1RamRwHN7bql2y0Eiy2fPEHXgoI
         IShhKJySo4r73Pdz1bYoq/BoZ82USMfqtgSmxxjFxAl/xMa+JxzC73efl3BCMYYfysew
         WLlLHI1MCge3v+RIwP/UYdsctLFi2kEOyR8u153tIuKCb2RygpXuYwNo7mFF0eUdzQxv
         HabQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVB3eKiF9nIh575OxvbYXQp/u0opIC9D/7c6L+2H4rf/3/DCJ9M
	RgPvaT/om3NaT9/rZZOnv0j/ui4UJZ5pDM7IiKpaK1qXoGd5PeU2hua90u4nX/mkzJZqrnOTNG4
	MvTuQiBH3pORw0svGF/dtycKd4BzQWDE6GxAjrXv3ixlnkyqcPct1FTg0zFb1ECqhxA==
X-Received: by 2002:a17:906:5846:: with SMTP id h6mr6802485ejs.200.1560275446945;
        Tue, 11 Jun 2019 10:50:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/QnCx8uooFPZtKblRx8Yo/PxCMx50BXtcXDbvV0Z3CVBATA/spAzzYpezaHkHGtToo8F2
X-Received: by 2002:a17:906:5846:: with SMTP id h6mr6802439ejs.200.1560275446056;
        Tue, 11 Jun 2019 10:50:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560275446; cv=none;
        d=google.com; s=arc-20160816;
        b=zHVaGoauXPNY4g1gjVLjUJ5LkeJCYebu517sKtqb0pIhsNjtJKp6fMPUdKDGUIH7//
         NV06t1vP45Z0dw5uNFLLCpohvOB3wFCF74pg2QScVaUT/2AEv1EISfofZOzFipTL0SOg
         5LGl7PVf6vK7iOhgdRHcnYt/OXDUwZ0uHdg+V0cMDqMmhgpQgYlak5h/C6Oe2GINrcI1
         +BniFniwQHrsXNcC5h8SuLnSb3RtFsYB1T4SXXhvtGE/ckh1hqckVsLg8ZzfzZ1JE+u9
         rRc9kKYyWpwfWMKoFmyF8gfgc37B9oDz3Ibi0mJrFnmjqRztwgS1nn+BrVgFs+IIfEy0
         V13Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VK15js9rOdFA81YfbRsGdiGRUgzc1A6qWvdMkzL0GsU=;
        b=QfdBmSbNg4GEhs724s2KT9aNeHawbMtZYDZaggFIzrURByfwKCUbf9EP582sIux0ai
         5OUbuC6AGGpYxG43srHaoQlrfIkkVdzl4+euHQpg72AprY63IJaX+1TCaeMAad/dYL6b
         FsKl/cmxZmSuj5yRDz9cyFC5FbpmCsKa+NGzxTzMLYPzPDgQargysRKrjpU9yrzcH/D7
         NJnEu8BI8RTgRA5FmVGbEcqkLsTYODdjPsFqAa+GDiMDLhxT8eOVSqsnWFwp+X3A4pba
         Q890y3TVOZxNOWz/e4TjcIJVcb8WwXwZlkXlxwys95nR3oM230oecdcj0q4AGzoXExZk
         Oyzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r23si1179136ejj.297.2019.06.11.10.50.45
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 10:50:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1D236337;
	Tue, 11 Jun 2019 10:50:45 -0700 (PDT)
Received: from mbp (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 18BF83F73C;
	Tue, 11 Jun 2019 10:50:39 -0700 (PDT)
Date: Tue, 11 Jun 2019 18:50:37 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
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
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 16/16] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <20190611175037.pflr6q6ob67zjj25@mbp>
References: <cover.1559580831.git.andreyknvl@google.com>
 <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
 <20190611150122.GB63588@arrakis.emea.arm.com>
 <CAAeHK+wZrVXxAnDXBjoUy8JK9iG553G2Bp8uPWQ0u1u5gts0vQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+wZrVXxAnDXBjoUy8JK9iG553G2Bp8uPWQ0u1u5gts0vQ@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 07:18:04PM +0200, Andrey Konovalov wrote:
> On Tue, Jun 11, 2019 at 5:01 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > static void *tag_ptr(void *ptr)
> > {
> >         static int tagged_addr_err = 1;
> >         unsigned long tag = 0;
> >
> >         if (tagged_addr_err == 1)
> >                 tagged_addr_err = prctl(PR_SET_TAGGED_ADDR_CTRL,
> >                                         PR_TAGGED_ADDR_ENABLE, 0, 0, 0);
> 
> I think this requires atomics. malloc() can be called from multiple threads.

It's slightly racy but I assume in a real libc it can be initialised
earlier than the hook calls while still in single-threaded mode (I had
a quick attempt with __attribute__((constructor)) but didn't get far).

Even with the race, under normal circumstances calling the prctl() twice
is not a problem. I think the risk here is that someone disables the ABI
via sysctl and the ABI is enabled for some of the threads only.

-- 
Catalin

