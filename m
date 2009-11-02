Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 536B96B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 05:42:14 -0500 (EST)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id nA2Ag9sP016979
	for <linux-mm@kvack.org>; Mon, 2 Nov 2009 02:42:10 -0800
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by spaceape13.eur.corp.google.com with ESMTP id nA2Ag5GW021854
	for <linux-mm@kvack.org>; Mon, 2 Nov 2009 02:42:06 -0800
Received: by pzk6 with SMTP id 6so6951108pzk.29
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 02:42:05 -0800 (PST)
Date: Mon, 2 Nov 2009 02:42:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <2f11576a0911010529t688ed152qbb72c87c85869c45@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0911020237440.13146@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com> <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com> <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com> <2f11576a0911010529t688ed152qbb72c87c85869c45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, 1 Nov 2009, KOSAKI Motohiro wrote:

> > total_vm
> > 673222 test
> > 195695 krunner
> > 168881 plasma-desktop
> > 130567 ktorrent
> > 127081 knotify4
> > 125881 icedove-bin
> > 123036 akregator
> > 121869 firefox-bin
> >
> > rss
> > 672271 test
> > 42192 Xorg
> > 30763 firefox-bin
> > 13292 icedove-bin
> > 10208 ktorrent
> > 9260 akregator
> > 8859 plasma-desktop
> > 7528 krunner
> >
> > firefox-bin seems much more preferred in this case than total_vm, but Xorg
> > still ranks very high with this patch compared to the current
> > implementation.
> 
> Hi David,
> 
> I'm very interesting your pointing out. thanks good testing.
> So, I'd like to clarify your point a bit.
> 
> following are badness list on my desktop environment (x86_64 6GB mem).
> it show Xorg have pretty small badness score. Do you know why such
> different happen?
> 

I don't know specifically what's different on your machine than Vedran's, 
my data is simply a collection of the /proc/sys/vm/oom_dump_tasks output 
from Vedran's oom log.

I guess we could add a call to badness() for the oom_dump_tasks tasklist 
dump to get a clearer picture so we know the score for each thread group 
leader.  Anything else would be speculation at this point, though.

> score    pid        comm
> ==============================
> 56382   3241    run-mozilla.sh
> 23345   3289    run-mozilla.sh
> 21461   3050    gnome-do
> 20079   2867    gnome-session
> 14016   3258    firefox
> 9212    3306    firefox
> 8468    3115    gnome-do
> 6902    3325    emacs
> 6783    3212    tomboy
> 4865    2968    python
> 4861    2948    nautilus
> 4221    1       init
> (snip about 100line)
> 548     2590    Xorg
> 

Are these scores with your rss patch or without?  If it's without the 
patch, this is understandable since Xorg didn't appear highly in Vedran's 
log either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
