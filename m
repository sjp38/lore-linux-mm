Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77A42C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:33:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 426AD206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:33:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 426AD206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA4BE6B0005; Wed, 17 Apr 2019 10:33:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B546A6B0006; Wed, 17 Apr 2019 10:33:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A69D26B0007; Wed, 17 Apr 2019 10:33:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 573E46B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:33:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p26so4599627edy.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:33:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UDi1VBi3Er+JacX8csYXUb+XVOVabealOpPN8Cz72S4=;
        b=Y0kuKjSbrgyj/tZeelIBIm8yw1Rkq96ZUF+SGRMPDYz3bXfrUr+woaqdBS0OJOgzQ1
         SiF5cXrnfZm3yW62Cqy1qYrSrBluDrsd95/OM52XlO0X5w/erD1dScwN2bB7BPlxgRye
         Iy3kGoss/LCEM3fdFl89w+3MlfWZqtpGMO2+P4TF1TNdpf3lvX7IAL0WO69kHynQu8eb
         hs5WhHT1epo9grOpzXzSxzHgmp/g2O5QmpRnyx0G/5vzvP1B39Pjs3nbb1qsSA0+f6bG
         OKNTqx91OgKKStxtsuIMtrmbcmRXxj3ajQE8OPgN7QITgyz+LZw9upnZrsrcX0yPL5Om
         o3Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXgIYAt3xXqnXqsq/oaGj6rk9vCKTJvz5Xwh1CDsTCJmaikYovS
	3FuEjuS1dKOTNtTlV4M1xMDZcbwbCb9mP/Ixx6XjcqugtMeAOxL+5ZfJswcmBG/INOsbDXMSiKw
	u1fxb/7oPvVFCSxHDzjKmpVSjUqaXim50wXLCNF1j9+aeXkwM4k8VDlj1h/KUwEF3/A==
X-Received: by 2002:a50:b1b0:: with SMTP id m45mr24372296edd.82.1555511610836;
        Wed, 17 Apr 2019 07:33:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+jUMubtlNbs2xNDJTTQ+Np5LXCKTnyjgSQf7vsMeahtqU26hNjrr5uTmw4h/fjl++LbXU
X-Received: by 2002:a50:b1b0:: with SMTP id m45mr24372248edd.82.1555511609901;
        Wed, 17 Apr 2019 07:33:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555511609; cv=none;
        d=google.com; s=arc-20160816;
        b=ALaCihubE12QhJEO7rnW1juKkEp0nvqRjzi831MNFH061O7ucPzUeSPGitljD2cyGf
         oY7PKP9Sk8JYGutfw73f+9ln07oFyRGqHT4zHkLzOutgAgOrretmp77xM35THopVnxew
         Ft4RSfskPdlgE/DlT8NV40OxILp9ERz3Gs5DEiTQEcRGMyVh7EmK1eN/jT8TotO80Y8/
         bNkpAmsRLjsX+BcGo679bkiHIpQniunIdk4PD5OvjOL6hG9135usTVq6L7u3DxNkK+Zb
         tw41uFjpVW3BeJkwKIpzKPZto1lcu4n0s3vpTUfrNUX5Z+EBjvNLBTKMxnbMLsNwv0Zr
         r+lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=UDi1VBi3Er+JacX8csYXUb+XVOVabealOpPN8Cz72S4=;
        b=ultjtGsTPhNrQiycWQYvfxWA4AHVf+/bgZ8qI+QVx2+MNFSiJ0+stK9/7Omnu9EYAI
         JJW9hG0wXwXLfdtFGdFMtvQZqAYf2STylRVHrfIunaZ42VhV5u/yalg6GRIQLZZr/kyY
         iITGa0dtHo8RTe35ojdG3Npv4p9+D/3I5Lh59JGNZ4VsrBRuvvZDo1zr47o/uE6YFLJv
         TXfgHaynI6pLObBx6HOaBnLz/fzRW/wyPVl3XU/uraqOXGT8LLo+6H21mnsu7Cw+VPjE
         /m0uH1SjGpsTA44Dlvsjcwmqn73FcaTGpYA88EKqkUIvHrSG6Pwn7r9fqm3psuxCnR/X
         xjXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y8si5629198edv.117.2019.04.17.07.33.29
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 07:33:29 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 96F8BA78;
	Wed, 17 Apr 2019 07:33:28 -0700 (PDT)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E33E03F557;
	Wed, 17 Apr 2019 07:33:24 -0700 (PDT)
Subject: Re: [PATCH v8 00/20] Convert x86 & arm64 to use generic page walk
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org,
 Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190403141627.11664-1-steven.price@arm.com>
 <4e804c87-1788-8903-ccc9-55953aa6da36@arm.com>
 <3b9561d0-3bde-ef7a-0313-c2cc6216f94d@intel.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <3acbf061-8c97-55eb-f4b6-163a33ea4d73@arm.com>
Date: Wed, 17 Apr 2019 15:28:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <3b9561d0-3bde-ef7a-0313-c2cc6216f94d@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/04/2019 15:44, Dave Hansen wrote:
> On 4/10/19 7:56 AM, Steven Price wrote:
>> Gentle ping: who can take this? Is there anything blocking this series?
> 
> First of all, I really appreciate that you tried this.  Every open-coded
> page walk has a set of common pitfalls, but is pretty unbounded in what
> kinds of bugs it can contain.  I think this at least gets us to the
> point where some of those pitfalls won't happen.  That's cool, but I'm a
> worried that it hasn't gotten easier in the end.

My plan was to implement the generic infrastructure and then work to
remove the per-arch code for ptdump debugfs where possible. This patch
series doesn't actually get that far because I wanted to get some
confidence that the general approach would be accepted.

> Linus also had some strong opinions in the past on how page walks should
> be written.  He needs to have a look before we go much further.

Fair enough. I'll post the initial work I've done on unifying the
x86/arm64 ptdump code - the diffstat is a bit nicer on that - but
there's still work to be done so I'm posting just as an RFC.

Thanks,

Steve

