Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD55FC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:26:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AE5A2177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:26:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AE5A2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1692C6B000C; Fri, 14 Jun 2019 14:26:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 119D56B026D; Fri, 14 Jun 2019 14:26:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008D56B026F; Fri, 14 Jun 2019 14:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD42D6B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:26:12 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n1so2055951plk.11
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:26:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=jHal8Kdori90ChQYwiQo829JmwQ/DbxvSNPRmCMJNqU=;
        b=lBLa3QIJo3AebwSAm6BSWZQAq92C6tnaSSAdIQiQ+7I/qsjPE5DUNnZ+BwNHlP1utU
         W8fC9wULO3Ab/Z6lTtKvv+ASISknh1MLfxPUNZ2uo5fMM4Ecc9eqIzLPvoieiCc9vrkP
         qBTk6oVADees+KR4NBlLV/dUMHpZykRZT3iU8rQ3p4lB9vNV3srrJThhgcv0TLH/vfWq
         D7WHbm/gc1QdaHokdYQAi0zLZr9jtqnoEAm/1mFv0ouXzc2dWL2MWSEgHXSXOfqe3wEl
         OUgtJv5DsmqsJFW4gSd45APT/AbaUjCrJ7Avd0QpghCwvUPeDawU3GQXc8x6Rk+d0NB7
         dRtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUKBOEqwYru1g1xY4C2aQpq5CdD/8aGcDJWN/15md/LL3wocb35
	Clz8xqks9chei9C08aDqqLAGYiUNyNbEZxr/+WxFNpR6gYEYBYfHxOT6W+CzBXFzsYvGYH7ANA6
	F9IviJiU14d/1RlAp0+BzDkVOeH9UIdoH032ImlBg6X9Buoro1IjrgaJQ/OQJeJUW6A==
X-Received: by 2002:a63:6111:: with SMTP id v17mr36916962pgb.206.1560536772347;
        Fri, 14 Jun 2019 11:26:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpKbWqXjwZMGtg/eUHdrRq0qhRJyUG116qZhCHdwkw+qciA6vOWUH1Ane/gqV39xCEwP4T
X-Received: by 2002:a63:6111:: with SMTP id v17mr36916922pgb.206.1560536771591;
        Fri, 14 Jun 2019 11:26:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560536771; cv=none;
        d=google.com; s=arc-20160816;
        b=ozBB42Q6frJY6PNfTcxTYEckz+YKSQbxUdeRywhSKdsIq5KX9IkXiqFOA9hX5b/Qzp
         nl9jeKkStBTU6vghnRPd1MO/K0fyBE9bMAUhK/Li5DcEYMCFkXCXHJyrLAYjOubALtWN
         Vh/zJq8e7g+gUNnv6oOvQCi0ps6U8ii+frXDoi0fMWhlL8H1Ius+ZRij3+cL2Ypj7Ey1
         o0t/iTSZBvtA2xqOqhVtEZrc5KOXsTyUMcmuXVe4XCNkyGPGYWFPZPT/vK3KaCFVv+qa
         8FOkuoLnGOYib4NzWTMyxYwZZoZGH4JxGraISTNttoaBxK3ngmmZIUgeCnlaIHJT3uXS
         sDyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=jHal8Kdori90ChQYwiQo829JmwQ/DbxvSNPRmCMJNqU=;
        b=jfJLxVnoBxnkeUvYVD92Xrzru5TGVmczYQOnFapjwnhYaKc0xh+H5R2x1ah51BL5DO
         +n2bQg7qeU8WSt2z4I+7s8s2CuMoanESlV3sTm5dggIQnSKNgrYLLv0NWyqrYQFzYnrY
         wPB8oxXXQ/VWZQ6QdCHPVioF9V4TF5pLIztV5ZOZdiU7X3+Cn8e+e3LtcFc2g+uirCaZ
         nYzkfa4u4JmC7dpwiRuvjcqzhQNyodv/qaGAX5xIX1ThAWKithL+DYC7dXxPCkqqcQGR
         Jc0MHcuY6PjN+ynNQ8LzEp0VB7nSL9jqwIZ8QCePtwGKBdJ+jZeqPCpBy9OOGAH+gBX0
         j3Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 74si3092902pga.291.2019.06.14.11.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 11:26:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 11:26:11 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.15]) ([10.7.201.15])
  by orsmga003.jf.intel.com with ESMTP; 14 Jun 2019 11:26:10 -0700
Subject: Re: [PATCH, RFC 44/62] x86/mm: Set KeyIDs in encrypted VMAs for MKTME
To: Alison Schofield <alison.schofield@intel.com>,
 Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@amacapital.net>, David Howells <dhowells@redhat.com>,
 Kees Cook <keescook@chromium.org>, Kai Huang <kai.huang@linux.intel.com>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
 kvm@vger.kernel.org, keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
 <20190614114408.GD3436@hirez.programming.kicks-ass.net>
 <20190614173345.GB5917@alison-desk.jf.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <e0884a6b-78bc-209d-bc9a-90f69839189e@intel.com>
Date: Fri, 14 Jun 2019 11:26:10 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614173345.GB5917@alison-desk.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/14/19 10:33 AM, Alison Schofield wrote:
> Preserving the data across encryption key changes has not
> been a requirement. I'm not clear if it was ever considered
> and rejected. I believe that copying in order to preserve
> the data was never considered.

We could preserve the data pretty easily.  It's just annoying, though.
Right now, our only KeyID conversions happen in the page allocator.  If
we were to convert in-place, we'd need something along the lines of:

	1. Allocate a scratch page
	2. Unmap target page, or at least make it entirely read-only
	3. Copy plaintext into scratch page
	4. Do cache KeyID conversion of page being converted:
	   Flush caches, change page_ext metadata
	5. Copy plaintext back into target page from scratch area
	6. Re-establish PTEs with new KeyID

#2 is *really* hard.  It's similar to the problems that the poor
filesystem guys are having with RDMA these days when RDMA is doing writes.

What we have here (destroying existing data) is certainly the _simplest_
semantic.  We can certainly give it a different name, or even non-PROT_*
semantics where it shares none of mprotect()'s functionality.

Doesn't really matter to me at all.

