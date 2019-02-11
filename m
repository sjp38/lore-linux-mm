Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 961E3C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:46:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50031222A5
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 13:46:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ly3zG10V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50031222A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF7358E00E4; Mon, 11 Feb 2019 08:46:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7D258E00C3; Mon, 11 Feb 2019 08:46:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1FF88E00E4; Mon, 11 Feb 2019 08:46:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 859B68E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:46:16 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id x134so203879pfd.18
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 05:46:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cUsHcFdEBB6jsvyKRWmW8QXKBcmV7u18TEUHf7s4yJI=;
        b=CwCt46NN1P+6AbxSitHKAeS2OLJZ+MMEgCE0j0y3M8ao1QL/Iti8dVp8cZLIUcYO0R
         hQIv/XZO9LG/lBt94LdcVWZSg3Uoe9eIjwKG1hhs4eTk1wdV3XuYXV9x7JL63oZmtx3Z
         IXGg2lJleqhUtRVlO4xB1iJVweAMR1nZeqNYretQmaJGeNte6+dqwo0USh0HiLkY+W1q
         1VZsuESXCxQCYX+KAJ2jdQW8lhbeaAqTkZr2PiqZZDkkywGL74sNE3wQeXVS5Avn26un
         q0/MQmCQl5+mJ5qGmGzfUtvLLr+wbFhXYbjlsV633/8dcbUdkVfG1HTkJYqVoejRmhFv
         6sgA==
X-Gm-Message-State: AHQUAuYrPOtyl2Z7RMW8uuwI9/gKSaMm5n5g5KSC+s5MnU2e+u4IiSxf
	87ggs9VHbrGVM3NwvT1PF3C1d6dhN5sEpby4R3+Tmhdkb6sjCH9hoIUrH3YnE5Pt1buB0nSSsff
	8HDpU0IlABqrXvf4pHMP0aA8NRP6rw6p5p5JQJlrkJNX6SBbnNTSLW1xppa+GpQHuDw==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr38057895plp.34.1549892776141;
        Mon, 11 Feb 2019 05:46:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4SV2jvg2mabCYOEVx25m3l/4D3AhpINgl8Xo6hcHrX5KhB9u1r/syfZRJG0Rn7wm4FcRV
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr38057833plp.34.1549892775273;
        Mon, 11 Feb 2019 05:46:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549892775; cv=none;
        d=google.com; s=arc-20160816;
        b=r83JClbIPBlrIt1zGMKCEqJj+tHpky5rWOnsjohBglVlt60CukLvOcUegSIvom4j6I
         4mqDje9mYs8T6AIYKQqC+miHlt4hA3qxxbB/FHDvWKC3YJ7zWu1J5AOEptZBcT4ECe9k
         /8SGNRQccjxdBfJf69qD2J20qZj/8DGhDXTkI+wNMK1zQ5BAyAMwcUJHxsHZetLngydW
         rAG9Aop9r1OpXykOqKX2aADFByS4mwqhXIc2P2Q5t4vB/jkTFGUdypZ8BIHHpc3DT6fI
         Ry/ihA/CK4t0GkDgZdyNM4Kv6CCpSTeqzT4KeHfOdtjccwA/mHf3AXoJVJGfqE9y8Tcf
         eXsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cUsHcFdEBB6jsvyKRWmW8QXKBcmV7u18TEUHf7s4yJI=;
        b=scOx8dt0NxL4IzhKU+v4HgR8uvHvShdMdmJTTus0b3FUTrPxo8tgfyGEH8iKJ7WZp7
         nqDEWVLfnk2bkhDip3FW/3WHSRzutLDaKc+moGTCDOVYyQn5Qk+rQkEbfQgRINbBUkaj
         lrf7GEJ2ox0PUCnxFX4BnVcIGM4xoN7bZZKSGS0+TnCnUG7x/B5qNRgxTogjsKLEKEbk
         pKBwxk51CsDJzZRtgKNucS9KhOwAuUspwiFphMANuCzoJjomWIEP1ho93ER/wRL9SaIB
         lUG+f0o7HY5/lsCVXc0En7fNXlXY0Bjy9TPUe1Lrd946YXp2h/7Q1EjVaefsNjfFQygK
         lIpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ly3zG10V;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f69si9126913pgc.514.2019.02.11.05.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 05:46:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ly3zG10V;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=cUsHcFdEBB6jsvyKRWmW8QXKBcmV7u18TEUHf7s4yJI=; b=ly3zG10VIzfr4XYvaWCwYEcK2
	3s99Jc09hx8rc5JRvXL8tCKaOOaZnd+LwrswZiGOFyxZXCILYadSzYOwJf4z+vabopDJPeu/oDfOb
	QDZ8GS2wVaU+lJfvCR6Bw5UcxzAeJFvwIOHWz9nt3gj9pugVYYD10/mmetNQFN+FxoZjqoxGlHfr5
	NUqv+dICov/zKJTC26aHV3lID5M4WjjAR3TQ48Eo3tCSeu2AEF77MrjoxiN3PDjTwwyI6/KQwj/3E
	5V986xMZ6JAq/CNqzNyD3jAb3fJ0DZLYzOs7OPGJemALatfUgLHEZctsz68wZYYUH9Yb2/Il9trVY
	kaNxiNJxw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtBuU-0007Qi-3a; Mon, 11 Feb 2019 13:46:14 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 89A0C20D0E3CE; Mon, 11 Feb 2019 14:46:07 +0100 (CET)
Date: Mon, 11 Feb 2019 14:46:07 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Chintan Pandya <chintan.pandya@oneplus.com>
Cc: Linux Upstream <linux.upstream@oneplus.com>,
	"hughd@google.com" <hughd@google.com>,
	"jack@suse.cz" <jack@suse.cz>,
	"mawilcox@microsoft.com" <mawilcox@microsoft.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 1/2] page-flags: Make page lock operation atomic
Message-ID: <20190211134607.GA32511@hirez.programming.kicks-ass.net>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
 <20190211125337.16099-2-chintan.pandya@oneplus.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211125337.16099-2-chintan.pandya@oneplus.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:53:53PM +0000, Chintan Pandya wrote:
> Currently, page lock operation is non-atomic. This is opening
> some scope for race condition. For ex, if 2 threads are accessing
> same page flags, it may happen that our desired thread's page
> lock bit (PG_locked) might get overwritten by other thread
> leaving page unlocked. This can cause issues later when some
> code expects page to be locked but it is not.
> 
> Make page lock/unlock operation use the atomic version of
> set_bit API. There are other flag set operations which still
> uses non-atomic version of set_bit API. Bit, that might be
> the change for the future.
> 
> Change-Id: I13bdbedc2b198af014d885e1925c93b83ed6660e

That doesn't belong in patches.

> Signed-off-by: Chintan Pandya <chintan.pandya@oneplus.com>

NAK.

This is bound to regress some stuff. Now agreed that using non-atomic
ops is tricky, but many are in places where we 'know' there can't be
concurrency.

If you can show any single one is wrong, we can fix that one, but we're
not going to blanket remove all this just because.

