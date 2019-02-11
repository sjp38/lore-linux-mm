Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95826C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:57:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32DC421B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:57:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="O9Z8ZFPK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32DC421B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FC238E011A; Mon, 11 Feb 2019 12:57:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A9DA8E0115; Mon, 11 Feb 2019 12:57:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 798668E011A; Mon, 11 Feb 2019 12:57:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38F988E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:57:01 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so8902099pgb.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:57:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kI0sdjrum5jiu2PQ9Dll1y9K5Hr4fyaJQ95yFl7qdOI=;
        b=CgrFShx+zpjpaDEq9hQ9qHJtYnh1+u2O4tBN6tULFAwbKimkiXX+RyjYuseq5rWtL3
         oNuYirAxcsVWLN1dWgcWPaejrtqMCwZnkXG4lM/g+lkwL9ezf9zEfmbndQmu+V2OGTSG
         abH1q3+n2AOlUbTiCY8+WsSza97Dxa824tRaIUe76J5DVSQsFtwX93o3NRlXBrgPS/cZ
         8tdaDjtUhihWyK2ib3f/h6Z2KhF1d0QtXJsAN+W88FzGtEngkWnmAk2l2Q/fGfVHZpxs
         /JTc78a/mtn+5ihv1sVr2i3V3cuULbmaTegiwCeXJdaUam2AJhgC8aiO4iJh4MlJzfU+
         s4DA==
X-Gm-Message-State: AHQUAuYj4NNdtJVRhmhcbhtSS7AZpk+0oExrhAMu+SjogxDTrys9cm0V
	gyiHeexP619xztDwroIPBNcr8w2LWfJO1bEVyakd78BMebIuoPXZ57i/Nu+xbOPsF6TmKe1rDhC
	VXe7lQqX05/wchlPTHm+YOeyjlTO5tm8h4U0yw8jDXSWWj7eaid6m/kl2uf7QNJaGfQ==
X-Received: by 2002:a63:20e:: with SMTP id 14mr19503170pgc.161.1549907820831;
        Mon, 11 Feb 2019 09:57:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZxIgwxZq1wM0DFJGqTX9L5vQ1P8YoUMR9oZsKuMS9ZkA/ULAv+o4Gg+f4MRdr0yczsufX
X-Received: by 2002:a63:20e:: with SMTP id 14mr19503124pgc.161.1549907820139;
        Mon, 11 Feb 2019 09:57:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549907820; cv=none;
        d=google.com; s=arc-20160816;
        b=jggU1+ZsUchssXzu97vTXL0nWUbRRTjdrbVZO8cfWaifps8UJ4uWhpQOBpB4Wu4mcA
         uJHCox4nySRDmUw0N60bbeaQNYnk/yJ/uIKKfjp6pxAEI1nUxgdOoUejJurI8pmdl3nL
         F7UVMlWIDMCmuO4jr7Rq70wTi9W5un1V+5FBqyQJbzbSj9knxYyxyEp0KLmXG9shzdGv
         zVh75Z2IZTmqfX8gVVbhuT43WsuZOnf7zD6BqIYmkeLHAv45w4nr7JogdWH4FIMH+56v
         n0JcO/qbByqwdhBv+CxGFSYhF/fT1Tm6Pl78ClNBnetW7t7FWx8Tsummm/asqzL/teYf
         vQew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kI0sdjrum5jiu2PQ9Dll1y9K5Hr4fyaJQ95yFl7qdOI=;
        b=GGBmVJ9IyrpXB3plvr5kSKB1iWa6e7iW2pflKsraFWt3t5XUL+bl4CJd/bjzOQDQ01
         frgeifxm8V0lIy0ZsaSFXPZeecUZHd8oYnkGNbP2IrHFUO2Il7o8SNLNp0whEwyE2rpG
         YzW01Ci0OaRivQ8HS/g+iD6Ac3vzPV9921rUlo5/kwD1cP67FJU0O7aRIgbzDgcmKcgh
         umggkK83ED3x9Y+fTE6nmWSEcYWfeX6p3hOTwAsClKNDma8+6YhMXPcB8Hgf2nYUBVQ3
         E76Uoy0cf8K+C+PPp77KBLWhJoECWGOyFXPq+gwEesbvHeVcwu4FMRayFbETPyC4kbrA
         KVsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=O9Z8ZFPK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j66si10762301pfc.251.2019.02.11.09.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 09:57:00 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=O9Z8ZFPK;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=kI0sdjrum5jiu2PQ9Dll1y9K5Hr4fyaJQ95yFl7qdOI=; b=O9Z8ZFPKkq/iHXeziHspJFmWG
	qVV4bCOqDdmhhIFhQMuGKu+TYyI2ZfgdNo2CMjMBd5jLYMfe5rwQqcjArn2/K8Tlakm+Wxrz7Z7G5
	b9F7x1olYOK5jEA1n9cFgOIAfMabSJJjZ0EnCUdEdIeaM9WskzFQ53wmm/AEC9XhWoedYw9bF18dr
	q3kUicBGQ7+IbKIsfLpf9YIGNk1Nw4lizSkDUAdSu9BzU1qZaZqAHRkYtT2p7X75aDxj1374KFmgH
	PUgTOT0dDKrZXGbsz8Zpq7qkSVSM0dW9UxcCc41xcULeBKfgHudvyWBfE4Qze7taKyuhbBZ4OIWuQ
	FuDvIX6lQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtFp7-0000VJ-Hg; Mon, 11 Feb 2019 17:56:53 +0000
