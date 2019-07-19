Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD6FBC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:32:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 722CB2084C
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 08:32:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ti.com header.i=@ti.com header.b="TA7Ls/ZE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 722CB2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=ti.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09A136B000A; Fri, 19 Jul 2019 04:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04B278E0003; Fri, 19 Jul 2019 04:32:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7A628E0001; Fri, 19 Jul 2019 04:32:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id C28E26B000A
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 04:32:25 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d135so23291021ywd.0
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 01:32:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=IVqQ1ovk/uB5I3+HYY88jIzu+tAVMCodVGet/Jwe4Qw=;
        b=pqzyFZkmGb6gpJTCZZk1RcTKYQnJSLh9bPd9Wotke3mrrQT3h3bNjKSAez5tm7Sn9k
         X/Bcot9r9ntFZ1ZZpex4Q5tkTLvWvZ22viAcCi1QAbRHOS134TqQ1hkCOETGqIKIxRkB
         OAfn8Qb0IBiiHStcL8yuvwhfUS7WtyB7Ch4+6ArbWKfzwdhshMFkmTk1ZjyqesPF8Ki/
         eeD1UnHO1UrRnBx5KFVTjXo5b6cieLIgUGKAf2/+0fJ7S1havE8iHACDGs07WnDBRpwY
         43Bq8J+RZU0ldIk5fNDvYzw2FxS1IffHBJPXjZ0E4bTLDzz2WVBXWNIC7AGJFkjQPnvQ
         bIZQ==
X-Gm-Message-State: APjAAAXd7ROayAQksvzQG6FlRAmgQxAnK9uy7RCywbYwXFxI+FtOpKgZ
	IHNtt1FZMzbXAqyrWGlghkrJ1TmvtJTkcEE0q2+o1oiMi7CMHNbJOmKoEHh2SDAZjGHzZKMhxQH
	YX0lAXj5KRl523B+diFNZrL5OP40aswgAWdG9hHIVVMqJw/OzeGbOuEWgvuzHwzsO+g==
X-Received: by 2002:a0d:d70c:: with SMTP id z12mr30312964ywd.218.1563525145502;
        Fri, 19 Jul 2019 01:32:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnnLGSqKrCVc/IJf7+L91qTf3SJENGe1ek1jzUQrifRjml3kKKy5dZqc7ZI+qn94Zt0qCy
X-Received: by 2002:a0d:d70c:: with SMTP id z12mr30312935ywd.218.1563525144948;
        Fri, 19 Jul 2019 01:32:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563525144; cv=none;
        d=google.com; s=arc-20160816;
        b=DrAO/gmL60O8fl+5BGd0Pnvd/5jrRv6GnQtPNfi+W6w8IddnpozW/sz93bUpo/8X+H
         VvnRabztH4OXbJpbGFQzGVzZ62AbQQLAZUvCyYVbXDML8DH4DGO9GYyEYmDeRwuNAk16
         I1PEZ2emk5VH/6k1R5TA1aO6wXBO1U+4qzB5KlZYQ/5WLtxF9XIfoG243qfvkjjweE+V
         Lt3OOPQeHFVlJZuQstpjHXYOtS8aRpKeNjA0lnjDsppXKVL5tyzQRSWq4NeBZ9DxFPbd
         RhOBkAVvyt2nomqFn06Qhtmo0WeARy7UVILcWfkCxiYTmfuUX+UzKzsMyrnQbSXe0O/+
         skYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:cc:references:to:subject
         :dkim-signature;
        bh=IVqQ1ovk/uB5I3+HYY88jIzu+tAVMCodVGet/Jwe4Qw=;
        b=Qd8xP97CypxuBmQuedTFQqdu0qEM3NFOxFl1Pi3Q6GHAT4NOTm2NqHO5U2mWxnspw4
         446pXnTW6nuhKpD2EINBo3UyuroEA8qlcgYbkxVylQywmPq3/ayx3mG9JBNdDEZowaF2
         oBkdeEaqHOgP3o4yjpbZ3eMaBaEyACICI1rsM1cJiEUJCRXdebZP89HPFf+96x3PRIVf
         o/eYEgSgLgWlPbhl1NeAVbEj2c3sKExKm4iwzUjggz6VbXzxSBbUty6P12bAyX0M1Lj2
         VYO4uEYwv0AezBrfwjukUImMEv2jrLLSgemkPOcDlDjpAAY8zvdFKcik72wBHvSMCLcL
         aSng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ti.com header.s=ti-com-17Q1 header.b="TA7Ls/ZE";
       spf=pass (google.com: domain of vigneshr@ti.com designates 198.47.23.249 as permitted sender) smtp.mailfrom=vigneshr@ti.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=ti.com
