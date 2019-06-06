Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BA6EC28EB8
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C1A92083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:08:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C1A92083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD8906B02F1; Thu,  6 Jun 2019 18:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C61636B02F2; Thu,  6 Jun 2019 18:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB3DE6B02F3; Thu,  6 Jun 2019 18:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7014A6B02F1
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:08:25 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q2so30223plr.19
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:08:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=HysFCU62V7+/vxvPJrHZKidBn5+NIqy1307HWpiK79E=;
        b=gmfxc2v2yplki1L1f3DzOvHs0T5XBTqBhiwsIkiOKX/PEKotDt0PMoe0vsuHF2PBbj
         OCVuQp2bMEAsOUKzjL/2TgCJRnuB5aFd63Akj5z7JSx6Uo/NTK2ANmuroGtUsMk6qLZV
         RTyGwQzv7/Q0vGp6/JpvVRbi2kCAlFvm9NBbCe4chwna+6ScMni9Q4uyu8mHnQzTARZD
         4Hu/GO3g3g3CnSYDGYmr/tmxTKBxWcP5q4t/PiPZ5WAvgGMZeqcNb9YAXBSIDvuHX17n
         16jbZiVL6yJTC0qWro56DiC5oyYctnqLOsXhSIQ6Vk6eZmafEYZ4eJRvWbmiPawOpJjQ
         rrXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW7dtqnsGiQf4VXrvm+IOBEiheESk3ZZ/jRP8j24cNblW78qvNp
	fonLe7Op0LirucoNlvrxaS32CzMS3kCeyUUoO/448PsiwMPp6jOOfZKYopFaefiBybbC7OuGpLQ
	Rjk2JX8ztxXSKYuZR84IaES5MbC21iDdey1yH82obTt5Sl/aamOH+FQTzQiJrayKH1A==
X-Received: by 2002:a17:90a:cb97:: with SMTP id a23mr2002164pju.67.1559858905129;
        Thu, 06 Jun 2019 15:08:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCxxPC13ilQcDglRgXqRH7xVO3LJI/flq5CAqYDulqKYImwqUWcwPBDdf2BV+/yLBFmZ1h
X-Received: by 2002:a17:90a:cb97:: with SMTP id a23mr2002127pju.67.1559858904493;
        Thu, 06 Jun 2019 15:08:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559858904; cv=none;
        d=google.com; s=arc-20160816;
        b=ATDHe8L7e0H1xKxstB6dvIGqQjuATZF3tyveuKF0i9qFLaapkPDX4OjtTqIbaT/gkl
         TSnGAoEMNw7++ziezjVU0G4zcAIe9yzqO+D5CVqu30BBBoWa27pf37fu92Ynyp+MeuLZ
         s3fs+qeT6I1SW4Egk7ajPS1wGW8GH4Ssp3XxDDxyvVYcMZJJJ72OoZ7Ef7f5vzypG3aO
         dNubx/8KBFKAj7ZBKd7T5fG0Qm6Yo1gvID3w+CD9a6c7VTmQP5MIWyKUGT+nwTTXQAkt
         PfzRTye64ePN4mCDZldziYJ5+bwM3zhU3LTwjzNlOfY3kQ+mhyu3OCyscNWWtQuQzuja
         jGuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=HysFCU62V7+/vxvPJrHZKidBn5+NIqy1307HWpiK79E=;
        b=JAd95NsvhRWvKgZIfeIRA5KncUP2oqqKpFib/kxBQKwoK4Dw+IhTmddrdleAZVygYD
         CSSnK1Ht08Xg1EB878VoH5kNs6Cqui9RC95v7kuzWJU2x5sNkNIPs9Sc8tzgE8tvhU3S
         HWHLwCKyvDS7U9fHaDyW3mm3CQxXxdymo2L5NWNEHK1LUlNUzSMmtUF6qdriLwCqxQ5u
         h3LRtxaQ9y8eIOkyLjiHOUH4V/ZbPjgdF4x8T2J14foul69feA5UlzlzMRiaLxDmuujq
         vGbARY3yuBk9LDt+qvPgAGuj4PdsHlIxg70TIZrqoTUZjpc01HmFlIK5cBk8IJJzGM3l
         pxzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q18si185282pjp.70.2019.06.06.15.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 15:08:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 15:08:23 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.156]) ([10.7.198.156])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 15:08:23 -0700
Subject: Re: [PATCH v7 04/27] x86/fpu/xstate: Introduce XSAVES system states
To: Andy Lutomirski <luto@amacapital.net>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>,
 Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>,
 Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-5-yu-cheng.yu@intel.com>
 <0a2f8b9b-b96b-06c8-bae0-b78b2ca3b727@intel.com>
 <5EE146A8-6C8C-4C5D-B7C0-AB8AD1012F1E@amacapital.net>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <4effb749-0cdc-6a49-6352-7b2d4aa7d866@intel.com>
Date: Thu, 6 Jun 2019 15:08:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <5EE146A8-6C8C-4C5D-B7C0-AB8AD1012F1E@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/6/19 3:04 PM, Andy Lutomirski wrote:
>> But, that seems broken.  If we have supervisor state, we can't 
>> always defer the load until return to userspace, so we'll never?? 
>> have TIF_NEED_FPU_LOAD.  That would certainly be true for 
>> cet_kernel_state.
> 
> Ugh. I was sort of imagining that we would treat supervisor state
 completely separately from user state.  But can you maybe give
examples of exactly what you mean?
> 
>> It seems like we actually need three classes of XSAVE states: 1. 
>> User state
> 
> This is FPU, XMM, etc, right?

Yep.

>> 2. Supervisor state that affects user mode
> 
> User CET?

Yep.

>> 3. Supervisor state that affects kernel mode
> 
> Like supervisor CET?  If we start doing supervisor shadow stack, the 
> context switches will be real fun.  We may need to handle this in 
> asm.

Yeah, that's what I was thinking.

I have the feeling Yu-cheng's patches don't comprehend this since
Sebastian's patches went in after he started working on shadow stacks.

> Where does PKRU fit in?  Maybe we can treat it as #3?

I thought Sebastian added specific PKRU handling to make it always
eager.  It's actually user state that affect kernel mode. :)

