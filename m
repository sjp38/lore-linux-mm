Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A2A7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 20:53:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7EE2218A3
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 20:53:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r3YpB8fr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7EE2218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 632976B0007; Fri, 29 Mar 2019 16:53:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B9676B0008; Fri, 29 Mar 2019 16:53:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 482B46B000A; Fri, 29 Mar 2019 16:53:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 280176B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 16:53:32 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id v193so3311277itv.9
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:53:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SXLIsWX+sIMJiNWtF0Uz0Css8O/+w93TgCqvxQgHdgU=;
        b=MFEPlkOIzwgfOk+h3OuthhkwNui7qlqo0E0XUDqTdu+Z6JGCNb0ImzAtoUTfzSYX2/
         NzNcerOjQus1ufv/BEDBH3oZwmbGaHiDNXawsESHU7MKoKek5YI6zHo1GmiLyzYHQFrn
         OQrMEQbqw5j/+O7cAT06PoWFXOjr6Bfix9a6msU+ZITy7uLq7OEtCkDf9QCNNg8NK9LF
         /vlFrcqljYjsROvMX5YceyoQKOZqaiMPnbv2YdJVeispVASV5F99/LSJqeSYGMnP1NAn
         05liTxeNttNRSKlrvCYaTWF46nn5A88andzR2YMeJ3725TLqwzB+JueyLJvYs4IWzCPJ
         +JKg==
X-Gm-Message-State: APjAAAVjlFDfET++Rt4dCfU6A6DFFuaGb9oN5Md/hnsBOdSRETulb+Rg
	nbKPpIhjChHXz5ttbQ/pdjZAXtaU8/tDOLbVTlowJgjmJw8QDFJOwDaUlc6Zs/iSvecLjZSjq8p
	9ZjdTJuyyHRUXMg1bQfqaV2XLfgCD1Ug+cPnhq7Kk+gFrAwhDnL6CZqsfCokVN7Mu1g==
X-Received: by 2002:a5e:d506:: with SMTP id e6mr14029192iom.7.1553892811887;
        Fri, 29 Mar 2019 13:53:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQy+YDOBHOCBsCXYGZP7ALwnuv9HOWQ/JkXH3rdPMtzyH/PTIseuLA7VOquUdtoGZt6zlL
X-Received: by 2002:a5e:d506:: with SMTP id e6mr14029154iom.7.1553892810947;
        Fri, 29 Mar 2019 13:53:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553892810; cv=none;
        d=google.com; s=arc-20160816;
        b=pjWaS6RTypUTnx/Bn/Mzhsd1UGiia0zykOeDgPkrs9/JRgKxnA48WfLxteqTVExT6z
         6xDuZFpHMrI1VYfovU3ZGT9KG5Ijx4zapmrJQRFWRf5HZz8FHu/7kmcGLvGtzzvE1ic+
         Tc81bx0g0PahRvJZxnb5ncuKQfMhq4snvo4y5k1zMzO+xRTE9tV7vR97RRfSgv4a1lBp
         9TtRoO96HzeKucg4KfeeHKOMWB1JEt63YVugwF/oFWQfKLOpodrTvGt0c+OfR8TxpBP/
         zoyYAwZKajgEjSF9z89Lw4CODZK2+fm4OtXA4Iojupd5cTdv+busiBO6Jqjw7lgycc5S
         1sjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=SXLIsWX+sIMJiNWtF0Uz0Css8O/+w93TgCqvxQgHdgU=;
        b=eriHmEMkxIpr6QUV98RnWwMF1yKM0P+dD6uNAxvyfBa4bMSkydXldVq2jC8EPHvvrP
         yLixnFyuNQkRfQBMbMCI/gFruQANHIXEkoqfU/vugnp6kfz24XUOvQhDvdBK44CeZ9bJ
         kT5Q1wfYyLTKY5Knx4BmXYRM+pPPJgO+huc2gc0bvPrsjzc+SnRZXLSsfJ6ECA91eThC
         QXGvotIKJCjO++QTUS8kJjY6VjCd+1wWiNSiSZO6ueZh2uhBjmLkJLjCYdvTZUdRi33X
         F2zI5gAH1s5coXA3cC+w3CqJNSCo1fFZT/HDE2qzKbLkR0rs8abXdaDl2LVKL2jrTbY5
         TfSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=r3YpB8fr;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 72si1577316jaa.37.2019.03.29.13.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 13:53:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=r3YpB8fr;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=SXLIsWX+sIMJiNWtF0Uz0Css8O/+w93TgCqvxQgHdgU=; b=r3YpB8frv2MwYfBW++6LtXZqqh
	J8MQ1igNj30Dkbfak77RQSfJMVWXukSQuE2PYmgokaTkjdMQABrYXM0MhU7nwvqDf+OTOh1KKE4fi
	4l9TKnJ9txerl45TWGywTqNIW/Fck3uLrrNjEWmVLEk3bnGo45RD3bL+W9aTDLODdzCHHpDONmkh8
	BU/J8qGHl9wccB0rAugzNEWnKwv34ouxpnQajvFjL2kqzPhU/+aQZi/fO0qaCdTG59E6jvycqfr7x
	s6VORPvkkQdsFQEFohtLgxnkIgoCBW4RSyHii7MVdQhKREvcv4fBnPBqYppVbFKTEov7XbyV2HrK/
	jesYArHA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9yV6-0008NG-8l; Fri, 29 Mar 2019 20:53:20 +0000
