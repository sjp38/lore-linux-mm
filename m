Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
Date: Sat, 28 Jul 2001 22:13:13 +0200
References: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0107281035380.5720-100000@freak.distro.conectiva>
MIME-Version: 1.0
Message-Id: <01072822131300.00315@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Andrew Morton <akpm@zip.com.au>, Mike Galbraith <mikeg@wen-online.de>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Saturday 28 July 2001 15:40, Marcelo Tosatti wrote:
> On Sat, 28 Jul 2001, Daniel Phillips wrote:
> > On Saturday 28 July 2001 01:43, Roger Larsson wrote:
> > > Hi again,
> > >
> > > It might be variations in dbench - but I am not sure since I run
> > > the same script each time.
> >
> > I believe I can reproduce the effect here, even with dbench 2.  So
> > the next two steps:
> >
> >   1) Get some sleep
> >   2) Find out why
>
> I would suggest getting the SAR patch to measure amount of successful
> request merges and compare that between the different kernels.
>
> It sounds like the test being done is doing a lot of contiguous IO,
> so increasing readahead also increases throughtput.

I used /proc/stat to determine whether the problem is more IO or more 
scanning.  The answer is: more IO.

Next I took a look at the dbench code to see what it's actually doing, 
including stracing it.  It does a lot of different kinds of things, 
some of them very strange.  (To see what it does, read the client.txt 
file in the dbench directory, it's more-or-less self explanatory.)

One strange thing it does is a lot of 1K, 2K or 4K sized reads at 
small-number overlapping offsets.  Weird.  Why would anybody do that?

On the theory that it's the odd-sized offsets that cause the problem I 
hacked dbench so it always reads and writes at even page offsets, see 
the patch below.  Sure enough, the use-once patch then outperformed 
drop-behind, by about 7%.

Now what's going on?  I still don't know, but I'm getting warmer.  The 
leading suspect on my list is that aging isn't really working very 
well, and this is aggravated by the fact that I haven't implemented any 
clusered-access optimization (as Rik pointed out earlier).  Treating an 
intial cluster of accesses as separate accesses, wrongly activating the 
page, really should not make more than a couple of percent difference.  
What we see is closer to 30%.  My tentative conclusion is that, once 
activated, pages are taking far longer to deactivate than they should.

Here is what I think is happening on a typical burst of small, non-page 
aligned reads:

  - Page is read the 1st time: age = 2, inactive
  - Page is read the second time: age = 5, active
  - Two more reads immediately on the same page: age = 11

Then the page isn't ever used again.  Now it has to go around the 
active ring 5 times:

  1, age = 11
  2, age = 5
  3, age = 2
  4, age = 1
  5, age = 0, deactivated

So this page that should have been discarded early is now competing 
with swap pages, buffers, and file pages that truly are used more than 
once.  And, despite the fact that we found it unreferenced four times 
in a row, that still wasn't enough to convince us that the page should 
be tested for short-term popularity, i.e., deactivated.

Implementing some sort of clustered-use detection will avoid this 
problem.  I must do this, but it will just paper over what I see as the 
bigger problem, an out-of-balance active scanning strategy.

So how come mm is in general working so well if active scanning isn't?  
I think the real work is being done by the inactive queue at this point 
(that is, without the use-once patch) and it works so well it covers up 
problems with the active scanning.  The result being that performance 
on some loads is beautiful, others suck.

Please treat all of the above as speculation at this point, this has 
not been properly confirmed by measurements.

Oh, by the way, my suspicions about the flakiness of dbench as a 
benchmark were confirmed: under X, having been running various memory 
hungry applications for a while, dbench on vanilla 2.4.7 turned in a 7%
better performance (with a distinctly different process termination 
pattern) than in text mode after a clean reboot.

Maybe somebody can explain to me why there is sometimes a long wait 
between the "+" a process prints when it exits and the "*" printed in 
the parent's loop on waitpid(0, &status, 0).  And similarly, why all 
the "*"'s are always printed together.

Patch for page-aligned IO in dbench:

--- old/fileio.c	Sat Jul 28 20:18:38 2001
+++ fileio.c	Sat Jul 28 19:43:30 2001
@@ -115,7 +115,7 @@
 #endif
 		return;
 	}
-	lseek(ftable[i].fd, offset, SEEK_SET);
+	lseek(ftable[i].fd, offset & 4095, SEEK_SET);
 	if (write(ftable[i].fd, buf, size) != size) {
 		printf("write failed on handle %d\n", handle);
 	}
@@ -132,7 +132,7 @@
 		       line_count, handle, size, offset);
 		return;
 	}
-	lseek(ftable[i].fd, offset, SEEK_SET);
+	lseek(ftable[i].fd, offset & 4095, SEEK_SET);
 	read(ftable[i].fd, buf, size);
 }
 
@@ -197,7 +197,7 @@
 		return;
 	}
 	if (S_ISDIR(st.st_mode)) return;
-
+	return;
 	if (st.st_size != size) {
 		printf("(%d) nb_stat: %s wrong size %d %d\n", 
 		       line_count, fname, (int)st.st_size, size);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
