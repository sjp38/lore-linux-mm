Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAFAF6B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 08:47:54 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p12-v6so7424671qtg.5
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 05:47:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c138-v6si7641390qka.130.2018.06.15.05.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 05:47:53 -0700 (PDT)
Date: Fri, 15 Jun 2018 08:47:52 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
In-Reply-To: <20180615115547.GH24039@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
References: <1528790608-19557-1-git-send-email-jing.xia@unisoc.com> <20180612212007.GA22717@redhat.com> <alpine.LRH.2.02.1806131001250.15845@file01.intranet.prod.int.rdu2.redhat.com> <CAN=25QMQiJ7wvfvYvmZnEnrkeb-SA7_hPj+N2RnO8y-aVO8wOQ@mail.gmail.com>
 <20180614073153.GB9371@dhcp22.suse.cz> <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com> <20180615073201.GB24039@dhcp22.suse.cz> <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615115547.GH24039@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On Fri, 15 Jun 2018, Michal Hocko wrote:

> On Fri 15-06-18 07:35:07, Mikulas Patocka wrote:
> > 
> > Because mempool uses it. Mempool uses allocations with "GFP_NOIO | 
> > __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN". An so dm-bufio uses 
> > these flags too. dm-bufio is just a big mempool.
> 
> This doesn't answer my question though. Somebody else is doing it is not
> an explanation. Prior to your 41c73a49df31 there was no GFP_NOIO
> allocation AFAICS. So why do you really need it now? Why cannot you

dm-bufio always used "GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | 
__GFP_NOWARN" since the kernel 3.2 when it was introduced.

In the kernel 4.10, dm-bufio was changed so that it does GFP_NOWAIT 
allocation, then drops the lock and does GFP_NOIO with the dropped lock 
(because someone was likely experiencing the same issue that is reported 
in this thread) - there are two commits that change it - 9ea61cac0 and 
41c73a49df31.

> simply keep retrying GFP_NOWAIT with your own throttling?
> 
> Note that I am not trying to say that 41c73a49df31, I am merely trying
> to understand why this blocking allocation is done in the first place.
>  
> > If you argue that these flags are incorrect - then fix mempool_alloc.
> 
> AFAICS there is no report about mempool_alloc stalling here. Maybe this

If the page allocator can stall dm-bufio, it can stall mempool_alloc as 
well. dm-bufio is just bigger, so it will hit this bug sooner.

> is the same class of problem, honestly, I dunno. And I've already said
> that stalling __GFP_NORETRY might be a good way around that but that
> needs much more consideration and existing users examination. I am not
> aware anybody has done that. Doing changes like that based on a single
> user is certainly risky.

Why don't you set any rules how these flags should be used?

If you use GFP_NOIO | __GFP_NORETRY in your own code and blame other 
people for doing so - you are as much evil as Linus, who praised people 
for reverse-engineering hardware and blamed them for reverse-engineering 
bitkeeper :-)

Mikulas
