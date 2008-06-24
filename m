In-reply-to: <alpine.LFD.1.10.0806241022120.2926@woody.linux-foundation.org>
	(message from Linus Torvalds on Tue, 24 Jun 2008 10:30:21 -0700 (PDT))
Subject: Re: [rfc patch 3/4] splice: remove confirm from
 pipe_buf_operations
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0806241022120.2926@woody.linux-foundation.org>
Message-Id: <E1KBDBg-0002XZ-DG@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Jun 2008 20:24:16 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > 
> > OK it could be done, possibly at great pain.  But why is it important?
> > What's the use case where it matters that splice-in should not block
> > on the read?
> 
> If you're splicing from one file to another, the _goal_ you should have is 
> that you want to have a mode where you can literally steal the page, and 
> never _ever_ be IO-synchronous (well, meta-data accesses will be, you 
> can't really avoid that sanely).
> 
> IOW, it should be possible to do a
> 
>  - splice() file->pipe with SPLICE_STEAL
> 	don't even wait for the read to finish!
> 
>  - splice() pipe->file
> 	insert the page into the destination page cache, mark it dirty
> 
> an no, we probably do not support that yet (for example, I wouldn't be 
> surprised if "dirty + !uptodate" is considered an error for the VM even 
> though the page should still be locked from the read), but it really was a 
> design goal.

OK.  But currently we have an implementation that

 1) doesn't do any of this, unless readahead is disabled

 2) if readhead is disabled, it does the async splice-in (file->pipe),
    but blocks on splice-out (pipe->any)

 3) it blocks on read(pipefd, ...) even if pipefd is set to O_NONBLOCK

And in addition, splice-in and splice-out can return a short count or
even zero count if the filesystem invalidates the cached pages during
the splicing (data became stale for example).  Are these the right
semantics?  I'm not sure.

> Also, asynchronous is important even when you "just" want to overlap IO 
> with CPU, so even if it's going to the network, then if you can delay the 
> "wait for IO to complete" until the last possible moment (ie the _second_ 
> splice, when you end up copying it into an SKB, then both your throughput 
> and your latency are likely going to be noticeably better, because you've 
> now been able to do a lot of the costly CPU work (system exit + entry at 
> the least, but hopefully a noticeable portion of the TCP stack too) 
> overlapped with the disk seeking.

My feeling is (and I'm not an expert in this area at all) is that disk
seeking will be many orders of magnitude slower than any CPU work
associated with getting the data out to the network.

> So asynchronous ops was really one of the big goals for splice. 

Well, if it can be implemented right, I have nothing against that.
But what we currently have is very far from that, and it seems to me
there are very big hurdles to overcome yet.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
