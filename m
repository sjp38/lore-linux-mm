Date: Tue, 24 Jun 2008 10:30:21 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc patch 3/4] splice: remove confirm from
 pipe_buf_operations
In-Reply-To: <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.1.10.0806241022120.2926@woody.linux-foundation.org>
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 24 Jun 2008, Miklos Szeredi wrote:
> 
> OK it could be done, possibly at great pain.  But why is it important?
> What's the use case where it matters that splice-in should not block
> on the read?

If you're splicing from one file to another, the _goal_ you should have is 
that you want to have a mode where you can literally steal the page, and 
never _ever_ be IO-synchronous (well, meta-data accesses will be, you 
can't really avoid that sanely).

IOW, it should be possible to do a

 - splice() file->pipe with SPLICE_STEAL
	don't even wait for the read to finish!

 - splice() pipe->file
	insert the page into the destination page cache, mark it dirty

an no, we probably do not support that yet (for example, I wouldn't be 
surprised if "dirty + !uptodate" is considered an error for the VM even 
though the page should still be locked from the read), but it really was a 
design goal.

Also, asynchronous is important even when you "just" want to overlap IO 
with CPU, so even if it's going to the network, then if you can delay the 
"wait for IO to complete" until the last possible moment (ie the _second_ 
splice, when you end up copying it into an SKB, then both your throughput 
and your latency are likely going to be noticeably better, because you've 
now been able to do a lot of the costly CPU work (system exit + entry at 
the least, but hopefully a noticeable portion of the TCP stack too) 
overlapped with the disk seeking.

So asynchronous ops was really one of the big goals for splice. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
