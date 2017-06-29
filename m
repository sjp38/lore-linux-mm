Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F95E6B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 16:42:19 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f92so45431974qtb.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:42:19 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id r101si5946111qkr.72.2017.06.29.13.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 13:42:18 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id v143so330393qkb.3
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:42:18 -0700 (PDT)
Message-ID: <1498768934.5710.7.camel@poochiereds.net>
Subject: Re: [PATCH v8 12/18] Documentation: flesh out the section in
 vfs.txt on storing and reporting writeback errors
From: Jeff Layton <jlayton@poochiereds.net>
Date: Thu, 29 Jun 2017 16:42:14 -0400
In-Reply-To: <BY2PR21MB003653755FD85FCE2C49393ECBD20@BY2PR21MB0036.namprd21.prod.outlook.com>
References: <20170629131954.28733-1-jlayton@kernel.org>
	 <20170629131954.28733-13-jlayton@kernel.org>
	 <20170629171137.GE5874@birch.djwong.org>
	 <1498760014.22569.13.camel@poochiereds.net>
	 <BY2PR21MB003653755FD85FCE2C49393ECBD20@BY2PR21MB0036.namprd21.prod.outlook.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, "jlayton@kernel.org" <jlayton@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, "tytso@mit.edu" <tytso@mit.edu>, "axboe@kernel.dk" <axboe@kernel.dk>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "corbet@lwn.net" <corbet@lwn.net>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

On Thu, 2017-06-29 at 18:21 +0000, Matthew Wilcox wrote:
> From: Jeff Layton [mailto:jlayton@poochiereds.net]
> > On Thu, 2017-06-29 at 10:11 -0700, Darrick J. Wong wrote:
> > > On Thu, Jun 29, 2017 at 09:19:48AM -0400, jlayton@kernel.org wrote:
> > > > +Handling errors during writeback
> > > > +--------------------------------
> > > > +Most applications that utilize the pagecache will periodically call
> > > > +fsync to ensure that data written has made it to the backing store.
> > > 
> > > /me wonders if this sentence ought to be worded more strongly, e.g.
> > > 
> > > "Applications that utilize the pagecache must call a data
> > > synchronization syscall such as fsync, fdatasync, or msync to ensure
> > > that data written has made it to the backing store."
> > 
> > Well...only if they care about the data. There are some that don't. :)
> 
> Also, applications don't "utilize the pagecache"; filesystems use the pagecache.
> Applications may or may not use cached I/O.  How about this:
> 

I meant "applications that do buffered I/O" as opposed to O_DIRECT, but
yeah that's not very clear.


> Applications which care about data integrity and use cached I/O will
> periodically call fsync(), msync() or fdatasync() to ensure that their
> data is durable.
> 
> > What should we do about sync_file_range here? It doesn't currently call
> > any filesystem operations directly, so we don't have a good way to make
> > it selectively use errseq_t handling there.
> > 
> > I could resurrect the FS_* flag for that, though I don't really like
> > that. Should I just go ahead and convert it over to use errseq_t under
> > the theory that most callers will eventually want that anyway?
> 
> I think so.

Ok, I'll leave that for the next pile of patches though.

Here's a revised section

------------------------------8<--------------------------------
Handling errors during writeback
--------------------------------
Most applications that do buffered I/O will periodically call a file
synchronization call (fsync, fdatasync, msync or sync_file_range) to
ensure that data written has made it to the backing store.  When there
is an error during writeback, they expect that error to be reported when
a file sync request is made.  After an error has been reported on one
request, subsequent requests on the same file descriptor should return
0, unless further writeback errors have occurred since the previous file
syncronization.

Ideally, the kernel would report errors only on file descriptions on
which writes were done that subsequently failed to be written back.  The
generic pagecache infrastructure does not track the file descriptions
that have dirtied each individual page however, so determining which
file descriptors should get back an error is not possible.

Instead, the generic writeback error tracking infrastructure in the
kernel settles for reporting errors to fsync on all file descriptions
that were open at the time that the error occurred.  In a situation with
multiple writers, all of them will get back an error on a subsequent
fsync,
even if all of the writes done through that particular file descriptor
succeeded (or even if there were no writes on that file descriptor at
all).

Filesystems that wish to use this infrastructure should call
mapping_set_error to record the error in the address_space when it
occurs.  Then, after writing back data from the pagecache in their
file->fsync operation, they should call file_check_and_advance_wb_err to
ensure that the struct file's error cursor has advanced to the correct
point in the stream of errors emitted by the backing device(s).
------------------------------8<--------------------------------

Thanks for the review so far!
-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
