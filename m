Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 65C916B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 03:27:44 -0400 (EDT)
Subject: Re: [PATCH 4/5] Use add_page_to_lru_list() helper function
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090720143352.747E.A69D9226@jp.fujitsu.com>
References: <20090716173921.9D54.A69D9226@jp.fujitsu.com>
	 <1247833128.15751.41.camel@twins>
	 <20090720143352.747E.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 20 Jul 2009 09:28:31 +0200
Message-Id: <1248074911.15751.8023.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-07-20 at 14:37 +0900, KOSAKI Motohiro wrote:
> > > @@ -1241,7 +1241,6 @@ static void move_active_pages_to_lru(str
> > >  			spin_lock_irq(&zone->lru_lock);
> > >  		}
> > >  	}
> > > -	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> > >  	if (!is_active_lru(lru))
> > >  		__count_vm_events(PGDEACTIVATE, pgmoved);
> > >  }
> > 
> > This is a net loss, you introduce pgmoved calls to __inc_zone_state,
> > instead of the one __mod_zone_page_state() call.
> 
> max pgmoved is 32. 32 times __inc_zone_state() make 0 or 1 time
> atomic operation (not much than two).
> I don't think it reduce performance.

its not just atomics, count calls and branches too. It simply adds a ton
of code for no particular reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
