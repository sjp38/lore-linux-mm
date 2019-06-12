Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E81D4C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:57:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A603321734
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:57:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A603321734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20B8E6B0008; Wed, 12 Jun 2019 11:57:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BB786B000A; Wed, 12 Jun 2019 11:57:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 083D46B000D; Wed, 12 Jun 2019 11:57:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEFEB6B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:57:04 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c27so11291067edn.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:57:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VKb09obOTdWBCfaWJVe7ZF4m/xCKPcwi/G5ac4kdKbg=;
        b=n8Wt/JnFKU3Uns84Dkmk1hwegxGlRHcZCcLS0u2yG/YtxuaEa2DRQboIXxeE4KTqwh
         Msf6m9maaTcx745+4E9O9eGQA6wgR1ZOtz6o1Mdrwms4uucWGPztFaO9qNYzVLcrLrIh
         EhPQt6+z4kP0Wr45rDGeJnag07Biop88KbBJXeGv1kHsP1XXEBSFyMa+Qym9uPX/ueXY
         XE1Yaf1A+Nu5XFxuDBdGUv1WrAX+BtuzYfKx+f7MZqyLQs0omB3Ojgqm0lg3KmN4otdp
         V8XAICpyeLDxFgPM8HTporvVw/RFM+4Qs9xVWoRB+XwkMGBl2iU7TIe1v8eQtZ8SMhjM
         Bkmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXuomNNjcVpnjOB5vGm9KZscM7ak+Nfj3iNuQu7LBBH0S/1F2e4
	oICGCB3rkpwXjSahELDJ/rT6k37af0RS3p8xJ/7Ltfb8QgZfeBBTD38l1+hQtKo8yEX9+BfE+Rn
	SuXL67Y24HWjN9G4eujHH5EqK2LEk9I2GHgqvRQzEovdoKWYNo65nOlgTPAOhUbQXaA==
X-Received: by 2002:aa7:c14f:: with SMTP id r15mr23256245edp.116.1560355024270;
        Wed, 12 Jun 2019 08:57:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvfjVbS1gFuLhDOS1mDqMDazI+ccE2UjJQB23zGWfINF4JIjgvnYbh9ztRy7fgz/MnDKbu
X-Received: by 2002:aa7:c14f:: with SMTP id r15mr23256166edp.116.1560355023475;
        Wed, 12 Jun 2019 08:57:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560355023; cv=none;
        d=google.com; s=arc-20160816;
        b=VN3TedLA5TbKj1ofrC7mqUogxIrtHSvkCqumUNf0ep4GSF2QVotVEm3UCdmRmp9jk4
         CgZkrJa1QOqBC7E9bBozBfOM3gHeLy0OivLGH62lfOXDGwXxbweoOhm+Chz1/lcI6jaz
         qD5kWa8eHi/ZYfu4Dw/Fwti8PkTyuLntZTAivaydHK2+QkXLaoqMoADtC7pJVcr/xU7Z
         xx8tYohXj8VBkBzsVxstT3YbdGNryXV+ezAofT0gU6F85V4LN6HGoSceRZpv7EtsOrNF
         QAg7N+EnxDSCOWimbiQT+qpmz0jZ/qqjIkO5nz8WwC5o/kZ/S44D6NDJR8RSgHICbXUM
         0GPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VKb09obOTdWBCfaWJVe7ZF4m/xCKPcwi/G5ac4kdKbg=;
        b=CVL6KwsiTQdcUp/2xUuKjIB53Hixt6VRQzN7NqZw9fAS/EQbOZD7WBD7O4WMal5c0K
         mpmShExLc5zotYOn5ryrXSs69mi0R/F/MFBNlopmI+6i4xQCXbkBDHrNDSo9U7ODy03Q
         nqkremUwPthseJAh43Sw2pJpNYYZNAL0zFPDjUsjEH3ZQSbMQQ9iKlhwAZBvPrQCPcE2
         z1JhmgzFTmI7LQqphBSxXBmlSZ60GjGFErHmF/jFv31plksEao35PZsmTG7Uy0VBP4Yo
         z/cIy3aHY7KKDQ2Gcl/5QgZXNuNU8GwIAwn3Ux9CXHBbA/Z8E6Wnd3eNIiNVjFhATXCv
         ch/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id o21si96404edc.65.2019.06.12.08.57.03
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 08:57:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8F334337;
	Wed, 12 Jun 2019 08:57:02 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B245D3F73C;
	Wed, 12 Jun 2019 08:56:58 -0700 (PDT)
Date: Wed, 12 Jun 2019 16:56:52 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-mm@kvack.org, linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v4 2/2] arm64: Relax
 Documentation/arm64/tagged-pointers.txt
Message-ID: <20190612155651.GM28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-3-vincenzo.frascino@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612142111.28161-3-vincenzo.frascino@arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A couple of minor nits below.

On Wed, Jun 12, 2019 at 03:21:11PM +0100, Vincenzo Frascino wrote:
> --- a/Documentation/arm64/tagged-pointers.txt
> +++ b/Documentation/arm64/tagged-pointers.txt
> @@ -18,7 +18,8 @@ Passing tagged addresses to the kernel
>  --------------------------------------
>  
>  All interpretation of userspace memory addresses by the kernel assumes
> -an address tag of 0x00.
> +an address tag of 0x00, unless the userspace opts-in the ARM64 Tagged
> +Address ABI via the PR_SET_TAGGED_ADDR_CTRL prctl().
>  
>  This includes, but is not limited to, addresses found in:
>  
> @@ -31,18 +32,23 @@ This includes, but is not limited to, addresses found in:
>   - the frame pointer (x29) and frame records, e.g. when interpreting
>     them to generate a backtrace or call graph.
>  
> -Using non-zero address tags in any of these locations may result in an
> -error code being returned, a (fatal) signal being raised, or other modes
> -of failure.
> +Using non-zero address tags in any of these locations when the
> +userspace application did not opt-in to the ARM64 Tagged Address ABI,

Nitpick: drop the comma after "ABI," since a predicate follows.

> +may result in an error code being returned, a (fatal) signal being raised,
> +or other modes of failure.
>  
> -For these reasons, passing non-zero address tags to the kernel via
> -system calls is forbidden, and using a non-zero address tag for sp is
> -strongly discouraged.
> +For these reasons, when the userspace application did not opt-in, passing
> +non-zero address tags to the kernel via system calls is forbidden, and using
> +a non-zero address tag for sp is strongly discouraged.
>  
>  Programs maintaining a frame pointer and frame records that use non-zero
>  address tags may suffer impaired or inaccurate debug and profiling
>  visibility.
>  
> +A definition of the meaning of ARM64 Tagged Address ABI and of the
> +guarantees that the ABI provides when the userspace opts-in via prctl()
> +can be found in: Documentation/arm64/tagged-address-abi.txt.
> +
>  
>  Preserving tags
>  ---------------
> @@ -57,6 +63,9 @@ be preserved.
>  The architecture prevents the use of a tagged PC, so the upper byte will
>  be set to a sign-extension of bit 55 on exception return.
>  
> +This behaviours are preserved even when the the userspace opts-in the ARM64

"These" ... "opts in to"

> +Tagged Address ABI via the PR_SET_TAGGED_ADDR_CTRL prctl().
> +
>  
>  Other considerations
>  --------------------
> -- 
> 2.21.0

-- 
Catalin

