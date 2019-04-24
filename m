Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBAF1C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:15:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7447421773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:15:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="J8NPq1X7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7447421773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D32BF6B0005; Wed, 24 Apr 2019 08:15:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDFA36B0006; Wed, 24 Apr 2019 08:15:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B82756B0007; Wed, 24 Apr 2019 08:15:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4D96B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 08:15:54 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so11742011pfn.8
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 05:15:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vj3d8vRWRgl1TUYLwBnfGWFxKdoE7W/fi9Cn4NFB8No=;
        b=oBYVJM4iUoyI+v/FlWFVQedluGSyPyAiB5borjk+CV2nI3QRIqKrrmre50vuy2azsV
         vixww11C9eHnkwzMR7xwAAErBqFxSU3devv00bT8mnI0RF48bYGHxDsDE7Oi/7U3xqYr
         TLT3q/RBkK82e351wqYZYBJ3VaNLXQcsOO/ELX3rhy8XGsW5GdMRnmxfwJaWJU4idwjr
         1+QaAw8nqAPAa8PRyouwRbYqp539zwozaqerOZ8mRDSslnPrIMugZUdJTwYv10ny8aHu
         Vvttbkq7GpBcPltHP4x6sF8JKvPhJB0FIWz5lkvZCt7B/uUYsr9gm4QZkwq3q/xNDho2
         3P9g==
X-Gm-Message-State: APjAAAUEY1LfphDOJGpHZ/L89Qb1csqGB5jRZRcvK55onsxpuFsWD09I
	YT1HAR0hEO4CW5yzYxQqelkSAgSWRVDKTx/c9SHmDY7pHLM4t/saE8pE+G196O1H/L28xl2FFRX
	uAtJeRfj8dzCsI2sAn7mC9wpHE62uudsi6tNpwA8IwniTiONkvrZ+pvjbwhJT5IX/Yg==
X-Received: by 2002:a62:4649:: with SMTP id t70mr34140945pfa.100.1556108154143;
        Wed, 24 Apr 2019 05:15:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaN8sVcPbJdxGR+zQVDhKYdKrd2PuWRF3KJXiZRDeNEBAcqOtSfm/QFqKYfvSYaWHEbz9e
X-Received: by 2002:a62:4649:: with SMTP id t70mr34140881pfa.100.1556108153415;
        Wed, 24 Apr 2019 05:15:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556108153; cv=none;
        d=google.com; s=arc-20160816;
        b=qo5rjgL8cNft4YXuuOjPlANoVNYOoh3Ob4oUEls6yD5f1vYEV1HSCNIoual0tz+Dr7
         wc/fgUQkJwIXjngWJd5mRB81iC3SGpKP1xgYbKNUOJlUxRl+dZ5YoLPxD0CaYMuDrAwK
         zSs55tpv5h3yY/RvDpmafm4NiVPVID6TtjCCFPw8KhOW1M+F3uM/2puvWwrHhyw3FhuB
         r7p96giP9MO+p2Kp1TdREc5J8HndTT+6wx85jls83vwSwttp9kbXFOZe2/ttrvOZ+8NP
         WVFNGnvWms1hbaBSbhnC+ts9gqnGEBo28Gah2MxKhgQWvg+EpC0QlPFy6YkmUuXOwavx
         LvLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vj3d8vRWRgl1TUYLwBnfGWFxKdoE7W/fi9Cn4NFB8No=;
        b=siea7y77r6vI47UMg2I+7vr14YSm9dyYWW48wAsjRoa48hrOxcCNdZWRsrkp3U2POU
         Xyex99JBvPzLIbRIks9v/045hkpe9YNoKVkw3vel3cfJgvqXOIixR5G3LxRiQUbEgZXY
         gOxrASEvY4KESUyYGdat6Rc/VG9ROA+dnW3u4ilyPrUCs3xjnQO5gVkNECAvwR8iGYeO
         VaH9FcL7PBEn3qKaBDD92nljHB0bhytGkWkgygQu/iTQeOpkpE3ctTKgSCTC8TFFAf1w
         cVP/X7vSmISkHXD0QOTmAcxMAIF9bGk00HlC0KEmhxonYFE5/sjRNXgWcclta/uOHrYm
         f00Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J8NPq1X7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v12si910721pgr.454.2019.04.24.05.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 05:15:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=J8NPq1X7;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=vj3d8vRWRgl1TUYLwBnfGWFxKdoE7W/fi9Cn4NFB8No=; b=J8NPq1X7WmSDNtrLizSrfa18N
	glrdrjtxQ84BeviuPHlUcWxnpwS5ifwUV8UrwJOwCe8jwYAahVStfF5QCj7r1SeCgfvG0puP4kR8e
	kMNY1nHHZpt66U40Yfz/CtUV1mG7lAzp8cAAPmd/oxsAqgJ5RUZarP73PVhXo/AiXPcSiA1rBnYvi
	aeXxqDYZqKWFsbTmnL1zJrVMuu7Qk912EloZedAFDKqCM0ab9VA0vCAkGjERb7JdZ0YlJzezzBXw5
	P7+ByEpqDtNHMxgHAjDDQ0I2pFsyFmvxU1RXViI1sariHkEgsDRhy8HCFkgZ66M+Bxthf6jFllLcz
	nsR030Thw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJGoa-0001PG-Dz; Wed, 24 Apr 2019 12:15:52 +0000
Date: Wed, 24 Apr 2019 05:15:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, frederic@kernel.org,
	Christoph Lameter <cl@linux.com>, anna-maria@linutronix.de
Subject: Re: [PATCH 0/4 v2] mm/swap: Add locking for pagevec
Message-ID: <20190424121552.GD19031@bombadil.infradead.org>
References: <20190424111208.24459-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424111208.24459-1-bigeasy@linutronix.de>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 01:12:04PM +0200, Sebastian Andrzej Siewior wrote:
> The swap code synchronizes its access to the (four) pagevec struct
> (which is allocated per-CPU) by disabling preemption. This works and the
> one struct needs to be accessed from interrupt context is protected by
> disabling interrupts. This was manually audited and there is no lockdep
> coverage for this.
> There is one case where the per-CPU of a remote CPU needs to be accessed
> and this is solved by started a worker on the remote CPU and waiting for
> it to finish.
> 
> In v1 [0] it was attempted to add per-CPU spinlocks for the access to
> struct. This would add lockdep coverage and access from a remote CPU so
> the worker wouldn't be required.

From my point of view, what is missing from this description is why we
want to be able to access these structs from a remote CPU.  It's explained
a little better in the 4/4 changelog, but I don't see any numbers that
suggest what kinds of gains we might see (eg "reduces power consumption
by x% on a particular setup", or even "average length of time in idle
extended from x ms to y ms").

