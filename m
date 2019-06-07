Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E059C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 21:05:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAC34208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 21:05:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAC34208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 487046B0270; Fri,  7 Jun 2019 17:05:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 438366B0271; Fri,  7 Jun 2019 17:05:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BA3B6B0272; Fri,  7 Jun 2019 17:05:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6AE46B0270
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 17:05:46 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m12so2112102pls.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 14:05:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=RImMhg7AxuokTjj0TmrlAbMw2oKojuq5FfRpqC1iwKU=;
        b=EIJxdnp2IfSbPySoO5QtNla/vkJ3+2tKO+ESJFn/Hme3W22o0kQ+w/pkZc6DUM+8Xv
         W5gBBdAEoGQlPsoMwzxUg/IUUM0+y001OsEmRomXt3uw8hHq4omNBbU1YWYMUEiYnSCd
         HQZNScXkNKNogbRoBu1z1Jzm49C76TB8pilUry1AgT4dKF605aSm3b2LPaTmlJ9v9H07
         FhpuV96wJKTA4tAELxf7TLSKLG4++X6e2S1ehdhU28UN1zCZQOAe7pITFoaq2ATcFXru
         21tfwLTYeBcqKsj8XgDD6TmwzpPcYT+LkYzAi5eX6FxoRTUOGJIuLPcNS2UwYR8QX6QZ
         52wQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXuyx25eK+fXSRISjefUTXpDQTlZukyTQOwEpSdUPnZTayt2ql1
	DFTH8aLgqelGVZo4tNU3diEoh+jUDUHJfLUhB6vA4gJYsNbq4Z4fL0q2gxs/BvXpA6F+1nosMRf
	ZxFesDyWGWH4+YSuQ3ePJDXidblzOi00fiqt3U0kPQL2suyNp3FugwfM3Kj9h760G7Q==
X-Received: by 2002:aa7:8e45:: with SMTP id d5mr52161897pfr.172.1559941546553;
        Fri, 07 Jun 2019 14:05:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCBO4N7LkSiNAOT570ozJZboU/KRcczTrCpJfVCSn+a3mBLhux+fTyRTxSC67K0KEHCLBL
X-Received: by 2002:aa7:8e45:: with SMTP id d5mr52161854pfr.172.1559941545886;
        Fri, 07 Jun 2019 14:05:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559941545; cv=none;
        d=google.com; s=arc-20160816;
        b=Oq88ad1lyek09TfDJw7y3wezELQY3vpRbmJYDO2XH4S+YbNxBSURi42baoMzkv7P8R
         JskPPaQkrqNgvj1ibmzipWSiBOPv4OgOJwNoV6JxxapN4bR+DyswfxaOECZJcnkZrj9v
         A1k7KHv2jm95KRnIQwNbxWqVWm4MDEj+FcjeyVvEg805VpDm9KOtzfKBCSmwzoIXU9VN
         6uv+s06iDAG1Az84wRpydx1PkkyAyIdzwk8wOuPP/OwAwx2z3x0ObD2XxarphKJjdQxk
         rAtLkh39zQEJTdhczAMCZvnzcGq1kCZ7LQXRFAhMoxAX04pCg2PJ7xndU5UdawKNaUsP
         gscA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=RImMhg7AxuokTjj0TmrlAbMw2oKojuq5FfRpqC1iwKU=;
        b=nqaNFO5sYB662jV6EeC9uPxd8+pnSXtP5ZAakKasUHlbmYjjcolHqrLYspd36pztMd
         hqXoMFDt9fy8Yj+3nEIVMa4G8CuPf2lR10SI+q1HojLAB4KSqwG/b66rwgf6oFjqqDlt
         1+wyfrftt6YO2HpepJFhCksc38wmnhqtcF7IILWhw2h7pJ6bVZyP+MPUUDFB6JdWnF1n
         JHqXyqPlPXFF7dkl0M9rNMwSf37TR7ar2jnzjiUYuRCgw1EP0hkkmS6izPAw3SUeOsYP
         HpADi3lT8cTSjoZk9v0+GmjhPRd9hwP5OKWP3+urPWu7SJGQo2S518G+PbgWIajZDJpP
         PtCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l102si1937131pje.78.2019.06.07.14.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 14:05:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 14:05:45 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.156]) ([10.7.198.156])
  by orsmga006.jf.intel.com with ESMTP; 07 Jun 2019 14:05:44 -0700
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
To: Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Yu-cheng Yu
 <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org,
 linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>,
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
 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
 <352e6172-938d-f8e4-c195-9fd1b881bdee@intel.com>
 <D10B5B59-1BE7-44DC-8E91-C8E4292DC6FB@amacapital.net>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <74620397-a839-cb8c-8c8b-fe72b921803c@intel.com>
Date: Fri, 7 Jun 2019 14:05:29 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <D10B5B59-1BE7-44DC-8E91-C8E4292DC6FB@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 1:40 PM, Andy Lutomirski wrote:
>>> Hmm.  Can we be creative and skip populating it with zeros?  The
>>> CPU
>> should only ever touch a page if we miss an ENDBR on it, so, in
>> normal operation, we don’t need anything to be there.  We could try
>> to prevent anyone from *reading* it outside of ENDBR tracking if we
>> want to avoid people accidentally wasting lots of memory by forcing
>> it to be fully populated when the read it.
>> 
>> Won't reads on a big, contiguous private mapping get the huge zero
>> page anyway?
> 
> The zero pages may be free, but the page tables could be decently
large.  Does the core mm code use huge, immense, etc huge zero pages?
Or can it synthesize them by reusing page table pages that map zeros?

IIRC, we only ever fill single PMDs, even though we could gang a pmd
page up and do it for 1GB areas too.

I guess the page table consumption could really suck if we had code all
over the 57-bit address space and that code moved around and the process
ran for a long long time.  Pathologically, we need a ulong/pmd_t for
each 2MB of address space which is 8*2^56-30=512GB per process.  Yikes.
 Right now, we'd at least detect the memory consumption and OOM-kill the
process(es) eventually.  But, that's not really _this_ patch's problem.
 It's a general problem, and doesn't even require the zero page to be
mapped all over.

Longer-term, I'd much rather see us add some page table reclaim
mechanism that new how to go after things like excessive page tables  in
MAP_NORESERVE areas.

