Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19B56C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:39:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB23F2067C
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:39:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB23F2067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 724576B0007; Fri,  7 Jun 2019 12:39:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D5C46B000C; Fri,  7 Jun 2019 12:39:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59D346B0271; Fri,  7 Jun 2019 12:39:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1DA6B0007
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:39:46 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j21so1848000pff.12
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:39:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=AuurSrnF6IKsePTIlXuc0m65kFJC67LwiWc26/aDSlA=;
        b=FU92bulYP2DU1lb6p+WjJ1n9fuRDc1BrqdZ+HoR8NfddFZ15I5+3Dg5moDnJc05nGl
         yjbudVysErhVIB+qlRMqr7WizNBmwXUwU/utW/izD67bcgb2erCmzVbXov4dYyMaP6t6
         pWCx3PvN246S3TlXc/C1Kde1QmYqXIpOyCXzEyaKjiIftrWWgGb+ibc0Gj6sN90BJOBg
         zAWMvfUn32c3ptpkK5oM1ib5MKCe+85oWA8RvFJyXfdcKmT1DCC2aE/7GN98Holr7DFK
         akbbrs/p5ZU50hMKxTnzP9nJlHm9Ppkx1MYfGzl0DRSsT9kvx5ab1gcNqe2P0LCqtCJF
         cmNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVV5xjhpGpoFFyfBaSwYo7eRm68RTObmFkn04gBPbCYaFkjs8k6
	cJW4pixSflzs4pUzvdZGH8r0nyVkTi+JQFH7Ilwqzert9W6zTK76gtcmsSvA6tlROBhkZRcaS2p
	7M4JynL+PwnBho1kOmdVkheeff5LZY8U8wU4K1Y5tWLFHjoCJKxwMyDSffw9U0SZdXA==
X-Received: by 2002:a17:902:7004:: with SMTP id y4mr10811931plk.31.1559925585783;
        Fri, 07 Jun 2019 09:39:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjves4aexRdeiFxCk6SVSUatvpCWqOwL6UqTWxqztrLEq6hwH0HV1/EUgLSn1BSGbeI4uz
X-Received: by 2002:a17:902:7004:: with SMTP id y4mr10811875plk.31.1559925585201;
        Fri, 07 Jun 2019 09:39:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559925585; cv=none;
        d=google.com; s=arc-20160816;
        b=mnUb3mMPed903J1rVNTRB/SuWOwYkC9HiZbm6WwOOpN1mWTBXD4jH644LULDWScoQV
         UhixYhDnYe4WymRSTnac5cMYUYFJcFmfJhde6rYQK+yl93uozIP4aENcRjn9BxjVB/1W
         VpqKDki8ImbRZY9cISAQF0e1h/ld77eZG102UaTeWNk5VqoDxtYl3DIk3g2rE5pphmHd
         uHh5uiBpBZbk3AF185AaYG1CNJTgkIUvvamWtahX4BPdx+jQwlbUozCMPrRCP9EFaTqK
         /DXgV7Lh6TUPXgBw8t3EfpMEuvjbiUDDD4QQ7hE+rCMWQC7NYRFJZTJmln9hfke1INWu
         gCTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=AuurSrnF6IKsePTIlXuc0m65kFJC67LwiWc26/aDSlA=;
        b=FiPGwSix5lbYh+kjzowm9hhGc+UYhhpwid4bHF/piUUTGQOE9QsLF/K0jYPe2/LAQN
         TRUq2hXZ9Zv+3JRogj7SU0Pm16f5Uo0Njp2lEnBMnpQQOq0KW2TBr5N1XLYY3t4N8yLN
         pX8i7XwmOD64wD2UooW44c3VyHxIX2yZoElq+TjnkzViNx2kYps6Gm07guzRa6SVY5jG
         BOTXtIGUq3O4YUrCaPXqViQ83e8IqgR0+UHCW9aOwVeJpkcA+Is2DZ6D9icAeuktWfxr
         6JEIEnQaKNrlwoRLSX0vrxqHBfRi+lq9zOsAyRbm3quQyTdNknQnkDKMVEfkDH19kxJU
         cQRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id c21si2287581plo.308.2019.06.07.09.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:39:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 09:39:44 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.156]) ([10.7.198.156])
  by orsmga002.jf.intel.com with ESMTP; 07 Jun 2019 09:39:42 -0700
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
To: Andy Lutomirski <luto@amacapital.net>, Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
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
 Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <76B7B1AE-3AEA-4162-B539-990EF3CCE2C2@amacapital.net>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <00421c4e-c64b-57cf-882e-aa7b9a007661@intel.com>
Date: Fri, 7 Jun 2019 09:39:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <76B7B1AE-3AEA-4162-B539-990EF3CCE2C2@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 9:35 AM, Andy Lutomirski wrote:
> One might reasonably wonder why this state is privileged in the first
> place and, given that, why we’re allowing it to be written like
> this.

I think it's generally a good architectural practice to make things like
this privileged.  They're infrequent so can survive the cost of a trip
in/out of the kernel and are a great choke point to make sure the OS is
involved.  I wish we had the same for MPX or pkeys per-task "setup".

