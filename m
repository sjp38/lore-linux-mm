Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C3A136B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 19:13:16 -0500 (EST)
Received: by pdjg10 with SMTP id g10so61610803pdj.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 16:13:16 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id ol1si6779691pdb.236.2015.03.04.16.13.14
        for <linux-mm@kvack.org>;
        Wed, 04 Mar 2015 16:13:15 -0800 (PST)
Date: Thu, 5 Mar 2015 11:13:12 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/3] xfstests: generic/080 test that mmap-write updates
 c/mtime
Message-ID: <20150305001312.GA4251@dastard>
References: <54F733BD.7060807@plexistor.com>
 <54F734C4.7080409@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F734C4.7080409@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Mar 04, 2015 at 06:37:24PM +0200, Boaz Harrosh wrote:
> From: Yigal Korman <yigal@plexistor.com>
> 
> when using mmap() for file i/o, writing to the file should update
> it's c/mtime. Specifically if we first mmap-read from a page, then
> memap-write to the same page.
> 
> This test was failing for the initial submission of DAX because
> pfn based mapping do not have an page_mkwrite called for them.
> The new Kernel patches that introduce pfn_mkwrite fixes this test.

This is a lot more complex than it needs to be - xfs_io does
everything we already need, so the test really just needs to
follow the template set out by generic/309. i.e:


# pattern the file.
$XFS_IO_PROG -f -c "pwrite 0 64k" -c fsync $testfile | _filter_xfs_io

# sample timestamps.
mtime1=`stat -c %Y $testfile`
ctime1=`stat -c %Z $testfile`

# map read followed by map write to trigger timestamp change
sleep 2
$XFS_IO_PROG -c "mmap 0 64k" -c "mread 0 64k" -c "mwrite 0 4k" $testfile |_filter_xfs_io

# sample and check timestamps have changed.
mtime2=`stat -c %Y $testsfile`
ctime2=`stat -c %Z $testsfile`

if [ "$mtime1" == "$mtime2" ]; then
        echo "mtime not updated"
        let status=$status+1
fi
if [ "$ctime1" == "$ctime2" ]; then
        echo "ctime not updated"
        let status=$status+1
fi

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
