Date: Tue, 24 Apr 2007 09:23:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/44] fs: introduce write_begin, write_end, and perform_write aops
Message-ID: <20070424072327.GC20640@wotan.suse.de>
References: <20070424012346.696840000@suse.de> <20070424013433.975224000@suse.de> <17965.43747.979798.715583@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17965.43747.979798.715583@notabene.brown>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 24, 2007 at 04:59:47PM +1000, Neil Brown wrote:
> On Tuesday April 24, npiggin@suse.de wrote:
> > +  write_begin: This is intended as a replacement for prepare_write. Called
> > +        by the generic buffered write code to ask the filesystem to prepare
> > +        to write len bytes at the given offset in the file. flags is a field
> > +        for AOP_FLAG_xxx flags, described in include/linux/mm.h.
> 
> Putting "This is intended as a replacement.." there sees a bit
> dangerous.  It could well accidentally remain when the documentation
> for prepare_write gets removed.  I would make it a separate paragraph
> and flesh it out.  And include text from prepare_write before that
> gets removed.
> 
>    write_begin:
>          This is intended as a replacement for prepare_write.  The key 
>          differences being that:
> 		- it returns a locked page (in *pagep) rather than
>                   being given a pre-locked page:
> 		- it can pass arbitrary state to write_end rather than
> 		  having to hide stuff in some filesystem-internal
> 	          data structure 
> 		- The (largely undocumented) flags option.
> 
>          Called by  the generic bufferred write code to ask an
>          address_space to prepare to write len bytes at the given
>          offset in the file.
> 
> 	 The address_space should check that the write will be able to
>   	 complete, by allocating space if necessary and doing any other
>   	 internal housekeeping.  If the write will update parts of any
>   	 basic-blocks on storage, then those blocks should be pre-read
>   	 (if they haven't been read already) so that the updated blocks
>   	 can be written out properly.
> 	 The possible flags are listed in include/linux/fs.h (not
>   	 mm.h) and include
> 		AOP_FLAG_UNINTERRUPTIBLE:
> 			It is unclear how this should be used.  No
> 		  	current code handles it.

Yeah, reasonable points. I'll do an incremental patch to clean up
some of the documentation.

BTW. AOP_FLAG_UNINTERRUPTIBLE can be used by filesystems to avoid
an initial read or other sequence they might be using to handle the
case of a short write. ecryptfs uses it, others can too.

For buffered writes, this doesn't get passed in (unless they are
coming from kernel space), so I was debating whether to have it at
all.  However, in the previous API, _nobody_ had to worry about
short writes, so this flag means I avoid making an API that is
fundamentally less performant in some situations.

> 
> (together with the rest...)
> > +
> > +        The filesystem must return the locked pagecache page for the caller
> > +        to write into.
> > +
> > +        A void * may be returned in fsdata, which then gets passed into
> > +        write_end.
> > +
> > +        Returns < 0 on failure, in which case all cleanup must be done and
> > +        write_end not called. 0 on success, in which case write_end must
> > +        be called.
> 
> 
> As you are not including perform_write in the current patchset, maybe
> it is best not to include the documentation yet either?

Right, missed that, thanks!

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
