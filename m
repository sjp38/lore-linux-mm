Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F3FFC4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3E4F20692
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="F1xoMG61"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3E4F20692
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75D376B000D; Sun, 15 Sep 2019 17:38:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7102F6B000E; Sun, 15 Sep 2019 17:38:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 625206B0010; Sun, 15 Sep 2019 17:38:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0253.hostedemail.com [216.40.44.253])
	by kanga.kvack.org (Postfix) with ESMTP id 404CB6B000D
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:38:41 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CECA4180AD7C3
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:40 +0000 (UTC)
X-FDA: 75938469600.09.wax69_4bbd5e8a8692c
X-HE-Tag: wax69_4bbd5e8a8692c
X-Filterd-Recvd-Size: 4997
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:40 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id 4so15867797pld.10
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 14:38:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=h/ncaV79w3xY6uDWRhXLpEpTfQJmu4P1Z2vnPyRUpIA=;
        b=F1xoMG61RxtRCLXxjqDWYUm0394z6rD85HVnbn9F4gsb3b6dKZUs9ZjGFrY9c4ImFQ
         1fLIlFzwuuyAwStdYmUlNMDXXLPNk7cpjjtxoTbPqFLI2nzdgsRuplCMLHccqnXBlsRt
         zPPAUujdo989SuLOVZdYzUjtT6YHBiz08XF/+p25bO/kOJ1PO6OPkLXLEap/lRNrmaSe
         DDSXYYdOv51j1IemdzFk2LfKF8FH8E8EitP1K2z/eoYuLkzT8Pitdv6hkjhH+EFmVRWl
         czAe17sRG2HvdbEXLERIcpiBgmBbUKDHXFD1gE/AKmwxXxeArRl9mOObvXfhsXV/FgQB
         kXRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=h/ncaV79w3xY6uDWRhXLpEpTfQJmu4P1Z2vnPyRUpIA=;
        b=rv/ZNJZRD1EJZvd4jK1DCCn8H2/7PTtycc9pDMtj2YTeFVwg34IUrOuiqoTpaONnhQ
         ad25BOKaCXjW3vkYgY9+LIXPMOwA1VOyjfypsuNW3AI86sWHnjGlCcYL4P4KQJwm2lMR
         grWcmpoKZ/im214r5Ewiev0cSab2Zdd0sOSouFZ/UOwx63duy8hKNxl4PeXlbhZxenpD
         fgefQv16Jv+pKzoBZvvHpUwwECy5MGOCNE72GAvhfA5Xs9gqizrtmdVuPCiVkop8T2nB
         MKjrENr3EQmYr5eNfR+6KLdQj/U98b6qJqlPII2Vbs/ikEaRPJEFjwlFa+nyzORy1AJ3
         6aUQ==
X-Gm-Message-State: APjAAAXvURxSy/Ylq3UUHwjNy+Gu415cu/A8k9khI7k8Q17bRgO427U0
	vjIMhuMsOb3Ca7YFioe4OnJC4Q==
X-Google-Smtp-Source: APXvYqxg7TWt8JQFo35pgCsPA1Lke131vcZRopO4TAfjZaxIMibIfqzIgqSRmfyUEyRISgME2WKVKw==
X-Received: by 2002:a17:902:8e8b:: with SMTP id bg11mr59400191plb.93.1568583519068;
        Sun, 15 Sep 2019 14:38:39 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id v44sm21332300pgn.17.2019.09.15.14.38.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 14:38:38 -0700 (PDT)
Date: Sun, 15 Sep 2019 14:38:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, cl@linux.com, 
    penberg@kernel.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, guro@fb.com
Subject: Re: [RESEND v4 6/7] mm, slab_common: Initialize the same size of
 kmalloc_caches[]
In-Reply-To: <20190915170809.10702-7-lpf.vector@gmail.com>
Message-ID: <alpine.DEB.2.21.1909151434140.211705@chino.kir.corp.google.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-7-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000014, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Pengfei Li wrote:

> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 2aed30deb071..e7903bd28b1f 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1165,12 +1165,9 @@ void __init setup_kmalloc_cache_index_table(void)
>  		size_index[size_index_elem(i)] = 0;
>  }
>  
> -static void __init
> +static __always_inline void __init
>  new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t flags)
>  {
> -	if (type == KMALLOC_RECLAIM)
> -		flags |= SLAB_RECLAIM_ACCOUNT;
> -
>  	kmalloc_caches[type][idx] = create_kmalloc_cache(
>  					kmalloc_info[idx].name[type],
>  					kmalloc_info[idx].size, flags, 0,
> @@ -1185,30 +1182,22 @@ new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t flags)
>  void __init create_kmalloc_caches(slab_flags_t flags)
>  {
>  	int i;
> -	enum kmalloc_cache_type type;
>  
> -	for (type = KMALLOC_NORMAL; type <= KMALLOC_RECLAIM; type++) {
> -		for (i = 0; i < KMALLOC_CACHE_NUM; i++) {
> -			if (!kmalloc_caches[type][i])
> -				new_kmalloc_cache(i, type, flags);
> -		}
> -	}
> +	for (i = 0; i < KMALLOC_CACHE_NUM; i++) {
> +		if (!kmalloc_caches[KMALLOC_NORMAL][i])
> +			new_kmalloc_cache(i, KMALLOC_NORMAL, flags);
>  
> -	/* Kmalloc array is now usable */
> -	slab_state = UP;
> +		new_kmalloc_cache(i, KMALLOC_RECLAIM,
> +					flags | SLAB_RECLAIM_ACCOUNT);

This seems less robust, no?  Previously we verified that the cache doesn't 
exist before creating a new cache over top of it (for NORMAL and RECLAIM).  
Now we presume that the RECLAIM cache never exists.

Can we just move a check to new_kmalloc_cache() to see if 
kmalloc_caches[type][idx] already exists and, if so, just return?  This 
should be more robust and simplify create_kmalloc_caches() slightly more.

