Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 251826B0036
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:15:39 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so6376684wes.1
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 23:15:38 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:6f8:1178:4:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id co16si19263667wjb.120.2014.06.22.23.15.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Jun 2014 23:15:38 -0700 (PDT)
Date: Mon, 23 Jun 2014 08:15:26 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [patch 12/13] mm: memcontrol: rewrite charge API
Message-ID: <20140623061526.GH13440@pengutronix.de>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-13-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1403124045-24361-13-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel@pengutronix.de

Hello,

On Wed, Jun 18, 2014 at 04:40:44PM -0400, Johannes Weiner wrote:
> The memcg charge API charges pages before they are rmapped - i.e. have
> an actual "type" - and so every callsite needs its own set of charge
> and uncharge functions to know what type is being operated on.  Worse,
> uncharge has to happen from a context that is still type-specific,
> rather than at the end of the page's lifetime with exclusive access,
> and so requires a lot of synchronization.
> ...

this patch made it into next-20140623 as 5e49555277df (mm: memcontrol: rewrite
charge API) and it makes efm32_defconfig (ARCH=arm) fail with:

  CC      mm/swap.o
mm/swap.c: In function 'lru_cache_add_active_or_unevictable':
mm/swap.c:719:2: error: implicit declaration of function 'TestSetPageMlocked' [-Werror=implicit-function-declaration]
  if (!TestSetPageMlocked(page)) {
  ^
cc1: some warnings being treated as errors
scripts/Makefile.build:257: recipe for target 'mm/swap.o' failed
make[3]: *** [mm/swap.o] Error 1
Makefile:1471: recipe for target 'mm/swap.o' failed

imx_v4_v5_defconfig works, so probably the thing that makes
efm32_defconfig fail is CONFIG_MMU=n.

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
