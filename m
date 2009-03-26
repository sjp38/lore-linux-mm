Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E6C1B6B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 03:28:17 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2Q7lXwB020745
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 13:17:33 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2Q8FD0x2810086
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 13:45:13 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2Q8IjmI031215
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 13:48:45 +0530
Date: Thu, 26 Mar 2009 13:48:43 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090326081843.GA8207@skywalker>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au> <20090319164638.GB3899@duck.suse.cz> <200903241844.22851.nickpiggin@yahoo.com.au> <20090324123935.GD23439@duck.suse.cz> <20090324125510.GA9434@duck.suse.cz> <20090324132637.GA14607@duck.suse.cz> <1237903305.17910.4.camel@think.oraclecorp.com> <20090324140720.GE23439@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090324140720.GE23439@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Chris Mason <chris.mason@oracle.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, linux-ext4@vger.kernel.org, Ying Han <yinghan@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 24, 2009 at 03:07:21PM +0100, Jan Kara wrote:
> On Tue 24-03-09 10:01:45, Chris Mason wrote:
> > On Tue, 2009-03-24 at 14:26 +0100, Jan Kara wrote:
> > > On Tue 24-03-09 13:55:10, Jan Kara wrote:
> > 
> > > >   And one more interesting thing I don't yet fully understand - I see pages
> > > > having PageError() set when they are removed from page cache (and they have
> > > > been faulted in before). It's probably some interaction with pagecache
> > > > readahead...
> > >   Argh... So the problem seems to be that get_block() occasionally returns
> > > ENOSPC and we then discard the dirty data (hmm, we could give at least a
> > > warning for that). I'm not yet sure why getblock behaves like this because
> > > the filesystem seems to have enough space but anyway this seems to be some
> > > strange fs trouble as well.
> > > 
> > 
> > Ouch.  Perhaps the free space is waiting on a journal commit?
>   Yes, exactly. I've already found there's lot of space hold by the
> committing transaction (it can easily hold a few hundred megs or a few gigs
> with larger journal and my UML images aren't that big...). And writepage()
> implementation in ext3 does not have a logic to retry. Also
> block_write_full_page() clears buffers dirty bits so it's not easy to retry
> even if we did it. I'm now looking into how to fix this...

We retry block allocation in ext3_write_begin. And for mmap we should be
doing something similar to ext4_page_mkwrite so that we can be sure
that during writepage we don't need to do block allocation.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
