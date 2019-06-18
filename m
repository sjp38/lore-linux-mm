Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61A80C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21C6D20873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:14:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21C6D20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF94E6B0003; Tue, 18 Jun 2019 10:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B834E8E0002; Tue, 18 Jun 2019 10:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FD8F8E0001; Tue, 18 Jun 2019 10:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66F926B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:13:59 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a125so9364309pfa.13
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 07:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=E4i3LIh/m9tSAGe9vovcvngkAelrko0JEdPbasRTIMs=;
        b=FisKxUQoafDiAqLBZCzw9MVTzqYSOfKjYV7xFDcUSVi5marZ3e/k9vbZD9+aTqWEfI
         O7YQC1QsJVAcKyEy7dh/2R2Zx9dpkOfSE5OYchojtZO0jixrfYqOBA++Vskmt8ew8Dd1
         pCrP7c1IAVcTWx9qFlhFZ2KT1brruOgDDLvGLs59V99c5Jepzx2Om4PwNsZ5ym5geo69
         yoQWaoOwpks9VBHd9IX5CajDZ5/L6wBsEOfejTfCnFNgLm9QNlmtss8jAQlvniiQAY1E
         uufKHSLgjehQXWTSGG5edLlCornxRmPvQM/ASFxA2oDgYwhFczX66ZrDHypnZcnSojUZ
         RXDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV6TNXGHyhznfANfUjJ+cHgQ8NO+b6FcBydsTmvPKY+vbgTIi4S
	DBOVMcnfISqc/LZZSzGRFCd44VXtg9AC3yqX5xCJ0WBrA4aHbam73c7QJZg7HTAGEDt7AOouhG8
	URFs4I0bzt+5E/fI0H8MWpC943TY5xo129R5ubhprLQIyKJngKvTuJaTLPWEOJvKmrQ==
X-Received: by 2002:a17:902:a412:: with SMTP id p18mr46900051plq.105.1560867239094;
        Tue, 18 Jun 2019 07:13:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCnJyI5SRQGMuCuzRfQNiLVt5XaRAN+lTBQejWLAyCZUh4lhDD2n0+Iw4quqGJC+cE5NJZ
X-Received: by 2002:a17:902:a412:: with SMTP id p18mr46900002plq.105.1560867238500;
        Tue, 18 Jun 2019 07:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560867238; cv=none;
        d=google.com; s=arc-20160816;
        b=Zm1AW0pPfOOYf0XMsyNJMa81tGFKPvwSc9SJ/W4FZkp0BBif+etFz0lRmCzZDW0w/r
         3JJm0JBaUZLyf3nIKf/yrmDX87gKVxl0aeNrIul0J1U2CuCOCnUQ1wRzO6UMyf30tKy7
         TJFtYeMQtBE/tJiT9cK3Ch699Dh+UIdm3S9GtGD8/FuHCZw9sCr5yM8ftQPDM+AxRVkJ
         KNuqX4XMHWQ/hwdaQAqL/AiMUiMt+ZLsEmgCTF3133Vu5bWxrrB+KbZxrQVwJu3T/NKH
         txW0fSR7mhyk2UFarhDYTNiYNogNe3AIh2UO1CP8DPEfk721A//MiOrEXcvumK6bNd2O
         xwSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=E4i3LIh/m9tSAGe9vovcvngkAelrko0JEdPbasRTIMs=;
        b=Zv6sB1iLsjHzdekD5bIgWVK7HZ5ItnwAST6bkCYOcXBgbaLpZpwP+04OJCEkvT1e2+
         egmM3tTkRn0W7+VXYwC7z4riuCI16G5sa11zvr6O8hW6MGposwo2jjoJvSNk1lbKbCa4
         2zjaqeUmrz1lNrEjksRYFgWnOC3/bQyJWi6+WzUWx62fqnxOn42VgUFxVxvrfHquGbP/
         XIiu/PWHmcnBgwjdGBAz1X2FndtP8L2xXK1hE1fYetG1Hg0OvZHdPJzcsc7glZ5p/c43
         6uJGP+AQBfzcIDG6f389xX8RC7rnSPSwyAt+Jp+Pz7jpKSFlSw7pPWUCrBTbNoOAt08g
         WCpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id j1si12625893pll.417.2019.06.18.07.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 07:13:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 07:13:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,389,1557212400"; 
   d="scan'208";a="243003841"
Received: from oamaslek-mobl.amr.corp.intel.com (HELO [10.251.9.224]) ([10.251.9.224])
  by orsmga001.jf.intel.com with ESMTP; 18 Jun 2019 07:13:57 -0700
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for
 MKTME
To: Andy Lutomirski <luto@kernel.org>, Kai Huang <kai.huang@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>,
 Kees Cook <keescook@chromium.org>, Jacob Pan
 <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, Linux-MM
 <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
 keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <1560816342.5187.63.camel@linux.intel.com>
 <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <32d5332d-b549-9ffd-b1d1-72dcd83bbb5f@intel.com>
Date: Tue, 18 Jun 2019 07:13:56 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 5:15 PM, Andy Lutomirski wrote:
>>> But I really expect that the encryption of a DAX device will actually
>>> be a block device setting and won't look like this at all.  It'll be
>>> more like dm-crypt except without device mapper.
>> Are you suggesting not to support MKTME for DAX, or adding MKTME support to dm-crypt?
> I'm proposing exposing it by an interface that looks somewhat like
> dm-crypt.  Either we could have a way to create a device layered on
> top of the DAX devices that exposes a decrypted view or we add a way
> to tell the DAX device to kindly use MKTME with such-and-such key.

I think this basically implies that we need to settle (or at least
present) on an interface for storage (FS-DAX, Device DAX, page cache)
before we merge one for anonymous memory.

That sounds like a reasonable exercise.

