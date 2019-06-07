Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A69CC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:22:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D4CB20840
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:22:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D4CB20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A22A6B000E; Fri,  7 Jun 2019 12:22:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 952846B0266; Fri,  7 Jun 2019 12:22:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8416F6B0269; Fri,  7 Jun 2019 12:22:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBB46B000E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:22:54 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a125so1818761pfa.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:22:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iT22djDSQtamTnm+ifqkRdr/Mh/u02Kshf2tMhjBsJY=;
        b=lIgkW7c/6k7o6OzWpptp64m/WgyfFRafVuIhS90IFNTdP+yjvSYagjwDq/xv9kymvF
         F8xQH10cV0lFqqRmlfzXeR91wk6gwuj4/r9NGwBkDvXlMroA8nAHRkCsgZo7UrFVgaGx
         niIov8pbEhdZ4RCIX3Uw8u5FLmiI0Qja4a80vKolkZU6itKnCjzuuq+YLNqOZLqnyxGV
         WaGmKI9zxiEoVaVbewEVwxL4oD10ZXYT/J8b+6JzVYstCGYUE6jG76RWtKIAjfHeiDmt
         E2FZOlN4Hc2nzBszHfUS2V97kmJ0raobB6s5C4mAsr/T6cTuaX6AKHMLynklGm28zn3z
         GdNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVkRquFyodNTZB3WCy7WqERGwzrrGFNtcgjKmSqfUmoIHJRBU+I
	ga1CitTeg8EWe/KvG3eDOBFPAi8t5PwmDTijfmW1AwT+J/N6aB/dPbed+f5QERhBWwovk4fj7yd
	eRSnqTRaVQSjI1zGA2Jt497gxkYgjd94sa5YCdZyJA2GOEWe8DaOa/S+I6khgebhQIQ==
X-Received: by 2002:a62:1707:: with SMTP id 7mr44105207pfx.26.1559924573932;
        Fri, 07 Jun 2019 09:22:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVO5F7HvBeKaBHmxZ0EnQl1bC6fdWR1wmdNypXIOpl3v9USfxy+iogrH6KiNlD7Ipy6iBe
X-Received: by 2002:a62:1707:: with SMTP id 7mr44105131pfx.26.1559924573267;
        Fri, 07 Jun 2019 09:22:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559924573; cv=none;
        d=google.com; s=arc-20160816;
        b=ni5dqgl0Imv+ZRCQFkY5MkcQ79lo9IHK3Z8dhIucbqgEnL7m47QdDK3NqJ4MzfNwuR
         q7+wTuadEeK/0QTDHYBBg+au31iSvEpyHDWqtrhKyvlQmhY5438VmCeHerirJ7QCMxaw
         it8BuEEfh92drVAq7Bv+OlYVdhdlDsF2AY53QftOklqhaVq85ns3o7X4U0/57PycSo8B
         CrqKukSGXLDOP1NdFThOGnQYNWU0TGrUqiFoNLdKkc+Feipaz5ok7WVgV+KcxJS4Spu1
         ckcklxRSt8gBHAJ3uYe3xMRCfA1LmmKxoPBuy84xkAz2mJa7aZu8doh6TmA1LCv86jx4
         lySw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=iT22djDSQtamTnm+ifqkRdr/Mh/u02Kshf2tMhjBsJY=;
        b=MwNEEyTJPfNQLN/Q6kqklQu0mxQGnBW3tRLlVUXV/AgCJtpRev7ALbqeDRVBbDvxOa
         r3LoRHEgYhGjc65dm6CuoHsairSqnG7DigQn8f6+DUKy8GVoxknATCaswDUvB2DNnTGk
         OZPYZFyCsyFHaHRv1/QzHHQGutLjAU19xSaAeJ8MvpnFCYDGT8wSnh1fw4DNoZkboSWr
         J0XjEkpoL4sFaDvISBbD3zeZAnrC/lNLrov9cJWQ/DrqjLq9fMyGw37JTk6qRYpgKk6k
         Q7UnMnFV/RIOAM5wEiflXcesvpefG6qnfx0AslL0ZefcAPQEj2Mc50xa/DsfU11H/Xo7
         3omQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j38si2243611pgi.227.2019.06.07.09.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:22:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 09:22:52 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,563,1557212400"; 
   d="scan'208";a="182719233"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga002.fm.intel.com with ESMTP; 07 Jun 2019 09:22:52 -0700
Message-ID: <388e702bfa4ed38f460327ae09ebc9b18b582bb5.camel@intel.com>
Subject: Re: [PATCH v7 05/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>, Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,  Pavel Machek
 <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar"
 <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Fri, 07 Jun 2019 09:14:50 -0700
In-Reply-To: <20190607070725.GN3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-6-yu-cheng.yu@intel.com>
	 <20190607070725.GN3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 09:07 +0200, Peter Zijlstra wrote:
> On Thu, Jun 06, 2019 at 01:06:24PM -0700, Yu-cheng Yu wrote:
> > Intel Control-flow Enforcement Technology (CET) introduces the
> > following MSRs.
> > 
> >     MSR_IA32_U_CET (user-mode CET settings),
> >     MSR_IA32_PL3_SSP (user-mode shadow stack),
> >     MSR_IA32_PL0_SSP (kernel-mode shadow stack),
> >     MSR_IA32_PL1_SSP (Privilege Level 1 shadow stack),
> >     MSR_IA32_PL2_SSP (Privilege Level 2 shadow stack).
> > 
> > Introduce them into XSAVES system states.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  arch/x86/include/asm/fpu/types.h            | 22 +++++++++++++++++++++
> >  arch/x86/include/asm/fpu/xstate.h           |  4 +++-
> >  arch/x86/include/uapi/asm/processor-flags.h |  2 ++
> >  arch/x86/kernel/fpu/xstate.c                | 10 ++++++++++
> >  4 files changed, 37 insertions(+), 1 deletion(-)
> 
> And yet, no changes to msr-index.h !?

You are right.  I will move msr-index.h changes to here.

Yu-cheng

