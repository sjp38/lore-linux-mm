Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48A49C46477
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:19:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DD0520873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:19:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DD0520873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A70B36B0003; Tue, 18 Jun 2019 10:19:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1F698E0002; Tue, 18 Jun 2019 10:19:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E7088E0001; Tue, 18 Jun 2019 10:19:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53C706B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:19:52 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n1so7875902plk.11
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 07:19:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=BQs/ZV8no/o/nsyWelS+A6b8o3m0VdvlsfJvWckYvLs=;
        b=Mh8gf4X7anjXTBsK3J7X9yEK1lSIRS2/lxW1UjWAqWMs0Dh7Nm8PJ1EFLWSKfeMtaN
         h0Q6qYOC7j+LOtizgWsSJqVWHf/MdkKNcu+oWfnjYbDRdY0rTafiq2GoZ/R7/7Z561c+
         FKUinD3NiEOcdcSNp3FkwmteiYBuhijI1/2I+B5BEyEAl7LcCcILrv3TQyXHHxI8uniZ
         22hjGetzkwMKgjCFNOiGobGi/GtNY9wHpbVkF0voQwIcGnnsd8lVfCs0gGbA4KE2Or2w
         6vIlAUAC48SjVgoQPXAYOshzSIsrsjhczkC3uIkl26DQxec4xAmlg6D0xzijKXHIHqZ7
         X5Hg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVChv0yuE59OFUpPt5X45u2Ix5Q04DIhVfUbRTDf7gXHP2v4pxI
	cFhVazG2f/dwJ1SlXMGFrLSj1o35GXECkGRxwmz6ImfFSLMUWTMqqyQgU1lGYUO9GEeIzOED/WQ
	up4v9qFI1eZM4NxQXYfbEIfij4rbotDpC047lwhbaosralfJemcz5JKU2cCEylRFKUQ==
X-Received: by 2002:a17:90a:376f:: with SMTP id u102mr5483817pjb.5.1560867591992;
        Tue, 18 Jun 2019 07:19:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGfFc+c2373bUYzVY8bBOqUO9rr7qYENFWu27xne6zRzIOCYEeMjIufXeQ++NaMR9d3BmY
X-Received: by 2002:a17:90a:376f:: with SMTP id u102mr5483764pjb.5.1560867591400;
        Tue, 18 Jun 2019 07:19:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560867591; cv=none;
        d=google.com; s=arc-20160816;
        b=NioxwPF/ONWa5tMGgAVEVR0n8abihQWa3sJVyaJooKr6Znifd+jAO0xpBb6wNVa0Y9
         4T7TgylVcZBfbzVslRiOb0qUjICaO32cmXXt0AHbtUH/s5pDh/1NDQvE+Mbq6iahKogh
         Jt9oMFKZn384G0JUAxbqm3UAnIp8rAzYquDf7ntm0g0fMfHmD0NPO9rpQq5uRw/qRJ/G
         PU/mygL6ASteWTq9a2K4vjvuH/h8ghKJxDK5EKs+1jY5ANKBYNTlV20aXvlkKo5DToG0
         zZ+FvwmG3Q8gIqVV5ym6ZXtGNhTnD/Tdg3vsVyGQjpD8dqU5JwXfhD46kQovHNz/EOYI
         bDJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=BQs/ZV8no/o/nsyWelS+A6b8o3m0VdvlsfJvWckYvLs=;
        b=CUX5YbbjTB4axl0ysru5wYVWvS7pB131liJLhJBBApgwDbqAh4v937JdIkVzLSgonx
         sFr4cXJLkLkN7sItGP74OxZO/+uQiRcZSuwZcTQq5G5QRTFrk3JmewYqmFnoiI0pfotZ
         iJl9QLsynKbdZeoEGPTA9P4cdTlwRtJwAwagG1TnmmLLwhHVGkkN7wQ876YWupEaAznQ
         taDj9ACinC8hz9UfgjuKNm3kQgqvr8yq/Dh0bYBf6FpFiU2juHst6TMMFKQVw5u+CbAx
         8MlEc8vVYFekWSTc18jrtMPPr9DJI/uVsJ8P8pf8A+PgaTjFpxTXjf8HZdfozt/Wfnjx
         5PCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d21si296562pgl.591.2019.06.18.07.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 07:19:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 07:19:47 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,389,1557212400"; 
   d="scan'208";a="243005454"
Received: from oamaslek-mobl.amr.corp.intel.com (HELO [10.251.9.224]) ([10.251.9.224])
  by orsmga001.jf.intel.com with ESMTP; 18 Jun 2019 07:19:47 -0700
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
 <d599b1d7-9455-3012-0115-96ddbad31833@intel.com>
 <1560818931.5187.70.camel@linux.intel.com>
 <CALCETrXNCmSnrTwGiwuF9=wLu797WBPZ0gt92D-CyU+V3sq7hA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <8dc08b4c-82ee-8458-6941-248141afa2a3@intel.com>
Date: Tue, 18 Jun 2019 07:19:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALCETrXNCmSnrTwGiwuF9=wLu797WBPZ0gt92D-CyU+V3sq7hA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/17/19 6:50 PM, Andy Lutomirski wrote:
> I'm also wondering whether the kernel will always be able to be a
> one-stop shop for key allocation -- if the MKTME hardware gains
> interesting new uses down the road, who knows how key allocation will
> work?

I can't share all the details on LKML, of course, but I can at least say
that this model of allocating KeyID slots will continue to be used for a
number of generations.