Received: from lelv0142.ext.ti.com (lelv0142.ext.ti.com. [198.47.23.249])
        by mx.google.com with ESMTPS id p201si622184ybg.484.2019.07.19.01.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 01:32:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of vigneshr@ti.com designates 198.47.23.249 as permitted sender) client-ip=198.47.23.249;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ti.com header.s=ti-com-17Q1 header.b="TA7Ls/ZE";
       spf=pass (google.com: domain of vigneshr@ti.com designates 198.47.23.249 as permitted sender) smtp.mailfrom=vigneshr@ti.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=ti.com
Received: from lelv0266.itg.ti.com ([10.180.67.225])
	by lelv0142.ext.ti.com (8.15.2/8.15.2) with ESMTP id x6J8WALd020368;
	Fri, 19 Jul 2019 03:32:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ti.com;
	s=ti-com-17Q1; t=1563525130;
	bh=IVqQ1ovk/uB5I3+HYY88jIzu+tAVMCodVGet/Jwe4Qw=;
	h=Subject:To:References:CC:From:Date:In-Reply-To;
	b=TA7Ls/ZEkH2MbrRXeYpK/I5F6jqRsO9SrdHYTKsvbb8YV35on1KfFQeB8SYPnL6re
	 6NnLvVEyQ/sNskzSNhGBpXoW24Vu3AOGMPKwtXzVy9rmIuySPxWTc7hbTUkKRxRZh0
	 RK1pIyAePXpb4zqaFDDjRbt9YttbGuTaI9GGpXn4=
Received: from DFLE101.ent.ti.com (dfle101.ent.ti.com [10.64.6.22])
	by lelv0266.itg.ti.com (8.15.2/8.15.2) with ESMTPS id x6J8WAor097464
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 19 Jul 2019 03:32:10 -0500
Received: from DFLE111.ent.ti.com (10.64.6.32) by DFLE101.ent.ti.com
 (10.64.6.22) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id 15.1.1713.5; Fri, 19
 Jul 2019 03:32:10 -0500
Received: from lelv0326.itg.ti.com (10.180.67.84) by DFLE111.ent.ti.com
 (10.64.6.32) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id 15.1.1713.5 via
 Frontend Transport; Fri, 19 Jul 2019 03:32:10 -0500
Received: from [172.24.145.136] (ileax41-snat.itg.ti.com [10.172.224.153])
	by lelv0326.itg.ti.com (8.15.2/8.15.2) with ESMTP id x6J8W6xV081189;
	Fri, 19 Jul 2019 03:32:07 -0500
Subject: Re: mmotm 2019-07-17-16-05 uploaded (MTD_HYPERBUS, HBMC_AM654)
To: Randy Dunlap <rdunlap@infradead.org>, <linux-fsdevel@vger.kernel.org>
References: <20190717230610.zvRfipNL4%akpm@linux-foundation.org>
 <4b510069-5f5d-d079-1a98-de190321a97a@infradead.org>
CC: <akpm@linux-foundation.org>, <broonie@kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <linux-next@vger.kernel.org>, <mhocko@suse.cz>,
        <mm-commits@vger.kernel.org>, <sfr@canb.auug.org.au>,
        <linux-mtd@lists.infradead.org>
From: Vignesh Raghavendra <vigneshr@ti.com>
Message-ID: <c3b93f7a-5861-475f-faeb-3ec7e8e9b728@ti.com>
Date: Fri, 19 Jul 2019 14:02:47 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <4b510069-5f5d-d079-1a98-de190321a97a@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-EXCLAIMER-MD-CONFIG: e1e8a2fd-e40a-4ac6-ac9b-f7e9cc9ee180
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 18/07/19 9:15 PM, Randy Dunlap wrote:
> On 7/17/19 4:06 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-07-17-16-05 has been uploaded to
>>
>>    http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>> more than once a week.
>>
> 
> on x86_64, when CONFIG_OF is not set/enabled:
> 
> WARNING: unmet direct dependencies detected for MUX_MMIO
>   Depends on [n]: MULTIPLEXER [=y] && (OF [=n] || COMPILE_TEST [=n])
>   Selected by [y]:
>   - HBMC_AM654 [=y] && MTD [=y] && MTD_HYPERBUS [=y]
> 
> due to
> config HBMC_AM654
> 	tristate "HyperBus controller driver for AM65x SoC"
> 	select MULTIPLEXER
> 	select MUX_MMIO
> 
> Those unprotected selects are lacking something.
> 

Sorry for that! I have posted a fix here. Let me know if that works. Thanks!

https://patchwork.ozlabs.org/patch/1133946/

-- 
Regards
Vignesh

