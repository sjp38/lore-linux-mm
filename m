Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 68A8C6B0105
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 23:43:23 -0400 (EDT)
Message-ID: <4CCA42D0.5090603@redhat.com>
Date: Thu, 28 Oct 2010 23:43:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
References: <1288200090-23554-1-git-send-email-yinghan@google.com>	<4CC869F5.2070405@redhat.com>	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>	<AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>	<20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>	<AANLkTikdE---MJ-LSwNHEniCphvwu0T2apkWzGsRQ8i=@mail.gmail.com> <20101029114529.4d3a8b9c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101029114529.4d3a8b9c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ken Chen <kenchen@google.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10/28/2010 10:45 PM, KAMEZAWA Hiroyuki wrote:

> Hmm. Without flushing anywhere in memory reclaim path, a process which
> cause page fault and enter vmscan will not see his own recent access bit on
> pages in LRU ?

Worse still, because kernel threads do a lazy mmu switch, even
page faulting in the process will not cause the TLB entries to
be flushed.

> I think it should be flushed at least once..

A periodic flush may make sense.

Maybe something along the lines of if the TLB has not been
flushed for over a second (we can see that in timer or scheduler
code), flush it?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
