Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1FEFF6B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 08:04:09 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id f32-v6so9870618otc.13
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 05:04:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t45si307483otf.353.2018.03.19.05.04.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 05:04:02 -0700 (PDT)
Subject: Re: [PATCH v2] mm: Warn on lock_page() from reclaim context.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180319090419.GR23100@dhcp22.suse.cz>
	<20180319101440.6xe5ixd5nn4zrvl2@node.shutemov.name>
	<20180319103336.GU23100@dhcp22.suse.cz>
	<20180319104502.n524uvuvjze3hbdz@node.shutemov.name>
	<20180319105517.GX23100@dhcp22.suse.cz>
In-Reply-To: <20180319105517.GX23100@dhcp22.suse.cz>
Message-Id: <201803192104.DAG43292.MJFHOLOSFtVQOF@I-love.SAKURA.ne.jp>
Date: Mon, 19 Mar 2018 21:04:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

Michal Hocko wrote:
> On Mon 19-03-18 13:45:02, Kirill A. Shutemov wrote:
> > On Mon, Mar 19, 2018 at 11:33:36AM +0100, Michal Hocko wrote:
> > > On Mon 19-03-18 13:14:40, Kirill A. Shutemov wrote:
> > > > On Mon, Mar 19, 2018 at 10:04:19AM +0100, Michal Hocko wrote:
> > > > > On Sun 18-03-18 10:22:49, Tetsuo Handa wrote:
> > > > > > >From f43b8ca61b76f9a19c13f6bf42b27fad9554afc0 Mon Sep 17 00:00:00 2001
> > > > > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > > > Date: Sun, 18 Mar 2018 10:18:01 +0900
> > > > > > Subject: [PATCH v2] mm: Warn on lock_page() from reclaim context.
> > > > > > 
> > > > > > Kirill A. Shutemov noticed that calling lock_page[_killable]() from
> > > > > > reclaim context might cause deadlock. In order to help finding such
> > > > > > lock_page[_killable]() users (including out of tree users), this patch
> > > > > > emits warning messages when CONFIG_PROVE_LOCKING is enabled.
> > > > > 
> > > > > So how do you ensure that this won't cause false possitives? E.g. do we
> > > > > ever allocate while holding the page lock and not having the page on the
> > > > > LRU list?
> > > > 
> > > > Hm. Do we even have a reason to lock such pages?
> > > > Probably we do, but I cannot come up with an example.
> > > 
> > > Page lock is way too obscure to be sure :/
> > > Anyway, maybe we want to be more conservative and only warn about LRU
> > > pages...
> > 
> > I would rather see what we actually step onto. Sometimes false-positive
> > warning may bring useful insight.
> > 
> > Maybe keep in in mm- tree for few cycles? (If it wouldn't blow up
> > immediately)
> 
> I would be OK to keep it in mmotm for some time. But I am not yet
> convinced this is a mainline material yet. Please also note that we have
> some PF_MEMALLOC (ab)users outside of the MM proper and thy use the flag
> to break into reserves and I wouldn't be all that surprised if they id
> lock_page as well.

I don't know who is doing such thing. But if the purpose of abusing PF_MEMALLOC
is "not to block the current thread" by allowing memory reserves, I think it is
better to warn locations (like lock_page()) which might be unexpectedly blocked
due to invisible dependency.
