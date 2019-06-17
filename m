Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D961C31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:28:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDA820833
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:28:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDA820833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FA068E0003; Mon, 17 Jun 2019 11:28:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A9938E0001; Mon, 17 Jun 2019 11:28:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5717B8E0003; Mon, 17 Jun 2019 11:28:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6438E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:28:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r142so7261202pfc.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:28:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=rLZ9MyE0kfwOJZXQDviuQQkC27YpzWHn6Oef/8UHUNE=;
        b=UvwUcKR/FFOT3s8OoNsaz+K9nDZLQ03gCIeCK2q+TClmoCcBRssqLe3ZpQ0aVKlidc
         PGMD+GecV2khpkUh+Ormweh8qG3tzbcNzyzU99SUC6IGRnK2XUL2/moqA7G73AeBs94D
         h21LTnYzZCEVFKDT3840E0WJ2gMQIhshfxCEqpzdvF+0ndRzdDpyALjt+/x5tLbWBQ1Y
         Y9DjYuZg0diUIpI4LbQ8fBnJ70pA1IaXIm3ywXnOxFvSMlVq/w7rupwFCLrZJ8g3GbWe
         k8VW9qU6isyjannWIumYVV1W/uprx4YGPAaRRKIblZqngRtLKemRMnNXlgMJwX/hQmDq
         fAQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXo26y8rWa0e7B4zIg+fFEgYljYVrY8/QSv7YF5ITBzEPx6s33m
	+3bR/ID8Mdi/75blIjaWI1KeLUUzzcj1JSwtr/RpzHgT57nZuRopu5af0duBSVh9jF0MuKMlI3V
	qkIQjNVPpGrAdOctAQATf89LhEbEHhz/FdjTp2YkLpPetn4Xu2l3RdAr8SyBKa6rmYQ==
X-Received: by 2002:a63:b1d:: with SMTP id 29mr49634451pgl.103.1560785309598;
        Mon, 17 Jun 2019 08:28:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMcIJz4B9377qag/emGouK6tldfNe2CMYTZc7FmfnZBcgQb7BZeUP6Rzuy7lOHIgz/dOBf
X-Received: by 2002:a63:b1d:: with SMTP id 29mr49634393pgl.103.1560785308691;
        Mon, 17 Jun 2019 08:28:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560785308; cv=none;
        d=google.com; s=arc-20160816;
        b=i0v59ANFKYwFKeuV1P57bqoWT2GmRAx8GSApmij2HRxM8M0cLFgSvwh5Re+tpy+uWp
         HCaU+cToD49EzPClitwAKd6pPOJ6b/hDVqV2zq7PsuezRwwye2MYGyxtvn+MN26fuoiy
         Rg2RyZy3A1bvE9GN6iQPSUPla99eEjILmNd1xe1JEsuG1ogPSlDsk2DfXzZPOMD5CW0s
         bIJdynL0gbrlJE5qf1oE1XaElgFYj0kOiOKoYmvMuPnpU7pOlFzNGqz+O3nlRb9HgRa5
         Ou32e2giEVdtxvwhkwyZlBuPJcmCA2Q0GE8iWrnHx3TX1Ll1SjTC/OevHXQwQ/vc1d+p
         Z5WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=rLZ9MyE0kfwOJZXQDviuQQkC27YpzWHn6Oef/8UHUNE=;
        b=avMTzJ0w07CXRCLRLNOJpvoovwQjzb+LaZt2E2HU4oTEKlickEoWsZksHj9hSVCkwe
         bpVNqx/ycJFuKJIXs2rg3sWa0IFaznfmlHbzPTDDk5weYhLDs1HX29p8SJdpcw3Yx85W
         luUij1v8dM4rWceV/LoGPNUdi8tafmgpqcpCe4RSleuvS/o0qCWMe69ViXDMm0QYfqCU
         i/mAA2qvx+HX1lswnpljToloFaKhhOWHBtzixg+NmsLjAEc3HZNjJo3d07dnR2fSP+lJ
         FkQle6RT9dyha1RDG+wrgTr5F16bZASA8smSns4jIiMYkcihowzD6PH4DiriCye3z6HL
         mcpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id a22si11192866pgb.292.2019.06.17.08.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:28:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 08:28:28 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga002.jf.intel.com with ESMTP; 17 Jun 2019 08:28:27 -0700
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for
 MKTME
To: Andy Lutomirski <luto@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>,
 Kees Cook <keescook@chromium.org>, Kai Huang <kai.huang@linux.intel.com>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, Linux-MM
 <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
 keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
Date: Mon, 17 Jun 2019 08:28:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 8:07 AM, Andy Lutomirski wrote:
> I still find it bizarre that this is conflated with mprotect().

This needs to be in the changelog.  But, for better or worse, it's
following the mprotect_pkey() pattern.

Other than the obvious "set the key on this memory", we're looking for
two other properties: atomicity (ensuring there is no transient state
where the memory is usable without the desired properties) and that it
is usable on existing allocations.

For atomicity, we have a model where we can allocate things with
PROT_NONE, then do mprotect_pkey() and mprotect_encrypt() (plus any
future features), then the last mprotect_*() call takes us from
PROT_NONE to the desired end permisions.  We could just require a plain
old mprotect() to do that instead of embedding mprotect()-like behavior
in these, of course, but that isn't the path we're on at the moment with
mprotect_pkey().

So, for this series it's just a matter of whether we do this:

	ptr = mmap(..., PROT_NONE);
	mprotect_pkey(protect_key, ptr, PROT_NONE);
	mprotect_encrypt(encr_key, ptr, PROT_READ|PROT_WRITE);
	// good to go

or this:

	ptr = mmap(..., PROT_NONE);
	mprotect_pkey(protect_key, ptr, PROT_NONE);
	sys_encrypt(key, ptr);
	mprotect(ptr, PROT_READ|PROT_WRITE);
	// good to go

I actually don't care all that much which one we end up with.  It's not
like the extra syscall in the second options means much.

> This is part of why I much prefer the idea of making this style of
> MKTME a driver or some other non-intrusive interface.  Then, once
> everyone gets tired of it, the driver can just get turned off with no
> side effects.

I like the concept, but not where it leads.  I'd call it the 'hugetlbfs
approach". :)  Hugetblfs certainly go us huge pages, but it's continued
to be a parallel set of code with parallel bugs and parallel
implementations of many VM features.  It's not that you can't implement
new things on hugetlbfs, it's that you *need* to.  You never get them
for free.

For instance, if we do a driver, how do we get large pages?  How do we
swap/reclaim the pages?  How do we do NUMA affinity?  How do we
eventually stack it on top of persistent memory filesystems or Device
DAX?  With a driver approach, I think we're stuck basically
reimplementing things or gluing them back together.  Nothing comes for free.

With this approach, we basically start with our normal, full feature set
(modulo weirdo interactions like with KSM).

