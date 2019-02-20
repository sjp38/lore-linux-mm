Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04966C10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B78F720880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 13:44:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ORPlDrRI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B78F720880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D76D8E0017; Wed, 20 Feb 2019 08:44:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45C9E8E0002; Wed, 20 Feb 2019 08:44:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FDD88E0017; Wed, 20 Feb 2019 08:44:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2AD18E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:44:57 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g197so3574352pfb.15
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 05:44:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RUB2frUU7NuwNJE/JAugdb4Jo4DDQEbUbHsxvIgWYSw=;
        b=uQdAFNAUhdHp8wRjkVndY+LobfRY7NLPAC4uxvQQ7WOU+oTFC+X2QzOYRECujF+hDN
         BjUXfQKPp2+aSQoIbPzsmsVtOWc2CZCFfEKQkNPstPzzvDxL5Y+RLiN3exa9iSulUsZ1
         0o5CX4l4htmsiaDAPUyt9vJeKblytfhhWPQP9gFDc5RohlX++97oGJGbrnx5lAY1sNSA
         MNJGP4h9sEO2ZjZ3aL1NT2sTkANtHWpzyVlufGPRUL8y42lxfVrSSHFGQzk7pyH09PwX
         gX4z/X7kMQeb/aEgAmIlR9AgLJf71Whrnwrh2dC8iUL2PA5o3YGvFrEJmvUGHNe5KHFl
         5Gqg==
X-Gm-Message-State: AHQUAuYR591j/yiOqknL4m8CBRvNQuN18HgMVvMgsnVohoM4vAEM9y1d
	ZjnrCV2FLC7OBmukU+khe0k5pAM3pKbX5ttbQTWpHW2KBz0x1Ff6hKifn1HkZdHpS8TGpN8RoKi
	ufK/FTF3VRZCax5SR7ta6si9HhzY9B6KBYz6EB5vWHS52unCkPZYw4qtzRX+yFoYQ3w==
X-Received: by 2002:a62:53c7:: with SMTP id h190mr21977512pfb.204.1550670297546;
        Wed, 20 Feb 2019 05:44:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYquVkDD2PXj6uE4Sz4qm1lbr+Ne3LH1dVwmZDLR9R0k3F2CZc/I4kSkEkRHWPt/B8EszX4
X-Received: by 2002:a62:53c7:: with SMTP id h190mr21977474pfb.204.1550670296779;
        Wed, 20 Feb 2019 05:44:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550670296; cv=none;
        d=google.com; s=arc-20160816;
        b=gymhP5XSZUdn2HBzHAMvpo4fpK+gcXF8Rm0TiONx6Jlz+uM8ajROJN6q8aq23LWBDu
         J6pZsmGDTg+asyEmoqxixvto0IkrdN8kWQwGhhYNH5y4HSbKjSL7vgEnlSJOWCdgq4j9
         9SO2iRhrta61I6BpJhWX14l0g94dUvIPZ/7VqmZ3FunwInKAv7gPiRXSaS1HjwhTOTFS
         DMs5nnXSClQZrMw7flwdTbC5MnJq5fTD1iurUoTlaT7C1z4ZAnYzYK7QWe1+e0iy1AAB
         fO8o7oFvYrhRvIXy9xoW7stNSaXyAXPe99mdBYJ67GKNZG8BYFU3rS8/80YVUygiTqdA
         p+wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RUB2frUU7NuwNJE/JAugdb4Jo4DDQEbUbHsxvIgWYSw=;
        b=W7csFZb4hIKhWJQjiUZfzDOD7z5Q9rsKBB1CoLwGZbxSa51BdVn/Rr/PQ1dwO7kptn
         dw5Lkuj8w7QwQIrAbc3B/ClGL53ZF1lz2jWL0O9+K1pLaICiCs8ImyHfZavJ7os+rOSu
         Xyug1vL62yBs22CGC64aqIJPAjNDzg8JSwa6KQqYbCa4oGIjP0yNPaHuNhgZUnSk6xdw
         kr9mV5rONaveTaXGcLWg5rx0aXXJC7eD4g3+UJRQhYACRoVBmL6/FfDUE2J8RrkB8Q3M
         rGmXYgtwOiPSqvcKejyPeUqWisc4a+T77r/T9Bsev6XdYbuKBxKzRov5UKh5abAU7nAZ
         l+Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ORPlDrRI;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a2si9043078pga.476.2019.02.20.05.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 05:44:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ORPlDrRI;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RUB2frUU7NuwNJE/JAugdb4Jo4DDQEbUbHsxvIgWYSw=; b=ORPlDrRIncIEgDpBIoRn0pv/O
	OWaymA+60UkjBiy1sG7/Gquj0ik20o3WUiwtN19IREtGqCbMb3K7O+isXK5Cy+6cjj3qZvuL+ST6g
	kEpEfKxrqLYkmSDLkJGv27mHHBGCfWzyEPhDWD/erKpljWiB0Zh2tJmcxw79SSuRuKhkyTqAJBH/v
	8EmYf+wEM5Me83XrbXVpLOME9VSdlG8vszwlplW72LU+KE8Mc5cJnsi8DpIYwlszFYoK/ze2GzKLa
	8nb6XaziINVVHnqLBxSBqkVIa3OwpjVHKrf4feTn8pJaoQRg/15HLyQTyJbjWSq8Z/sUwGY6LDnvP
	AkimOjmPw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwSBD-0003DN-1W; Wed, 20 Feb 2019 13:44:55 +0000
