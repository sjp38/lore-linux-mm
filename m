Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7656B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 05:31:01 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so3747435wib.12
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:30:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ky5si22353577wjb.143.2014.06.23.02.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 02:30:55 -0700 (PDT)
Date: Mon, 23 Jun 2014 11:30:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 12/13] mm: memcontrol: rewrite charge API
Message-ID: <20140623093052.GG9743@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-13-git-send-email-hannes@cmpxchg.org>
 <20140623061526.GH13440@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140623061526.GH13440@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel@pengutronix.de

On Mon 23-06-14 08:15:26, Uwe Kleine-Konig wrote:
> Hello,
> 
> On Wed, Jun 18, 2014 at 04:40:44PM -0400, Johannes Weiner wrote:
> > The memcg charge API charges pages before they are rmapped - i.e. have
> > an actual "type" - and so every callsite needs its own set of charge
> > and uncharge functions to know what type is being operated on.  Worse,
> > uncharge has to happen from a context that is still type-specific,
> > rather than at the end of the page's lifetime with exclusive access,
> > and so requires a lot of synchronization.
> > ...
> 
> this patch made it into next-20140623 as 5e49555277df (mm: memcontrol: rewrite
> charge API) and it makes efm32_defconfig (ARCH=arm) fail with:
> 
>   CC      mm/swap.o
> mm/swap.c: In function 'lru_cache_add_active_or_unevictable':
> mm/swap.c:719:2: error: implicit declaration of function 'TestSetPageMlocked' [-Werror=implicit-function-declaration]
>   if (!TestSetPageMlocked(page)) {
>   ^
> cc1: some warnings being treated as errors
> scripts/Makefile.build:257: recipe for target 'mm/swap.o' failed
> make[3]: *** [mm/swap.o] Error 1
> Makefile:1471: recipe for target 'mm/swap.o' failed
> 
> imx_v4_v5_defconfig works, so probably the thing that makes
> efm32_defconfig fail is CONFIG_MMU=n.

Fix is here:
http://marc.info/?l=linux-mm&m=140330132521104

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
