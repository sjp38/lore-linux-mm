Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C29275F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 05:32:40 -0400 (EDT)
Message-ID: <49E5A9DC.2050309@inria.fr>
Date: Wed, 15 Apr 2009 11:33:16 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH] migration: only migrate_prep() once per move_pages()
References: <49E58D7A.4010708@ens-lyon.org> <20090415164955.41746866.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090415164955.41746866.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 15 Apr 2009 09:32:10 +0200
> Brice Goglin <Brice.Goglin@ens-lyon.org> wrote:
>
>   
>> migrate_prep() is fairly expensive (72us on 16-core barcelona 1.9GHz).
>> Commit 3140a2273009c01c27d316f35ab76a37e105fdd8 improved move_pages()
>> throughput by breaking it into chunks, but it also made migrate_prep()
>> be called once per chunk (every 128pages or so) instead of once per
>> move_pages().
>>
>> This patch reverts to calling migrate_prep() only once per chunk
>> as we did before 2.6.29.
>> It is also a followup to commit 0aedadf91a70a11c4a3e7c7d99b21e5528af8d5d
>>     mm: move migrate_prep out from under mmap_sem
>>
>> This improves migration throughput on the above machine from 600MB/s
>> to 750MB/s.
>>
>> Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
>>
>>     
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> I think this patch is good. page migration is best-effort syscall ;)
>   

My next feeling now is about improving migrate_prep() itself. It makes
the move_pages() startup overhead very high.

But lru_add_drain_all() touches some code that I am far from
understanding :/ Can we imagine using IPI instead of a deferred
work_struct for this kind of things? Or maybe, for each processor, check
whether drain_cpu_pagevecs() would have something to do before actually
scheduling the local work_struct? It's racy, but migrate_prep() doesn't
guarantee anyway that pages won't be moved out of the LRU before the
actual migration, so...

Also I don't see why the cost of lru_add_drain_all() seems to increase
linearly with the number of cores in the machine. There may be some lock
contention, but it should scale better when there's pretty-much nothing
in the CPU lists...

> BTW, current users of sys_move_pages() does retry when it gets -EBUSY ?
>   

I'd say they ignore it since it doesn't happen often :)

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
