Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AAD246B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 03:56:47 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2Q8jhF2030500
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 19:45:43 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2Q8lvYe438554
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 19:47:59 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2Q8lcV2023946
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 19:47:39 +1100
Date: Thu, 26 Mar 2009 14:17:23 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090326084723.GB8207@skywalker>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <20090324125510.GA9434@duck.suse.cz> <20090324132637.GA14607@duck.suse.cz> <200903250130.02485.nickpiggin@yahoo.com.au> <20090324144709.GF23439@duck.suse.cz> <1237906563.24918.184.camel@twins> <20090324152959.GG23439@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090324152959.GG23439@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 24, 2009 at 04:29:59PM +0100, Jan Kara wrote:
> On Tue 24-03-09 15:56:03, Peter Zijlstra wrote:
> > On Tue, 2009-03-24 at 15:47 +0100, Jan Kara wrote:
> > > 
> > > Or we could implement ext3_mkwrite() to allocate buffers already when we
> > > make page writeable. But it costs some performace (we have to write page
> > > full of zeros when allocating those buffers, where previously we didn't
> > > have to do anything) and it's not trivial to make it work if pagesize >
> > > blocksize (we should not allocate buffers outside of i_size so if i_size
> > > = 1024, we create just one block in ext3_mkwrite() but then we need to
> > > allocate more when we extend the file).
> > 
> > I think this is the best option, failing with SIGBUS when we fail to
> > allocate blocks seems consistent with other filesystems as well.
>   I agree this looks attractive at the first sight. But there are drawbacks
> as I wrote - the problem with blocksize < pagesize, slight performance
> decrease due to additional write,

It should not cause an additional write. Can you let me why it would
result in additional write ?


>page faults doing allocation can take a
> *long* time 

That is true

>and overall fragmentation is going to be higher (previously
> writepage wrote pages for us in the right order, now we are going to
> allocate in the first-accessed order). So I'm not sure we really want to
> go this way.


block allocator should be improved to fix that. For example ext4
mballoc also look at the logical file block number when doing block
allocation. So if we does enough reservation it should handle the 
the first-accessed order and sequential order allocation properly.

Another reason why I think we would need ext3_page_mkwrite is, if we
really are out of space how do we handle it ? Currently the patch you
posted does redirty_page_for_writepage, which would imply we can't
reclaim the page and since get_block get ENOSPC we can't allocate
blocks.

>   Hmm, maybe we could play a trick ala delayed allocation - i.e., reserve
> some space in mkwrite() but don't actually allocate it. That would be done
> in writepage(). This would solve all the problems I describe above. We could
> use PG_Checked flag to track that the page has a reservation and behave
> accordingly in writepage() / invalidatepage(). ext3 in data=journal mode
> already uses the flag but the use seems to be compatible with what I want
> to do now... So it may actually work.
>   BTW: Note that there's a plenty of filesystems that don't implement
> mkwrite() (e.g. ext2, UDF, VFAT...) and thus have the same problem with
> ENOSPC. So I'd not speak too much about consistency ;).
> 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
