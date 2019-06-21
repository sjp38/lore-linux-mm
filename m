Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D713C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:16:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF08A2070B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF08A2070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 822758E0003; Fri, 21 Jun 2019 11:16:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D3D58E0001; Fri, 21 Jun 2019 11:16:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69BCE8E0003; Fri, 21 Jun 2019 11:16:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD768E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:16:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so9546908edd.22
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:16:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=55qj7pfvk/gtDF22O9pLGm/R0IceuKjj3S5ykBWI0VQ=;
        b=GM/rnsSZpiPLehlBN/kVtZsEbD7uDlpVHUTeb8IPm8fjP1Y/ze9T0X4FS7kR11YTye
         TgM1DI04q5hfN7YO6PZpONVIilpaSNAy/QHiedYPhlb2QOOs6N/L0HXZ3ziEd+s15az0
         qE9aWuVTSSVFJXh0ACGhG7H8sXXsvPkQhVsZDz5zMx+XMFlf9Zv1B9cZ6WZTuiCOmFVL
         kzpvs0vlFckBVHhXA4Q8mbotZ0oeahmAuUxqVZSIy346jfD6iVBcwBD/QDaIe3Br5+1x
         cBWsSTkGyGI8FLyyjOSq/8AwQYkVHdLeXHOl36lXFtucBt6h3ucFfFPPrOmF/0pJXX1G
         61Rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWY8ZLkYSyHI4HDS3baL1ZjILdJ9bKVvEOBjcYsYkV6OZrLjjoC
	XOKAvmwNNpY0Si9K/TjRmbG1t1CNp7aWnx8v3k3pIHeKx6wX8HVzE1OeZCjEtXNlPy8pv2D67Rq
	oXOVOasqMem2keVBd78nk2ZWf+tJCU8tQyWrfDwx0F6/SHJi0NKY6Pz4wVTr0Ze6vOw==
X-Received: by 2002:a50:fa96:: with SMTP id w22mr48426278edr.45.1561130206645;
        Fri, 21 Jun 2019 08:16:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLwDRt3ixOm0UKCAXvwRpltRcfJxhFcmIXgOZ/Lo+XT/Ay6UTw5mT0P/eDbIDH+E7Dspm1
X-Received: by 2002:a50:fa96:: with SMTP id w22mr48426169edr.45.1561130205792;
        Fri, 21 Jun 2019 08:16:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561130205; cv=none;
        d=google.com; s=arc-20160816;
        b=tU6jJU4Pb+readTy6SIZpFnOQ8o7GVLG2KdGvhCW+p7vk8D3U/rvt55Z1LuCsTCOHU
         f0m2N0ensrJCCPuFpx0n+yn4SHcSbc8w02BDXXuWRqcXobQSCaO3nnytbMImIcOAP7BC
         YezjC7L9sa7+OSuEM2ZZ8Rdp/k76gRV+oC4GrbTv+NYtBF+u1xRHhK900tup8IFof/5/
         EExp0ckaOn4WTMdfACYRZ2xoChNXipzzzan+o5SueqhnTQAonssvmp/Kdp7aDG/Pgt82
         rln84v5d3R0lr4niJmabPexspHx35sbV53dweWYW3vfcWnrqzpuG1/mK0xeDg4xfxInQ
         1GqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=55qj7pfvk/gtDF22O9pLGm/R0IceuKjj3S5ykBWI0VQ=;
        b=GKwZyB2YSDmDGGx16975DQ1dYUl+JJS+dXgdjoNHBgxGlZH3hVa1W2MqkFxJ9ShDpp
         TItAKCQLJuK8B/0Kn+pQdIqByV01lYFmrUJQu/IoyahKP9dF0pq4woS8hzmW3Nm/xzVH
         MACAikXbbbaU1KmdeFtRNDG/Gd0Qf+cywrCfF5fAAa0XB7vXCVxRxX6R23/uWSbttbdO
         g0G37yxLWktbCkSvumv5CYCxhxG0m7pwDpQvitrX0o3B++6XzNNIf1TWYzBJ24bFuoX0
         ckmbbv01RH+XIskQ17bzo+HM1tURM6XpwgjNYxktVjyrSaH+L+LpwbY0JtllPp8cfsWn
         DRnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l13si2008619ejb.383.2019.06.21.08.16.45
        for <linux-mm@kvack.org>;
        Fri, 21 Jun 2019 08:16:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C4CF5344;
	Fri, 21 Jun 2019 08:16:44 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 558C63F575;
	Fri, 21 Jun 2019 08:16:43 -0700 (PDT)
