Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B99EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:58:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB4022086D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:58:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="NTBxFLX5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB4022086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78FEC8E0056; Wed, 20 Feb 2019 20:58:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73F0C8E0002; Wed, 20 Feb 2019 20:58:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 608558E0056; Wed, 20 Feb 2019 20:58:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 324788E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 20:58:45 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k37so25246815qtb.20
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:58:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SNMyx3mvyEhumH87qacwojMOgIg98VYddiiEUf2zBNE=;
        b=Na0ouralECNAx3l5CX8SQoGZRlkh9tCYnUqo/Rz1D+9xcYNilNz1sOyWGr1MtKO6Nd
         fJdzFQi0JtIukThI670mli3tG13xbrQJ9KyQXibUSq0beX+hjfwW9Hk++loT+m+wZDNS
         SKfifJuxFrvDSq2njdFU97/DzDxKbDx89SOewY31lbad/Og+kcfjsTVGH8XKzY8nKtlX
         nfENLdZ30pzEiKfQclefMpxlGum/QYToIWvhX8f1aEwspP5L8GuXgW+hIhu4C8GXWnk+
         /URYOsZ6eLVogHA+iXb/Fnyq+Jwt3jxJQBKTKlBBJXaFOKzDdkZa1+j8CB+Gwl8MGHv2
         ErvA==
X-Gm-Message-State: AHQUAuaofo2hvY7IB579asuAe+WqCu/mQ+Tuvd+hEdOptOgYJ7OcXuFm
	mzPrfHyvaIJkZ6J1+6fqPbx/7OfewtrSFCenjfg3t26pPPe5j/bXQuqkkYpljlBwImXIRTBHZFh
	v9xHUKEa10LN+nC9W+vlO6u/BSloZ4zfq68fbctATlu33y3g16DQ+UTuSh0uzu+ROAnIhZpkMWB
	3fyWac5m0ZYaTDmcuNh7gNEt0ZKhXqCRCB0ibpxsABRXD98czgA9BgshRMV99v2x2I+wdhfaDuF
	gYPw8JP8mM1Vh5kxbZzJlhY8Te1ny3RRJ2Ktl6V6n/0NgNzZ9vwLm6/u74nj+wvrqcJuocQVyuc
	+B8ZtTc+yNqCGImZUIci4xUXvg17tkEMNw+KulbifFLQeaCARPHCrOFy8BmTJEbr7SryM7cZPrz
	t
X-Received: by 2002:a37:a4c1:: with SMTP id n184mr13973243qke.229.1550714324903;
        Wed, 20 Feb 2019 17:58:44 -0800 (PST)
X-Received: by 2002:a37:a4c1:: with SMTP id n184mr13973222qke.229.1550714324340;
        Wed, 20 Feb 2019 17:58:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550714324; cv=none;
        d=google.com; s=arc-20160816;
        b=eoBaK5LbgL5Mwt43E3//Yx1chmE5FHvdB7Xg9ZQMLCs94bLvhqXlwpNBICdtUmPlra
         YGR0+XBfaoX4L0AJF+Etl6HyqyKCohODlxOpLtlQUkcwFweBlh2CwV9iyOq0bx21KAoF
         h0wQEXYA6yg6toSZSyR+YYRJToluULoAaeGxrmVWJaBsvEsdS44xrlvUnwLTVnKfHftY
         DNOL88+ccqjlLEMDOUc2qlhLVg+YhiPzH1iG83rm7MUMnoKdOgeamhfBDCvu5iEmXcr5
         BkNU2Ab+ma38IM+GpulMIyUTWYoALEfmor9mSlgyc5az7is2Fk1Tpom48PS41OkRAHjp
         qiWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=SNMyx3mvyEhumH87qacwojMOgIg98VYddiiEUf2zBNE=;
        b=gdY+5xzIrPI6s8S77zQepUEwRxwVIS5QHOgW0If5HTfsE9wKdeFJwZTJpxuJJiHNlF
         j9YaLfWyA2U/mJEsdBWvpPPHMdEnoXWSTwub9z4L64wMRtfqWt4WvSKt7UMecisRNfSE
         NLP+9qjXeeOFpavs9tUT+b5gG1jS6tsL10MYOv4m12WcdPIkTsXqWXnuGoL0EmJT7AwM
         5F9MgH22CZIqkssMqmBDFPjbeJhcyf6VNMVWiHkJ2arPqswheUBJJUE0IZgrL8RTP0Cr
         1I820+h+kGaT0eW20wxhDY6kWmAoWhKbE16OdsXYGJ4RIdgMhH30ECi/KCh22CarP6Ci
         TaCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=NTBxFLX5;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a81sor11921041qkg.130.2019.02.20.17.58.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 17:58:44 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=NTBxFLX5;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=SNMyx3mvyEhumH87qacwojMOgIg98VYddiiEUf2zBNE=;
        b=NTBxFLX54Jn7ha8lCrCA3BheJXv+WNR8+OH7uJxY9EhKMfBmTmbsoe7IZmi8E6WW8F
         UT4G5hX8+DwG/9EgN0iICC+cCYpHnzbjwC3uL/Z8BH7jUZBB19cCSFNhRHW6DONg4I6S
         aS0LVN2zgZ0YozT9v4xbVmiU819eWcKd2iuaxfKYwFRzZIBAFpQ7CGsWDHIy4Z6vGjSG
         tSvqRnOzuoCVyUmJ/FH4oA2rv88o+e6xFtv9fRb/Z5HAKTqvEcuURdu77IcMBhabfQxN
         1lZDBelOExgawckUYHLW7WS/4rT5k2mOxr76RpRhgLnZDef2ehQLHZPpZsfcyTH5K2ix
         uu8w==
