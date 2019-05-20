Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FEAAC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D10F920645
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:00:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Q2ZvmjGT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D10F920645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32BB66B0003; Mon, 20 May 2019 15:00:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DB8E6B0005; Mon, 20 May 2019 15:00:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A6236B0006; Mon, 20 May 2019 15:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id E29A66B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 15:00:29 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 72so8408867otv.23
        for <linux-mm@kvack.org>; Mon, 20 May 2019 12:00:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wT81sA73prwjBsqvneE0nbb4zGsqTgjv/ErvD6Lkzzw=;
        b=fNUBFhjPxTeNFYCgSCAqu6R9OId40B2BY/9SRG+pzWgyPaWJtI1MjUZ8zC5gO4sFVr
         LDlyYzijJSpY2wuGbFgam4XeJ4I6brf258uV5qxQkfgJA7w9uGoJ4HPicSKgUR4DyxVy
         W6VKXbNRid2+k2B0jC+SDGqgmPDzabdFqr/ZP/Boo7FE56PZKg/V8wxo77fbEABn4Thi
         yq1i0596Xkv7gGJCpknbpd3mQimHivshbGb+i7ItfhxhZwT3yips2GeZYlD2HCn6HHJ0
         KFs8g6NIECw6LlxSpdmpWvC7PFVuJOjOWSx30pLPcNLCXBW+BhRXo7spYgFu4C4eeuEr
         3D6Q==
X-Gm-Message-State: APjAAAVoUGW2uQOud3MLJ/mA+HpTp1+wTmTTzfSIftNpKWeLlFiOafMt
	46uckSparDq/cYhHeao1kocI2Mi2Bm6RrlV3ZVWP5vgLi/Qxiw7QIzbzjmab60Y+FlV3lEvHeYR
	+Vk7TGLQM2MVtixSkbWzs6+loxnJYesgcR4SxHhjM+2vxWK1ma5Ai1YYJv9VueHoDug==
X-Received: by 2002:a9d:6a10:: with SMTP id g16mr46620793otn.203.1558378829398;
        Mon, 20 May 2019 12:00:29 -0700 (PDT)
X-Received: by 2002:a9d:6a10:: with SMTP id g16mr46620725otn.203.1558378828444;
        Mon, 20 May 2019 12:00:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558378828; cv=none;
        d=google.com; s=arc-20160816;
        b=Qxjjoy99EJho6oTSHRUOKbhQBm3WIPBq/4WTgwURPqPmKvrbSU0zoLGW0OGMwM3nlC
         42fW9P6Xzl6VMyu5DGY8/M6/C2SNqXzOg+UV9amyGRim8hZ3ejxF3eXCsHy8erv4nrgQ
         vodqeQRY4wkSW8BgJIEyRDdHdhUCNWh1WDxY2FWaCDvYXKjsQeuJdptGB8cT+FgyCNpv
         4AeRIiaqRDcEgkLgwVX/j/Rtl26O5UrD5Pg5H3dWez6yEd+RUWKquU5aL5K/OtdGWmB4
         5GLsjwcUbfOXhX0Pq2dUi4A0XCKycnoan+JuL2Hs5IgaW6+FY79ku6zSqa9jLr12634R
         2GFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wT81sA73prwjBsqvneE0nbb4zGsqTgjv/ErvD6Lkzzw=;
        b=FOrp7yU88yRIp+5avXVr67Nbk0/sYKbEhdnmtU+cWTm6GIaiwn6NhPuCMSVNiP5UoG
         kaxhPfdZBE1szq9n2Jyi6XAXkrW522pYooXgRQg4Kv5y6sHEVP/o+NnVItpuOcCmwHlr
         f3yWJTB6jtvoCeleDbaGANgQsZj4GYEAluUPy9uhONDQGB3AfNJBSkYoXOrz98GsxdIw
         dqLfu6SnbhqsiHSygN2//7qjBebvVAIAg4BU9e9Rw+Rg9vfLOEQ0mdxC8q96gUCtVRzp
         6AJ3elJIYe7C6IeADxqrLtjpz1gs+X6gxjQIf2AGxQ1fc8ioCU7Cua8PJeA9dFxCOq6T
         rO1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Q2ZvmjGT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e23sor1054398otf.98.2019.05.20.12.00.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 12:00:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Q2ZvmjGT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wT81sA73prwjBsqvneE0nbb4zGsqTgjv/ErvD6Lkzzw=;
        b=Q2ZvmjGTacUUOs5fbuhnrA6Wr2XUFQFnYsPj9j7PrBl7WzFcR9qhhhOoKQh++mdR0f
         0YNT8dqvY9XRrep6/Gl5xt8G/DrBDRRbA0YTIz7mGP8WG2+qWdjmPdWZsTGyB7RUKOPx
         h/gjeBGv9LnFBL98Caa3RLNhkAwG8yksaRRdTioQnoUhhLLf7/tqKprIoHFiVMFZcWJH
         x81dNJsAF33+dyWCE9HotSRfO+nnkWl5h/rp4iyupAobkJoMCbKyOI5J46AcPdwaXIt8
         +SDgrX9kJf8yDczFvjxsCjhkU2OlicK02qE7WywQBzvK/RLwIOhzUlCMPY/VwNDpoSbB
         4XLw==
