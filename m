Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA09922
	for <linux-mm@kvack.org>; Wed, 17 Jun 1998 23:52:47 -0400
Subject: Re: PTE chaining, kswapd and swapin readahead
References: <Pine.LNX.3.96.980617173630.722A-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 17 Jun 1998 23:06:58 -0500
In-Reply-To: Rik van Riel's message of Wed, 17 Jun 1998 18:03:14 +0200 (CEST)
Message-ID: <m1k96fxsil.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> On 17 Jun 1998, Eric W. Biederman wrote:

>> If we get around to using a true LRU algorithm we aren't too likely
>> too to swap out address space adjacent pages...  Though I can see the
>> advantage for pages of the same age.

RR> True LRU swapping might actually be a disadvantage. The way
RR> we do things now (walking process address space) can result
RR> in a much larger I/O bandwidth to/from the swapping device.

The truly optimal algorithm is I to read in the page/pages we are going
to use next, and remove the page we won't use for the longest period
of time.  It's the same as LRU but in reverse time order.   And both
of these algorithms have the important property that they avoid
Belady's anomoly.  That is with more memory they won't cause more page
faults and more I/O.

The goal should be to reduce disk I/O as disk bandwidth is way below
memory bandwidth.  Using ``unused'' disk bandwidth in prepaging may
also be a help.  

Note: much of the write I/O performance we achieve is because
get_swap_page() is very efficient at returning adjacent swap pages.
I don't see where location is memory makes a difference.

As to which pages should be put close to each other for read
performance, that is a different question.  Files tend to be
read/written sequentially, so it is a safe bet to anticipate this one
usage pattern and if it is going on capitalize on it, if not don't do
any read ahead.

We could probably add a few more likely cases to the vm system.  The
only simple special cases I can think to add are reverse sequential
access, and stack access where pages 1 2 3 4 are accesed and then 4 3
2 1 are accessed in reverse order.  But for the general case it is quite
difficult to predict, and a wrong prediction could make things worse.

>> Also for swapin readahead the only effective strategy I know is to
>> implement a kernel system call, that says I'm going to be accessing

The point I was hoping to make is that for programs that find
themselves swapping frequently a non blocking read (for mmapped areas)
can be quite effective.  Because in certain circumstances a program
can in fact predict which pages it will be using next.  And this will
allow a very close approximation of the true optimal paging
algorithm, and is fairly simple to implement.  

For a really close approximation we might also want to have a system
call that says which pages we aren't likely to be using soon.
Perhaps:
mtouch(void *addr, int len, int when);
where ``when'' can be SOON or LATER ...

Or after looking at:
http://cesdis.gsfc.nasa.gov/beowulf/software/pager.html

struct mtouch_tuple {
	caddr_t addr;
	size_t extent;
	int when;
} prepage_list[NR_ELEMENTS];
mtouch(&prepage_list);

Where prepage_list is terminated with an special element.
I don't like suggested terminator of a NULL address of 0 because there
are some programs that actually use that...

The when paremeter is my idea...

RR> There are more possibilities. One of them is to use the
RR> same readahead tactic that is being used for mmap()
RR> readahead. 

Actually that sounds like a decent idea.  But I doubt it will help
much. I will start on the vnodes fairly soon, after I get a kernel
pgflush deamon working.

Eric
