Date: Wed, 25 Feb 1998 19:00:56 GMT
Message-Id: <199802251900.TAA00898@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <Pine.LNX.3.91.980225113925.376A-100000@mirkwood.dummy.home>
References: <199802242338.XAA03262@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.91.980225113925.376A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, "Benjamin C.R. LaHaise" <blah@kvack.org>, Linus Torvalds <torvalds@transmeta.com>, Itai Nahshon <nahshon@actcom.co.il>, Alan Cox <alan@lxorguk.ukuu.org.uk>, paubert@iram.es, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 25 Feb 1998 11:41:20 +0100 (MET), Rik van Riel
<H.H.vanRiel@fys.ruu.nl> said:

> On Tue, 24 Feb 1998, Stephen C. Tweedie wrote:
>> That is already scheduled as part of phase 4 of this work.  The patch I
>> have just posted is phase 2, modifying the swapper for shared pages.
>> Phase three is to implement MAP_SHARED | MAP_ANONYMOUS, and part four is
>> to do much what you describe, proactively soft-swapping data out

> Hmm, is there anything I can do to help with this

Probably not right now.  I'm probably going to swap round bits 3 and 4
of this work and defer the shared mapping, because Ben's work with
using inodes to label mm structs for anonymous maps is probably going
to be a lot better than my own plan of using a label inode per new
anonymous vma.  Ben, any thoughts about integrating this stuff or
sharing patches?  I'd like to see what you've done with this before
storming off on my own. 

> If not, I'll be working on buffer/cache memory limits
> so one file/process can't clog up all of memory (a'la
> badblocks -w), of course with DU like tunability...

Interestingly enough, the thing I wanted to do next with the VM was
similar --- implementing proper control of process RSS.  There's no
reason why we can't give big processes a smaller RSS if we start
getting memory contention, and that will let the swapper efficiently
deal with overly large processes without massively impacting the
performance of smaller processes.  Similarly, we ought to be able to
give small processes a guaranteed RSS to allow them to proceed (even
if at a reduced pace) during a swap storm.  

Doing something similar with the buffer cache will help some things a
_lot_.  Another thing to think about is to do similar tuning on the
device request lists, as I suspect that a lot of our performance /
fairness problems under high load come largely from request
starvation.  One thing I was thinking about was the possibility of
forcing processes to wait for a certain number of requests to complete
if they fill up the request queue, effectively giving them request
"credits" similar to the scheduler's credits.  This would be a simple
but probably quite effective way of making sure that processes doing
small amounts of single-block IO don't get overly starved by processes
performing large writes (such as bdflush).

Feel free to comment; I won't be working on this any time in the
immediate future...

--Stephen.
