Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DAE2C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:19:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4778220665
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:19:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4778220665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDB598E0005; Thu,  1 Aug 2019 04:19:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8B518E0001; Thu,  1 Aug 2019 04:19:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C52D38E0005; Thu,  1 Aug 2019 04:19:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 875908E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:19:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i27so45210873pfk.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:19:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Q8VVsZjMcE72bida3jLuQzxcX2Xg95cWq2GmHRaih9o=;
        b=nJDln8V2Wv3a7TY79UvVbTkSPaALrIFTeJj2PG+AgmsHXkq7mRL/x2ob0LzrTIJqlt
         d3LwluHh94RoO4jiLGldGmQpjcjuRjBicrvhMnWK+XuLHek37uNdVcgyMvf1FNcesvuJ
         cJqxNM0URAnt5G2vB8HPQZ+0A7/gnzFXk3LN2YNevHlDyhGJnXY7/8Ac5WbTVZ/jrJ2d
         2RZVTep69LoBcSyFR4QCSPv8AQKP2QhOk+CblYx07vT5qQXvR0BMqvFCOV6Ac7z3Gm3b
         9IHiMuoTRMhmHJ5HHSI5mH+VQ/oxZZHFXnCM0UZb8eFxUihPN8gEiE683YnxOkzJYP56
         GCXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAUhO7UrSb2+vj+WNIf2ZKA+9HAk+eEaFFDpHCcP6JpCK70zUCfe
	M1q9/d+yeikkSR8+xuSvHTJoFxuPQiHH/jnK49H5d18rCpjfiB2/BHR94b+FVJNwIbyMHjW3n1q
	y5TEFdb9EYiOmu9pzgMyZXYdQ32tOpKrfIm86KgFcvM1S9djCNCX8zvMXi/MuqYxzfw==
X-Received: by 2002:a62:b411:: with SMTP id h17mr49690657pfn.99.1564647556182;
        Thu, 01 Aug 2019 01:19:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/3yheEAYC1jZDBKEew6qT/+023deKzJixTtZjpYjh7PhRtWjuMW/Ygt1HfM/rpzRF+jpj
X-Received: by 2002:a62:b411:: with SMTP id h17mr49690594pfn.99.1564647555248;
        Thu, 01 Aug 2019 01:19:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564647555; cv=none;
        d=google.com; s=arc-20160816;
        b=GQaUL3t/Wrvly3sf2nam82hKkM7gdI9DQar2KvU/ZE94EGXHUb//BuUhBY00XW9Mpx
         ey0jPE0AGH26W7ttFONiCZBicmSDcE85P/2zj4tbo7YVlt5QXEb9FSls7ghy8C1gipye
         XNhGv4MnLqg5FKhM8+KkeiPUP2l3yPZX90brPdd5UN+zapiL1cTh96sFLdDtzBwGKcW8
         42oOubkXIFZPg8F4qk8wfMWEbz0UZZW0Zkfi+dwp4FroMMfq0tf+ddBkNVuqFN/VQ/cy
         eheWUJ3WRjlhxUuY2eTIeT2Gknnwv83JRU7pcGZv5awhm59KVbYeRcosDeRm4ZZVU1h6
         Aqfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=Q8VVsZjMcE72bida3jLuQzxcX2Xg95cWq2GmHRaih9o=;
        b=X5F8RcgxgAALe4+qUBhZDbnt0lLwp9W+U5wydxKvrjW70a0zqRbQcWjBd7PAIa4Old
         1ibanXMjhBFdw2nu20r4t3nuBOkCmU8Xsl4SLU6APqkZBz/A9curOtx4mLzDQsTs+4jy
         bDClu+zN4I9/DhKEbdWk76Da2qqVmq8ptae0uo4gRRExC5g8oEH0WQJFkv/2wdSQs65W
         /k/s725AV3ac0rwwQfsbJkOamhTwX9vmNAFzlr30MBpF+bmOzRAY1bZtRLAt/wiqOllO
         X/YvJS+VwDfrcP188aqqCYMvaGVOAOUkqRGGrKBqijDZPk29PA5a/wmw1dz99L8FN6Io
         SLGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id bg3si29773962plb.83.2019.08.01.01.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:19:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x718JDMC025230
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 1 Aug 2019 17:19:13 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x718JD2t023372;
	Thu, 1 Aug 2019 17:19:13 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x718Isjq021046;
	Thu, 1 Aug 2019 17:19:13 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7316139; Thu, 1 Aug 2019 17:17:39 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0439.000; Thu, 1
 Aug 2019 17:17:38 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Jane Chu <jane.chu@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH v3 2/2] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
