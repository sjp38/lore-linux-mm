Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44FE1C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1894F20B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:08:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1894F20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 814156B0006; Fri,  2 Aug 2019 06:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79CA26B0008; Fri,  2 Aug 2019 06:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B2316B000A; Fri,  2 Aug 2019 06:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 394846B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 06:08:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y15so46679808edu.19
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 03:08:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AqewJ3T81UosVhATq5r9DHsuzG0uNfiTZ0GWZ3z4lWM=;
        b=ME3uFoPQWhJ1BwFoq1YUYqLghL+5m0JwStdObYH0oTvthK5g+bJjWRdqtaXln5jrVy
         8ii0NgFv1yK52t09KSW4NFJHTgbmKOXjC0kg0UMbKuhJsH+DoSUaq1+Wh1aqx76MBFY5
         6No3+mBEzsfe0RVg+Zj1uqoJer1rMw3HecBsWAj4ZGkXQkhfiNjAfrfM9aBFiWuObuS+
         SJvkAAvTfXQVzJEUlwLMTTK1+C8qtIxVCOIdMiC2gwKNusSsrXrZ/PfKNHEZ3YoaCKI4
         t7SQ9XjFFajVu0gRR64oqxj5h4aIDHzG/Mp/C2OvdLBkeL0cgdnX/CgIHgPxzBMmoazy
         IKsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAU6Kt1Xfoqi6s0ICHPQ4p6w1DDWjTAm8mqjIDNsiV2DcOiYj7po
	YaKcYnRMFknXV+TI2xZzRydNiFAkl3OUPOawTNp6dpD227D3xvI8zdF+erGzMUTZPQwi0yjOSys
	Qrcv5nh3ziTmMUZYDZxzZRCqOnX7ty9j4sO7nTvtZ0WLzt+o4WWxHY4ty6/TZM5LQfw==
X-Received: by 2002:a50:a4ad:: with SMTP id w42mr115561028edb.230.1564740520797;
        Fri, 02 Aug 2019 03:08:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEnwcBv2k0kCI5hpP3NzogsYULy3TDmJac9hUUaaSlHcUv3w4mrhDAJ93naRieS/Jv+Ifa
X-Received: by 2002:a50:a4ad:: with SMTP id w42mr115560970edb.230.1564740520049;
        Fri, 02 Aug 2019 03:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564740520; cv=none;
        d=google.com; s=arc-20160816;
        b=fQ0FpEzTijKyt06c8SjKr6ppHZAviUxMFp7sZXPvwLGDkIt5khGf8i7vM94mNMCGxW
         ks1Z2ZWWIAqRoNAU6E4YmtjL2In5CCYtznq2xoRPtoo/AYNKavbWlp9hlHUJqdyLUGhQ
         +YIPBaIqiHIPNN5f/NYA8Ehyb4it5eNoQGlxPRe6qvKaFgWfMDKAoQydM6w8q4F5tgDH
         wz5R5BLxy7AiS2mjsmEiBjSdiEyDVfUZg9zFb4aZvUDeapr5P/3EuwGaVF3TyAEhgHtb
         ncc3MS1esh0VGjgATRAThtm0NRVJvQzn7QSxeb3zYHIiwOmksI9+9Z9QrqNhK9lPYz4Z
         VbWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AqewJ3T81UosVhATq5r9DHsuzG0uNfiTZ0GWZ3z4lWM=;
        b=Yi9rhehNqC3LF1J0WHb8IZrQhxzd7C7ZJSj5wa5Ad0bcd3kGV8mrSLuWJFCVDXisnb
         dDEymgngaTSl6fK+3vzzsS5RZs+aVu+4qm4SI95d2gLPoCZzvcjGrIMYDyCXpO7QrlKf
         i1nrqWISZQDXpMBTc80urx+qDQ9dSKnANxCeOBaI3jqVpCQZVmmcR+m5KbIcu3TNL+3q
         wsxNOQjJeXvshEzsOimedBBHjQYFyTeAfz/QlRY0VaHZgLK7xiDFEP9N7dkuaNAiHIaT
         i6MtWKYseQZbGo9NpIs/5/ixj7O5f+Cu0TNi4mXnZyEO94gcpyE4XpTy24PYicohiyMB
         D99w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l42si24788948edc.120.2019.08.02.03.08.39
        for <linux-mm@kvack.org>;
        Fri, 02 Aug 2019 03:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2C9EB344;
	Fri,  2 Aug 2019 03:08:39 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B1D323F71F;
	Fri,  2 Aug 2019 03:08:37 -0700 (PDT)
Date: Fri, 2 Aug 2019 11:08:35 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Szabolcs Nagy <szabolcs.nagy@arm.com>
Subject: Re: [PATCH v6 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.rst
Message-ID: <20190802100835.GA4175@arrakis.emea.arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <20190725135044.24381-1-vincenzo.frascino@arm.com>
 <20190725135044.24381-2-vincenzo.frascino@arm.com>
 <b74e7ce7-d58a-68a0-2f28-6648ec6302c0@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b74e7ce7-d58a-68a0-2f28-6648ec6302c0@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

On Wed, Jul 31, 2019 at 09:43:46AM -0700, Dave Hansen wrote:
> On 7/25/19 6:50 AM, Vincenzo Frascino wrote:
> > With the relaxed ABI proposed through this document, it is now possible
> > to pass tagged pointers to the syscalls, when these pointers are in
> > memory ranges obtained by an anonymous (MAP_ANONYMOUS) mmap().
> 
> I don't see a lot of description of why this restriction is necessary.
> What's the problem with supporting MAP_SHARED?

We could support MAP_SHARED | MAP_ANONYMOUS (and based on some internal
discussions, this would be fine with the hardware memory tagging as
well). What we don't want in the ABI is to support file mmap() for
top-byte-ignore (or MTE). If you see a use-case, please let us know.

-- 
Catalin

