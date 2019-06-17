Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25BFEC31E50
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:12:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD7E12084B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:12:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ais7vmnl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD7E12084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66F228E0004; Mon, 17 Jun 2019 10:12:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61EF88E0001; Mon, 17 Jun 2019 10:12:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50ED88E0004; Mon, 17 Jun 2019 10:12:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3BEF8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:12:55 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id m8so1150387lfl.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:12:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UR02dBMpLO2IwgmJl+zzqfvWxW4b3uNT3A/fq8b3Xl8=;
        b=GJWt6f2Azkzb7qO1mTk7BAo1d0/KL6BcVP3+1qxXQJ+3lqSOqBpHduJu19WLaNungI
         udOUtO2Sd6oTYfQ/UqiUlDf/9P/JovjJvMo5B4FoUENG317VZjLbN+fDr27lkhqas5Uj
         S4OMiICvNcDggoXq9wYR71XVAvrLqchTjgCuyXSZn9om9lMThrAnjqng1QaQrqpLQJjL
         +r9ROmtm/5JJgOAp0lSXJAIFrBXY6pTTbmO2/ny+RGesHf7ZXcMKWyVqPjC5Yqm79TSi
         1I6vS3hj5nlqgejXukfs46WhEk9ayJg23XJf0zA5Q0RdaOcPrxLpnYMj3E1XezIgybEI
         EXbg==
X-Gm-Message-State: APjAAAUBO3BQdGxiZKSLad7cAkwxdTxiaW1ZHPKXgFQict4Tf7ba2sIh
	ncezqJRaInDYWl8x9bSpIhkHWFbYNpMe/CkaSWXhz5SUsfDs6FZhxPwyPOzDlGg+r4d2OEnWz5P
	ekf+qHQSCUye6gRgsBEoGlzkVCWAFmelDZG/d/pOvIHWM/dTOXfGfZcp8A5FLeOJBxw==
X-Received: by 2002:a2e:9b10:: with SMTP id u16mr13024965lji.231.1560780775086;
        Mon, 17 Jun 2019 07:12:55 -0700 (PDT)
X-Received: by 2002:a2e:9b10:: with SMTP id u16mr13024916lji.231.1560780774295;
        Mon, 17 Jun 2019 07:12:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560780774; cv=none;
        d=google.com; s=arc-20160816;
        b=k+uaYAfeDFagtW96VO1xdyVN2B2191eRvdn/evGQUCvo8mpxtSB3iaJRyeqEazypbt
         7Kb8YnQ6cLno1b1uuAqbYyIpiblU7VZwj1QMno4s/keKM53CeHRTh4hD/IaXHKYwJe/q
         wZ26hDzQyi9cKGWimstMdob6KxADUt/E1RKI1syJkjjMmNaxNW0sHzxeDbMrwjPEYhpe
         IDZll1d9hNE2xIY9huIZVrc6pG42yjpD5/3SOwTkV/VuILeKOSWyQuvmC+kxKx0PmVDt
         ZgFUnnr99PFt71wQ/z8ZE1Gq1MXolWAyro3EWdPaCvcURqNc3O9K3mnNutVyAv8SEqWe
         t7yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=UR02dBMpLO2IwgmJl+zzqfvWxW4b3uNT3A/fq8b3Xl8=;
        b=NMn9v4yF3hdkVRnKSP39X7ZU463Ul/ocX6KjZGcIJNiMiDbaKWTbXZ3dcSA0z/7tel
         Yhp0DYMAJqxQff59HwRORwsa6hufSSWDdi8UnSTtfVz3g7XGJRZkBwlEeDz4QbdTjkOX
         XmBWN0hVjZbcGL3bzbu5uoKAbd11gvdjpBGhV1DAbjl9bzAlrX2Eo9a8NZQGqArFEV2c
         rOTcHOBUTM/13RC6Gcaf2Idx2OxijNlTPsgd+fN8dlcrGVH48EDRTU3r/iCzGshco6ZY
         3SEAriGcfIlPZKDXS2SYwx0URf0S0R8DNReTb3G6EbxnhybRcCscvJC7Jm5iDRhNggxI
         Xw/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ais7vmnl;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d26sor6047432lji.22.2019.06.17.07.12.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 07:12:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ais7vmnl;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UR02dBMpLO2IwgmJl+zzqfvWxW4b3uNT3A/fq8b3Xl8=;
        b=ais7vmnlp64PLs4/yXLarwLc3vWBtVrRpvk2YVRLCu5vOynXF/ETKfQV3kRZdWVNd4
         AHp8ZVFVSXxWboDrThV6ewKEIoHbd9p0HhILdPz/MdACLBMShrwayFTu7p68fLujVUpA
         7QgSAMEcPGG8pk5jzEBlYJaUZxq5mjlgKzrocXpZfIuC+o7svmRuMipiT8lk1mPzseBJ
         3B6aL30SNmWb5x3EbValwnSyXeV0QGAIs5ZXgxIw1CAP1Ewia2ASPyhh1EyVWVPkLgBW
         iZUdOfLWIzgYGZgHNgxHtDyaqaplfikrHJgT3afxiLgYycfJpZk/SyQVnLvwV2i0xldT
         dNhA==
X-Google-Smtp-Source: APXvYqz67dES8orYwdSlSUe3JHIspV1NctOeVCA4RYfKHZHj2HcSoZQBqbf24JEc9RSK1DCSvpM3ZA==
X-Received: by 2002:a2e:988b:: with SMTP id b11mr17763540ljj.110.1560780773866;
        Mon, 17 Jun 2019 07:12:53 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id n3sm1784184lfh.3.2019.06.17.07.12.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 07:12:53 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 17 Jun 2019 16:12:44 +0200
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Roman Penyaev <rpenyaev@suse.de>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in
 pcpu_get_vm_areas
Message-ID: <20190617141244.5x22nrylw7hodafp@pc636>
References: <20190617121427.77565-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617121427.77565-1-arnd@arndb.de>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:14:11PM +0200, Arnd Bergmann wrote:
> gcc points out some obviously broken code in linux-next
> 
> mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
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
> Fixes: 68ad4a330433 ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
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
>  
> -- 
> 2.20.0
> 
Please do not apply this. It will just break everything. As Roman
pointed we can just set lva = NULL; in the beginning to make GCC happy. 
For some reason GCC decides that it can be used uninitialized, but that
is not true.

--
Vlad Rezki