Date: Wed, 20 Feb 2019 05:44:54 -0800
From: Matthew Wilcox <willy@infradead.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-fsdevel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC ][LSF/MM ATTEND] Read-only Mapping of Program Text
 using Large THP Pages
Message-ID: <20190220134454.GF12668@bombadil.infradead.org>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 04:17:13AM -0700, William Kucharski wrote:
> At present, the conventional methodology of reading a single base PAGE and
> using readahead to fill in additional pages isn't useful as the entire (in my
> prototype) PMD page needs to be read in before the page can be mapped (and at
> that point it is unclear whether readahead of additional PMD sized pages would
> be of benefit or too costly.

I remember discussing readahead with Kirill in the past.  Here's my
understanding of how it works today and why it probably doesn't work any
more once we have THPs.  We mark some page partway to the current end of
the readahead window with the ReadAhead page flag.  Once we get to it,
we trigger more readahead and change the location of the page with the
ReadAhead flag.  Our current RA window is on the order of 256kB.

With THPs, we're mapping 2MB at a time.  We don't get a warning every
256kB that we're getting close to the end of our RA window.  We only get
to know every 2MB.  So either we can increase the RA window from 256kB
to 2MB, or we have to manage without RA at all.

Most systems these days have SSDs, so the whole concept of RA probably
needs to be rethought.  We should try to figure out if we care about
the performance of rotating rust, and other high-latency systems like
long-distance networking and USB sticks.  (I was going to say network
filesystems in general, but then I remembered clameter's example of
400Gbps networks being faster than DRAM, so local networks clearly aren't
a problem any more).

Maybe there's scope for a session on readahead in general, but I don't
know who'd bring data and argue for what actions based on it.

> Additionally, there are no good interfaces at present to tell filesystem layers
> that content is desired in chunks larger than a hardcoded limit of 64K, or to
> to read disk blocks in chunks appropriate for PMD sized pages.

Right!  It's actually slightly worse than that.  The VFS allocates
pages on behalf of the filesystem and tells the filesystem to read them.
So there's no way to allow the filesystem to say "Actually, I'd rather
read in 32kB chunks because that's how big my compression blocks are".
See page_cache_read() and __do_page_cache_readahead().

I've mentioned in the past my preferred interface for solving this is to
have a new address space operation called ->populate().  The VFS would
call this from both of the above functions, allowing a filesystem to
allocate, say, an order-3 page and place it in i_pages before starting
IO on it.  I haven't done any work towards this, though.  And my opinion
on it might change after having written some code.

That interface would need to have some hint from the VFS as to what
range of file offsets it's looking for, and which page is the critical
one.  Maybe that's as simple as passing in pgoff and order, where pgoff is
not necessarily aligned to 1<<order.  Or maybe we want to explicitly
pass in start, end, critical.

I'm in favour of William attending LSFMM, for whatever my opinion
is worth.  Also Kirill, of course.

