Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C49BC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:56:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D588D2173E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:56:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PHYffguA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D588D2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 441156B0003; Wed, 17 Jul 2019 10:56:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F1AD6B0005; Wed, 17 Jul 2019 10:56:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E1DA8E0001; Wed, 17 Jul 2019 10:56:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE65B6B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:56:01 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so14612863pfi.6
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:56:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Hqyv4zXqfJWvsDUEBnkw44GnKu9JuXe0Tjma2P25hIA=;
        b=Drqmf39PYaJ5Eeln6zpYLQy5x4EnnD9RkVvoVBTXYWU8xlPZu654IU73oTn4lVOU9S
         ZKjRX2LKB5vniXcapRJJhs8jSrVDb0s1zQZlGqr291VdFYH1e24K/j8uVwQevIipzWGG
         98iqf0zl4Kq3DJpUoeGyxnyli/COLskLbX1hJTFgqe8ncTgrZ46Tpk1jyxi7Jn91Qh7/
         LRQTG79Y/QTLqquU/qYGnuPCAIbceYLhnI0Yink5DsN4Pkfm0w1sx+CS7SkjcIU+Qr1I
         M8P2HToaT85RmhfU98JsWl+coFP9DwPrH+VJ5NEppHqNsSTw/1q9umhPu+itvuC8fciv
         qYlw==
X-Gm-Message-State: APjAAAXlw4TDR6KlsxtxPTdB5Dq9ri9QWSjBqZ7RpqaScU5efxpkHle2
	cNjXsxJcqTJyH+teeRtb7/UsifiXaKop83DvUay+i/oaHn6P5vWCf8J0f/Th1KQnG+YzM5hzQz3
	VgFScCkh3u/pgIJYMv6/GvoplLimo8VbZa6pZcLjMyr1Y9NeCuVoMEt+0AiQeWO7npQ==
X-Received: by 2002:a65:610a:: with SMTP id z10mr41591716pgu.178.1563375361477;
        Wed, 17 Jul 2019 07:56:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBjclZkYYnhqc5f7dDJLeFpzgSllzTh3zw2eEy4qeEdnsfjcXNJVAm/6iOMbobcFoMI95L
X-Received: by 2002:a65:610a:: with SMTP id z10mr41591557pgu.178.1563375360244;
        Wed, 17 Jul 2019 07:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563375360; cv=none;
        d=google.com; s=arc-20160816;
        b=Lz9vjClzLuoopH0yYTXeE/grvrhBWowIEiM0J+HCxdmgtPW+idX41KtxCBEXhX2u3Y
         BFtSyyYpg+myMhVeALzQio5PTuuC3a48DmczqsVWT8g9/ah6a4h0J1zZKfBfVw0sgZg2
         Z4Yph6Lixj0TEllVaSTlXAraIe3eX3nLLB4Im9k1WY6dOUhZB5Zwn8iEyfc6aY2nTkhe
         Ggfwp8+51/hNmJ1GIksd9N+dQCITwGY91g+7g/PIRFbTle8ejGY5pulIqZUINXIslPyP
         nSzP6Ch9NXDjrHxflGauITOADE3JY6k+iEGmdfCqQzlBooqO8zxr9utCeIMEzCZNibL5
         PYKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Hqyv4zXqfJWvsDUEBnkw44GnKu9JuXe0Tjma2P25hIA=;
        b=hKFqFxSQci/K5n/gMkmCByfdJJBd8XXe0kaJOBwtgT+KsULh8wH+AXNAZCv/CC58no
         garM+u22zXLQf6IzmCqxZaNntdM8tpSA3hKeyIoEZvFlSFJ7qAqbwQbzyYj4n09Ot4Ei
         KW2Hk5ia/VEgxU1HFjnM9Z7ocPW3bFrm/niKjdWCpZeS7C84KPSyuJ4WB3MgAGlNO2NJ
         m0GDAquGAgn4AQAD77ujlxTGh6LrK5p6uPMtxzvrjCDG0aASIlkWALdzeKp61b+HH3t+
         dQVba+8tB9Rn1eIz5FSfvA6lz3DfKkAdiHwyuIfXXpInmhcHxDKkv4dKDNhilGqfUW7F
         Vfyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PHYffguA;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x125si22126687pgx.332.2019.07.17.07.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 07:56:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PHYffguA;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Hqyv4zXqfJWvsDUEBnkw44GnKu9JuXe0Tjma2P25hIA=; b=PHYffguA8Do4AfdhPOYF0/QtR
	EBq7JI6/Gk9l93jsR/Cf9s2z+BbMdIBQ8GHui9bYZGDTSOqKeEPo/kvRMc4XhyPbZg2VeZDfN0uuq
	foSMg9eo7rjoTJo418aje2TXH7SjtLzXIp0/024YtEiakXEukBeaFPEnJuwj6ksU8Uy4EjPlMD80D
	10Yefa9I8t2ANsgEGs7aA+mZbNIoVtd1UaJV1sHNPVep8F7ZoTA2S8w8riTU21Nv3hQZMregOi8uN
	KYjnbu21XWjjfu/mQuFe0rj+2NdprGxL/TaghcjCuL/dek6+vevJsl/qY6XeyUxY0yxdGeIopMHvg
	K3FHAlAig==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hnlLb-0006dc-4A; Wed, 17 Jul 2019 14:55:59 +0000
Subject: Re: mmotm 2019-07-16-17-14 uploaded
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190717001534.83sL1%akpm@linux-foundation.org>
 <8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
 <20190717143830.7f7c3097@canb.auug.org.au>
 <a9d0f937-ef61-1d25-f539-96a20b7f8037@infradead.org>
 <072ca048-493c-a079-f931-17517663bc09@infradead.org>
 <20190717180424.320fecea@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a1179bac-204d-110e-327f-845e9b09a7ab@infradead.org>
Date: Wed, 17 Jul 2019 07:55:57 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717180424.320fecea@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/17/19 1:04 AM, Stephen Rothwell wrote:
> Hi Randy,
> 
> On Tue, 16 Jul 2019 23:21:48 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> drivers/dma-buf/dma-buf.c:
>> <<<<<<< HEAD
>> =======
>> #include <linux/pseudo_fs.h>
>>>>>>>>> linux-next/akpm-base  
> 
> I can't imagine what went wrong, but you can stop now :-)
> 
> $ grep '<<< HEAD' linux-next.patch | wc -l
> 1473

Yes, I did the grep also, decided to give up.

> I must try to find the emails where Andrew and I discussed the
> methodology used to produce the linux-next.patch from a previous
> linux-next tree.



-- 
~Randy

