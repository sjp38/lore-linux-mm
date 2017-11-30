Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E76366B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 01:53:40 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i14so3742643pgf.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 22:53:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q70si2724548pfa.284.2017.11.29.22.53.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 22:53:39 -0800 (PST)
Date: Thu, 30 Nov 2017 07:53:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-ID: <20171130065335.zno7peunnl2zpozq@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
 <20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
 <20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
 <20171129134159.c9100ea6dacad870d69929b7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129134159.c9100ea6dacad870d69929b7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: JianKang Chen <chenjiankang1@huawei.com>, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Wed 29-11-17 13:41:59, Andrew Morton wrote:
> On Wed, 29 Nov 2017 17:04:46 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Mon 27-11-17 12:33:41, Michal Hocko wrote:
> > > On Mon 27-11-17 19:09:24, JianKang Chen wrote:
> > > > From: Jiankang Chen <chenjiankang1@huawei.com>
> > > > 
> > > > __get_free_pages will return an virtual address, 
> > > > but it is not just 32-bit address, for example a 64-bit system. 
> > > > And this comment really confuse new bigenner of mm.
> > > 
> > > s@bigenner@beginner@
> > > 
> > > Anyway, do we really need a bug on for this? Has this actually caught
> > > any wrong usage? VM_BUG_ON tends to be enabled these days AFAIK and
> > > panicking the kernel seems like an over-reaction. If there is a real
> > > risk then why don't we simply mask __GFP_HIGHMEM off when calling
> > > alloc_pages?
> > 
> > I meant this
> > ---
> > >From 000bb422fe07adbfa8cd8ed953b18f48647a45d6 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 29 Nov 2017 17:02:33 +0100
> > Subject: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
> > 
> > There is no real reason to blow up just because the caller doesn't know
> > that __get_free_pages cannot return highmem pages. Simply fix that up
> > silently. Even if we have some confused users such a fixup will not be
> > harmful.
> 
> mm...  So we have a caller which hopes to be getting highmem pages but
> isn't.  Caller then proceeds to pointlessly kmap the page and wonders
> why it isn't getting as much memory as it would like on 32-bit systems,
> etc.

How he can kmap the page when he gets a _virtual_ address?

> I do think we should help ferret out such bogosity.  A WARN_ON_ONCE
> would suffice.

This function has always been about lowmem pages. I seriously doubt we
have anybody confused and asking for a highmem page in the kernel. I
haven't checked that but it would already blow up as VM_BUG_ON tends to
be enabled on many setups.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
