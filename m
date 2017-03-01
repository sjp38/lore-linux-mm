Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B08146B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 11:05:32 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w37so18789714wrc.2
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 08:05:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l4si1496650wmb.49.2017.03.01.08.05.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 08:05:31 -0800 (PST)
Date: Wed, 1 Mar 2017 17:05:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] lockdep: Teach lockdep about memalloc_noio_save
Message-ID: <20170301160529.GI11730@dhcp22.suse.cz>
References: <1488367797-27278-1-git-send-email-nborisov@suse.com>
 <20170301154659.GL6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170301154659.GL6515@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nikolay Borisov <nborisov@suse.com>, linux-kernel@vger.kernel.org, vbabka.lkml@gmail.com, linux-mm@kvack.org, mingo@redhat.com

On Wed 01-03-17 16:46:59, Peter Zijlstra wrote:
> On Wed, Mar 01, 2017 at 01:29:57PM +0200, Nikolay Borisov wrote:
> > Commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O
> > during memory allocation") added the memalloc_noio_(save|restore) functions
> > to enable people to modify the MM behavior by disbaling I/O during memory
> > allocation. This was further extended in Fixes: 934f3072c17c ("mm: clear 
> > __GFP_FS when PF_MEMALLOC_NOIO is set"). memalloc_noio_* functions prevent 
> > allocation paths recursing back into the filesystem without explicitly 
> > changing the flags for every allocation site. However, lockdep hasn't been 
> > keeping up with the changes and it entirely misses handling the memalloc_noio
> > adjustments. Instead, it is left to the callers of __lockdep_trace_alloc to 
> > call the functino after they have shaven the respective GFP flags. 
> > 
> > Let's fix this by making lockdep explicitly do the shaving of respective
> > GFP flags. 
> 
> I edited that to look like the below, then my compiler said:
> 
> ../kernel/locking/lockdep.c: In function a??lockdep_set_current_reclaim_statea??:
> ../kernel/locking/lockdep.c:3866:33: error: implicit declaration of function a??memalloc_noio_flagsa?? [-Werror=implicit-function-declaration]
>   current->lockdep_reclaim_gfp = memalloc_noio_flags(gfp_mask);
>                                  ^~~~~~~~~~~~~~~~~~~
> cc1: some warnings being treated as errors
> ../scripts/Makefile.build:294: recipe for target 'kernel/locking/lockdep.o' failed

It did compile for me
$ grep CONFIG_LOCKDEP .config
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_LOCKDEP=y

Anyway, does the following help?
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 47e4f82380e4..d5386ad7ed3f 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -47,6 +47,7 @@
 #include <linux/kmemcheck.h>
 #include <linux/random.h>
 #include <linux/jhash.h>
+#include <linux/sched.h>
 
 #include <asm/sections.h>
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
