Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF0982F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 15:52:11 -0400 (EDT)
Received: by wmec75 with SMTP id c75so20125364wme.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 12:52:10 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id m135si5789344wmb.47.2015.10.30.12.51.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 12:51:43 -0700 (PDT)
Received: by wikq8 with SMTP id q8so17883248wik.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 12:51:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151030194300.GA22670@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
	<CAPcyv4haGNytokPfgL3m-qOEw=BO4QF5dO3woLSYZDCRmL-YWg@mail.gmail.com>
	<20151030194300.GA22670@linux.intel.com>
Date: Fri, 30 Oct 2015 12:51:40 -0700
Message-ID: <CAPcyv4jnEF2g+tUs+ZZxzmdgacWhU=KepKQvXLfFVHri=Pj+Jg@mail.gmail.com>
Subject: Re: [RFC 00/11] DAX fsynx/msync support
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Fri, Oct 30, 2015 at 12:43 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Fri, Oct 30, 2015 at 11:34:07AM -0700, Dan Williams wrote:
>> On Thu, Oct 29, 2015 at 1:12 PM, Ross Zwisler
>> <ross.zwisler@linux.intel.com> wrote:
>> > This patch series adds support for fsync/msync to DAX.
>> >
>> > Patches 1 through 8 add various utilities that the DAX code will eventually
>> > need, and the DAX code itself is added by patch 9.  Patches 10 and 11 are
>> > filesystem changes that are needed after the DAX code is added, but these
>> > patches may change slightly as the filesystem fault handling for DAX is
>> > being modified ([1] and [2]).
>> >
>> > I've marked this series as RFC because I'm still testing, but I wanted to
>> > get this out there so people would see the direction I was going and
>> > hopefully comment on any big red flags sooner rather than later.
>> >
>> > I realize that we are getting pretty dang close to the v4.4 merge window,
>> > but I think that if we can get this reviewed and working it's a much better
>> > solution than the "big hammer" approach that blindly flushes entire PMEM
>> > namespaces [3].
>> >
>> > [1] http://oss.sgi.com/archives/xfs/2015-10/msg00523.html
>> > [2] http://marc.info/?l=linux-ext4&m=144550211312472&w=2
>> > [3] https://lists.01.org/pipermail/linux-nvdimm/2015-October/002614.html
>> >
>> > Ross Zwisler (11):
>> >   pmem: add wb_cache_pmem() to the PMEM API
>> >   mm: add pmd_mkclean()
>> >   pmem: enable REQ_FLUSH handling
>> >   dax: support dirty DAX entries in radix tree
>> >   mm: add follow_pte_pmd()
>> >   mm: add pgoff_mkclean()
>> >   mm: add find_get_entries_tag()
>> >   fs: add get_block() to struct inode_operations
>> >   dax: add support for fsync/sync
>> >   xfs, ext2: call dax_pfn_mkwrite() on write fault
>> >   ext4: add ext4_dax_pfn_mkwrite()
>>
>> This is great to have when the flush-the-world solution ends up
>> killing performance.  However, there are a couple mitigating options
>> for workloads that dirty small amounts and flush often that we need to
>> collect data on:
>>
>> 1/ Using cache management and pcommit from userspace to skip calls to
>> msync / fsync.  Although, this does not eliminate all calls to
>> blkdev_issue_flush as the fs may invoke it for other reasons.  I
>> suspect turning on REQ_FUA support eliminates a number of those
>> invocations, and pmem already satisfies REQ_FUA semantics by default.
>
> Sure, I'll turn on REQ_FUA in addition to REQ_FLUSH - I agree that PMEM
> already handles the requirements of REQ_FUA, but I didn't realize that it
> might reduce the number of REQ_FLUSH bios we receive.

I'll let Dave chime in, but a lot of the flush requirements come from
guaranteeing the state of the metadata, if metadata updates can be
done with REQ_FUA then there is no subsequent need to flush.

>> 2/ Turn off DAX and use the page cache.  As Dave mentions [1] we
>> should enable this control on a per-inode basis.  I'm folding in this
>> capability as a blkdev_ioctl for the next version of the raw block DAX
>> support patch.
>
> Umm...I think you just said "the way to avoid this delay is to just not use
> DAX".  :)  I don't think this is where we want to go - we are trying to make
> DAX better, not abandon it.

That's a bit of an exaggeration.  Avoiding DAX where it is not
necessary is not "abandoning DAX", it's using the right tool for the
job.  Page cache is fine for many cases.

>> It's entirely possible these mitigations won't eliminate the need for
>> a mechanism like this, but I think we have a bit more work to do to
>> find out how bad this is in practice as well as the crossover point
>> where walking the radix becomes prohibitive.
>
> I'm guessing a single run through xfstests will be enough to convince you that
> the "big hammer" approach is untenable.  Tests that used to take a second now
> take several minutes, at least in my VM testing environment...  And that's
> only using a tiny 4GiB namespace.
>
> Yes, we can distribute the cost over multiple CPUs, but that just distributes
> the problem and doesn't reduce the overall work that needs to be done.
> Ultimately I think that looping through multiple GiB or even TiB of cache
> lines and blindly writing them back individually on every REQ_FLUSH is going
> to be a deal breaker.

Right, part of the problem is that the driver doesn't know which
blocks are actively DAX mapped.  I think we can incrementally fix that
without requiring DAX specific fsync/msync handling code for each fs
that supports DAX.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
