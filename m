Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 451066B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:52:12 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so2218940pdb.27
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:52:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id kk10si3536090pbd.238.2014.07.23.12.52.10
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 12:52:11 -0700 (PDT)
Date: Wed, 23 Jul 2014 15:50:55 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 00/22] Support ext4 on NV-DIMMs
Message-ID: <20140723195055.GF6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <53CFDBAE.4040601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CFDBAE.4040601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 23, 2014 at 06:58:38PM +0300, Boaz Harrosh wrote:
> Have you please pushed this tree to git hub. It used to be on the prd
> tree, if you could just add another branch there, it would be cool.
> (https://github.com/01org/prd)

Ross handles the care & feeding of that tree ... he'll push that branch
out soon.

> With reads they are all the same with pmfs-prd a bit on top.
> But writes, shmem is by far far better. I'll Investigate this farther, it
> does not make sense looks like a serialization of writes somewhere.

I imagine there's locking that needs to happen for real filesystems that
shmem can happily ignore.  Maybe one of the journal locks?

> (All numbers rounded)
> 
> fio 4K random reads 24 threads (different files):
> pmfs-prd: 7,300,000
> ext4-dax: 6,200,000
> shmem:    6,150,000
> 
> fio 4k random writes 24 threads (different files):
> pmfs-prd: 900,000
> ext4-dax: 800,000
> shmem:    3,500,000
> 
> BTW:
> With the new pmfs-prd which I have also ported to the DAX tree - the old
> pmfs was copy/pasting xip-write and xip-mmap from generic code with some
> private hacks, but was still using xip-read stuff. I have just moved the
> old xip-read stuff inside (like write path did before) and so ported to the
> dax tree which removed these functions. I have spent a couple of hours on
> looking on the DAX read/write/mmap path vs the current pmfs read/write/mmap
> paths. Though they are very similar and clearly originated from the same code
> The new DAX code is even more alien to pmfs, specially with the current use
> of buffer-heads. (It could be made to work but with lots of extra shimming)
> So the current DAX form is more "block" based and not very suited to a pure
> memory based FS. If any of those come up they will need their own interfaces
> more similar to shmem's private implementation.

I think you misunderstand the point of buffer_head.  It's not "this is
block based", it's "this is how filesystems describe their extents to
the VFS/block layer".

> Above you said regarding the old xip:
> 	".. but it has some races which are unfixable in the current design"
> 
> I have tested pmfs-prd under xfstest and I'm passing lots of them. I cannot
> easily spot the race you are talking about. (More like dir seeks and missing
> stuff) Could you point me to a test I should run, to try and find it?

xfstests seems to have more "check correct functionality" tests than
"find races" tests.  I'm trying to persuade our QA people to write more
tests for xfstests with little success so far.  Consider truncate()
vs page fault.  Consider truncate() versus read().  Consider write()
to a hole vs page fault on that hole.

Oh, and as for pmfs itself ... consider the fact that it uses RCU for
locking, except the only call to synchronise_rcu() is commented out.
So it only has RCU read locks, which compile to, er, nothing.  If the
RCU were actually protecting anything, the fact that it takes mutexes
while in an RCU locked section would rather invalidate the RCU protection.

So, yeah.  Actually getting the locking right has an effect on
performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
