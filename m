From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: [RFC] Limit the size of the pagecache
Reply-To: 7eggert@gmx.de
Date: Thu, 25 Jan 2007 15:51:34 +0100
References: <7GEEK-4lH-39@gated-at.bofh.it> <7GLdb-5Uz-13@gated-at.bofh.it> <7GRix-7fU-1@gated-at.bofh.it> <7GRLZ-7Uy-29@gated-at.bofh.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8Bit
Message-Id: <E1HA5ws-0000vQ-KM@be1.lrz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Aubrey Li <aubreylee@gmail.com>, Christoph Lameter <clameter@sgi.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, ?missing, Michael <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Wed, 2007-01-24 at 22:22 +0800, Aubrey Li wrote:
>> On 1/24/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

>> > He wants to make a nommu system act like a mmu system; this will just
>> > never ever work.
>> 
>> Nope. Actually my nommu system works great with some of patches made by us.
>> What let you think this will never work?
> 
> Because there are perfectly valid things user-space can do to mess you
> up. I forgot the test-case but it had something to do with opening a
> million files, this will scatter slab pages all over the place.

a) Limit the number of open files.
b) Don't do that then.

> Also, if you cycle your large user-space allocations a bit unluckily
> you'll also fragment it into oblivion.
> 
> So you can not guarantee it will not fragment into smithereens stopping
> your user-space from using large than page size allocations.

Therefore you should purposely increase the mess up to the point where the
system is guaranteed not to work? IMO you should rather put the other issues
onto the TODO list.

BTW: I'm not sure a hard limit is the right thing to do for mmu systems,
I'd rather implement high and low watermarks; if one pool is larger than
it's high watermark, it will be next get it's pages evicted, and it won't
lose pages if it's at the lower watermark.

> If your user-space consists of several applications that do dynamic
> memory allocation of various sizes its a matter of (run-) time before
> things will start failing.
> 
> If you prealloc a large area at boot time (like we now do for hugepages)
> and use that for user-space, you might 'reset' the status quo by cycling
> the whole of userspace.

Preallocating the page cache (and maybe the slab space?) may very well be
the right thing to do for nommu systems. It worked quite well in DOS times
and on old MACs.
-- 
Funny quotes:
30. Why is a person who plays the piano called a pianist but a person who
    drives a race car not called a racist?
Friss, Spammer: iz@7eggert.dyndns.org pveUtv@rFGfMneI.7eggert.dyndns.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
