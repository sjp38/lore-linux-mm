Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id lA1G6bfL006221
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 12:06:37 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA1H6vQo121598
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 11:06:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA1H6uCC004778
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 11:06:56 -0600
Subject: Re: migratepage failures on reiserfs
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20071101115103.62de4b2e@think.oraclecorp.com>
References: <1193768824.8904.11.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030135442.5d33c61c@think.oraclecorp.com>
	 <1193781245.8904.28.camel@dyn9047017100.beaverton.ibm.com>
	 <20071030185840.48f5a10b@think.oraclecorp.com>
	 <1193847261.17412.13.camel@dyn9047017100.beaverton.ibm.com>
	 <20071031134006.2ecd520b@think.oraclecorp.com>
	 <1193935137.26106.5.camel@dyn9047017100.beaverton.ibm.com>
	 <20071101115103.62de4b2e@think.oraclecorp.com>
Content-Type: text/plain
Date: Thu, 01 Nov 2007 10:10:26 -0800
Message-Id: <1193940626.26106.13.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>, mel@csn.ul.ie
Cc: reiserfs-devel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-01 at 11:51 -0400, Chris Mason wrote:
> On Thu, 01 Nov 2007 08:38:57 -0800
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > On Wed, 2007-10-31 at 13:40 -0400, Chris Mason wrote:
> > > On Wed, 31 Oct 2007 08:14:21 -0800
> > > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > > 
> > > > I tried data=writeback mode and it didn't help :(
> > > 
> > > Ouch, so much for the easy way out.
> > > 
> > > > 
> > > > unable to release the page 262070
> > > > bh c0000000211b9408 flags 110029 count 1 private 0
> > > > unable to release the page 262098
> > > > bh c000000020ec9198 flags 110029 count 1 private 0
> > > > memory offlining 3f000 to 40000 failed
> > > > 
> > > 
> > > The only other special thing reiserfs does with the page cache is
> > > file tails.  I don't suppose all of these pages are index zero in
> > > files smaller than 4k?
> > 
> > Ahhhhhhhhhhhhh !! I am so blind :(
> > 
> > I have been suspecting reiserfs all along, since its executing
> > fallback_migrate_page(). Actually, these buffer heads are
> > backing blockdev. I guess these are metadata buffers :( 
> > I am not sure we can do much with these..
> 
> Hmpf, my first reply had a paragraph about the block device inode
> pages, I noticed the phrase file data pages and deleted it ;)
> 
> But, for the metadata buffers there's not much we can do.  They are
> included in a bunch of different lists and the patch would
> be non-trivial.

Unfortunately, these buffer pages are spread all around making
those sections of memory non-removable. Of course, one can use
ZONE_MOVABLE to make sure to guarantee the remove. But I am
hoping we could easily group all these allocations and minimize
spreading them around. Mel ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
