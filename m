Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3E45C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:25:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 831CB20B7C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:25:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Oh0OGRwP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 831CB20B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DA386B0003; Fri, 26 Apr 2019 14:25:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18A2A6B0005; Fri, 26 Apr 2019 14:25:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A08B6B0010; Fri, 26 Apr 2019 14:25:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C761B6B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:25:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so2592820pgc.1
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:25:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G0xTXKIQ8y4bDWP1ltZzmN7QjtbVN/tN5BtZMKSHm/s=;
        b=PCYiP1Nre26YtZwKbQHCTo8p+gTIQaf1KIIccwnZdNS4zCT52lUPKV5VnqYl49/hu7
         OPp3+C8GSRdWbePCKElq/9K2UFV18bGH31tS4Ny3rGod+uYExafa0EoVYjGKWjxVf7Kr
         f8xgz8usWzXLzePO2pe436nMPSMue1lfwN2qvh6dtfNHJO9CHMkl5anj6RLeMsfyznPX
         JON87EoW0P/89bkn0B55jpwPWr4vjDrlmrUJJA4/61WZ8dxR39Ow+qmqg6HO2Qs5O0Tn
         /nd8FxltbiBW+O6niiOe0XKuZSNePvJkgBkxfaQbhmkTse+JdF2LCezCNzbwGrC6tkSf
         ixAw==
X-Gm-Message-State: APjAAAXZXJ7pE1LnI3/jb2VOcSM4JHPleiTsXF1wMijn+9207yvEtYy0
	lSw1pe+KRTGtE27xIysCHvojpfLpWVdTmEdwzo2E/cl1uAQGPEBgMwoU87PbI13hvhg0u9KQtMe
	7RGrIS4UFrNzSqgTpWUcmN6PfWcThvP56ghzSyb8SrCih6x0JgMlw+8gYj2lThvfXKQ==
X-Received: by 2002:aa7:8186:: with SMTP id g6mr11930955pfi.126.1556303144356;
        Fri, 26 Apr 2019 11:25:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMTLhIyBBTtpe22XoXg3cCBE/vhbuloOzAjVw+/lqdij8ud61cWwXC3avNtr3BdPgldaTe
X-Received: by 2002:aa7:8186:: with SMTP id g6mr11930899pfi.126.1556303143429;
        Fri, 26 Apr 2019 11:25:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556303143; cv=none;
        d=google.com; s=arc-20160816;
        b=PmAwDpmMEnsNqfdIxo04J32/1woRyfrR2Rkin4Q8/pOPINhrvbDNaTuVCnh4qtczGv
         lYjvbE8Sg9yl1P/ZZFXK69qE08jPi0wyT5w/tbikz8FNPcWnPen5wDO6T5yVxOOrNw18
         a7KeuPkyvDZmNQoLwc8sAs+Nuz5/sMmQ9Ky0tvQFwvcZsqCHacTTVLXv99rBRxYMdb7B
         l35nt5F2apV/zBAoYmDLFX7QQu5KXOZiYQLzF5lzWn7WVDagE7NiqbDotGe3G/cfkOCU
         yVP8kfZQ2NTLKU6Qm5vJbkdXt7iV4kIe6z940fFZgS+LShN08j0oA5f8uHuc4cV4xoTo
         t+8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=G0xTXKIQ8y4bDWP1ltZzmN7QjtbVN/tN5BtZMKSHm/s=;
        b=Vj3huMnsUO+Q036BvyaxEGFCKCtVxxDWfBvBTBbxuv07SFK//fACRTBsh6Pmf87wD6
         8UsuXoz/Jf7b+YEvDef+oB6mK9yWEKa03D+bAlDiiuaI3teltFsjVzzy7fb7GEzSC5u9
         C6bfmHwPwOictPgj+xP4jI1wbLD6ohUbiZ2ZjTTWToF29lFlyMLZ2ChQthBTn8ymuxQK
         JIMjmXki8ToRJJ1nXPHLcAUD/HartA8khiPWN1yTt/oZK4O09kHnTJH6UOAMwZzUFkAK
         KUiS27BSykjxo4h7l4syNj5FPPVD8jBJOosOWh96d3oBzOeBKXr5mnbo7xh1dhIHtU84
         sieA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Oh0OGRwP;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k5si23650301pgq.193.2019.04.26.11.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 11:25:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Oh0OGRwP;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DAB962077B;
	Fri, 26 Apr 2019 18:25:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556303143;
	bh=Azy+PMU1MYpeR5hI05Ymh1eBcpPLshTxYtXFlvQLilQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Oh0OGRwPWzHs0xhAGW1VnQQ20kGlA6XLbtPb7PEvoCel4p4vUVHER2LlUSR3ByTDo
	 OVHe5GrsdB2icUrFUMP0klijhvvWpnwpoH+9U8TFxB7bi3v5IMWZ19yVQWLVMTcexn
	 o8QB/tFuAmEOFKee76ekXn5jxnEbq9s9vFn91so4=
Date: Fri, 26 Apr 2019 11:25:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: jack@suse.cz, mhocko@suse.com, linux-mm@kvack.org,
 shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/page-writeback: introduce tracepoint for
 wait_on_page_writeback
Message-Id: <20190426112542.bf1cd9fe8e9ed7a659642643@linux-foundation.org>
In-Reply-To: <1556274402-19018-1-git-send-email-laoar.shao@gmail.com>
References: <1556274402-19018-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Apr 2019 18:26:42 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:

> Recently there're some hungtasks on our server due to
> wait_on_page_writeback, and we want to know the details of this
> PG_writeback, i.e. this page is writing back to which device.
> But it is not so convenient to get the details.
> 
> I think it would be better to introduce a tracepoint for diagnosing
> the writeback details.

Fair enough, I guess.

> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -537,15 +537,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
>  
>  extern void put_and_wait_on_page_locked(struct page *page);
>  
> -/* 
> - * Wait for a page to complete writeback
> - */
> -static inline void wait_on_page_writeback(struct page *page)
> -{
> -	if (PageWriteback(page))
> -		wait_on_page_bit(page, PG_writeback);
> -}
> -
> +void wait_on_page_writeback(struct page *page);
>  extern void end_page_writeback(struct page *page);
>  void wait_for_stable_page(struct page *page);
>  
> ...
>
> +/*
> + * Wait for a page to complete writeback
> + */
> +void wait_on_page_writeback(struct page *page)
> +{
> +	if (PageWriteback(page)) {
> +		trace_wait_on_page_writeback(page, page_mapping(page));
> +		wait_on_page_bit(page, PG_writeback);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(wait_on_page_writeback);

But this is a stealth change to the wait_on_page_writeback() licensing.
I will get sad emails from developers of accidentally-broken
out-of-tree filesystems.

We can discuss changing the licensing, but this isn't the way to do it!

--- a/mm/page-writeback.c~mm-page-writeback-introduce-tracepoint-for-wait_on_page_writeback-fix
+++ a/mm/page-writeback.c
@@ -2818,7 +2818,7 @@ void wait_on_page_writeback(struct page
 		wait_on_page_bit(page, PG_writeback);
 	}
 }
-EXPORT_SYMBOL_GPL(wait_on_page_writeback);
+EXPORT_SYMBOL(wait_on_page_writeback);
 
 /**
  * wait_for_stable_page() - wait for writeback to finish, if necessary.
_

