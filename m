Message-ID: <393DC544.8D8BA7B7@reiser.to>
Date: Tue, 06 Jun 2000 20:45:08 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:  
 it'snot just the code)
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva>
		<393DA31A.358AE46D@reiser.to> <yttya4ifeka.fsf@serpe.mitica>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Quintela Carreira Juan J." <quintela@fi.udc.es>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

"Quintela Carreira Juan J." wrote:
> 
> >>>>> "hans" == Hans Reiser <hans@reiser.to> writes:
> 
> Hi
> 
> hans> quite happy to see you drive it, I suggest to check with zam as he has some code
> hans> in progress.
> 
> hans> There are two issues to address:
> 
> hans> 1) If a buffer needs to be flushed to disk, how do we let the FS flush
> hans> everything else that it is optimal to flush at the same time as that buffer.
> hans> zam's allocate on flush code addresses that issue for reiserfs, and he has some
> hans> general hooks implemented also.  He is guessed to be two weeks away.
> 
> Ok, register a cache function and it will receive the _priority_ (also
> know as _how hard_ should try to free memory).  Once that memory is
> freed put that pages in the LRU list.  Not need to have them there
> before because there is no way that shrink_mmap would be able to free
> them anyway.
> 
> This is the reason because of what I think that one operation in the
> address space makes no sense.  No sense because it can't be called
> from the page.

What do you think of my argument that each of the subcaches should register
currently_consuming counters which are the number of pages that subcache
currently takes up in memory, plus register an integer "preciousness" value, and
that the pressure API should pressure according to the formula:

pressure equals currently_consuming squared times preciousness

Further, that the equation above should be a nice one line formula in one place
in the kernel so that we can easily play with variations on it and benchmark the
results.

I don't like the current scheme of priorities of caches, it seems wrong to me
intuitively.

> 
> hans> 2) If multiple kernel subsystem page pinners pin memory, how do we keep them
> hans> from deadlocking.  Chris as you know is the reiserfs guy for that.
> 
> I think that Riel is also working in that just now.  I think that is
> better to find one API that is good for everybody.

I think the issue is not who can do it well, but would somebody finally just do
it?  We have discussed it for 9 months now on fsdevel....:-)

> 
> I would also like to see some common API for this kind of allocation
> of memory.
> 
> Later, Juan.
> 
> --
> In theory, practice and theory are the same, but in practice they
> are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