X-Google-Smtp-Source: AHgI3IaLeqr5GDP9UozyfNZgGbyilkHrQUQOpmLrsV6q4ZPweAJHmgyumamCgnJ1wwj2aQQ7o4RAaw==
X-Received: by 2002:ae9:e702:: with SMTP id m2mr18772286qka.279.1550714324094;
        Wed, 20 Feb 2019 17:58:44 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s21sm14198665qki.94.2019.02.20.17.58.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 17:58:43 -0800 (PST)
Subject: Re: [PATCH -next] mm/debug: use lx% for atomic64_read() on ppc64le
To: akpm@linux-foundation.org
Cc: dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190221010819.92039-1-cai@lca.pw>
From: Qian Cai <cai@lca.pw>
Message-ID: <6c48d33a-083c-68bf-f94d-3d901453a198@lca.pw>
Date: Wed, 20 Feb 2019 20:58:42 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190221010819.92039-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Please ignore this patch.

On 2/20/19 8:08 PM, Qian Cai wrote:
> atomic64_read() on ppc64le returns "long int" while "long long" seems on
> all other arches, so deal the special case for ppc64le.
> 
> In file included from ./include/linux/printk.h:7,
>                  from ./include/linux/kernel.h:15,
>                  from mm/debug.c:9:
> mm/debug.c: In function 'dump_mm':
> ./include/linux/kern_levels.h:5:18: warning: format '%llx' expects
> argument of type 'long long unsigned int', but argument 19 has type
> 'long int' [-Wformat=]
>  #define KERN_SOH "\001"  /* ASCII Start Of Header */
>                   ^~~~~~
> ./include/linux/kern_levels.h:8:20: note: in expansion of macro
> 'KERN_SOH'
>  #define KERN_EMERG KERN_SOH "0" /* system is unusable */
>                     ^~~~~~~~
> ./include/linux/printk.h:297:9: note: in expansion of macro 'KERN_EMERG'
>   printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
>          ^~~~~~~~~~
> mm/debug.c:133:2: note: in expansion of macro 'pr_emerg'
>   pr_emerg("mm %px mmap %px seqnum %llu task_size %lu\n"
>   ^~~~~~~~
> mm/debug.c:140:17: note: format string is defined here
>    "pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
>               ~~~^
>               %lx
> 
> Fixes: 70f8a3ca68d3 ("mm: make mm->pinned_vm an atomic64 counter")
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/debug.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/debug.c b/mm/debug.c
> index c0b31b6c3877..e4ec3d68833e 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -137,7 +137,12 @@ void dump_mm(const struct mm_struct *mm)
>  		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
>  		"pgd %px mm_users %d mm_count %d pgtables_bytes %lu map_count %d\n"
>  		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
> -		"pinned_vm %llx data_vm %lx exec_vm %lx stack_vm %lx\n"
> +#ifdef __powerpc64__
> +		"pinned_vm %lx "
> +#else
> +		"pinned_vm %llx "
> +#endif
> +		"data_vm %lx exec_vm %lx stack_vm %lx\n"
>  		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
>  		"start_brk %lx brk %lx start_stack %lx\n"
>  		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
> 

