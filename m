Message-ID: <391BEAED.C9313263@sympatico.ca>
Date: Fri, 12 May 2000 07:28:45 -0400
From: John Cavan <john.cavan@sympatico.ca>
MIME-Version: 1.0
Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	 <yttya5ghhtr.fsf@vexeta.dc.fi.udc.es> <shsd7msemwu.fsf@charged.uio.no>
	 <yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
	 <14619.16278.813629.967654@charged.uio.no> <ytt1z38acqg.fsf@vexeta.dc.fi.udc.es>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: trond.myklebust@fys.uio.no, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

I'm by no means an expert in this, I just follow the list to learn, but
would it not be possible to make ITERATIONS count a runtime configurable
parameter in the /proc filesystem that defaults to 100? That would allow
for the best tuning scenario for a given system.

Just a thought.

John Cavan

"Juan J. Quintela" wrote:
> 
> >>>>> "trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
> >>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:
> >> Then you want only invalidate the non_locked pages: do you
> 
> trond> That's right. This patch looks much more appropriate.
> 
> >> + while (count == ITERATIONS) {
> >> + spin_lock(&pagecache_lock);
> >> + spin_lock(&pagemap_lru_lock);
> >> + head = &inode->i_mapping->pages;
> >> + curr = head->next;
> >> + count = 0;
> >> +
> >> + while ((curr != head) && (count++ < ITERATIONS)) {
> 
> trond> Just one question: Isn't it better to do it all in 1 iteration through
> trond> the loop rather than doing it in batches of 100 pages?
> trond> You can argue that you're freeing up the spinlocks for the duration of
> trond> the loop_and_test, but is that really going to make a huge difference
> trond> to SMP performance?
> 
> Trond, I have not an SMP machine (yet), and I can not tell you numbers
> now.  I put the counter there to show that we *may* want to limit the
> latency there.  I am thinking in the write of a big file, that can
> take a lot to free all the pages, but I don't know, *you* are the NFS
> expert, this was one of the reasons that we want feedback from the
> users of the call.  (You have been very good giving comments).
> 
> My idea to put a limit is to put a limit than normally you do all in
> one iteration, but in the exceptional case of a big amount of pages,
> the latency is limited.  There is a limit in the number of pages that
> can be in that list?
> 
> 100 is one number that can need tuning, I don't know.  SMP experts
> anywhere?
> 
> By the way, while we are here, the only difference between
> truncate_inode_pages and invalidate_inode_pages is the one that you
> told here before?  I am documenting some of the MM stuff, and your
> comments in that aspect are really wellcome.  (You will have noted
> now that I am quite newbie here).
> 
> Later, Juan.
> 
> --
> In theory, practice and theory are the same, but in practice they
> are different -- Larry McVoy
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
