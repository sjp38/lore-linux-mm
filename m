Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D44436B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 07:10:35 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Wed, 3 Feb 2010 13:10:27 +0100
References: <201002012302.37380.l.lunak@suse.cz> <20100203085711.GF19641@balbir.in.ibm.com>
In-Reply-To: <20100203085711.GF19641@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002031310.28271.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wednesday 03 of February 2010, Balbir Singh wrote:
> * Lubos Lunak <l.lunak@suse.cz> [2010-02-01 23:02:37]:
> >  In other words, use VmRSS for measuring memory usage instead of VmSize,
> > and remove child accumulating.
>
> I am not sure of the impact of changing to RSS, although I've
> personally believed that RSS based accounting is where we should go,
> but we need to consider the following
>
> 1. Total VM provides data about potentially swapped pages,

 Yes, I've already updated my proposal in another mail to switch from VmSize 
to VmRSS+InSwap. I don't know how to find out the second item in code, but at 
this point of discussion that's just details.

> overcommit, 

 I don't understand how this matters. Overcommit is memory for which address 
space has been allocated but not actual memory, right? Then that's exactly 
what I'm claiming is wrong and am trying to reverse. Currently OOM killer 
takes this into account because it uses VmSize, but IMO it shouldn't - if a 
process does malloc(400M) but then it uses only a tiny fraction of that, in 
the case of memory shortage killing that process does not solve anything in 
practice.

> etc.
> 2. RSS alone is not sufficient, RSS does not account for shared pages,
> so we ideally need something like PSS.

 Just to make sure I understand what you mean with "RSS does not account for 
shared pages" - you say that if a page is shared by 4 processes, then when 
calculating badness for them, only 1/4 of the page should be counted for 
each? Yes, I suppose so, that makes sense. That's more like fine-tunning at 
this point though, as long as there's no agreement that moving away from 
VmSize is an improvement.

> I suspect the correct answer would depend on our answers to 1 and 2
> and a lot of testing with any changes made.

 Testing - are there actually any tests for it, or do people just test random 
scenarios when they do changes? Also, I'm curious, what areas is the OOM 
killer actually generally known to work well in? I somehow get the feeling 
from the discussion here that people just tweak oom_adj until it works for 
them.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
