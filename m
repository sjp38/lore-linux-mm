Date: Sat, 28 Aug 2004 14:43:03 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on
 swap partition
Message-Id: <20040828144303.0ae2bebe.akpm@osdl.org>
In-Reply-To: <4130F55A.90705@pandora.be>
References: <20040824124356.GW2355@suse.de>
	<412CDE7E.9060307@seagha.com>
	<20040826144155.GH2912@suse.de>
	<412E13DB.6040102@seagha.com>
	<412E31EE.3090102@pandora.be>
	<41308C62.7030904@seagha.com>
	<20040828125028.2fa2a12b.akpm@osdl.org>
	<4130F55A.90705@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Karl Vogel <karl.vogel@pandora.be>
Cc: Jens Axboe <axboe@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Added linux-mm)

Karl Vogel <karl.vogel@pandora.be> wrote:
>
> Andrew Morton wrote:
> > Karl Vogel <karl.vogel@seagha.com> wrote:
> > 
> >>Further testing shows that all the schedulers exhibit this exact same
> >> problem when run with a nr_requests size of 8192 on the drive hosting 
> >> the swap partition.
> >>
> >> I tried noop, deadline, as and CFQ with:
> >>
> >> 	echo 8192 >/sys/block/hda/queue/nr_requests
> > 
> > 
> > That allows up to 2GB of memory to be under writeout at the same time.  The
> > VM cannot touch any of that memory.
> 
> Well I used that value as it is the default for CFQ.. and it was with 
> CFQ that I had the problems. The patch Jens offered to track down the 
> problem, commented out this 'q->nr_requests = 8192' in CFQ and it 
> helped. Therefor I tried the other schedulers with this value to see if 
> it made a difference.
> 
> So if I understand you correctly, CFQ shouldn't be using 8192 on 512Mb 
> systems?!

Yup.  It's asking for trouble to allow that much memory to be unreclaimably
pinned.

Of course, you could have the same problem with just 128 requests per
queue, and lots of queues.  I solved all these problems in the dirty memory
writeback paths.  But I forgot about swapout!

> With overcommit_memory set to 1, the program can be run again after the 
> OOM kill.. but the OOM killing remains.
> 
> With overcommit_memory set to 0 a second run fails. I 'think' it's 
> because somehow SwapCache is 500Kb after the OOM, so in effect my system 
> doesn't have 1Gb to spare anymore. Doing swapoff/swapon frees this and 
> then I can do the calloc(1Gb) again.
> 
> Another way to free the SwapCached is to generate lots of I/O doing 'dd 
> if=/dev/hda of=/dev/null' ... after a while SwapCached is < 1Mb again.
> 

urgh.  It sounds like the overcommit logic forgot to account swapcache as
reclaimable.  It's been a ton of trouble, that code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
