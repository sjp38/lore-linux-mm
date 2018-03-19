Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 334F96B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 06:55:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y20so9480131pfm.1
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 03:55:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t28si10412532pfk.187.2018.03.19.03.55.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Mar 2018 03:55:20 -0700 (PDT)
Date: Mon, 19 Mar 2018 11:55:17 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm: Warn on lock_page() from reclaim context.
Message-ID: <20180319105517.GX23100@dhcp22.suse.cz>
References: <1521295866-9670-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180317155437.pcbeigeivn4a23gt@node.shutemov.name>
 <201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
 <20180319090419.GR23100@dhcp22.suse.cz>
 <20180319101440.6xe5ixd5nn4zrvl2@node.shutemov.name>
 <20180319103336.GU23100@dhcp22.suse.cz>
 <20180319104502.n524uvuvjze3hbdz@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180319104502.n524uvuvjze3hbdz@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Mon 19-03-18 13:45:02, Kirill A. Shutemov wrote:
> On Mon, Mar 19, 2018 at 11:33:36AM +0100, Michal Hocko wrote:
> > On Mon 19-03-18 13:14:40, Kirill A. Shutemov wrote:
> > > On Mon, Mar 19, 2018 at 10:04:19AM +0100, Michal Hocko wrote:
> > > > On Sun 18-03-18 10:22:49, Tetsuo Handa wrote:
> > > > > >From f43b8ca61b76f9a19c13f6bf42b27fad9554afc0 Mon Sep 17 00:00:00 2001
> > > > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > > Date: Sun, 18 Mar 2018 10:18:01 +0900
> > > > > Subject: [PATCH v2] mm: Warn on lock_page() from reclaim context.
> > > > > 
> > > > > Kirill A. Shutemov noticed that calling lock_page[_killable]() from
> > > > > reclaim context might cause deadlock. In order to help finding such
> > > > > lock_page[_killable]() users (including out of tree users), this patch
> > > > > emits warning messages when CONFIG_PROVE_LOCKING is enabled.
> > > > 
> > > > So how do you ensure that this won't cause false possitives? E.g. do we
> > > > ever allocate while holding the page lock and not having the page on the
> > > > LRU list?
> > > 
> > > Hm. Do we even have a reason to lock such pages?
> > > Probably we do, but I cannot come up with an example.
> > 
> > Page lock is way too obscure to be sure :/
> > Anyway, maybe we want to be more conservative and only warn about LRU
> > pages...
> 
> I would rather see what we actually step onto. Sometimes false-positive
> warning may bring useful insight.
> 
> Maybe keep in in mm- tree for few cycles? (If it wouldn't blow up
> immediately)

I would be OK to keep it in mmotm for some time. But I am not yet
convinced this is a mainline material yet. Please also note that we have
some PF_MEMALLOC (ab)users outside of the MM proper and thy use the flag
to break into reserves and I wouldn't be all that surprised if they id
lock_page as well.
-- 
Michal Hocko
SUSE Labs
