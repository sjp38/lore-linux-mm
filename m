Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81B176B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:26:38 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7OEDXJn016851
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:13:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7OERQ2S134960
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:27:26 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7OEROvT002820
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 10:27:26 -0400
Date: Tue, 24 Aug 2010 19:57:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: cleancache followup from LSF10/MM summit
Message-ID: <20100824142718.GA24164@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <66336896-4396-458f-b8a5-51282a925816@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <66336896-4396-458f-b8a5-51282a925816@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <bharrosh@panasas.com>, ngupta@vflare.org, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, Andreas Dilger <andreas.dilger@oracle.com>, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

* dan.magenheimer@oracle.com <dan.magenheimer@oracle.com> [2010-08-20 08:14:59]:

> Hi Christophe (and others interested in cleancache progress) --
> 
> Thanks for taking some time to talk with me about cleancache
> at LSF summit!  You had some interesting thoughts and suggestions
> that I said I would investigate.  They are:
> 
> 1) use inode kva as key instead of i_ino
> 2) eliminate cleancache shim and call zcache directly
> 3) fs's requiring key > inode_t (e.g. 64-bit-fs on 32-bit-kernel)
> 4) eliminate fs-specific code entirely (e.g. "opt-in")
> 5) eliminate global variable
> 
> Here's my conclusions:
> 
> 1) You suggested using the inode kva as a "key" for cleancache.
>    I think your goal was to make it more fs-independent and also
>    to eliminate the need for using a per-fs enabler and "pool id".
>    I looked at this but it will not work because cleancache
>    retains page cache data pages persistently even when the
>    inode has been pruned from the inode_unused_list and only
>    flushes the data pages if the file gets removed/truncated.  If
>    cleancache used the inode kva, there would be coherency issues
>    when the inode kva is reused.  Alternately, if cleancache
>    flushed the pages when the inode kva was freed, much of
>    the value of cleancache would be lost because the cache
>    of pages in cleancache is potentially much larger than
>    the page cache and is most useful if the pages survive
>    inode cache removal.
> 
>    If I misunderstood your proposal or if you disagree, please
>    let me know.
> 
> 2) You suggested eliminating the cleancache shim layer and just
>    directly calling zcache, effectively eliminating Xen as
>    a user.  During and after LSF summit, I talked to developers
>    from Google who are interested in investigating the cleancache
>    interface for use with cgroups, an IBM developer who was
>    interested in cleancache for optimizing NUMA, and soon I
>    will be talking to HP Labs about using it as an interface
>    for "memory blades".  I also think Rik van Riel and Mel Gorman
>    were intrigued about its use for collecting better memory
>    utilization statistics to drive guest/host memory "rightsizing".
>    While it is true that none of these are current users yet, even
>    if you prefer to ignore Xen tmem as a user, it seems silly to
>    throw away the cleanly-layered generic cleancache interface now,
>    only to add it back later when more users are added.
> 
> 3) You re-emphasized the problem where cleancache's use of
>    the inode number as a key will cause problems on many 64-bit
>    filesystems especially running on a 32-bit kernel.  With
>    help from Andreas Dilger, I'm trying to work out a generic
>    solution for this using s_export_op->encode_fh which would
>    be used for any fs that provides it to guarantee a unique
>    multi-word key for a file, while preserving the
>    shorter i_ino as a key for fs's for which i_ino is unique.
> 
> 4) Though you were out of the room during the cleancache
>    lightning talk, other filesystem developers seemed OK
>    with the "opt-in" approach (as documented in lwn.net)...
>    one even asked "can't you just add a bit to the superblock?"
>    to which I answered "that's essentially what the one
>    line opt-in addition does".  Not sure if you are still
>    objecting to that, but especially given that the 64-bit-fs-on
>    32-bit-kernel issue above only affects some filesystems,
>    I'm still thinking it is necessary.
> 
> 5) You commented (before LSF) that the global variable should
>    be avoided which is certainly valid, and I will try Nitin's
>    suggestion to add a registration interface.
> 
> Did I miss anything?
> 
> I plan to submit a V4 for cleancache soon, and hope you will
> be inclined to ack this time.
>

Hi, Dan,

Sorry for commenting on your post so late. I've had some time to read
through your approach and compare it to my approach 
(http://www.linuxsymposium.org/2010/view_abstract.php?content_key=32)
and I had a few quick questions

1. Can't this be done at the MM layer - why the filesystem hooks? Is
it to enable faster block devices in the reclaim hierarchy?
2. I don't see a mention of slabcache in your approach, reclaim free
pages or freeing potentially free slab pages.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
