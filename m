Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4955F6B0387
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 18:57:32 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id x71so108648138qkb.6
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 15:57:32 -0800 (PST)
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com. [209.85.220.173])
        by mx.google.com with ESMTPS id s66si10629578qkh.230.2017.02.26.15.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 15:57:31 -0800 (PST)
Received: by mail-qk0-f173.google.com with SMTP id u188so74607150qkc.2
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 15:57:31 -0800 (PST)
Message-ID: <1488153448.2855.4.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] do we really need PG_error at all?
From: Jeff Layton <jlayton@redhat.com>
Date: Sun, 26 Feb 2017 18:57:28 -0500
In-Reply-To: <1488151856.4157.50.camel@HansenPartnership.com>
References: <1488120164.2948.4.camel@redhat.com>
	 <1488129033.4157.8.camel@HansenPartnership.com>
	 <877f4cr7ew.fsf@notabene.neil.brown.name>
	 <1488151856.4157.50.camel@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, NeilBrown <neilb@suse.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, linux-scsi <linux-scsi@vger.kernel.org>, linux-block@vger.kernel.org

On Sun, 2017-02-26 at 15:30 -0800, James Bottomley wrote:
> On Mon, 2017-02-27 at 08:03 +1100, NeilBrown wrote:
> > On Sun, Feb 26 2017, James Bottomley wrote:
> > 
> > > [added linux-scsi and linux-block because this is part of our error
> > > handling as well]
> > > On Sun, 2017-02-26 at 09:42 -0500, Jeff Layton wrote:
> > > > Proposing this as a LSF/MM TOPIC, but it may turn out to be me 
> > > > just not understanding the semantics here.
> > > > 
> > > > As I was looking into -ENOSPC handling in cephfs, I noticed that
> > > > PG_error is only ever tested in one place [1] 
> > > > __filemap_fdatawait_range, which does this:
> > > > 
> > > > 	if (TestClearPageError(page))
> > > > 		ret = -EIO;
> > > > 
> > > > This error code will override any AS_* error that was set in the
> > > > mapping. Which makes me wonder...why don't we just set this error 
> > > > in the mapping and not bother with a per-page flag? Could we
> > > > potentially free up a page flag by eliminating this?
> > > 
> > > Note that currently the AS_* codes are only set for write errors 
> > > not for reads and we have no mapping error handling at all for swap
> > > pages, but I'm sure this is fixable.
> > 
> > How is a read error different from a failure to set PG_uptodate?
> > Does PG_error suppress retries?
> 
> We don't do any retries in the code above the block layer (or at least
> we shouldn't).  
> 
> > > 
> > > From the I/O layer point of view we take great pains to try to 
> > > pinpoint the error exactly to the sector.  We reflect this up by 
> > > setting the PG_error flag on the page where the error occurred.  If 
> > > we only set the error on the mapping, we lose that granularity, 
> > > because the mapping is mostly at the file level (or VMA level for
> > > anon pages).
> > 
> > Are you saying that the IO layer finds the page in the bi_io_vec and
> > explicitly sets PG_error,
> 
> I didn't say anything about the mechanism.  I think the function you're
> looking for is fs/mpage.c:mpage_end_io().  layers below block indicate
> the position in the request.  Block maps the position to bio and the
> bio completion maps to page.  So the actual granularity seen in the
> upper layer depends on how the page to bio mapping is done.
> 
> >  rather than just passing an error indication to bi_end_io ??  That
> > would seem to be wrong as the page may not be in the page cache.
> 
> Usually pages in the mpage_end_io path are pinned, I think.
> 
> >  So I guess I misunderstand you.
> > 
> > > 
> > > So I think the question for filesystem people from us would be do 
> > > you care about this accuracy?  If it's OK just to know an error
> > > occurred somewhere in this file, then perhaps we don't need it.
> > 
> > I had always assumed that a bio would either succeed or fail, and 
> > that no finer granularity could be available.
> 
> It does ... but a bio can be as small as a single page.
> 
> > I think the question here is: Do filesystems need the pagecache to
> > record which pages have seen an IO error?
> 
> It's not just filesystems.  The partition code uses PageError() ... the
> metadata code might as well (those are things with no mapping).  I'm
> not saying we can't remove PG_error; I am saying it's not going to be
> quite as simple as using the AS_ flags.
> 
> James
> 

Ok, I see what you mean about the partition code. We may very well need
to keep PG_error for things like that.

If we do, then it'd be good to spell out when and how filesystems should
use it. Most of the usage seems to be the result of cargo-cult copying
all over the place.

In particular, I think we might be best off not using PG_error for
writeback errors in filesystems. It complicates the error path there and
I don't see how it adds much benefit. It's also inconsistent as a stray
sync() syscall can wipe the flag in most cases without reporting
anything.

For filesystem read errors, it might make sense to keep it, but it'd be
nice to see some guidelines about how it should be used there.

> > I think that for write errors, there is no value in recording
> > block-oriented error status - only file-oriented status.
> > For read errors, it might if help to avoid indefinite read retries, 
> > but I don't know the code well enough to be sure if this is an issue.
> > 
> > NeilBrown
> > 
> > 
> > > 
> > > James
> > > 
> > > > The main argument I could see for keeping it is that removing it 
> > > > might subtly change the behavior of sync_file_range if you have 
> > > > tasks syncing different ranges in a file concurrently. I'm not 
> > > > sure if that would break any guarantees though.
> > > > 
> > > > Even if we do need it, I think we might need some cleanup here 
> > > > anyway. A lot of readpage operations end up setting that flag 
> > > > when they hit an error. Isn't it wrong to return an error on 
> > > > fsync, just because we had a read error somewhere in the file in 
> > > > a range that was never dirtied?
> > > > 
> > > > --
> > > > [1]: there is another place in f2fs, but it's more or less 
> > > > equivalent to the call site in __filemap_fdatawait_range.
> > > > 

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
