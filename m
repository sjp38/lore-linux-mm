Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id F35C46B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:03:00 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id n15so2327385lbi.11
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 00:03:00 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id j4si33354835lbn.98.2014.10.16.00.02.58
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 00:02:59 -0700 (PDT)
Date: Thu, 16 Oct 2014 10:02:57 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <20141014.173246.921084057467310731.davem@davemloft.net>
Message-ID: <alpine.LRH.2.11.1410160956090.13273@adalberg.ut.ee>
References: <20141013235219.GA11191@js1304-P5Q-DELUXE> <20141013.200416.641735303627599182.davem@davemloft.net> <alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee> <20141014.173246.921084057467310731.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> >> > I'd like to know that your another problem is related to commit
> >> > bf0dea23a9c0 ("mm/slab: use percpu allocator for cpu cache").  So,
> >> > if the commit is reverted, your another problem is also gone
> >> > completely?
> >> 
> >> The other problem has been present forever.
> > 
> > Umm? I am afraid I have been describing it badly. This random 
> > SIGBUS+SIGSEGV problem is new - I have not seen it before.
> 
> Sorry, I thought it was the same bug that causes git corruptions
> for you.  I misunderstood.
> 
> > I have been able to do kernel compiles for years on sparc64 (modulo 
> > specific bugs in specific configurations) and 3.17 + start/end swap 
> > patch seems also stable for most machine. With yesterdays git + align 
> > patch, it dies with SIGBUS multiple times during compilation so it's a 
> > new regression for me.
> > 
> > Will try reverting that commit tomorrow.
> 
> If that fails, please try to bisect, it will help us a lot.

Commit bf0dea23a9c0 is working OK with no revert needed (checked out 
this revision and it tested OK).

So far I know that the breakage seems to have happened between
cadbb58039f7cab1def9c931012ab04c953a6997 (first sparc commit of 
the batch, working OK on V100) and 
bdcf81b658ebc4c2640c3c2c55c8b31c601b6996 (last sparc commit before the 
merge, breaks on E3500). Will continue bisecting the sparc64 commits.

Also, I noticed that when the problem happens, it's deterministic - with 
some kernels, sshd dies reproducibly on login. With most kernels, 
building kernel breaks in one specific location, not randomly.

scripts/Makefile.build:352: recipe for target 'sound/modules.order' failed
make[1]: *** [sound/modules.order] Bus error
make[1]: *** Deleting file 'sound/modules.order'
Makefile:929: recipe for target 'sound' failed

Will tell when I get more details.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