X-Google-Smtp-Source: APXvYqxY1aZ42ZhklyO4YSGancB5WqzPtQVKG8B6/X5MmZ+sCMgjK7BOHJprDezZUAhy6RWai7+JrGPqPs3PTdKdkp8=
X-Received: by 2002:a05:6830:1182:: with SMTP id u2mr34775429otq.71.1558378827193;
 Mon, 20 May 2019 12:00:27 -0700 (PDT)
MIME-Version: 1.0
References: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
 <20190517145050.2b6b0afdaab5c3c69a4b153e@linux-foundation.org> <cb8cbd57-9220-aba9-7579-dbcf35f02672@arm.com>
In-Reply-To: <cb8cbd57-9220-aba9-7579-dbcf35f02672@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 20 May 2019 12:00:16 -0700
Message-ID: <CAPcyv4iSTxmnORJY_UwXqeP2kiWc55j5h1Z+HgC8orRSaxTgfA@mail.gmail.com>
Subject: Re: [PATCH] mm/dev_pfn: Exclude MEMORY_DEVICE_PRIVATE while computing
 virtual address
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Laurent Dufour <ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 19, 2019 at 10:37 PM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
> On 05/18/2019 03:20 AM, Andrew Morton wrote:
> > On Fri, 17 May 2019 16:08:34 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> >
> >> The presence of struct page does not guarantee linear mapping for the pfn
> >> physical range. Device private memory which is non-coherent is excluded
> >> from linear mapping during devm_memremap_pages() though they will still
> >> have struct page coverage. Just check for device private memory before
> >> giving out virtual address for a given pfn.
> >
> > I was going to give my standard "what are the user-visible runtime
> > effects of this change?", but...
> >
> >> All these helper functions are all pfn_t related but could not figure out
> >> another way of determining a private pfn without looking into it's struct
> >> page. pfn_t_to_virt() is not getting used any where in mainline kernel.Is
> >> it used by out of tree drivers ? Should we then drop it completely ?
> >
> > Yeah, let's kill it.

+1 to killing it, since there has been a paucity of 'unsigned long
pfn' code path conversions to 'pfn_t', and it continues to go unused.

> > But first, let's fix it so that if someone brings it back, they bring
> > back a non-buggy version.

Not sure this can be solved without a rethink of who owns the virtual
address space corresponding to MEMORY_DEVICE_PRIVATE, and clawing back
some of the special-ness of HMM.

>
> Makes sense.
>
> >
> > So...  what (would be) the user-visible runtime effects of this change?
>
> I am not very well aware about the user interaction with the drivers which
> hotplug and manage ZONE_DEVICE memory in general. Hence will not be able to
> comment on it's user visible runtime impact. I just figured this out from
> code audit while testing ZONE_DEVICE on arm64 platform. But the fix makes
> the function bit more expensive as it now involve some additional memory
> references.

MEMORY_DEVICE_PRIVATE semantics were part of the package of the
initial HMM submission that landed in the kernel without an upstream
user. While pfn_t_to_virt() also does not have an upstream user it was
at least modeled after the existing pfn_to_virt() api to allow for
future 'unsigned long pfn' to 'pfn_t' conversions. As for what a fix
might look like, it seems to me that we should try to unify 'pfn_t'
and 'hmm_pfn's. I don't see why 'hmm_pfn's need to exist as their own
concept vs trying consume more flag space out of pfn_t. That would at
least allow the pfn_t_has_page() helper to detect the HMM case.