Subject: Re: [PATCH v2] gcov: fix when CONFIG_MODULES is not set
To: Nick Desaulniers <ndesaulniers@google.com>, oberpar@linux.ibm.com,
 akpm@linux-foundation.org
Cc: Greg Hackmann <ghackmann@android.com>, Tri Vo <trong@android.com>,
 linux-mm@kvack.org, kbuild-all@01.org, kbuild test robot <lkp@intel.com>,
 linux-kernel@vger.kernel.org
References: <eea3ce6a-732b-5c1d-9975-eddaeee21cf5@infradead.org>
 <20190329181839.139301-1-ndesaulniers@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <83226cfb-afa7-0174-896c-d9f7a6193cf4@infradead.org>
Date: Fri, 29 Mar 2019 13:53:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190329181839.139301-1-ndesaulniers@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/29/19 11:18 AM, Nick Desaulniers wrote:
> Fixes commit 8c3d220cb6b5 ("gcov: clang support")

There is a certain format for Fixes: and that's not quite it. :(

> Cc: Greg Hackmann <ghackmann@android.com>
> Cc: Tri Vo <trong@android.com>
> Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
> Cc: linux-mm@kvack.org
> Cc: kbuild-all@01.org
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Reported-by: kbuild test robot <lkp@intel.com>
> Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested

Thanks.

> ---
>  kernel/gcov/gcc_3_4.c | 4 ++++
>  kernel/gcov/gcc_4_7.c | 4 ++++
>  2 files changed, 8 insertions(+)
> 
> diff --git a/kernel/gcov/gcc_3_4.c b/kernel/gcov/gcc_3_4.c
> index 801ee4b0b969..8fc30f178351 100644
> --- a/kernel/gcov/gcc_3_4.c
> +++ b/kernel/gcov/gcc_3_4.c
> @@ -146,7 +146,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
>   */
>  bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
>  {
> +#ifdef CONFIG_MODULES
>  	return within_module((unsigned long)info, mod);
> +#else
> +	return false;
> +#endif
>  }
>  
>  /* Symbolic links to be created for each profiling data file. */
> diff --git a/kernel/gcov/gcc_4_7.c b/kernel/gcov/gcc_4_7.c
> index ec37563674d6..0b6886d4a4dd 100644
> --- a/kernel/gcov/gcc_4_7.c
> +++ b/kernel/gcov/gcc_4_7.c
> @@ -159,7 +159,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
>   */
>  bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
>  {
> +#ifdef CONFIG_MODULES
>  	return within_module((unsigned long)info, mod);
> +#else
> +	return false;
> +#endif
>  }
>  
>  /* Symbolic links to be created for each profiling data file. */
> 


-- 
~Randy

