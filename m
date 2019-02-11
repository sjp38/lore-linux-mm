Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF0C3C4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:31:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DBE6222A0
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:31:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MHT4nG1d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DBE6222A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27C828E010C; Mon, 11 Feb 2019 12:31:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22BA58E0108; Mon, 11 Feb 2019 12:31:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1425E8E010C; Mon, 11 Feb 2019 12:31:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC56C8E0108
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:31:44 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w20so9893305ply.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:31:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BvHOGo1g8yWo1gRoRLczgUpiw0DBDlt2BwWSm5YsHr0=;
        b=n2MZu5WJEDMV7GeX3SPPpd0LguyfYJ+F5Jru2E4Hecy9dU/RHQZ0MC4G757VjCnU2T
         gS2TSHIzNvEfOTB/5ZwLKYDg1grSPEcCLwyeEXNyzcG/IVZXduCKBtgoXQF5YgWifpoB
         8Xh5FSeQyZG5PRL9kc8GDrEA9/NIzsiXyM1JRtzJBTaAvzlaR2QooiJUAKrULtOQHmtS
         b47dUAof+Gt1ixRmfVZn6YX9mP3+XVw3LGPIoxYLvVbX4h7aZH9DFNO5YZwsLHAXtYmv
         1ZDbqOXh+01X8EX46lekeURANxnS7ZoX5uU/vZdhWUj4WrsQJ9RlsqBaoU8hk1L4gHcQ
         XPFg==
X-Gm-Message-State: AHQUAuZz5X6xiDdAY/pNO+22OgKYZgwYduMbNmTBZ7MBOnMwPCv07uQI
	V78CF8ON+wh5INFtw3Fl4N+HpP5N//ZT211/6HXSyMkMG8H6iOKKUcQxB0+SOfBmFez3NqmXOpE
	mSfYjekA0nCqrVfa1MqN8rmhqjavXPRgAiwv72mjNHGLPTtRvUketIU3fmjHbJl/b5A==
X-Received: by 2002:a63:f444:: with SMTP id p4mr19355738pgk.124.1549906304420;
        Mon, 11 Feb 2019 09:31:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbX57i6QgwuGO9+wDtHB7SzdNhuabvmgp17OhZdxTd1GZnxmpfLKaumSw/IhphgufVi3U12
X-Received: by 2002:a63:f444:: with SMTP id p4mr19355694pgk.124.1549906303677;
        Mon, 11 Feb 2019 09:31:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549906303; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCCT5UL4M1sQHiivEGSdo+vouM4yPTy8k9pLxqkpxg/cNVJOMIcj3O6iSyIC3Kt1Aa
         5uI4f/LwuSCQMOnzN6+p6JwBWgyuYgFfMSzyjK3zvVVhXSwNZZw9pN6Hl81NdlRqCA1t
         LLkPDQkCq9VhPXm41Y6L+WTn3sznnJQ5vMgRA2sqHHUlnYnAzd8G7jydWhPIzT4xk7Wc
         HZnmSFuAUAw8zom8L3/aMN4PYmaXSxw1LjgKWceT/6oySKyCcbd5tS3qf5/WZ38bF/wG
         16d4lkHITLBwHOWjucHtHvqnNsmCFzDN3V9thBwdN1qwGtE/dAxQocEuH5L8DN4FB1SJ
         ZBZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=BvHOGo1g8yWo1gRoRLczgUpiw0DBDlt2BwWSm5YsHr0=;
        b=nhTTHxa5uBwA5BroTgJz35yAKSqud4qiiEqcCP7dbozBjWNF/4oZnVaI4SmQmEhF80
         ckuDlB9JYZZoSR/cOBGxnyFwhWP0w6p3G8szOoQ6RBoj3469FLk+YqgFST2sCZwdq5El
         raUseGuKxvZdVqopu63NIq4HznsrGXFvLZMxfPmyRxEyrvc2QsDcubdpeA6b/N+Luby1
         MmQnATcoPAf2zPCannLeoKJN45ELMCDVwa1MlbcW/eve0wm8tgReHy/yZqp7KmVK/4KA
         thbBe5nrX8KUoRs/v5TSgl76E9mqWELmEqTyvNIHGb4JgZLAihX100lBFCjYHz7hhaPr
         f2yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MHT4nG1d;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k16si4752654pls.124.2019.02.11.09.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 09:31:43 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MHT4nG1d;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BvHOGo1g8yWo1gRoRLczgUpiw0DBDlt2BwWSm5YsHr0=; b=MHT4nG1dwudLVuNb9uk/lYi9C
	Ld+XmRNlSqXb3sl80y8roVhsnsLcDrU7QLhZD/rMYuw/+gYPZHdhyfqeaMqkpbUFFk9rwiK0r4VFm
	V2qSXAdaisVAOikr3Xso+aUmgYxoZJKF6B/IPfuLpNNLAqTVkOXEJW1lm46BuBIUqBEbFQ2fRNTYB
	D75MY13KTo1xiNsOfHL1R/B1rruuCNsSzlv4JKsqLhQN3ULxnP9VX1BPD1HK290Aq/o8vTe5ITXLM
	JBciWTtVahiE9SU1OFS//O0/y+RKqRdWuXdd4z1j4YaR8vhiyhcbEpPiqvzY1crui8ytlOsG/UW+b
	yNv3z/a9g==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtFQg-00022a-Uf; Mon, 11 Feb 2019 17:31:39 +0000
Subject: Re: [PATCH] Documentation: fix vm/slub.rst warning
To: Jonathan Corbet <corbet@lwn.net>, Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 Christoph Lameter <cl@linux.com>,
 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
 "Tobin C. Harding" <tobin@kernel.org>
References: <1e992162-c4ac-fe4e-f1b0-d8a16a51d5e7@infradead.org>
 <20190211082705.0ff3d86b@lwn.net>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <2a14eb40-ea42-fcf0-6f1a-458e13f9983d@infradead.org>
Date: Mon, 11 Feb 2019 09:31:37 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190211082705.0ff3d86b@lwn.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 7:27 AM, Jonathan Corbet wrote:
> On Sun, 10 Feb 2019 22:34:11 -0800
> Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> Fix markup warning by quoting the '*' character with a backslash.
>>
>> Documentation/vm/slub.rst:71: WARNING: Inline emphasis start-string without end-string.
>>
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
>> ---
>>  Documentation/vm/slub.rst |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> --- lnx-50-rc6.orig/Documentation/vm/slub.rst
>> +++ lnx-50-rc6/Documentation/vm/slub.rst
>> @@ -68,7 +68,7 @@ end of the slab name, in order to cover
>>  example, here's how you can poison the dentry cache as well as all kmalloc
>>  slabs:
>>  
>> -	slub_debug=P,kmalloc-*,dentry
>> +	slub_debug=P,kmalloc-\*,dentry
>>  
>>  Red zoning and tracking may realign the slab.  We can just apply sanity checks
>>  to the dentry cache with::
> 
> The better fix here is to make that a literal block ("slabs::").  Happily
> for all of us, Tobin already did that in 11ede50059d0.

Thanks for the info.

-- 
~Randy

