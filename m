Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4562BC468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:04:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03CC5208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:04:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03CC5208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74D686B0269; Fri,  7 Jun 2019 16:04:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E2E46B026A; Fri,  7 Jun 2019 16:04:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 550BC6B026B; Fri,  7 Jun 2019 16:04:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB616B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:04:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q2so2024883plr.19
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:04:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iJZHaE5MiCsrO1KQclInA0tIHjE0U6f5yWLWeAuFbjM=;
        b=fWDPWkdVnsN60jhCxOMuM9epyoTPKveqGpHhGaegwRX+xd7oVjN7+QaTiUkS0E7sRU
         gPmp9kCmDBLUxlBWc/+3mIiclza31c9IWYWbYqa73y/hNxaiXaYDyOgY1lbcokK2hZsm
         BayVhbVF5nuc/HI7fsKb8c2UrmDDsoO3dOkJSoLJCvMDW4ky72BMkrL6agAvPacBI5qk
         paAyfJex+LhwubzAbEs4SMCmOuLeAae8Owy40Zt0DSH/+2WX+NUSx+2BGoJCg0NALTpP
         Ty0Z8tQk65P6N8+/8EfmG22ls6EwzTuOHC9a7mbQLVvxanfW+hobzJItPfon/S8st06r
         fHvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVaomoIKiBRboEQau/9F0YiLH17gu0JE7CKtVNfhVPlpkBWo4UD
	KFWnFlgYcNj10aemlDEqg6TnkBIXJTnmLcxfKur5wSxyu19e2u7quirsIlgulKX/Hzuu4iZ6KE4
	F22q8mObZBFScijm3jka9ZS0+42gN4PXP5T6OkaWs7TtjBYFbNmSvOUu8F46dsg2SgA==
X-Received: by 2002:aa7:80d9:: with SMTP id a25mr60483841pfn.50.1559937883778;
        Fri, 07 Jun 2019 13:04:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzW0Zp0ueJt+yIbiiuXF4Ry70IQy+2KHVydxa0vXtbQQJdKvCT516Vrbg7amcOak92VOCxZ
X-Received: by 2002:aa7:80d9:: with SMTP id a25mr60483804pfn.50.1559937883222;
        Fri, 07 Jun 2019 13:04:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559937883; cv=none;
        d=google.com; s=arc-20160816;
        b=N2OhWdWOwVY+sLceHBjIW5ZCNCrA4H6cFPmTrwJsjWqXSicpjIKHD9ZQZtjMjWCbhj
         k9Dv82G7gy2JuRm3YYvub3HRqy+aPzaHPC0EGeBxxfUgBsgWtZOnDdtUazKJuadoD6WM
         nXdUe67ZfTmJ62Agy7rqX4TMNH7+Gq5WI5u1yiE2T82S5fwgQikjItwPTALgiJkBIFpS
         fRf3JifLTL0oxDD793k04ti7QYreRsT+RYqrdMmOV1rnRn15CRDjJmxZWRgTfE5FLWZB
         fzUMZTCaZPAlN61FycVnKsThMCpaQ86pkeYUqRWaiyVYTzfTyDdP221kzHjHthrE3CST
         ayaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=iJZHaE5MiCsrO1KQclInA0tIHjE0U6f5yWLWeAuFbjM=;
        b=R3Xd/GAnkMMNSmne4b52MlJCYlKm6aH59/sfHhrRlN9yj/YiAQm7hHTCJO0xqIBCy6
         fj/S6jIpP1TIzNRlBh7QqbqmEI9bmL4Z0l2Veqa3zlssUYMivAjiNahg3BdIJ3Nh+qUJ
         8LNsCFZBALs6CJcaG9Hc/7tXxTWup1alXtQ8Cq/MS+k+m6NlSp8ll6fwvbHJYJEJn4Xj
         1Hm6zV1rxrMAgPjhigR3QhKZMFKXqf4SvGNm/JFjFR+D1+blrnOw87Y3+gKElZxnnBIc
         NLWzjN6gqEmUGDkYhez22gG5InGIO6ojyUy9KlRsLtqWQcoYX7MPdTKx9t0SK9dvic3A
         JDfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e12si2944344pfd.4.2019.06.07.13.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:04:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 13:04:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,564,1557212400"; 
   d="scan'208";a="182781141"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga002.fm.intel.com with ESMTP; 07 Jun 2019 13:04:42 -0700
Message-ID: <9d3cedc83c236ee7a109325113fd1c1f9d849f25.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski
 <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
 <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene
 Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Fri, 07 Jun 2019 12:56:40 -0700
In-Reply-To: <352e6172-938d-f8e4-c195-9fd1b881bdee@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <352e6172-938d-f8e4-c195-9fd1b881bdee@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 11:58 -0700, Dave Hansen wrote:
> On 6/7/19 11:29 AM, Andy Lutomirski wrote:
> ...
> > > I think this new MSR probably needs to get included in oops output when
> > > CET is enabled.
> > 
> > This shouldn’t be able to OOPS because it only happens at CPL 3,
> > right?  We should put it into core dumps, though.
> 
> Good point.
> 
> Yu-cheng, can you just confirm that the bitmap can't be referenced in
> ring-0, no matter what?  We should also make sure that no funny business
> happens if we put an address in the bitmap that faults, or is
> non-canonical.  Do we have any self-tests for that?

Yes, the bitmap is user memory, but the kernel can still get to it (e.g.
copy_from_user()).  We can do more check on the address.

> 
> Let's say userspace gets a fault on this.  Do they have the
> introspection capability to figure out why they faulted, say in their
> signal handler?

The bitmap address is kept by the application; the kernel won't provide it again
to user-space.  In the signal handler, the app can find out from its own record.

[...]

