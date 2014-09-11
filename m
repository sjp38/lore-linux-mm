Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A03BA6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:04:59 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id k14so4881998wgh.24
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:04:59 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id az8si4857394wib.60.2014.09.11.01.04.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 01:04:58 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id ho1so507127wib.17
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:04:57 -0700 (PDT)
Date: Thu, 11 Sep 2014 10:04:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/compaction: Fix warning of 'flags' may be used
 uninitialized
Message-ID: <20140911080455.GA22047@dhcp22.suse.cz>
References: <1410329540-40708-1-git-send-email-Li.Xiubo@freescale.com>
 <alpine.DEB.2.02.1409101149500.27173@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1409101149500.27173@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Xiubo Li <Li.Xiubo@freescale.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, linux-mm@kvack.org

On Wed 10-09-14 11:50:41, David Rientjes wrote:
> On Wed, 10 Sep 2014, Xiubo Li wrote:
> 
> > C      mm/compaction.o
> > mm/compaction.c: In function isolate_freepages_block:
> > mm/compaction.c:364:37: warning: flags may be used uninitialized in
> > this function [-Wmaybe-uninitialized]
> >        && compact_unlock_should_abort(&cc->zone->lock, flags,
> >                                      ^
> > In file included from include/linux/irqflags.h:15:0,
> >                  from ./arch/arm/include/asm/bitops.h:27,
> >                  from include/linux/bitops.h:33,
> >                  from include/linux/kernel.h:10,
> >                  from include/linux/list.h:8,
> >                  from include/linux/preempt.h:10,
> >                  from include/linux/spinlock.h:50,
> >                  from include/linux/swap.h:4,
> >                  from mm/compaction.c:10:
> > mm/compaction.c: In function isolate_migratepages_block:
> > ./arch/arm/include/asm/irqflags.h:152:2: warning: flags may be used
> > uninitialized in this function [-Wmaybe-uninitialized]
> >   asm volatile(
> >   ^
> > mm/compaction.c:576:16: note: flags as declared here
> >   unsigned long flags;
> >                 ^
> > 
> > Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
> 
> Arnd Bergmann already sent a patch for this to use uninitialized_var() 
> privately but it didn't get cc'd to any mailing list, sorry.

Besides that setting flags to 0 is certainly a misleading way to fix
this issue. uninitialized_var is a correct way because the warning is a
false possitive. compact_unlock_should_abort will not touch the flags if
locked is false and this is true only after a lock has been taken and
flags set. (this should be preferably in the patch description).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
