Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EC92F6B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 02:10:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 67AE43EE081
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:10:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4523545DE4F
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:10:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AC4945DE53
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:10:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B82D1DB8048
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:10:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC5651DB8043
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 15:10:26 +0900 (JST)
Date: Wed, 20 Jul 2011 15:03:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] memcg: add vmscan_stat
Message-Id: <20110720150316.181f1977.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAL1qeaGC51POaL7PW9LK7Ke6CZt-hE8qJ3QSHu+2jaermCjuKQ@mail.gmail.com>
References: <20110711193036.5a03858d.kamezawa.hiroyu@jp.fujitsu.com>
	<CAL1qeaGC51POaL7PW9LK7Ke6CZt-hE8qJ3QSHu+2jaermCjuKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Bresticker <abrestic@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Mon, 18 Jul 2011 14:00:32 -0700
Andrew Bresticker <abrestic@google.com> wrote:

> On Mon, Jul 11, 2011 at 3:30 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
                       spin_unlock_irq(&zone->lru_lock);
> > @@ -1350,6 +1353,10 @@ static noinline_for_stack void update_is
> >
> >        reclaim_stat->recent_scanned[0] += *nr_anon;
> >        reclaim_stat->recent_scanned[1] += *nr_file;
> > +       if (!scanning_global_lru(sc)) {
> > +               sc->memcg_record->nr_scanned[0] += *nr_anon;
> > +               sc->memcg_record->nr_scanned[1] += *nr_file;
> > +       }
> >  }
> >
> >  /*
> > @@ -1457,6 +1464,9 @@ shrink_inactive_list(unsigned long nr_to
> >
> >        nr_reclaimed = shrink_page_list(&page_list, zone, sc);
> >
> > +       if (!scanning_global_lru(sc))
> > +               sc->memcg_record->nr_freed[file] += nr_reclaimed;
> > +
> >
> 
> Can't we stall for writeback?  If so, we may call shrink_page_list() again
> below.  The accounting should probably go after that instead.
> 

you're right. I'll fix this. 

Thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
