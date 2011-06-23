Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 71A96900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:30:09 -0400 (EDT)
Date: Thu, 23 Jun 2011 16:30:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 7/7] memcg: proportional fair vicitm node selection
Message-ID: <20110623143005.GL31593@tiehlicka.suse.cz>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616125741.c3d6a802.kamezawa.hiroyu@jp.fujitsu.com>
 <20110623134850.GK31593@tiehlicka.suse.cz>
 <BANLkTin0zMftnK2a+ex07JNdbwvEMCjXXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTin0zMftnK2a+ex07JNdbwvEMCjXXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu 23-06-11 23:10:11, Hiroyuki Kamezawa wrote:
> 2011/6/23 Michal Hocko <mhocko@suse.cz>:
> > On Thu 16-06-11 12:57:41, KAMEZAWA Hiroyuki wrote:
> >> From 4fbd49697456c227c86f1d5b46f2cd2169bf1c5b Mon Sep 17 00:00:00 2001
> >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> Date: Thu, 16 Jun 2011 11:25:23 +0900
> >> Subject: [PATCH 7/7] memcg: proportional fair node vicitm selection
> >>
> >> commit 889976 implements a round-robin scan of numa nodes for
> >> LRU scanning of memcg at hitting limit.
> >> But, round-robin is not very good.
> >>
> >> This patch implements a proportionally fair victim selection of nodes
> >> rather than round-robin. The logic is fair against each node's weight.
> >>
> >> Each node's weight is calculated periodically and we build an node's
> >> scheduling entity as
> >>
> >>      total_ticket = 0;
> >>      for_each_node(node)
> >>       node->ticket_start =  total_ticket;
> >>         node->ticket_end   =  total_ticket + this_node's_weight()
> >>         total_ticket = node->ticket_end;
> >>
> >> Then, each nodes has some amounts of tickets in proportion to its own weight.
> >>
> >> At selecting victim, a random number is selected and the node which contains
> >> the random number in [ticket_start, ticket_end) is selected as vicitm.
> >> This is a lottery scheduling algorithm.
> >>
> >> For quick search of victim, this patch uses bsearch().
> >>
> >> Test result:
> >>   on 8cpu box with 2 nodes.
> >>   limit memory to be 300MB and run httpd for 4096files/600MB working set.
> >>   do (normalized) random access by apache-bench and see scan_stat.
> >>   The test makes 40960 request. and see scan_stat.
> >>   (Because a httpd thread just use 10% cpu, the number of threads will
> >>    not be balanced between nodes. Then, file caches will not be balanced
> >>    between nodes.)
> >
> > Have you also tried to test with balanced nodes? I mean, is there any
> > measurable overhead?
> >
> 
> Not enough yet. I checked OOM trouble this week :).
> 
> I may need to make another fake_numa setup + cpuset
> to measurements. 

What if you just use NUMA rotor for page cache?

> In usual path, new overhead is random32() and
> bsearch().  I'll do some.
> 
> Thanks,
> -Kame

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
