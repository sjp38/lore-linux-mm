Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7352B6B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 16:13:50 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id n2RKZI4J002862
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 20:35:19 GMT
Received: from wf-out-1314.google.com (wff29.prod.google.com [10.142.6.29])
	by wpaz17.hot.corp.google.com with ESMTP id n2RKZGxe017816
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 13:35:17 -0700
Received: by wf-out-1314.google.com with SMTP id 29so1377434wff.12
        for <linux-mm@kvack.org>; Fri, 27 Mar 2009 13:35:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200903241844.22851.nickpiggin@yahoo.com.au>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
	 <200903200248.22623.nickpiggin@yahoo.com.au>
	 <20090319164638.GB3899@duck.suse.cz>
	 <200903241844.22851.nickpiggin@yahoo.com.au>
Date: Fri, 27 Mar 2009 13:35:16 -0700
Message-ID: <604427e00903271335p14f96910y912ccd349faf154c@mail.gmail.com>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jan Kara <jack@suse.cz>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 24, 2009 at 12:44 AM, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> On Friday 20 March 2009 03:46:39 Jan Kara wrote:
>> On Fri 20-03-09 02:48:21, Nick Piggin wrote:
>
>> > Holding mapping->private_lock over the __set_page_dirty should
>> > fix it, although I guess you'd want to release it before calling
>> > __mark_inode_dirty so as not to put inode_lock under there. I
>> > have a patch for this if it sounds reasonable.
>>
>>   Yes, that seems to be a bug - the function actually looked suspitious to
>> me yesterday but I somehow convinced myself that it's fine. Probably
>> because fsx-linux is single-threaded.
>
>
> After a whole lot of chasing my own tail in the VM and buffer layers,
> I think it is a problem in ext2 (and I haven't been able to reproduce
> with ext3 yet, which might lend weight to that, although as we have
> seen, it is very timing dependent).
>
> That would be slightly unfortunate because we still have Jan's ext3
> problem, and also another reported problem of corruption on ext3 (on
> brd driver).
I believe i see the same issue on ext2 as well as ext4.
>
> Anyway, when I have reproduced the problem with the test case, the
> "lost" writes are all reported to be holes. Unfortunately, that doesn't
> point straight to the filesystem, because ext2 allocates blocks in this
> case at writeout time, so if dirty bits are getting lost, then it would
> be normal to see holes.
>
> I then put in a whole lot of extra infrastructure to track metadata about
> each struct page (when it was last written out, when it last had the number
> of writable ptes reach 0, when the dirty bits were last cleared etc). And
> none of the normal asertions were triggering: eg. when any page is removed
> from pagecache (except truncates), it has always had all its buffers
> written out *after* all ptes were made readonly or unmapped. Lots of other
> tests and crap like that.

Do you think there might be a race in the page reclaim path? I did a
hack which commeted out
wakeup_pdflush in try_to_free_pages ( based on 2.6.21, just randomly
picked on has the problem)
It runs for couple of hours and the problem not happened yet. I am not
sure if that is the problem or not,
and i will leave it running.
The reason i tried the hack since i reproduce the "bad pages" easily
everytime i put more memory pressure
on the system.


diff --git a/mm/vmscan.c b/mm/vmscan.c
index db023e2..b4b7e1f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1067,11 +1067,13 @@ unsigned long try_to_free_pages(struct zone **zones, g
 		 * that's undesirable in laptop mode, where we *want* lumpy
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
+/*
 		if (total_scanned > sc.swap_cluster_max +
 					sc.swap_cluster_max / 2) {
 			wakeup_pdflush(laptop_mode ? 0 : total_scanned);
 			sc.may_writepage = 1;
 		}
+*/

 		/* Take a nap, wait for some writeback to complete */
 		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)

>
> So I tried what I should have done to start with and did an e2fsck after
> seeing corruption. Yes, it comes up with errors. Now that is unusual
> because that should be largely insulated from the vm: if a dirty bit gets
> lost, then the filesystem image should be quite happy and error-free with
> a hole or unwritten data there.
>
> I don't know ext? locking very well, except that it looks pretty overly
> complex and crufty.
>
> Usually, blocks are instantiated by write(2), under i_mutex, serialising
> the allocator somewhat. mmap-write blocks are instantiated at writeout
> time, unserialised. I moved truncate_mutex to cover the entire get_blocks
> function, and can no longer trigger the problem. Might be a timing issue
> though -- Ying, can you try this and see if you can still reproduce?
>
> I close my eyes and pick something out of a hat. a686cd89. Search for XXX.
> Nice. Whether or not this cased the problem, can someone please tell me
> why it got merged in that state?
>
> I'm leaving ext3 running for now. It looks like a nasty task to bisect
> ext2 down to that commit :( and I would be more interested in trying to
> reproduce Jan's ext3 problem, however, because I'm not too interested in
> diving into ext2 locking to work out exactly what is racing and how to
> fix it properly. I suspect it would be most productive to wire up some
> ioctls right into the block allocator/lookup and code up a userspace
> tester for it that could probably stress it a lot harder than kernel
> writeout can.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
