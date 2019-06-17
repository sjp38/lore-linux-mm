Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 325E2C46477
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 032A22089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:49:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 032A22089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CD948E0003; Mon, 17 Jun 2019 09:49:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67E278E0001; Mon, 17 Jun 2019 09:49:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56E438E0003; Mon, 17 Jun 2019 09:49:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 087DA8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:49:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so16506258eda.10
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 06:49:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=k8KJABV0pjaeSdu3eRzn39Bn+zaPpAMCsb34seUTEbE=;
        b=UxDvd/KXy1siPOTmjeSvM3ZQi5uXcpulnbrx/I1DusJh3JUlPjMhgc5kwLaqw/ktBV
         0fdEVmD2c5CF6sThEtgIDuuiuvjK+xhvpJJP7R9Cxi8wrEyJL4Zg335utc4WBuUioAaY
         Fh4Wnjk7Yo/kY03U8rDjVdFoBeCzHCpY2KyUTVjbERz8Dn2utHYIMdiQex+J/8UFPdBx
         3SWKZ45i83U5Hp8qnvUwmOIZLdY+9PfXHaOAWUN1F3cWq0vip022pOEr+j48NnVRMo+d
         5l55RMLQIEak62nVu8NGWvaj3eHk3C5VB07+tKlATY4HMlY3joIhdTM4+qhFBnvumK1+
         Sjkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: APjAAAUeBS+UB7stDYSV6bNqj3zMKRUBMuDxQ4Zu46dGFSeZ5rSiwZEe
	yhsqrnQwCI8ThKl6ujJXu2UbXbVYZ4MBuLPEFqJFxhxIda27Y2KBLTU/RzgaPMzUqB2KesPs/ae
	xFbrFyvtIqzZrtM33IBclJvZdStwMWeN2wxufkn3OBS7ijIpwgSfUMMlITz+nl9GXwA==
X-Received: by 2002:aa7:df93:: with SMTP id b19mr41408834edy.153.1560779395608;
        Mon, 17 Jun 2019 06:49:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVB/MPdHxfSwIL1G6/q9DzIEVi++6ou5TfBj2w0vZRSmybBObYrHS+parMPPT+c72TZwib
X-Received: by 2002:aa7:df93:: with SMTP id b19mr41408768edy.153.1560779394885;
        Mon, 17 Jun 2019 06:49:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560779394; cv=none;
        d=google.com; s=arc-20160816;
        b=LQEVJHVuieNwp57NhDwLVZl5iKMn8ngbuIzLM0s0teBply9TLTB+6ILtuJaK8FXT27
         OJa2PDDMTF9f6lSd2RAj6aRIsJOvhFGyhma9/SZqHorvroDGK5+yrovMIeWWgb/WJofz
         QvcatDzwXRxSciwGawaDE0NY0kjmMOkhvh+waiFY+eSKduFUNEXdYCmjZ6YwUdUDV3vX
         u5Xc+/9QQaFWh/pQ9dzorKOCa7DR3cA7amaY7aMxhY4SMVz0bwFBjCsI+/clvd9mtQfF
         5ye47MXMbRieXBj34lB1M0nVqRQKJ4f9jkirtsKdybxSQudoJlzi46heAvu2ScGTLY8Z
         Ewng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=k8KJABV0pjaeSdu3eRzn39Bn+zaPpAMCsb34seUTEbE=;
        b=Sn/36e7Gdo7WI2eoOHrhsH7LP5HTScUg+XGDavLU8PK2AUOQ0uhcKPoyDYZfeXb5Fx
         ofpxzmIWqaJHh+jdagM0uWB+T79gYyH9z0RbQEObebCQiLXNIQ4H+AJKfrj6Dp27oyRK
         iCr5/gSPnl8ZPFPTgHP/6itoL4Eb3pitWN7CzxhzfTZ0B/gLwh8Yu6S14jP7K1Ri9Y/w
         PwfUE6Bc8jOCn1RqzqZiV04C7zmuCLDYALGy9SjaBbUXet9uaNg1HTf1QL+K13TlYlPR
         MIxSPFACZrj4kN1qgS+9FfiPfDekwkz/w4aJirDD21pfpGR15/lnnJm5FEeMKHiuxYfE
         zWTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f30si8854762edf.183.2019.06.17.06.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 06:49:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BADC8AF30;
	Mon, 17 Jun 2019 13:49:53 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 17 Jun 2019 15:49:51 +0200
From: Roman Penyaev <rpenyaev@suse.de>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Roman Gushchin
 <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox
 <willy@infradead.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy
 Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds
 <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>,
 Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, Mike Rapoport <rppt@linux.ibm.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in
 pcpu_get_vm_areas
In-Reply-To: <20190617121427.77565-1-arnd@arndb.de>
References: <20190617121427.77565-1-arnd@arndb.de>
Message-ID: <457d8e5e453a18faf358bc1360a19003@suse.de>
X-Sender: rpenyaev@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-06-17 14:14, Arnd Bergmann wrote:
> gcc points out some obviously broken code in linux-next
> 
> mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this
> function [-Werror=maybe-uninitialized]
>     insert_vmap_area_augment(lva, &va->rb_node,
>     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>      &free_vmap_area_root, &free_vmap_area_list);
>      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> mm/vmalloc.c:916:20: note: 'lva' was declared here
>   struct vmap_area *lva;
>                     ^~~
> 
> Remove the obviously broken code. This is almost certainly
> not the correct solution, but it's what I have applied locally
> to get a clean build again.
> 
> Please fix this properly.
> 
> Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap
> allocation")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/vmalloc.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index a9213fc3802d..bfcf0124a773 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -984,14 +984,9 @@ adjust_va_to_fit_type(struct vmap_area *va,
>  		return -1;
>  	}
> 
> -	if (type != FL_FIT_TYPE) {
> +	if (type == FL_FIT_TYPE)
>  		augment_tree_propagate_from(va);
> 
> -		if (type == NE_FIT_TYPE)
> -			insert_vmap_area_augment(lva, &va->rb_node,
> -				&free_vmap_area_root, &free_vmap_area_list);
> -	}
> -
>  	return 0;
>  }


Hi Arnd,

Seems the proper fix is just setting lva to NULL.  The only place
where lva is allocated and then used is when type == NE_FIT_TYPE,
so according to my shallow understanding of the code everything
should be fine.

--
Roman



