Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D9C1C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC63526BE0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:20:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC63526BE0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EBF66B0010; Fri, 31 May 2019 12:20:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3763C6B026B; Fri, 31 May 2019 12:20:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23D776B026C; Fri, 31 May 2019 12:20:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB02C6B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 12:20:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so14567495edb.1
        for <linux-mm@kvack.org>; Fri, 31 May 2019 09:20:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p5rQBXnOETFoaoADzLwPGcefz0MOaI/LmtU9nK58nmI=;
        b=iyE/hCe5P4k++z7KKjwGPxEkIp6nPSMR1VMprsqPNJ0OV4wTQ4eFWtq6StSt9UcEDQ
         dWManolNfAVavsXsdc8Nh5HnctI2kWwoNxPxwKQzhGGYyVR3wlWZndddkCCG/7Dmv0Rh
         rknsfCIA0bZ9QpmzUMSEQOX/rS+9HKNd91vNWGp75bH0OGXRp+5xhYeO2xqOmilNYNlF
         CBZVGIUIHqYVxIVI8p7Y2iP/EHFKJkofy6ipgBbjYLwNF6YAg5/yQr5FJ6YWCpMcLFNh
         NDUu7Wz5SrseK2goZ74MtyzjbWuOWur+sN93DyWXfSHyaNZi+CrEtjy7B/IXut5xjNt7
         FJ9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV2QuUZsxCZCv4UzopYOjuHofLYU/+dRavyX1LXFrqfLzYikgMi
	9zQTJCWe2deZi1vxbqKYs2LVE+GKLEsDcBNnkw2DM9liAd4SmEKhjPcn7CMCZykF9as6r+ouBWR
	TJuznJ/QgIZ38Pl+Pq5bAyo1vjYHBn7erHTf7aUp2/H38Xs6ccP3M+if1/dY4uAflqQ==
X-Received: by 2002:a17:906:1502:: with SMTP id b2mr8812135ejd.284.1559319606369;
        Fri, 31 May 2019 09:20:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgKDX/sl/KCKRITlB5MhGd6mYjQ9M5R7gLovwDjmyt2/uT2O8JzuwXYvT8qJd4mrK9JjZS
X-Received: by 2002:a17:906:1502:: with SMTP id b2mr8812007ejd.284.1559319605128;
        Fri, 31 May 2019 09:20:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559319605; cv=none;
        d=google.com; s=arc-20160816;
        b=vnzLatuFpb3EL6freuOCee9xefi4HALhUZgrDxmPST8htXiLH/0J4l3swa2G7cER3O
         4vkZpWYyE6xnMyQBqOFS9uyjSMJGEO62YJ65XXrM4mWw8FvIpRM8qqfFN8TtV4XijdLE
         fgIgSdYnhrhSfg+FWt3OV0T/aLYIgZYX42jGCXCqnRO8spPtd3o4Ma7oux9dgj8LG05i
         9ThS6gDRyyyKEm12Ml3ek5JF1ODv/5RbBInU+m7nhBIh2DK5jjtQm8kCxTus612fisHE
         fziVq6mCNiyOGSMIZ5u63Gpr4IKPTeOq6l9DRjjqEZPA+JX/Yo3p4FZfikQh2i667vRy
         PDCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p5rQBXnOETFoaoADzLwPGcefz0MOaI/LmtU9nK58nmI=;
        b=zmzovhKsis/wKFJr7lHPYfArLRe21wKz/V8lfdQBhWAku6pep6Tuyl45U5tQDNxiLT
         KBft57CY5jkgGGgteSMO2DiIIGgnHZeN8KaiLjahQIAP8QQ0NJvC7pUf8R3n6ZDh//yy
         cpOXwfQWaWe3YVYixYKouHs+eIBPSeBR1zEQ+AcxQWvhK4pSE8WnhjoC5PlgPwAHbzJQ
         kveCsoDsXyXyuWLSnmCxKQyXcBTZ0chfRQMpJZgKvtRWPCYj755mdKzOeWpF0fkqbLex
         O2yJyqFv4zrVF99ul3xjY3As9niIhNgz1z9gA2CRhKlgE0MIWKlS6uG526RxYzpehh9p
         fKIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id qo11si4149486ejb.41.2019.05.31.09.20.04
        for <linux-mm@kvack.org>;
        Fri, 31 May 2019 09:20:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9E486341;
	Fri, 31 May 2019 09:20:03 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B67CE3F59C;
	Fri, 31 May 2019 09:19:57 -0700 (PDT)
Date: Fri, 31 May 2019 17:19:55 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
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
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190531161954.GA3568@arrakis.emea.arm.com>
References: <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
 <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
 <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
 <20190530171540.GD35418@arrakis.emea.arm.com>
 <CAAeHK+y34+SNz3Vf+_378bOxrPaj_3GaLCeC2Y2rHAczuaSz1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+y34+SNz3Vf+_378bOxrPaj_3GaLCeC2Y2rHAczuaSz1A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 04:29:10PM +0200, Andrey Konovalov wrote:
> On Thu, May 30, 2019 at 7:15 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Tue, May 28, 2019 at 04:14:45PM +0200, Andrey Konovalov wrote:
> > > Thanks for a lot of valuable input! I've read through all the replies
> > > and got somewhat lost. What are the changes I need to do to this
> > > series?
> > >
> > > 1. Should I move untagging for memory syscalls back to the generic
> > > code so other arches would make use of it as well, or should I keep
> > > the arm64 specific memory syscalls wrappers and address the comments
> > > on that patch?
> >
> > Keep them generic again but make sure we get agreement with Khalid on
> > the actual ABI implications for sparc.
> 
> OK, will do. I find it hard to understand what the ABI implications
> are. I'll post the next version without untagging in brk, mmap,
> munmap, mremap (for new_address), mmap_pgoff, remap_file_pages, shmat
> and shmdt.

It's more about not relaxing the ABI to accept non-zero top-byte unless
we have a use-case for it. For mmap() etc., I don't think that's needed
but if you think otherwise, please raise it.

> > > 2. Should I make untagging opt-in and controlled by a command line argument?
> >
> > Opt-in, yes, but per task rather than kernel command line option.
> > prctl() is a possibility of opting in.
> 
> OK. Should I store a flag somewhere in task_struct? Should it be
> inheritable on clone?

A TIF flag would do but I'd say leave it out for now (default opted in)
until we figure out the best way to do this (can be a patch on top of
this series).

Thanks.

-- 
Catalin

