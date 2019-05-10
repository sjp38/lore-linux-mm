Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C36C1C04AB2
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 18:07:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83833217D7
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 18:07:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83833217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 191C66B0003; Fri, 10 May 2019 14:07:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 143946B0005; Fri, 10 May 2019 14:07:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00A2B6B0006; Fri, 10 May 2019 14:07:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE2826B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 14:07:14 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 33so4513684pgv.17
        for <linux-mm@kvack.org>; Fri, 10 May 2019 11:07:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=yZRwa/tQROitfwXn19uwTOfWOIFAISjR5TNnS0OEr5o=;
        b=U6OXQYV0M9I/eM+ETz3v+NQS+YSQHnDMsGk/wJCylZmsyjWMGRFD4Z2rEh9D/xOra/
         PNcrvKla8VZdAQhKDGT4fcjGFFZVQtayqjBuGMUDuXtfsaif+VGO9W8TO0mhwRL/50V8
         5aY+Z8fJXtdzdemHlwfQziBcY2GQk0TqqSVEKDJ9sh62uq25fD7P9djeH/jhj8WeWrjD
         1hCb03ZnsZqOj8KMpIs6BF4XKVjpwMrNrOFmyslfT5hxZyn2w7CBDGfTcevkaktR+Dmd
         iMNh09P7VAEhnsUuNxBr42Bs5j2pzGqG0fxNp0r0prGUGGba1vgIzd+lzTN7tmxm4IeN
         Fuxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVxK1eAOTgegyUH5/LDhJpvolBBO6tndPLB2raYQaErbx/LbO/3
	GGjKpCV5tIEatmFtW7hqchGQuh7EF9yO/4rTIM3GfGl+uuM5iLfZWHX7DuTrs5cmPxM3acr9rc6
	g8dCLvyonteiOzynM/hH1fnK9ynMPoBoX2IwBE+0RUF5RczUopDddiiwdNVC5FKaqug==
X-Received: by 2002:a17:902:7207:: with SMTP id ba7mr14382147plb.329.1557511633782;
        Fri, 10 May 2019 11:07:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydQ2ubMuJ3O+NLVg/FUb38/ySWbk9iZXWc1q3HxohyfuyIHSfBJectkwx52OGUUEzs7H05
X-Received: by 2002:a17:902:7207:: with SMTP id ba7mr14382034plb.329.1557511632882;
        Fri, 10 May 2019 11:07:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557511632; cv=none;
        d=google.com; s=arc-20160816;
        b=z8v5b+iwZikwudPeJSwd5FCHlK4s7etkDM4iXPBt7h+IxKhKfXNkGpWY8B1rPz697w
         gc3T/G+BRAteN6wUiMvjLvkf7+Rfqq2nsZ7kyR7n/rL57Odd5UMk2Z/R7AXLVbBjPKSK
         QRyVgZFLaeFYmwMv3tnCm0Ea+1ygMuXwy1mDy33X4IYyIgDj86GgssLYwbK7x/kJU8no
         vL3RycCqCt0JatKVFNVEERx7x6K6DfvKxZdypUeUxUUk49ZlmyqB9JA6sBTjjYTII0Uo
         bZWr4tpmOrruVnG76lto0E7Th8j+RN0qL0YxUd3JSEtJOz4QT94oZf0ecyaqgPRrfkFh
         2xlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=yZRwa/tQROitfwXn19uwTOfWOIFAISjR5TNnS0OEr5o=;
        b=HvcEVXdJv3KBUnV7iRoas7rR63VbKuXJJPNUQR0rQMrHU86K69HwG5Mqn+Cpzze4Zk
         KE8GYRM4zFY8Q9Qf7j68tfqZa5gLPAQN4ZC91GgEA99+ybTZUSpaZlHiDFkPClYiZ2Db
         VmBOpkWgyXfuVmFXDNFuEVKtOdM7AmGnaGjhtD+2T2tb+5cSCJQ01RjQzlFst7JuYlHO
         9YqmLYjSa4S9GX52lnYWWgRVW+k2pWF6jagIdEwo7WuoAlI1Qh5q0Kqz3gJsJ+lJJ/ow
         YE/c+7ntpc6pgh0BaYD0wClxu7FqBg+S1J7mJxAafrHSkoFlRItIec1nUqaEGkMcgY52
         LCTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id y34si7571199plb.434.2019.05.10.11.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 11:07:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 May 2019 11:07:12 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.16]) ([10.7.201.16])
  by orsmga002.jf.intel.com with ESMTP; 10 May 2019 11:07:12 -0700
Subject: Re: [PATCH, RFC 03/62] mm/ksm: Do not merge pages with different
 KeyIDs
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski
 <luto@amacapital.net>, David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Kai Huang <kai.huang@linux.intel.com>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
 kvm@vger.kernel.org, keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-4-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <1697adad-6ae2-ea85-bab5-0144929ed2d9@intel.com>
Date: Fri, 10 May 2019 11:07:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190508144422.13171-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/8/19 7:43 AM, Kirill A. Shutemov wrote:
> KeyID indicates what key to use to encrypt and decrypt page's content.
> Depending on the implementation a cipher text may be tied to physical
> address of the page. It means that pages with an identical plain text
> would appear different if KSM would look at a cipher text. It effectively
> disables KSM for encrypted pages.
> 
> In addition, some implementations may not allow to read cipher text at all.
> 
> KSM compares plain text instead (transparently to KSM code).
> 
> But we still need to make sure that pages with identical plain text will
> not be merged together if they are encrypted with different keys.
> 
> To make it work kernel only allows merging pages with the same KeyID.
> The approach guarantees that the merged page can be read by all users.

I can't really parse this description.  Can I suggest replacement text?

Problem: KSM compares plain text.  It might try to merge two pages that
have the same plain text but different ciphertext and possibly different
encryption keys.  When the kernel encrypted the page, it promised that
it would keep it encrypted with _that_ key.  That makes it impossible to
merge two pages encrypted with different keys.

Solution: Never merge encrypted pages with different KeyIDs.