Date: Fri, 21 Jun 2019 16:16:41 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Kevin Brodsky <kevin.brodsky@arm.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v5 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
Message-ID: <20190621151640.GI18954@arrakis.emea.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190613155137.47675-1-vincenzo.frascino@arm.com>
 <20190613155137.47675-2-vincenzo.frascino@arm.com>
 <1c55a610-9aa5-4675-f7de-79a1661a660d@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1c55a610-9aa5-4675-f7de-79a1661a660d@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 02:13:01PM +0100, Kevin Brodsky wrote:
> On 13/06/2019 16:51, Vincenzo Frascino wrote:
> > +The ARM64 Tagged Address ABI is an opt-in feature, and an application can
> > +control it using the following:
> > + - /proc/sys/abi/tagged_addr: a new sysctl interface that can be used to
> > +        prevent the applications from enabling the relaxed ABI.
> > +        The sysctl is meant also for testing purposes in order to provide a
> > +        simple way for the userspace to verify the return error checking of
> > +        the prctl() commands without having to reconfigure the kernel.
> > +        The sysctl supports the following configuration options:
> > +         - 0: Disable ARM64 Tagged Address ABI for all the applications.
> > +         - 1 (Default): Enable ARM64 Tagged Address ABI for all the
> > +                        applications.
> 
> I find this very confusing, because it suggests that the default value of
> PR_GET_TAGGED_ADDR_CTRL for new processes will be set to the value of this
> sysctl, when in fact this sysctl is about restricting the *availability* of
> the new ABI. Instead of disabling the ABI, I would talk about disabling
> access to the new ABI here.

This bullet point needs to be re-written. The sysctl is meant to disable
opting in to the ABI. I'd also drop the "meant for testing" part. I put
it in my commit log as justification but I don't think it should be part
of the ABI document.

> > + - prctl()s:
> > +  - PR_SET_TAGGED_ADDR_CTRL: can be used to enable or disable the Tagged
> > +        Address ABI.
> > +        The (unsigned int) arg2 argument is a bit mask describing the
> > +        control mode used:
> > +          - PR_TAGGED_ADDR_ENABLE: Enable ARM64 Tagged Address ABI.
> > +        The arguments arg3, arg4, and arg5 are ignored.
> 
> Have we definitely decided that arg{3,4,5} are ignored? Catalin?

I don't have a strong preference either way. If it's simpler for the
user to ignore them, fine by me. I can see in the current prctl commands
a mix if ignore vs forced zero.

> > +the ABI guarantees the following behaviours:
> > +
> > +  - Every current or newly introduced syscall can accept any valid tagged
> > +    pointers.
> "pointer". Also, is it really useful to talk about newly introduced syscall?
> New from which point of view?

I think we should drop this guarantee. It would have made sense if we
allowed tagged pointers everywhere but we already have some exceptions.

> > +3. ARM64 Tagged Address ABI Exceptions
> > +--------------------------------------
> > +
> > +The behaviours described in section 2, with particular reference to the
> > +acceptance by the syscalls of any valid tagged pointer are not applicable
> > +to the following cases:
> > +  - mmap() addr parameter.
> > +  - mremap() new_address parameter.
> > +  - prctl_set_mm() struct prctl_map fields.
> > +  - prctl_set_mm_map() struct prctl_map fields.
> 
> prctl_set_mm() and prctl_set_mm_map() are internal kernel functions, not
> syscall names. IIUC, we don't want to allow any address field settable via
> the PR_SET_MM prctl() to be tagged. Catalin, is that correct? I think this
> needs rephrasing.

I fully agree. It should talk about PR_SET_MM, PR_SET_MM_MAP,
PR_SET_MM_MAP_SIZE.

-- 
Catalin

