Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0476B0260
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 06:32:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p190so58812372wmp.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:32:07 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id h5si28804140wjj.224.2016.11.07.03.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 03:32:06 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id u144so15937866wmu.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:32:06 -0800 (PST)
Date: Mon, 7 Nov 2016 14:07:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161107110736.GA13280@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
 <20161031181035.GA7007@node.shutemov.name>
 <20161101163940.GA5459@quack2.suse.cz>
 <20161102083204.GB13949@node.shutemov.name>
 <20161103204012.GC24234@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161103204012.GC24234@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Nov 03, 2016 at 09:40:12PM +0100, Jan Kara wrote:
> On Wed 02-11-16 11:32:04, Kirill A. Shutemov wrote:
> > Yes, buffer_head list doesn't scale. That's the main reason (along with 4)
> > why syscall-based IO sucks. We spend a lot of time looking for desired
> > block.
> > 
> > We need to switch to some other data structure for storing buffer_heads.
> > Is there a reason why we have list there in first place?
> > Why not just array?
> > 
> > I will look into it, but this sounds like a separate infrastructure change
> > project.
> 
> As Christoph said iomap code should help you with that and make things
> simpler. If things go as we imagine, we should be able to pretty much avoid
> buffer heads. But it will take some time to get there.

Just to clarify: is it show-stopper or we can live with buffer_head list
for now?

> > > 2) PMD-sized pages result in increased space & memory usage.
> > 
> > Space? Do you mean disk space? Not really: we still don't write beyond
> > i_size or into holes.
> > 
> > Behaviour wrt to holes may change with mmap()-IO as we have less
> > granularity, but the same can be seen just between different
> > architectures: 4k vs. 64k base page size.
> 
> Yes, I meant different granularity of mmap based IO. And I agree it isn't a
> new problem but the scale of the problem is much larger with 2MB pages than
> with say 64K pages. And actually the overhead of higher IO granularity of
> 64K pages has been one of the reasons we have switched SLES PPC kernels
> from 64K pages to 4K pages (we've got complaints from customers). 

I guess fadvise()/madvise() hints for opt-in/opt-out should be good enough
to deal with this. I probably need to wire them up.

> > > 3) In ext4 we have to estimate how much metadata we may need to modify when
> > > allocating blocks underlying a page in the worst case (you don't seem to
> > > update this estimate in your patch set). With 2048 blocks underlying a page,
> > > each possibly in a different block group, it is a lot of metadata forcing
> > > us to reserve a large transaction (not sure if you'll be able to even
> > > reserve such large transaction with the default journal size), which again
> > > makes things slower.
> > 
> > I didn't saw this on profiles. And xfstests looks fine. I probably need to
> > run them with 1k blocks once again.
> 
> You wouldn't see this in profiles - it is a correctness thing. And it won't
> be triggered unless the file is heavily fragmented which likely does not
> happen with any test in xfstests. If it happens you'll notice though - the
> filesystem will just report error and shut itself down.

Any suggestion how I can simulate this situation?

> > The numbers below generated with fio. The working set is relatively small,
> > so it fits into page cache and writing set doesn't hit dirty_ratio.
> > 
> > I think the mmap performance should be enough to justify initial inclusion
> > of an experimental feature: it useful for workloads that targets mmap()-IO.
> > It will take time to get feature mature anyway.
> 
> I agree it will take time for feature to mature so I'me fine with
> suboptimal performance in some cases. But I'm not fine with some of the
> hacks you do currently because code maintenability is an issue even if
> people don't actually use the feature...

Hm. Okay, I'll try to check what I can do to make it more maintainable.
My worry is that it will make the patchset even bigger...

> > Configuration:
> >  - 2x E5-2697v2, 64G RAM;
> >  - INTEL SSDSC2CW24;
> >  - IO request size is 4k;
> >  - 8 processes, 512MB data set each;
> 
> The numbers indeed look interesting for mmaped case. Can you post the fio
> cmdline? I'd like to compare profiles...

	fio \
		--directory=/mnt/ \
		--name="$engine-$rw" \
		--ioengine="$engine" \
		--rw="$rw" \
		--size=512M \
		--invalidate=1 \
		--numjobs=8 \
		--runtime=60 \
		--time_based \
		--group_reporting

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