Date: Mon, 11 Feb 2019 09:56:53 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: Linux Upstream <linux.upstream@oneplus.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Chintan Pandya <chintan.pandya@oneplus.com>,
	"hughd@google.com" <hughd@google.com>,
	"mawilcox@microsoft.com" <mawilcox@microsoft.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 1/2] page-flags: Make page lock operation atomic
Message-ID: <20190211175653.GE12668@bombadil.infradead.org>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
 <20190211125337.16099-2-chintan.pandya@oneplus.com>
 <20190211134607.GA32511@hirez.programming.kicks-ass.net>
 <364c7595-14f5-7160-d076-35a14c90375a@oneplus.com>
 <20190211174846.GM19029@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211174846.GM19029@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 06:48:46PM +0100, Jan Kara wrote:
> On Mon 11-02-19 13:59:24, Linux Upstream wrote:
> > > 
> > >> Signed-off-by: Chintan Pandya <chintan.pandya@oneplus.com>
> > > 
> > > NAK.
> > > 
> > > This is bound to regress some stuff. Now agreed that using non-atomic
> > > ops is tricky, but many are in places where we 'know' there can't be
> > > concurrency.
> > > 
> > > If you can show any single one is wrong, we can fix that one, but we're
> > > not going to blanket remove all this just because.
> > 
> > Not quite familiar with below stack but from crash dump, found that this
> > was another stack running on some other CPU at the same time which also
> > updates page cache lru and manipulate locks.
> > 
> > [84415.344577] [20190123_21:27:50.786264]@1 preempt_count_add+0xdc/0x184
> > [84415.344588] [20190123_21:27:50.786276]@1 workingset_refault+0xdc/0x268
> > [84415.344600] [20190123_21:27:50.786288]@1 add_to_page_cache_lru+0x84/0x11c
> > [84415.344612] [20190123_21:27:50.786301]@1 ext4_mpage_readpages+0x178/0x714
> > [84415.344625] [20190123_21:27:50.786313]@1 ext4_readpages+0x50/0x60
> > [84415.344636] [20190123_21:27:50.786324]@1 
> > __do_page_cache_readahead+0x16c/0x280
> > [84415.344646] [20190123_21:27:50.786334]@1 filemap_fault+0x41c/0x588
> > [84415.344655] [20190123_21:27:50.786343]@1 ext4_filemap_fault+0x34/0x50
> > [84415.344664] [20190123_21:27:50.786353]@1 __do_fault+0x28/0x88
> > 
> > Not entirely sure if it's racing with the crashing stack or it's simply
> > overrides the the bit set by case 2 (mentioned in 0/2).
> 
> So this is interesting. Looking at __add_to_page_cache_locked() nothing
> seems to prevent __SetPageLocked(page) in add_to_page_cache_lru() to get
> reordered into __add_to_page_cache_locked() after page is actually added to
> the xarray. So that one particular instance might benefit from atomic
> SetPageLocked or a barrier somewhere between __SetPageLocked() and the
> actual addition of entry into the xarray.

There's a write barrier when you add something to the XArray, by virtue
of the call to rcu_assign_pointer().