Thread-Topic: [PATCH v3 2/2] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
Thread-Index: AQHVQzSPZWUqS0z8rU+q1hsF+rBObKblZd+A
Date: Thu, 1 Aug 2019 08:17:37 +0000
Message-ID: <20190801081737.GA31767@hori.linux.bs1.fc.nec.co.jp>
References: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
 <1564092101-3865-3-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1564092101-3865-3-git-send-email-jane.chu@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <372749A4D6FFC14982F5FD30BC1E06A7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 04:01:41PM -0600, Jane Chu wrote:
> Mmap /dev/dax more than once, then read the poison location using address
> from one of the mappings. The other mappings due to not having the page
> mapped in will cause SIGKILLs delivered to the process. SIGKILL succeeds
> over SIGBUS, so user process looses the opportunity to handle the UE.
>=20
> Although one may add MAP_POPULATE to mmap(2) to work around the issue,
> MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
> isn't always an option.
>=20
> Details -
>=20
> ndctl inject-error --block=3D10 --count=3D1 namespace6.0
>=20
> ./read_poison -x dax6.0 -o 5120 -m 2
> mmaped address 0x7f5bb6600000
> mmaped address 0x7f3cf3600000
> doing local read at address 0x7f3cf3601400
> Killed
>=20
> Console messages in instrumented kernel -
>=20
> mce: Uncorrected hardware memory error in user-access at edbe201400
> Memory failure: tk->addr =3D 7f5bb6601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> dev_pagemap_mapping_shift: page edbe201: no PUD
> Memory failure: tk->size_shift =3D=3D 0
> Memory failure: Unable to find user space address edbe201 in read_poison
> Memory failure: tk->addr =3D 7f3cf3601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> Memory failure: tk->size_shift =3D 21
> Memory failure: 0xedbe201: forcibly killing read_poison:22434 because of =
failure to unmap corrupted page
>   =3D> to deliver SIGKILL
> Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware memo=
ry corruption
>   =3D> to deliver SIGBUS
>=20
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 22 +++++++++++++---------
>  1 file changed, 13 insertions(+), 9 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 51d5b20..f668c88 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -199,7 +199,6 @@ struct to_kill {
>  	struct task_struct *tsk;
>  	unsigned long addr;
>  	short size_shift;
> -	char addr_valid;
>  };
> =20
>  /*
> @@ -318,22 +317,27 @@ static void add_to_kill(struct task_struct *tsk, st=
ruct page *p,
>  	}
> =20
>  	tk->addr =3D page_address_in_vma(p, vma);
> -	tk->addr_valid =3D 1;
>  	if (is_zone_device_page(p))
>  		tk->size_shift =3D dev_pagemap_mapping_shift(p, vma);
>  	else
>  		tk->size_shift =3D compound_order(compound_head(p)) + PAGE_SHIFT;
> =20
>  	/*
> -	 * In theory we don't have to kill when the page was
> -	 * munmaped. But it could be also a mremap. Since that's
> -	 * likely very rare kill anyways just out of paranoia, but use
> -	 * a SIGKILL because the error is not contained anymore.
> +	 * Send SIGKILL if "tk->addr =3D=3D -EFAULT". Also, as
> +	 * "tk->size_shift" is always non-zero for !is_zone_device_page(),
> +	 * so "tk->size_shift =3D=3D 0" effectively checks no mapping on
> +	 * ZONE_DEVICE. Indeed, when a devdax page is mmapped N times
> +	 * to a process' address space, it's possible not all N VMAs
> +	 * contain mappings for the page, but at least one VMA does.
> +	 * Only deliver SIGBUS with payload derived from the VMA that
> +	 * has a mapping for the page.
>  	 */
> -	if (tk->addr =3D=3D -EFAULT || tk->size_shift =3D=3D 0) {
> +	if (tk->addr =3D=3D -EFAULT) {=20
                              ^
(sorry nitpicking...) there's a trailing whitespace.
Otherwise looks good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

>  		pr_info("Memory failure: Unable to find user space address %lx in %s\n=
",
>  			page_to_pfn(p), tsk->comm);
> -		tk->addr_valid =3D 0;
> +	} else if (tk->size_shift =3D=3D 0) {
> +		kfree(tk);
> +		return;
>  	}
> =20
>  	get_task_struct(tsk);
> @@ -361,7 +365,7 @@ static void kill_procs(struct list_head *to_kill, int=
 forcekill, bool fail,
>  			 * make sure the process doesn't catch the
>  			 * signal and then access the memory. Just kill it.
>  			 */
> -			if (fail || tk->addr_valid =3D=3D 0) {
> +			if (fail || tk->addr =3D=3D -EFAULT) {
>  				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of fail=
ure to unmap corrupted page\n",
>  				       pfn, tk->tsk->comm, tk->tsk->pid);
>  				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
> --=20
> 1.8.3.1
>=20
> =

