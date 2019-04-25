Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C708C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25A512081C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:01:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bvQI9jRK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25A512081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A80A6B0006; Thu, 25 Apr 2019 11:01:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 655AC6B0008; Thu, 25 Apr 2019 11:01:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F7476B000A; Thu, 25 Apr 2019 11:01:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1721F6B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:01:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so2777454plh.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:01:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UHTIv2bYWCMmrceWnwUo0Fh9FKFnrseI4vreb5e9FKc=;
        b=dWiQwpdUusv3zIz7YV05CehgDpVoJjfh6niXsGVqk03EDGK+RAughWEHSKkRMk6FgK
         OY8f8DMiLnG1HXpK5HAqI9wvnKMPnZIsbiLC7eUtsMKI8d9WZHUAuNEhmNFNe/ndMt5q
         KscyQzjs5r51uLk3wNuDasq396e+oTDquNHfBFEU62A3nthFE8Ryts070UXt9Ge1eyub
         Ihu0Qu/ziNI0gmtEEUC7TeLW0MlA2kxmxPiZFtKU3p7yjc2DLnp2EojryVTh2r6JsUG2
         fAxqB1a7VvT15nBPck0xk7m4q2MPvZrh2SghnacVkDMAhwXLgmU1Gh0vTR7zVVwRGCRl
         2ozQ==
X-Gm-Message-State: APjAAAW9s5jakkC2tHcvZ51MLd8tGkePSBRaYqhtPNzabVL97n3CsSFc
	yLJ/Edg4eGzyfLgfUse2Gkx1YTQMh6t34hnjSViogaDyZxd0in6yHgMvho66vtDnf3ykeDEtodr
	lccGnhbgWD5w5SUBTIoDyFHSaEYU46rtdZNdF+iu6AycC658jVG1jJlwiphJ9RMaghg==
X-Received: by 2002:aa7:8719:: with SMTP id b25mr1679119pfo.90.1556204503712;
        Thu, 25 Apr 2019 08:01:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLKvyllavyZSHo2hPahfmxxozzqjjctPOhU0wB9NT8crTrPYSX4TgGKgzL09LX41KKbLri
X-Received: by 2002:aa7:8719:: with SMTP id b25mr1679001pfo.90.1556204502712;
        Thu, 25 Apr 2019 08:01:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556204502; cv=none;
        d=google.com; s=arc-20160816;
        b=lJHRrgYgBFax1MMY32SJgNbpHz9rykgojIw1sjoIliqIqHp+IwYyeTEa1+Cz4wciNj
         0TIqSTtduPZM0+O3zeni0fC2LGn/UHA79DVIL0xDtVZwQO9NmBl+fvECQhFLZoLVB7yG
         aRZx3r1wRg0kkgZ+r1JKrvp2oV+r9zNLGcVhG2Ph4mdqoGLGZkYJ/VDFTQ+q2fgcPs1R
         RkUPxqBKUPAFc5Ljz4lgYjB+BMmA/KbRi2Wba+xR7JRgtf0n8hnB1BK4sYswtuiiXGU/
         I94WC0QsXOcnOtvJyazW6Igok22MKAb8sjmPLkuT2a3fhI50rSQgTSXPeY8M3QTWG7ae
         XawA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=UHTIv2bYWCMmrceWnwUo0Fh9FKFnrseI4vreb5e9FKc=;
        b=ZLC70sgc3GtRZD2yGobLGaGZyZHWw9wTFBJb8zT3aOvdI+kDd2M35ONIx73ehoIrC6
         wMAVgyjDSV7QTKtSZUoVoKIAisY1MzXyUa/+33wnGtd/JDdi2+1H14QEG8IwY1dh63Vh
         aafugUmwbbcBU6myP5cnjPqw95CFH9jqgcz0DQ7780Jm4slP865RbRz7J+bri7KxsjdA
         cgJiNRX1+bPfikfr+HTK2v+l8LPNlrBorxCvDhNPpamNLDsGr9jQzM53t/7XrwBguqO1
         VUBDN3V07H+dzLOEfVcw2iKOCfDLsEKpD3+RXGyWEa2vFEPAA+d+aBr/o+ruytn8V8u0
         sMKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bvQI9jRK;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s189si7146665pgb.346.2019.04.25.08.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 08:01:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bvQI9jRK;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UHTIv2bYWCMmrceWnwUo0Fh9FKFnrseI4vreb5e9FKc=; b=bvQI9jRKJKedhApGQGL7NC7Us
	ZTmouNizaDjyj/BFyna/0u54CTi/1wmbXgavf7Q+B7ARBQBne4dlXFL2pNCBauGrzvLiU05/W7wOO
	ZyZgJSVDU0U5W9XdFs4Wb9J4Ejlq4ZW+68Te8Szx5Vxz3a37YDHnzmxIsP8S2LU0u4mOmTphrGeiX
	fpuuBC69Gbvs+yjGC1GN/LtJlniccf+WmkfxyOqCoBkGD+nd7IgVYcoY6t0eVf1lEJzjUFCgvUBlc
	yKqIt2ZIREwAPWIdBcF+zvIwaKjYjz1mru5T3SoOoGGh5xd7cYT8bfc/mWtaHP6OfEqFgA01bpSlP
	jWoO65ebw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJfsb-0002iU-TR; Thu, 25 Apr 2019 15:01:41 +0000
Subject: Re: [PATCH] docs/vm: add documentation of memory models
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556101715-31966-1-git-send-email-rppt@linux.ibm.com>
 <a4def881-1df0-6835-4b9a-dc957c979683@infradead.org>
 <20190425082239.GC10625@rapoport-lnx>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <2b97f4db-78c0-1cad-bdf5-948720e8094f@infradead.org>
Date: Thu, 25 Apr 2019 08:01:39 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190425082239.GC10625@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 1:22 AM, Mike Rapoport wrote:
> Hi Randy,
> 
> On Wed, Apr 24, 2019 at 06:08:46PM -0700, Randy Dunlap wrote:
>> On 4/24/19 3:28 AM, Mike Rapoport wrote:
>>> Describe what {FLAT,DISCONTIG,SPARSE}MEM are and how they manage to
>>> maintain pfn <-> struct page correspondence.
>>>
>>> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
>>> ---
>>>  Documentation/vm/index.rst        |   1 +
>>>  Documentation/vm/memory-model.rst | 171 ++++++++++++++++++++++++++++++++++++++
>>>  2 files changed, 172 insertions(+)
>>>  create mode 100644 Documentation/vm/memory-model.rst
>>>
>>
>> Hi Mike,
>> I have a few minor edits below...
> 
> I kinda expected those ;-)
> 
>>> diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
>>> new file mode 100644
>>> index 0000000..914c52a
>>> --- /dev/null
>>> +++ b/Documentation/vm/memory-model.rst
> 
> ...
> 
>>> +
>>> +With FLATMEM, the conversion between a PFN and the `struct page` is
>>> +straightforward: `PFN - ARCH_PFN_OFFSET` is an index to the
>>> +`mem_map` array.
>>> +
>>> +The `ARCH_PFN_OFFSET` defines the first page frame number for
>>> +systems that their physical memory does not start at 0.
>>
>> s/that/when/ ?  Seems awkward as is.
> 
> Yeah, it is awkward. How about
> 
> The `ARCH_PFN_OFFSET` defines the first page frame number for
> systems with physical memory starting at address different from 0.

OK.  Thanks.

>>> +
>>> +DISCONTIGMEM
>>> +============
>>> +
>>
>> thanks.
>> -- 
>> ~Randy
>>
> 


-- 
~Randy

