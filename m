Subject: Re: shrink_mmap() change in ac-21
References: <87r99t8m2r.fsf@atlas.iskon.hr> <000d01bfda37$f34c3ee0$0a1e18ac@local>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 20 Jun 2000 10:21:51 +0200
In-Reply-To: "Manfred Spraul"'s message of "Mon, 19 Jun 2000 23:47:14 +0200"
Message-ID: <dnaeggn4o0.fsf@magla.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

"Manfred Spraul" <manfred@colorfullife.com> writes:

> From: "Zlatko Calusic" <zlatko@iskon.hr>
> >
> > The reason is balancing of the DMA zone (which is much smaller on a
> > 128MB machine than the NORMAL zone!). shrink_mmap() now happily evicts
> > wrong pages from the memory and continues doing so until it finally
> > frees enough pages from the DMA zone. That, of course, hurts caching
> > as the page cache gets shrunk a lot without a good reason.
> >
> What caused the zone balancing?
> Did you deliberately allocate GFP_DMA memory (sound card, old scsi card,
> floppy disk, ...) or was it during "normal" operation?
> 

No, I haven't done anything special with the DMA zone. But pages get
allocated from the DMA zone normally (it is almost 16MB of free RAM,
after all).

Then when kswapd kicks in because free memory in the DMA zone got low,
it starts freeing pages until we free enough pages from the DMA
zone. But it doesn't check if such a freeing hurts other zones.

Simple mathematics: On a 128MB machine, DMA zone is 16MB, thus NORMAL
zone is 112MB. 112/16 = 7. So statistically, for every DMA page freed,
we free another SEVEN! pages from the NORMAL zone. And we won't stop
doing such a genocide until DMA zone recovers.

That was 128MB machine, consider how the problem gets progressively
worse on machines with more RAM.
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
