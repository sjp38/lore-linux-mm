Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 900AEC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:29:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D7B92080D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 12:29:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="a67LLsIq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D7B92080D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C69388E0014; Tue, 12 Feb 2019 07:29:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C18568E0011; Tue, 12 Feb 2019 07:29:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B077D8E0014; Tue, 12 Feb 2019 07:29:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57B5E8E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:29:45 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id q126so130506wme.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:29:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xr7bqCJiI54yGklJuDMTx+dj7QMK1lT6F8mLmTV+W30=;
        b=knPwPBBQMpHRGiA2AVXFU/yoyjjHHe6yWXIVDmHmp+c712mCIfosD+Me1VQrrNA/iN
         2BNqO4IoTgGqPXxun5LYXZ3TjwYvzgQ+4qH7Z9yywaPYhM51bQtHeWKBUlRWzYEGDIjn
         YyCgIhJT2eA16fCzEo3mXHWOwtdP3E6ESAY1flFflGmeQOAGjQrAln2zi8rmqXteAhVN
         Vn/ibE16qqTUp/MvrhHLDl+x80got2MOMODmCREjCLlScv+TCQXYCDyR12ZK/QnTkO3g
         jqpJu2ftmezrqQAoH6AfULjKd9IeTLGs07uct/srhGROMGaqUjdDDhj8Il0+FvGo7Xqt
         4rxQ==
X-Gm-Message-State: AHQUAuYlZmSxBArTx2WItVxCQiO/XZJRIgjHrQA2iop+EkPRz437isPX
	c1JRoV1KhkLqRajNGUcCrJK28xxv25DsRowhiyTz6/gwBMhrBccmuwyghAHBr1TOPninMZPQag5
	xSBYUN9zcdZMdKmvQmkgYLZc9lDou8ogCRo06RiMWwT9dt8Ab/eZpAz7Gdxd+Gruimg==
X-Received: by 2002:adf:a211:: with SMTP id p17mr2687549wra.179.1549974584910;
        Tue, 12 Feb 2019 04:29:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY3R/RsshX+uI40uujjUsb1saFEoKQreDH4DFgjOGJptcLlBasjjZFriOTSKpdNrWDw7Sz1
X-Received: by 2002:adf:a211:: with SMTP id p17mr2687491wra.179.1549974583925;
        Tue, 12 Feb 2019 04:29:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549974583; cv=none;
        d=google.com; s=arc-20160816;
        b=RVC5HOQVDNn647ey6FO48snBP+8boJnkZjOhIy2wO7RkbjPnq66vSFw0/A1CIyjnFq
         FDNNi7YeUtqcDgcM1e1bQmY4eYk/U0wKel1bba+7Y5SmY6VHr1e/C9lb+XApeuuMjnTK
         pAaRCsQJtAEOCfUYj0NLskdU4tWnYn0FqL7X6fRde/W9N6N/tWI/ozBF8nSZcYCVAupW
         YfGY5RAITnJA6A4XN7p2Ec88hm6iE9jgIwRw+6i2C7ZHjSHmkolaELYlgEwWgTOn7d9Y
         c5EwEe3H66C8ibZ+f92zLKwAW7IK91tfnWyTlePNUtQyD1q23HJcQfrPSLghRDszHzWM
         uBnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xr7bqCJiI54yGklJuDMTx+dj7QMK1lT6F8mLmTV+W30=;
        b=qwRomwcocW0z7xZTT/S6Vtcp+KGXgh/UobnWj9doy/NI4p58zP85NlKWJjQ1qPI49p
         E1U+rUpiDkvQvjlBttTOi/jzP8Z3Wg/B7KLZsweggYKrVyRWBYvXOBfM7l0PkKVXzUTh
         vKw8AYB6hgUuIBupZ9helElS3c1DD4sz9vk7aPZofPEvyPy741liLQ3F866RvJ6gPoOP
         YABJftvRQb/NxgzyMJVGAf7zXaSE9WUUC90wvT2fiY7voi4zLGAbCbwYhfpm0VXjF9Rl
         p6TZBuElLHfOjh/TkJ9wIk4MCxlqMtIhDfOMVbQpsJMCkrv+/yDWhHjeggqbBmEsG11K
         8h6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=a67LLsIq;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m5si5280999wrq.87.2019.02.12.04.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 04:29:38 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=a67LLsIq;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=xr7bqCJiI54yGklJuDMTx+dj7QMK1lT6F8mLmTV+W30=; b=a67LLsIqFy/WCGZTLMb8JVn22
	oNHRxicM5qqAeYh+/wVUQGDM47Kr7yO8goXG/vH+Gjd3/vacWRwmnx26ThvNn+keOik4il26F1O+F
	UXLF+tovYc+kG2OMiOcoJP9mBmh1teycVvrstW3ap4JblorozrGHF3pYid2/CiStj+q7J+xpc7qO7
	ewUorOH1Wos2yHu0qkLE6V6xCS8zcfoIvA7Rz9qpkptcNXEHeN4tjKu3rVdk/ox53/2MEjzhaey3q
	yeN3HdVOBCyX3dq8YHehFS6OsKsog6+z/n/Ja+ZzDXAZFaAIQKWuXwtd198eNdwQz+mRrQFzrRXOe
	aanWKjyGg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtXBp-00041n-QW; Tue, 12 Feb 2019 12:29:30 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 6085B23EB8AF7; Tue, 12 Feb 2019 13:29:26 +0100 (CET)
