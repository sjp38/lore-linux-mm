Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2037C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A7B521929
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:32:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A7B521929
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 065738E0005; Fri, 15 Feb 2019 12:32:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2E088E0001; Fri, 15 Feb 2019 12:32:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCF8B8E0005; Fri, 15 Feb 2019 12:32:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8060F8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:32:39 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so4166627edt.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:32:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ri3wGGSb3ZjxcvWOJ9kDqmAtUiSO9zTiGqi+iWGaxZY=;
        b=Q8vIT4KJYN/PLgwJsBJHeRiR5Y0/Np6ELYPeDzkjRacqy8PS5ovm173Y7moYqpTNVZ
         7pjveDgbjnnQ5+wVHqOEp+OzNG6KU/1kreZL5JnJ3ebvr3QnBq4xbFtE1kqmwjpLJa41
         S9D1HWelYpuacBxElXWOTX7cGw+dZSEyOXmywznH5PBhULHEb7OZEI3csdxp7C61nhRE
         L8xv2gW3VB7GXugfqtngH+yjvPZiRFD8N4mUDVNN1UUQ7qK2Cttgg+mBplZcplPWmWVC
         O5cA21d0gT4blCNIAQsEFjOS3jMtMflwWvCTIm9vFlEAbbU/FEsyRYfc1aSe0BEjWKwJ
         ANOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZYtyaIaDyOjkNy0yyhxQafHJCFQRcqy2MTIQeyZcTyWPyf0p+p
	cabhz0uiEH2fU9V0xgTXzg1xeDqRIeomrGJM6zogaUdyWkIa2dj2a4BfipQcyKGdpB7jRRAELiB
	gFiRdmkV4fxRrRa78J9IBxLikcg0ep1X1XEjtKpU1wvZbBA9khBevYj6CNWGFYeNLew==
X-Received: by 2002:a50:fc12:: with SMTP id i18mr8470119edr.149.1550251959075;
        Fri, 15 Feb 2019 09:32:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYxZ/eOmOu9C8CHj75T/PiAVS0pJMdVYZvX7VkX8rD+oQwHpmh1sH9WzpsAQOUravIVgcco
X-Received: by 2002:a50:fc12:: with SMTP id i18mr8470044edr.149.1550251957939;
        Fri, 15 Feb 2019 09:32:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550251957; cv=none;
        d=google.com; s=arc-20160816;
        b=MEgAXGUVJTYjCUU//DpmNUFMgAbXlARuTi8FiHGjp574f2TJgSA2OFDCM4jO4GOVII
         Wt58bkMMChLrUz/1KqmonG1Yk1UMLdZmJkrzAFxzT5RHEdTT+oUnlWDqUQ8ktbcSN16w
         oghyJYC4jdXY3idxg6SaTloJt9XK08l3yMXhznXwvpnntCEnUDS4etajY0sTwbHHKMxw
         HeuWr37oH8buMKnbj3kVhB7dnjmTlvumhAzI5rLp1oBzXNUifsDLXD/QOVsSARsHbWT/
         LuiMVxYzpHxrU6ta1joCsXYfZJUV1jHGUZL20tEGBnIgmyKC062/Q5hX66TRQYpX5/3+
         VNLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ri3wGGSb3ZjxcvWOJ9kDqmAtUiSO9zTiGqi+iWGaxZY=;
        b=DGmypeRXlK0Xry25BaAXve/ek0WaRFfHyquvG+152ROv8GIGRmkylF9kAifIiOgH5u
         eN5bi1upJuYxDzhrvbexzg0z5HYf36eZgOJdXFHZkNWsHCOWCXdO72Hs1vA3n3pgZo/P
         d2NJL0xksb5p8jYHYdU0D/JH7g/rtjNAEmk1CiWd/83ntYkfkpXoNOgfs70UHqD7gGHo
         ZmaLLULYcOa5jBhAWwTh53cSZKF7ik/7q648UWw1JSuQ1ht7ATcTYkcQicx8Mv0G0PeN
         5XVpHOLspyB0q1SDiCMAjKAoxqvZWi5odbXU5z5kVwse1qX9tNhTlctT6NBOMsrvtQKw
         xHvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z40si1802178edc.10.2019.02.15.09.32.37
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:32:37 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CA2C5A78;
	Fri, 15 Feb 2019 09:32:36 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 02A433F589;
	Fri, 15 Feb 2019 09:32:33 -0800 (PST)
Subject: Re: [PATCH 13/13] x86: mm: Convert dump_pagetables to use
 walk_page_range
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-14-steven.price@arm.com>
 <59a6d402-e383-b9d0-499a-7d65b9a2d402@intel.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <9d7d1e1f-93de-c9a8-e6bb-63696e162210@arm.com>
Date: Fri, 15 Feb 2019 17:32:32 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <59a6d402-e383-b9d0-499a-7d65b9a2d402@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 15/02/2019 17:16, Dave Hansen wrote:
> On 2/15/19 9:02 AM, Steven Price wrote:
>>  arch/x86/mm/dump_pagetables.c | 281 ++++++++++++++++++----------------
>>  1 file changed, 146 insertions(+), 135 deletions(-)
> 
> I'll look through this in more detail in a bit.  But, I'm a bit bummed
> out by the diffstat.  When I see patches add a bunch of infrastructure,
> I *really* hope for code simplification.
> 
> Looking at the diff, I think it gets there.  The code you add is
> simpler than the code you remove.  But, the diffstat is misleading.

I agree, I was disappointed myself by the diffstat. Hopefully the code
is simplier though - there's unfortunately quite a bit of boiler plate
code in the new version, but that code is at least easier to understand.

My hope is that it will be possible to move the boiler plate code into
common code (there's a lot of similarity with arm64 here). However I
wanted to get some agreement on the approach and make a non-functional
change before attempting to unify the different dump_pagetables
implementations (which is likely to cause minor functional changes).

> I'd probably address this disparity for each patch in the changelogs.

Good point, I'll try to remember for next time.

Thanks for taking a look,

Steve

