Received: from localhost (hahn@localhost)
	by coffee.psychology.mcmaster.ca (8.8.7/8.8.7) with ESMTP id TAA08210
	for <linux-mm@kvack.org>; Thu, 11 May 2000 19:40:18 -0400
Date: Thu, 11 May 2000 19:40:17 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <dnitwmfwtk.fsf@magla.iskon.hr>
Message-ID: <Pine.LNX.4.10.10005101410420.1653-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I checked pre7-8 briefly, but I/O & MM interaction is bad. Lots of
> swapping, lots of wasted CPU cycles and lots of dead writer processes
> (write(2): out of memory, while there is 100MB in the page cache).

I've checked pre7-8 and -9 fairly extensively, and it works GREAT.  
this is the first kernel since around 2.3.36 that passes my main criteria:

1. I have an app that sequentially traverses 12 40M chunks of data by
mmaping one, reading each u16, unmapping, on to the next.  until
pre7-8, old 40M chunks would NOT be scavenged, and instead the ~10M
rss of the analysis program would be thrashed, over and over.
with pre7-8 and -9, there's only incidental swapping, and performance 
is roughly 2.2x better than preceeding kernels.

2. big compilations (kernel make -j2) seem to run fine:

under 2.3.99-7-8:
334.65user 20.28system 3:01.53elapsed 195%CPU (330186major+472843minor)pf
334.23user 20.28system 2:58.13elapsed 199%CPU (340672major+472770minor)pf
334.33user 20.28system 2:57.79elapsed 199%CPU (329202major+472769minor)pf
287.99user 17.51system 2:33.72elapsed 198%CPU (270411major+396913minor)pf
335.65user 20.31system 3:01.13elapsed 196%CPU (332370major+472770minor)pf

under 2.3.99-pre7 (somewhat hacked):
333.55user 20.37system 3:19.69elapsed 177%CPU (341428major+472709minor)
334.02user 19.53system 3:09.28elapsed 186%CPU (330283major+472709minor)
334.57user 18.98system 3:08.02elapsed 188%CPU (328941major+472709minor)
334.89user 18.97system 3:07.91elapsed 188%CPU (328941major+472709minor)
333.22user 20.36system 3:07.75elapsed 188%CPU (328941major+472709minor)
334.15user 19.42system 3:07.84elapsed 188%CPU (328941major+472709minor)

under 2.3.36:
332.59user 19.93system 3:38.24elapsed 161%CPU (331704major+468634minor)
332.16user 21.14system 3:07.62elapsed 188%CPU (328998major+468634minor)
296.87user 17.93system 2:39.25elapsed 197%CPU (284086major+408452minor)
332.48user 20.89system 3:07.80elapsed 188%CPU (328998major+468634minor)
296.28user 18.08system 2:39.04elapsed 197%CPU (283978major+408169minor)

under 2.3.99-7-9:
331.28user 21.01system 3:18.83elapsed 177%CPU (328941major+472703minor)
334.06user 19.17system 3:07.72elapsed 188%CPU (328941major+472703minor)
332.79user 20.59system 3:07.73elapsed 188%CPU (328941major+472703minor)
334.29user 19.22system 3:07.55elapsed 188%CPU (328941major+472703minor)
332.25user 20.96system 3:07.55elapsed 188%CPU (328941major+472703minor)
332.09user 21.45system 3:07.67elapsed 188%CPU (328941major+472703minor)
334.04user 19.62system 3:07.72elapsed 188%CPU (328941major+472703minor)
334.38user 18.98system 3:07.50elapsed 188%CPU (328941major+472703minor)
333.67user 19.54system 3:07.54elapsed 188%CPU (328941major+472703minor)

wow, those identical PF numbers are kinda eerie!  the machine was otherwise
idle during these tests, but not single-user.  I don't really understand 
why 2.3.36 would sometimes perform *significantly* better.

3. disk bandwidth (bonnie) is excellent on 2.3.99-7-8 or -9

I usually use this machine remotely, so I can't comment on "feel".
big memory or IO load didn't seem to hurt the update latency of top/vmstat
type tools.  machine is a dual celeron/550, bx, 128M, single udma.

I briefly tested a kernel build on an old 32M cyrix 166, and it 
was a little slower than 2.3.36.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
