Date: Sun, 29 Aug 2004 18:53:45 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040829165345.GC11219@suse.de>
References: <20040824124356.GW2355@suse.de> <412CDE7E.9060307@seagha.com> <20040826144155.GH2912@suse.de> <412E13DB.6040102@seagha.com> <412E31EE.3090102@pandora.be> <41308C62.7030904@seagha.com> <20040828125028.2fa2a12b.akpm@osdl.org> <4130F55A.90705@pandora.be> <20040828144303.0ae2bebe.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040828144303.0ae2bebe.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Karl Vogel <karl.vogel@pandora.be>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 28 2004, Andrew Morton wrote:
> 
> (Added linux-mm)
> 
> Karl Vogel <karl.vogel@pandora.be> wrote:
> >
> > Andrew Morton wrote:
> > > Karl Vogel <karl.vogel@seagha.com> wrote:
> > > 
> > >>Further testing shows that all the schedulers exhibit this exact same
> > >> problem when run with a nr_requests size of 8192 on the drive hosting 
> > >> the swap partition.
> > >>
> > >> I tried noop, deadline, as and CFQ with:
> > >>
> > >> 	echo 8192 >/sys/block/hda/queue/nr_requests
> > > 
> > > 
> > > That allows up to 2GB of memory to be under writeout at the same time.  The
> > > VM cannot touch any of that memory.
> > 
> > Well I used that value as it is the default for CFQ.. and it was with 
> > CFQ that I had the problems. The patch Jens offered to track down the 
> > problem, commented out this 'q->nr_requests = 8192' in CFQ and it 
> > helped. Therefor I tried the other schedulers with this value to see if 
> > it made a difference.
> > 
> > So if I understand you correctly, CFQ shouldn't be using 8192 on 512Mb 
> > systems?!
> 
> Yup.  It's asking for trouble to allow that much memory to be unreclaimably
> pinned.

It's not pinned, it's in-progress. I think it's really bad behaviour to
_allow_ so much to be in-progress, if you can't handle it. It's silly to
expect the io scheduler to know this and limit it, belongs at a
different level (the vm, where you have such knowledge).

> Of course, you could have the same problem with just 128 requests per
> queue, and lots of queues.  I solved all these problems in the dirty memory
> writeback paths.  But I forgot about swapout!

Precisely. Or 128 requests on a 16MB system. More proof that this is a
vm problem.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
