Subject: Re: [PATCH] Recent VM fiasco - fixed
References: <Pine.LNX.4.10.10005102204370.1155-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Wed, 10 May 2000 22:10:13 -0700 (PDT)"
Date: 11 May 2000 19:25:19 +0200
Message-ID: <yttln1hhudc.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "James H. Cloos Jr." <cloos@jhcloos.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

linus> On 11 May 2000, Juan J. Quintela wrote:
>> 
>> I have done my normal mmap002 test and this goes slower than
>> ever, it takes something like 3m50 seconds to complete, (pre7-8 2m50,
>> andrea classzone 2m8, and 2.2.15 1m55 for reference).

linus> Note that the mmap002 test is avery bad performance test.

Yes, I know, I included it in the memtest suite not like a benchmark.
I put the time results only for comparison.  The important thing is
that if we are running a memory hog like mmap002, we have very bad
interactive performance.  We swap the incorrect aplications (i.e. no
mmap002 data).

More in this sense is the test mmap001,  this is one test that *only*
mmaps a file the size of the physical memory and writes it (only one
pass).  Then closes the file.  With that test in pre7-9 I got load 14
and dropouts in sound (MP3 playing) of more than one second.  And the
interactive performance is *ugly*.  The system is unresponsive while I
run that,  I am *unable* to change Desktops with the keyboard.  You
don't want to know about the jumps of the mouse.  I think that we need
to solve that problems.  I don't mind that that aplication goes
slower, but it can got so much CPU/memory.  My system here is an
Athlon 500Mhz with 256MB of RAM.  This system is unable to write an
mmaped file of 256MB char by char.  That sound bad from my point of
view.

The tests in memtest try to found problems like that.  I am sorry if
it appears that I talk about raw clock time (re-reading my post I see
that I made that point very *unclear*, sorry for the confusion).

linus> Why?

linus> Because it's a classic "walk a large array in order" test, which means
linus> that the worst possible order to page things out in is LRU.

Yes, I know that we don't want to optimise for that things, but is not
good also that one of that things can got our server to its knees.

linus> So toreally speed up mmap002, the best approach is to try to be as non-LRU
linus> as possible, which is obviously the wrong thing to do in real life. So in
linus> that sense optimizing mmap002 is a _bad_ thing.

I don't want to optimize for mmap002, but mmap002 don't touch his
pages in a long time, then its pages must be swaped out, and when
touched again, swaped in.  This is not what appears to happen here.

linus> What I found interesting was how the non-waiting version seemed to have
linus> the actual _disk_ throughput a lot higher. That's much harder to measure,
linus> and I don't have good numbers for it, the best I can say is that it causes
linus> my ncr SCSI controller to complain about too deep queueing depths, which
linus> is a sure sign that we're driving the IO layer hard. Which is a good
linus> thingwhen you measure how efficiently you page things in and out..

I think that the problem is that we are not agresive enough to swap
pages that can be swaped and then, in one moment we are unable to find
*any* memory.

linus> But don't look at wall-clock times for mmap002. 

Yes, I know, sorry again for the confusion.  And thanks for all your
comments, I appreciate them very much.

Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
