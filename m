Date: Sat, 13 May 2000 09:03:48 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <20000513125701.E14984@redhat.com>
Message-ID: <Pine.LNX.4.21.0005130901070.7316-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sat, 13 May 2000, Stephen C. Tweedie wrote:
> On Fri, May 12, 2000 at 07:48:45PM -0300, Rik van Riel wrote:
> 
> > >  				if (tsk->need_resched)
> > > -					schedule();
> > > +					goto sleep;
> > 
> > This is wrong. It will make it much much easier for processes to
> > get killed (as demonstrated by quintela's VM test suite).
> 
> It shouldn't.  If tasks are getting killed, then the fix should be
> in alloc_pages, not in kswapd.  Tasks _should_ be quite able to wait
> for memory, and if necessary, drop into try_to_free_pages themselves.

Indeed, but waiting for memory or running
try_to_free_pages themselves is not without
problems either, as you describe below...

> Linus, the fix above seems to be necessary.  Without it, even a
> simple playing of mp3 audio on 2.3 fails once memory is full on
> a 256MB box, with kswapd consuming between 5% and 25% of CPU and
> locking things up sufficiently to cause dropouts in the playback
> every second or more. With that one-liner fix, mp3 is smooth
> even in the presence of other background file activity.

Kswapd freeing pages in the background means that processes
in the foreground can proceed with their allocation without
waiting, leading to smoother VM performance. I guess we
want that ... ;)

Besides, kswapd will _only_ continue if there's a zone with
zone->free_pages < zone->pages_low ... I'm now running pre8
with the patch below and it works fine.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- mm/vmscan.c.orig	Fri May 12 20:13:08 2000
+++ mm/vmscan.c	Fri May 12 20:15:24 2000
@@ -538,16 +538,19 @@
 			int i;
 			for(i = 0; i < MAX_NR_ZONES; i++) {
 				zone_t *zone = pgdat->node_zones+ i;
+				if (tsk->need_resched)
+					schedule();
 				if (!zone->size || !zone->zone_wake_kswapd)
 					continue;
-				something_to_do = 1;
+				if (zone->free_pages < zone->pages_low)
+					something_to_do = 1;
 				do_try_to_free_pages(GFP_KSWAPD);
 			}
 			run_task_queue(&tq_disk);
 			pgdat = pgdat->node_next;
 		} while (pgdat);
 
-		if (tsk->need_resched || !something_to_do) {
+		if (!something_to_do) {
 			tsk->state = TASK_INTERRUPTIBLE;
 			interruptible_sleep_on(&kswapd_wait);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
