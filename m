Date: Wed, 26 Mar 2008 10:41:32 +1100
Message-ID: <87tziu5q37.wl%peter@chubb.wattle.id.au>
From: Peter Chubb <peterc@gelato.unsw.edu.au>
In-Reply-To: <20080325.162244.61337214.davem@davemloft.net>
References: <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
	<20080324.144356.104645106.davem@davemloft.net>
	<Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>
	<20080325.162244.61337214.davem@davemloft.net>
Subject: Re: larger default page sizes...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, ianw@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

>>>>> "David" == David Miller <davem@davemloft.net> writes:

David> From: Christoph Lameter <clameter@sgi.com> Date: Tue, 25 Mar
David> 2008 10:48:19 -0700 (PDT)

>> On Mon, 24 Mar 2008, David Miller wrote:
>> 
>> > There are ways to get large pages into the process address space
>> for > compute bound tasks, without suffering the well known
>> negative side > effects of using larger pages for everything.
>> 
>> These hacks have limitations. F.e. they do not deal with I/O and
>> require application changes.

David> Transparent automatic hugepages are definitely doable, I don't
David> know why you think this requires application changes.

It's actually harder than it looks.  Ian Wienand just finished his
Master's project in this area, so we have *lots* of data.  The main
issue is that, at least on Itanium, you have to turn off the hardware
page table walker for hugepages if you want to mix superpages and
standard pages in the same region. (The long format VHPT isn't the
panacea we'd like it to be because the hash function it uses depends
on the page size).  This means that although you have fewer TLB misses
with larger pages, the cost of those TLB misses is three to four times
higher than with the standard pages.  In addition, to set up a large
page takes more effort... and it turns out there are few applications
where the cost is amortised enough, so on SpecCPU for example, some
tests improved performance slightly, some got slightly worse.

What we saw was essentially that we could almost eliminate DTLB misses,
other than the first, for a huge page.  For most applications, though,
the extra cost of that first miss, plus the cost of setting up the
huge page, was greater than the few hundred DTLB misses we avoided.

I'm expecting Ian to publish the full results soon.

Other architectures (where the page size isn't tied into the hash
function, so the hardware walked can be used for superpages) will have
different tradeoffs.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
http://www.ertos.nicta.com.au           ERTOS within National ICT Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
