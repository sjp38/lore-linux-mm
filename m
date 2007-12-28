Date: Fri, 28 Dec 2007 10:44:57 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mem notifications v3
In-Reply-To: <20071227201311.GA14995@dmt>
References: <20071225122326.D25C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20071227201311.GA14995@dmt>
Message-Id: <20071228103819.7F20.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Daniel =?ISO-2022-JP?B?U3AbJEJpTxsoQmc=?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Marcelo-san

> > > +			pages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];
> > 
> > Hmm...
> > may be, don't works well.
> > 
> > MAX_NR_ZONES determined at compile time and determined by distribution vendor.
> > but real highest zone is determined by box total memory.
> 
> That is OK because the calculation of lowmem reserves will take into account 
> all zones (mm/page_alloc.c::setup_per_zone_lowmem_reserve).

really?
sorry, I will check again.


> But it might be better to use the precalculated totalreserve_pages instead.

Hmm...
unfortunately, accumulate of all zone memory is incompatible to NUMA awareness.
please think again.


> > > +		if (pages_free < (pages_high+pages_reserve)*2) 
> > > +			val = POLLIN;
> > 
> > why do you choice fomula of (pages_high+pages_reserve)*2 ?
> 
> Just to make sure its not sending a spurious notification in the case the system
> has enough free memory already.

Can I think "*2" is your experimental rule? 
if so, I agree your experience.


> > > -static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> > > +static bool shrink_active_list(unsigned long nr_pages, struct zone *zone,
> > >  				struct scan_control *sc, int priority)
> > 
> > unnecessary type change.
> > if directly call mem_notify_userspace() in shrink_active_list, works well too.
> > because notify rate control can implement by mem_notify_userspace() and mem_notify_poll().
> 
> Yes, and doing that should also guarantee that the notification is sent
> before swapout is performed (right now it sends the notification after
> shrink_inactive_list(), which is performing swapout).

Agreed.


- kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
