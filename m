Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 512396B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 09:09:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t19-v6so5312504plo.9
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 06:09:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4-v6si6519906pgf.169.2018.06.15.06.09.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jun 2018 06:09:29 -0700 (PDT)
Date: Fri, 15 Jun 2018 15:09:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
Message-ID: <20180615130925.GI24039@dhcp22.suse.cz>
References: <1528790608-19557-1-git-send-email-jing.xia@unisoc.com>
 <20180612212007.GA22717@redhat.com>
 <alpine.LRH.2.02.1806131001250.15845@file01.intranet.prod.int.rdu2.redhat.com>
 <CAN=25QMQiJ7wvfvYvmZnEnrkeb-SA7_hPj+N2RnO8y-aVO8wOQ@mail.gmail.com>
 <20180614073153.GB9371@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615073201.GB24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615115547.GH24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 15-06-18 08:47:52, Mikulas Patocka wrote:
> 
> 
> On Fri, 15 Jun 2018, Michal Hocko wrote:
> 
> > On Fri 15-06-18 07:35:07, Mikulas Patocka wrote:
> > > 
> > > Because mempool uses it. Mempool uses allocations with "GFP_NOIO | 
> > > __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN". An so dm-bufio uses 
> > > these flags too. dm-bufio is just a big mempool.
> > 
> > This doesn't answer my question though. Somebody else is doing it is not
> > an explanation. Prior to your 41c73a49df31 there was no GFP_NOIO
> > allocation AFAICS. So why do you really need it now? Why cannot you
> 
> dm-bufio always used "GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | 
> __GFP_NOWARN" since the kernel 3.2 when it was introduced.
> 
> In the kernel 4.10, dm-bufio was changed so that it does GFP_NOWAIT 
> allocation, then drops the lock and does GFP_NOIO with the dropped lock 
> (because someone was likely experiencing the same issue that is reported 
> in this thread) - there are two commits that change it - 9ea61cac0 and 
> 41c73a49df31.

OK, I see. Is there any fundamental reason why this path has to do one
round of GFP_IO or it can keep NOWAIT, drop the lock, sleep and retry
again?

[...]
> > is the same class of problem, honestly, I dunno. And I've already said
> > that stalling __GFP_NORETRY might be a good way around that but that
> > needs much more consideration and existing users examination. I am not
> > aware anybody has done that. Doing changes like that based on a single
> > user is certainly risky.
> 
> Why don't you set any rules how these flags should be used?

It is really hard to change rules during the game. You basically have to
examine all existing users and that is well beyond my time scope. I've
tried that where it was possible. E.g. __GFP_REPEAT and turned it into a
well defined semantic. __GFP_NORETRY is a bigger beast.

Anyway, I believe that it would be much safer to look at the problem
from a highlevel perspective. You seem to be focused on __GFP_NORETRY
little bit too much IMHO. We are not throttling callers which explicitly
do not want to or cannot - see current_may_throttle. Is it possible that
both your md and mempool allocators can either (ab)use PF_LESS_THROTTLE
or use other means? E.g. do you have backing_dev_info at that time?
-- 
Michal Hocko
SUSE Labs
