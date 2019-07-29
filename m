Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BA68C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:50:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEC8A214AE
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 12:50:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEC8A214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62FAD8E0005; Mon, 29 Jul 2019 08:50:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E00B8E0002; Mon, 29 Jul 2019 08:50:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CFA78E0005; Mon, 29 Jul 2019 08:50:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F32A28E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:50:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so38216002eda.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:50:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qbQQU53UglvrrbWSy5+lYBnTBvKWtMJX3xJYOO4TtfU=;
        b=IDxbNJp4UG8SbykRWqDf88qQeZoLX/s8eLrMe8b1aRCV3l0DehPlPfqOcCs4wtczkd
         /97nu8pXmJTMCIx5f0yeYxWpWbtx9p9RV4LcZq401Op8YTs5L/7q7YBcDDJmeJWrQhk/
         Zqc5bOkmOQmyDl646ma+VcMJpR+eyxlBhtL/9EhYQEeop4mdStOzEs9nDT37SqEplPZ1
         hTupVS0a5xBGBn7NZHGBWLmrgJJqsSXbO+yrmBuVPR8g1CReHi5mvhws91lWH1m+4QLD
         fhmgJqQ9ZpYzkpFw4DXk8773nm2MvqEJ+uDoc9XQxmfkuCrpsSM3nyFhKEHwMrJbXBBY
         pNAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWOPn69WwhU31evUQhPw8whUG4pdkvd79pYKWq2PHK0ul1h4iDt
	0BTzADay7hnJzIQ12uDPEpgRkdlBhdGEEkQIA73HkdRC0mVBYz8PJdWzpOTPWjCS7HIKcmoIKRL
	S2kcbqvcBx0AkVkRMWZiZEcwgc299kKGTQrSobAK0lc70/rrLwdCLiAjTqmppaZrQhA==
X-Received: by 2002:a50:b13b:: with SMTP id k56mr98777444edd.192.1564404623580;
        Mon, 29 Jul 2019 05:50:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYGwsQmLpm2zBhUXFlrI6uFz0BOJsj38HMkXG8fAXtH/zRcXEZK0+0ZXvqO+1HPrItulwL
X-Received: by 2002:a50:b13b:: with SMTP id k56mr98777387edd.192.1564404622898;
        Mon, 29 Jul 2019 05:50:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564404622; cv=none;
        d=google.com; s=arc-20160816;
        b=CVIpQOTBIZrWXfuhpMjmJBfM5LMnVlSwjAWD1WONkkjQEFuByMSql0AbBR7UQcqmdd
         YIfeYOm4SrCVAqysp6Qur9mJgezPH1wrYXx6E5AskJc8W1Bc4B7m/y2f90iM1I6eeHKR
         89awlFDiLMnMJFYdkT5SoAQWa+k45Wurgkv7TbBHoMOPDh9F65R2iWvzF/DL8pk/J2ry
         umo5f6eLr/XQQPhu7YolJjPZWU7nUyyrSGA+I+pMn81jUi/v4l1yVFL5YD5Ka7R3+22J
         m7xgxpr79YnV0pR3lTHRBhtR0iafTG++a3vMCBIvQ/ODHuaVKomUHaKbj5mCGj0QNYEM
         U7nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qbQQU53UglvrrbWSy5+lYBnTBvKWtMJX3xJYOO4TtfU=;
        b=iti2JUxyx044+Wk6RRoDTwEWnORIAdmrwdOLhozOmRxsRtZUq+wkVWcXve0jcFbW0/
         PdfhIt9ZBlfldrdlg3j+TlXUs7AV8G2l2IRpD6BrVwlStVOUxnZVQcnAW+INEIGza3CB
         GuxT5auwXcmPCDPzXmomuuvF/SV+5h+r4eQ0rm01GF2l8MU/ygiUKYl+chmxi+UJCkGP
         4Th5+2zCcD7e8amkStDvCt+NENRObO6zkFtTuMgijdeUIxNgHzarYGl4LObx/9ZFzwaq
         plwDGSCUj4wdiOdDfpKPmeHfnyl0kj0xYpkndNcp1l5m51Xz8MDQRNMvEZfL7XAxr3H3
         Lnjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g6si16855408edc.90.2019.07.29.05.50.22
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 05:50:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C5EA528;
	Mon, 29 Jul 2019 05:50:21 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3C2A43F71F;
	Mon, 29 Jul 2019 05:50:19 -0700 (PDT)
Date: Mon, 29 Jul 2019 13:50:13 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
	x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
Message-ID: <20190729125013.GA33794@lakrids.cambridge.arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-11-steven.price@arm.com>
 <20190723094113.GA8085@lakrids.cambridge.arm.com>
 <ce4e21f2-020f-6677-d79c-5432e3061d6e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ce4e21f2-020f-6677-d79c-5432e3061d6e@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 28, 2019 at 05:14:31PM +0530, Anshuman Khandual wrote:
> On 07/23/2019 03:11 PM, Mark Rutland wrote:
> > It might also be worth pointing out the reasons for this naming, e.g.
> > p?d_large() aren't currently generic, and this name minimizes potential
> > confusion between p?d_{large,huge}().
> 
> Agreed. But these fallback also need to first check non-availability of large
> pages. 

We're deliberately not making the p?d_large() helpers generic, so this
shouldn't fall back on those.

It's up to the architecture to implement these correctly, and the
architecture-specific implementations will be added in subsequent
patches.

Thanks,
Mark.

