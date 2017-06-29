Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 758DC6B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 14:13:40 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 19so41166929qty.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:13:40 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id r64si5152229qtd.15.2017.06.29.11.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 11:13:38 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id 91so12618684qkq.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:13:38 -0700 (PDT)
Message-ID: <1498760014.22569.13.camel@poochiereds.net>
Subject: Re: [PATCH v8 12/18] Documentation: flesh out the section in
 vfs.txt on storing and reporting writeback errors
From: Jeff Layton <jlayton@poochiereds.net>
Date: Thu, 29 Jun 2017 14:13:34 -0400
In-Reply-To: <20170629171137.GE5874@birch.djwong.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
	 <20170629131954.28733-13-jlayton@kernel.org>
	 <20170629171137.GE5874@birch.djwong.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>, jlayton@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Thu, 2017-06-29 at 10:11 -0700, Darrick J. Wong wrote:
> On Thu, Jun 29, 2017 at 09:19:48AM -0400, jlayton@kernel.org wrote:
> > From: Jeff Layton <jlayton@redhat.com>
> > 
> > Let's try to make this extra clear for fs authors.
> > 
> > Cc: Jan Kara <jack@suse.cz>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  Documentation/filesystems/vfs.txt | 43 ++++++++++++++++++++++++++++++++++++---
> >  1 file changed, 40 insertions(+), 3 deletions(-)
> > 
> > diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> > index f42b90687d40..1366043b3942 100644
> > --- a/Documentation/filesystems/vfs.txt
> > +++ b/Documentation/filesystems/vfs.txt
> > @@ -576,7 +576,42 @@ should clear PG_Dirty and set PG_Writeback.  It can be actually
> >  written at any point after PG_Dirty is clear.  Once it is known to be
> >  safe, PG_Writeback is cleared.
> >  
> > -Writeback makes use of a writeback_control structure...
> > +Writeback makes use of a writeback_control structure to direct the
> > +operations.  This gives the the writepage and writepages operations some
> > +information about the nature of and reason for the writeback request,
> > +and the constraints under which it is being done.  It is also used to
> > +return information back to the caller about the result of a writepage or
> > +writepages request.
> > +
> > +Handling errors during writeback
> > +--------------------------------
> > +Most applications that utilize the pagecache will periodically call
> > +fsync to ensure that data written has made it to the backing store.
> 
> /me wonders if this sentence ought to be worded more strongly, e.g.
> 
> "Applications that utilize the pagecache must call a data
> synchronization syscall such as fsync, fdatasync, or msync to ensure
> that data written has made it to the backing store."
> 

Well...only if they care about the data. There are some that don't. :)

> I'm also wondering -- fdatasync and msync will also report any writeback
> errors that have happened anywhere (like fsync), since they all map to
> vfs_fsync_range, correct?  If so, I think it worth it to state
> explicitly that the other *sync methods behave the same as fsync w.r.t.
> writeback error reporting.
> 

Good point. I'll fix this to make it clear that fsync, msync and
fdatasync all advance the error cursor in the same way.

While we're on the subject...

What should we do about sync_file_range here? It doesn't currently call
any filesystem operations directly, so we don't have a good way to make
it selectively use errseq_t handling there.

I could resurrect the FS_* flag for that, though I don't really like
that. Should I just go ahead and convert it over to use errseq_t under
the theory that most callers will eventually want that anyway?

Thanks for the review so far!

> > +When there is an error during writeback, they expect that error to be
> > +reported when fsync is called.  After an error has been reported on one
> > +fsync, subsequent fsync calls on the same file descriptor should return
> > +0, unless further writeback errors have occurred since the previous
> > +fsync.
> > +
> > +Ideally, the kernel would report an error only on file descriptions on
> > +which writes were done that subsequently failed to be written back.  The
> > +generic pagecache infrastructure does not track the file descriptions
> > +that have dirtied each individual page however, so determining which
> > +file descriptors should get back an error is not possible.
> > +
> > +Instead, the generic writeback error tracking infrastructure in the
> > +kernel settles for reporting errors to fsync on all file descriptions
> > +that were open at the time that the error occurred.  In a situation with
> > +multiple writers, all of them will get back an error on a subsequent fsync,
> > +even if all of the writes done through that particular file descriptor
> > +succeeded (or even if there were no writes on that file descriptor at all).
> > +
> > +Filesystems that wish to use this infrastructure should call
> > +mapping_set_error to record the error in the address_space when it
> > +occurs.  Then, at the end of their fsync operation, they should call
> > +file_check_and_advance_wb_err to ensure that the struct file's error
> > +cursor has advanced to the correct point in the stream of errors emitted
> > +by the backing device(s).
> >  
> >  struct address_space_operations
> >  -------------------------------
> > @@ -804,7 +839,8 @@ struct address_space_operations {
> >  The File Object
> >  ===============
> >  
> > -A file object represents a file opened by a process.
> > +A file object represents a file opened by a process. This is also known
> > +as an "open file description" in POSIX parlance.
> >  
> >  
> >  struct file_operations
> > @@ -887,7 +923,8 @@ otherwise noted.
> >  
> >    release: called when the last reference to an open file is closed
> >  
> > -  fsync: called by the fsync(2) system call
> > +  fsync: called by the fsync(2) system call. Also see the section above
> > +	 entitled "Handling errors during writeback".
> >  
> >    fasync: called by the fcntl(2) system call when asynchronous
> >  	(non-blocking) mode is enabled for a file
> > -- 
> > 2.13.0
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
