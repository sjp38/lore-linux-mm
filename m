Message-ID: <404D56D8.2000008@cyberone.com.au>
Date: Tue, 09 Mar 2004 16:32:08 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/4] VM split active lists
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,
Background: there are a number of problems in the 2.6 page reclaim
algorithms. Thankfully, most of them were simple oversights or small
bugs, the worst of which Andrew Morton and myself have fixes for in
his -mm tree and being mostly simple and obviously correct, they will
hopefully be included in 2.6.5.

With these fixes, 2.6 swapping performance (the area I'm focusing on)
is very much improved. Unfortunately there is another more complex
patch in limbo that improves performance by a additional 10%. It is
Nikita's dont-rotate-active-list.

The reason for the improvement is that it improves ordering of mapped
pages on the active list. Now I I'd like to fix this problem and get
this 10%. However dont-rotate-active-list is pretty ugly to put it
nicely.

OK, the theory is that mapped pagecache pages are worth more than
unmapped pages. This is a good theory because mapped pages will
usually have far more random access patterns, so pagein *and* pageout
will be much less efficient. Also, applications are probably coded to
be more suited to blocking in read() than a random code / anon memory
page. So a factor of >= 16 wouldn't be out of the question.

Now the basic problem is that we have these two classes of pages on
one (the active) list, and we attempt to place different scanning
semantics on each class. This is done with the reclaim_mapped logic.
Now I won't be too disparaging of reclaim_mapped because I think
Andrew crea^W^W^W^W it somehow more or less works, but it has a couple
of problems.

* Difficult to trace: relies on some saved state from earlier in time.
* difficult to control: relies on inner workings (eg "priority").
  mapped vs unmapped scanning behaviour is derived basically by black
  magic.
* not-quite-right semantics: mapped pages are infinitely preferable
  to unmapped pages until something goes click and then they are worth
  about half as much.
* These semantics mean that in low memory pressure (before the click),
  truely inactive mapped pages will never be reclaimed. Probably they
  should be to increase resident working set.
* Also, a significant number of mapped pages can be passed over
  without doing any real work.
* This causes list position information to be lost (which is where
  that 10% comes from).

Now I have an alternative which hopefully solves all these problems
and with less complexity than dont-rotate-active-list which only
solves the last one: split the active list into active_mapped and
active_unmapped lists. Pages are moved between them lazily at scan
time, and they needn't be totally accurate.

You then simply put 16 (or whatever) times the amount of pressure on
the unmapped list as you do on the mapped list. This number can be the
tunable (instead of swapiness).

I have an implementation which compiles, boots, and survives a -j8
kbuild. Probably still has a few problems though. Couple of things: it
presently just puts even pressure on both lists, so it is swappy
(trivial to fix). It also gives unmapped pages the full two level
(active+inactive) system because it was just easier to do it that way.
Don't know if this would be good or bad.

The patches go like this:
1/4: vm-lrutopage-cleanup
Cleanup from Nikita's dont-rotate-active-list patch.

2/4: vm-nofixed-active-list
Generalise active list scanning to scan different lists.

3/4: vm-no-reclaim_mapped
Kill reclaim_mapped and its merry men.

4/4: vm-mapped-x-active-lists
Split the active list into mapped and unmapped pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
