Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 498476B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:42:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a141so1980749wma.8
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:42:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z68si2145951wrb.354.2017.11.29.13.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 13:42:03 -0800 (PST)
Date: Wed, 29 Nov 2017 13:41:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-Id: <20171129134159.c9100ea6dacad870d69929b7@linux-foundation.org>
In-Reply-To: <20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
	<20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
	<20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: JianKang Chen <chenjiankang1@huawei.com>, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Wed, 29 Nov 2017 17:04:46 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 27-11-17 12:33:41, Michal Hocko wrote:
> > On Mon 27-11-17 19:09:24, JianKang Chen wrote:
> > > From: Jiankang Chen <chenjiankang1@huawei.com>
> > > 
> > > __get_free_pages will return an virtual address, 
> > > but it is not just 32-bit address, for example a 64-bit system. 
> > > And this comment really confuse new bigenner of mm.
> > 
> > s@bigenner@beginner@
> > 
> > Anyway, do we really need a bug on for this? Has this actually caught
> > any wrong usage? VM_BUG_ON tends to be enabled these days AFAIK and
> > panicking the kernel seems like an over-reaction. If there is a real
> > risk then why don't we simply mask __GFP_HIGHMEM off when calling
> > alloc_pages?
> 
> I meant this
> ---
> >From 000bb422fe07adbfa8cd8ed953b18f48647a45d6 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 29 Nov 2017 17:02:33 +0100
> Subject: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
> 
> There is no real reason to blow up just because the caller doesn't know
> that __get_free_pages cannot return highmem pages. Simply fix that up
> silently. Even if we have some confused users such a fixup will not be
> harmful.

mm...  So we have a caller which hopes to be getting highmem pages but
isn't.  Caller then proceeds to pointlessly kmap the page and wonders
why it isn't getting as much memory as it would like on 32-bit systems,
etc.

I do think we should help ferret out such bogosity.  A WARN_ON_ONCE
would suffice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
