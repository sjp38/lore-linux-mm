Date: Tue, 24 Apr 2007 08:17:56 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 06/44] mm: trim more holes
Message-ID: <20070424061756.GA20640@wotan.suse.de>
References: <20070424012346.696840000@suse.de> <20070424013432.826128000@suse.de> <17965.40615.454568.662916@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <17965.40615.454568.662916@notabene.brown>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 24, 2007 at 04:07:35PM +1000, Neil Brown wrote:
> On Tuesday April 24, npiggin@suse.de wrote:
> > 
> > If prepare_write fails with AOP_TRUNCATED_PAGE, or if commit_write fails, then
> > we may have failed the write operation despite prepare_write having
> > instantiated blocks past i_size. Fix this, and consolidate the trimming into
> > one place.
> > 
> ..
> > @@ -2025,40 +2012,53 @@ generic_file_buffered_write(struct kiocb
> >  						cur_iov, iov_offset, bytes);
> >  		flush_dcache_page(page);
> >  		status = a_ops->commit_write(file, page, offset, offset+bytes);
> > -		if (status == AOP_TRUNCATED_PAGE) {
> > -			page_cache_release(page);
> > -			continue;
> > +		if (unlikely(status < 0))
> > +			goto fs_write_aop_error;
> > +		if (unlikely(copied != bytes)) {
> > +			status = -EFAULT;
> > +			goto fs_write_aop_error;
> >  		}
> 
> It isn't clear to me that you are handling the case
>        status == AOP_TRUNCATED_PAGE
> here.  AOP_TRUNCATED_PAGE is > 0 (0x80001 to be precise)

Yes, you are right there.


> Maybe ->commit_write cannot return AOP_TRUNCATED_PAGE.  If that is
> true, then a comment to that effect (i.e. that the old code was wrong)
> in the change log might easy review. 
> 
> Or did I miss something?

Actually, it seems that the old ocfs2 code (in mainline, not -mm) can
return AOP_TRUNCATED_PAGE from commit_write.

So that line should be changed to
+           if (unlikely(status < 0 || status == AOP_TRUNCATED_PAGE)) 

Although we get rid of it in a subsequent patch anyway.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
