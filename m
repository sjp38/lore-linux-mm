Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D88276B0258
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:48:49 -0500 (EST)
Received: by padhx2 with SMTP id hx2so184667714pad.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:48:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id mj10si36292555pab.207.2015.11.16.11.48.48
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 11:48:48 -0800 (PST)
Date: Mon, 16 Nov 2015 12:48:46 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 03/11] pmem: enable REQ_FUA/REQ_FLUSH handling
Message-ID: <20151116194846.GB32203@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4j4arHE+iAALn1WPDzSb_QSCDy8udtXU1FV=kYSZDfv8A@mail.gmail.com>
 <22E0F870-C1FB-431E-BF6C-B395A09A2B0D@dilger.ca>
 <CAPcyv4jwx3VzyRugcpH7KCOKM64kJ4Bq4wgY=iNJMvLTHrBv-Q@mail.gmail.com>
 <20151116133714.GB3443@quack.suse.cz>
 <20151116140526.GA6733@quack.suse.cz>
 <CAPcyv4jZjnkz2YYtGWmkA23KAUMT092kjRtFkJ3QrzgPfTucfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jZjnkz2YYtGWmkA23KAUMT092kjRtFkJ3QrzgPfTucfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andreas Dilger <adilger@dilger.ca>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Nov 16, 2015 at 09:28:59AM -0800, Dan Williams wrote:
> On Mon, Nov 16, 2015 at 6:05 AM, Jan Kara <jack@suse.cz> wrote:
> > On Mon 16-11-15 14:37:14, Jan Kara wrote:
> [..]
> > But a question: Won't it be better to do sfence + pcommit only in response
> > to REQ_FLUSH request and don't do it after each write? I'm not sure how
> > expensive these instructions are but in theory it could be a performance
> > win, couldn't it? For filesystems this is enough wrt persistency
> > guarantees...
> 
> We would need to gather the performance data...  The expectation is
> that the cache flushing is more expensive than the sfence + pcommit.

I think we should revisit the idea of removing wmb_pmem() from the I/O path in
both the PMEM driver and in DAX, and just relying on the REQ_FUA/REQ_FLUSH
path to do wmb_pmem() for all cases.  This was brought up in the thread
dealing with the "big hammer" fsync/msync patches as well.

https://lkml.org/lkml/2015/11/3/730

I think we can all agree from the start that wmb_pmem() will have a nonzero
cost, both because of the PCOMMIT and because of the ordering caused by the
sfence.  If it's possible to avoid doing it on each I/O, I think that would be
a win.

So, here would be our new flows:

PMEM I/O:
	write I/O(s) to the driver
		PMEM I/O writes the data using non-temporal stores

	REQ_FUA/REQ_FLUSH to the PMEM driver
		wmb_pmem() to order all previous writes and flushes, and to
		PCOMMIT the dirty data durably to the DIMMs

DAX I/O:
	write I/O(s) to the DAX layer
		write the data using regular stores (eventually to be replaced
		with non-temporal stores)

		flush the data with wb_cache_pmem() (removed when we use
		non-temporal stores)

	REQ_FUA/REQ_FLUSH to the PMEM driver
		wmb_pmem() to order all previous writes and flushes, and to
		PCOMMIT the dirty data durably to the DIMMs

DAX msync/fsync:
	writes happen to DAX mmaps from userspace

	DAX fsync/msync
		all dirty pages are written back using wb_cache_pmem()

	REQ_FUA/REQ_FLUSH to the PMEM driver
		wmb_pmem() to order all previous writes and flushes, and to
		PCOMMIT the dirty data durably to the DIMMs
	
DAX/PMEM zeroing (suggested by Dave: https://lkml.org/lkml/2015/11/2/772):
	PMEM driver receives zeroing request
		writes a bunch of zeroes using non-temporal stores

	REQ_FUA/REQ_FLUSH to the PMEM driver
		wmb_pmem() to order all previous writes and flushes, and to
		PCOMMIT the dirty data durably to the DIMMs

Having all these flows wait to do wmb_pmem() in the PMEM driver in response to
REQ_FUA/REQ_FLUSH has several advantages:

1) The work done and guarantees provided after each step closely match the
normal block I/O to disk case.  This means that the existing algorithms used
by filesystems to make sure that their metadata is ordered properly and synced
at a known time should all work the same.

2) By delaying wmb_pmem() until REQ_FUA/REQ_FLUSH time we can potentially do
many I/Os at different levels, and order them all with a single wmb_pmem().
This should result in a performance win.

Is there any reason why this wouldn't work or wouldn't be a good idea?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
