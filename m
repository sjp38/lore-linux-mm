Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53032C28EB8
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:19:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4673206BB
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:18:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4673206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F1BC6B02F5; Thu,  6 Jun 2019 18:18:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A2C36B02F6; Thu,  6 Jun 2019 18:18:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 491EA6B02F7; Thu,  6 Jun 2019 18:18:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D34F6B02F5
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:18:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 5so2821547pff.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:18:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XJNu7sen3MKt/5bh7xDkzC+qT4zLIA/t3Gj09QiyowI=;
        b=O3CLPJmqYbDZQ7apBgeZvBB7gBm9uJS8JU5vt7kwqyZg+8lKXpLRIiLSLGGL+fEwv6
         xQKZ2ZvLuqLWGwFkgF70nxP2P/p3wF1KL3I11ROdl6mcqS3gwgU3I7VjmtdCjN2t5vbE
         koB2kqpQqmyqWehMLL07Y3JmV3DrXZBJW/SuTda+5CuwH3eni33qAy8RXZpc6I0ZT/Lc
         n0adrK0mkXt4mF8kbP5388t2IQfZhUf7xamyDgFH7cCJrNIexxtcqn58B4DP5PPSkU93
         Srp2Gxg8An1M5dzO4gzExDxS7jCPJlCsO9xK8OCR6LHGpVPNjTUdcnfjUjLFOCpJnkdG
         C0Vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUO2mFR9oWdEcaX6WEUcmqofyXC+Z9RlWTtwyctvBQWmzGuZCaJ
	OqiTmp8sWIV47LYO9N0Xfb5pl4Zy7KMrGP+C67AfWSo4akpOl4N2v7ALUd/oIJ+ptkYQNGfuKfv
	Dx8f9NV2PfKkD5e32akTS9j8KHod5Q3IgG0zbxVc0c5zZK3aOGN4fzkIQS1HDTVoDgw==
X-Received: by 2002:a63:91c4:: with SMTP id l187mr56182pge.95.1559859538623;
        Thu, 06 Jun 2019 15:18:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrfrR5E1yhB0Dsth30RYkNWxefuiNciNIAc0YTIZsHQU6wjsK8UJN83FMBXvSrfCeaGL02
X-Received: by 2002:a63:91c4:: with SMTP id l187mr56142pge.95.1559859537869;
        Thu, 06 Jun 2019 15:18:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559859537; cv=none;
        d=google.com; s=arc-20160816;
        b=a70Lwdyj56Zwz4ONxJM0Noq6PHW9DIF0OnDCxb17XAnOf+BSgjcG1XLEkWee5PbEPX
         LWK4bnyeNGnrRkFsWsvlBSbrYAxcBugpvU9bJDFqOJ4sfiOdeZKEePi4rOlBaHk+kryJ
         RBP8ronz0/gvQB5tBGnhgUxxRFdAupplRLD0qdUpoSJlA+aySnBjBiXLM8tIpqRp2rLA
         bMy2H+QkSh6KQhDJ+HNJQp0GXpw+fmWhL1L+rCvDtRPuiPhHUzWhLQ4PtEWuTCsYzl4D
         8hWvWfXWcEVD1U8JQOJBcZUuIZWqV9BcCzdLLkzDOcC2Jhjqs3kYBs/zq4bKseYKsyq9
         jh6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=XJNu7sen3MKt/5bh7xDkzC+qT4zLIA/t3Gj09QiyowI=;
        b=VyZpNqir8lC3Lb3g8PWKeWD18WGX9NPzr0VrOFD0o0hrtVBYEmfnsP3JAOd98Dva+z
         GbnY3XX/UpPNegXrPBKvqYxR2K6BMv3MqAo4Uyjom8e17IrQ66eFcDcDQgJ4yLCWe0ot
         4nToNn8zfnZzwdeYd77XxDTWY8Sm9UC8ImsvN3836lzVtG1D+725O0uhsm7xx/6Ihtwc
         E7Hb/9+WCeEEPxGCTfxcgHCGiy26aB/mOE3h0k2lRHuuwtZX02sd+BdMu9EkPH7XbY0y
         ONyQGkYlA36Lnk6JgabITICBUsvFZoRqECGGknUN9JoddT4SJbvffPlQxhPCkp1qJvsq
         10Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b36si243569pla.353.2019.06.06.15.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 15:18:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 15:18:57 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga004.jf.intel.com with ESMTP; 06 Jun 2019 15:18:56 -0700
Message-ID: <93ee5b103b8261d2b50de89f8658d133639a9af5.camel@intel.com>
Subject: Re: [PATCH v7 04/27] x86/fpu/xstate: Introduce XSAVES system states
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski
 <luto@amacapital.net>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov
 <esyr@redhat.com>,  Florian Weimer <fweimer@redhat.com>, "H.J. Lu"
 <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>, Oleg
 Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Thu, 06 Jun 2019 15:10:55 -0700
In-Reply-To: <4effb749-0cdc-6a49-6352-7b2d4aa7d866@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-5-yu-cheng.yu@intel.com>
	 <0a2f8b9b-b96b-06c8-bae0-b78b2ca3b727@intel.com>
	 <5EE146A8-6C8C-4C5D-B7C0-AB8AD1012F1E@amacapital.net>
	 <4effb749-0cdc-6a49-6352-7b2d4aa7d866@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-06 at 15:08 -0700, Dave Hansen wrote:
> 
> On 6/6/19 3:04 PM, Andy Lutomirski wrote:
> > > But, that seems broken.  If we have supervisor state, we can't 
> > > always defer the load until return to userspace, so we'll never?? 
> > > have TIF_NEED_FPU_LOAD.  That would certainly be true for 
> > > cet_kernel_state.
> > 
> > Ugh. I was sort of imagining that we would treat supervisor state
> 
>  completely separately from user state.  But can you maybe give
> examples of exactly what you mean?
> > 
> > > It seems like we actually need three classes of XSAVE states: 1. 
> > > User state
> > 
> > This is FPU, XMM, etc, right?
> 
> Yep.
> 
> > > 2. Supervisor state that affects user mode
> > 
> > User CET?
> 
> Yep.
> 
> > > 3. Supervisor state that affects kernel mode
> > 
> > Like supervisor CET?  If we start doing supervisor shadow stack, the 
> > context switches will be real fun.  We may need to handle this in 
> > asm.
> 
> Yeah, that's what I was thinking.
> 
> I have the feeling Yu-cheng's patches don't comprehend this since
> Sebastian's patches went in after he started working on shadow stacks.
> 
> > Where does PKRU fit in?  Maybe we can treat it as #3?
> 
> I thought Sebastian added specific PKRU handling to make it always
> eager.  It's actually user state that affect kernel mode. :)

For CET user states, we need to restore before making changes.  If they are not
being changed (i.e. signal handling and syscalls), then they are restored only
before going back to user-mode.

For CET kernel states, we only need to make small changes in the way similar to
the PKRU handling, right?  We'll address it when sending CET kernel-mode
patches.

I will put in more comments as suggested by Dave in earlier emails.

Yu-cheng