Date: Tue, 12 Feb 2019 13:29:26 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>,
	Linux Upstream <linux.upstream@oneplus.com>,
	Chintan Pandya <chintan.pandya@oneplus.com>,
	"hughd@google.com" <hughd@google.com>,
	"mawilcox@microsoft.com" <mawilcox@microsoft.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC 1/2] page-flags: Make page lock operation atomic
Message-ID: <20190212122926.GG32494@hirez.programming.kicks-ass.net>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
 <20190211125337.16099-2-chintan.pandya@oneplus.com>
 <20190211134607.GA32511@hirez.programming.kicks-ass.net>
 <364c7595-14f5-7160-d076-35a14c90375a@oneplus.com>
 <20190211174846.GM19029@quack2.suse.cz>
 <20190211175653.GE12668@bombadil.infradead.org>
 <20190212074535.GN19029@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212074535.GN19029@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 08:45:35AM +0100, Jan Kara wrote:
> On Mon 11-02-19 09:56:53, Matthew Wilcox wrote:
> > On Mon, Feb 11, 2019 at 06:48:46PM +0100, Jan Kara wrote:
> > > On Mon 11-02-19 13:59:24, Linux Upstream wrote:
> > > > > 
> > > > >> Signed-off-by: Chintan Pandya <chintan.pandya@oneplus.com>
> > > > > 
> > > > > NAK.
> > > > > 
> > > > > This is bound to regress some stuff. Now agreed that using non-atomic
> > > > > ops is tricky, but many are in places where we 'know' there can't be
> > > > > concurrency.
> > > > > 
> > > > > If you can show any single one is wrong, we can fix that one, but we're
> > > > > not going to blanket remove all this just because.
> > > > 
> > > > Not quite familiar with below stack but from crash dump, found that this
> > > > was another stack running on some other CPU at the same time which also
> > > > updates page cache lru and manipulate locks.
> > > > 
> > > > [84415.344577] [20190123_21:27:50.786264]@1 preempt_count_add+0xdc/0x184
> > > > [84415.344588] [20190123_21:27:50.786276]@1 workingset_refault+0xdc/0x268
> > > > [84415.344600] [20190123_21:27:50.786288]@1 add_to_page_cache_lru+0x84/0x11c
> > > > [84415.344612] [20190123_21:27:50.786301]@1 ext4_mpage_readpages+0x178/0x714
> > > > [84415.344625] [20190123_21:27:50.786313]@1 ext4_readpages+0x50/0x60
> > > > [84415.344636] [20190123_21:27:50.786324]@1 
> > > > __do_page_cache_readahead+0x16c/0x280
> > > > [84415.344646] [20190123_21:27:50.786334]@1 filemap_fault+0x41c/0x588
> > > > [84415.344655] [20190123_21:27:50.786343]@1 ext4_filemap_fault+0x34/0x50
> > > > [84415.344664] [20190123_21:27:50.786353]@1 __do_fault+0x28/0x88
> > > > 
> > > > Not entirely sure if it's racing with the crashing stack or it's simply
> > > > overrides the the bit set by case 2 (mentioned in 0/2).
> > > 
> > > So this is interesting. Looking at __add_to_page_cache_locked() nothing
> > > seems to prevent __SetPageLocked(page) in add_to_page_cache_lru() to get
> > > reordered into __add_to_page_cache_locked() after page is actually added to
> > > the xarray. So that one particular instance might benefit from atomic
> > > SetPageLocked or a barrier somewhere between __SetPageLocked() and the
> > > actual addition of entry into the xarray.
> > 
> > There's a write barrier when you add something to the XArray, by virtue
> > of the call to rcu_assign_pointer().
> 
> OK, I've missed rcu_assign_pointer(). Thanks for correction... but...
> rcu_assign_pointer() is __smp_store_release(&p, v) and that on x86 seems to
> be:
> 
>         barrier();                                                      \
>         WRITE_ONCE(*p, v);                                              \
> 
> which seems to provide a compiler barrier but not an SMP barrier? So is x86
> store ordering strong enough to make writes appear in the right order? So far
> I didn't think so... What am I missing?

X86 is TSO, and that is strong enough for this. The only visible
reordering on TSO is due to the store-buffer, that is: writes may happen
after later reads.

