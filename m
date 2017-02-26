Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1F086B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 17:43:57 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id x71so106806021qkb.6
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 14:43:57 -0800 (PST)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com. [209.85.220.174])
        by mx.google.com with ESMTPS id 25si703310qts.283.2017.02.26.14.43.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 14:43:56 -0800 (PST)
Received: by mail-qk0-f174.google.com with SMTP id u188so73319978qkc.2
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 14:43:56 -0800 (PST)
Message-ID: <1488149033.2855.2.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] do we really need PG_error at all?
From: Jeff Layton <jlayton@redhat.com>
Date: Sun, 26 Feb 2017 17:43:53 -0500
In-Reply-To: <877f4cr7ew.fsf@notabene.neil.brown.name>
References: <1488120164.2948.4.camel@redhat.com>
	 <1488129033.4157.8.camel@HansenPartnership.com>
	 <877f4cr7ew.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, linux-scsi <linux-scsi@vger.kernel.org>, linux-block@vger.kernel.org

On Mon, 2017-02-27 at 08:03 +1100, NeilBrown wrote:
> On Sun, Feb 26 2017, James Bottomley wrote:
> 
> > [added linux-scsi and linux-block because this is part of our error
> > handling as well]
> > On Sun, 2017-02-26 at 09:42 -0500, Jeff Layton wrote:
> > > Proposing this as a LSF/MM TOPIC, but it may turn out to be me just 
> > > not understanding the semantics here.
> > > 
> > > As I was looking into -ENOSPC handling in cephfs, I noticed that
> > > PG_error is only ever tested in one place [1] 
> > > __filemap_fdatawait_range, which does this:
> > > 
> > > 	if (TestClearPageError(page))
> > > 		ret = -EIO;
> > > 
> > > This error code will override any AS_* error that was set in the
> > > mapping. Which makes me wonder...why don't we just set this error in 
> > > the mapping and not bother with a per-page flag? Could we potentially
> > > free up a page flag by eliminating this?
> > 
> > Note that currently the AS_* codes are only set for write errors not
> > for reads and we have no mapping error handling at all for swap pages,
> > but I'm sure this is fixable.
> 
> How is a read error different from a failure to set PG_uptodate?
> Does PG_error suppress retries?
> 

The thing is that we only ever TestClearError in write and fsync type
codepaths. Does it make sense to report read errors _at_all_ in fsync?

> > 
> > From the I/O layer point of view we take great pains to try to pinpoint
> > the error exactly to the sector.  We reflect this up by setting the
> > PG_error flag on the page where the error occurred.  If we only set the
> > error on the mapping, we lose that granularity, because the mapping is
> > mostly at the file level (or VMA level for anon pages).
> 
> Are you saying that the IO layer finds the page in the bi_io_vec and
> explicitly sets PG_error, rather than just passing an error indication
> to bi_end_io ??  That would seem to be wrong as the page may not be in
> the page cache. So I guess I misunderstand you.
> 
> > 
> > So I think the question for filesystem people from us would be do you
> > care about this accuracy?  If it's OK just to know an error occurred
> > somewhere in this file, then perhaps we don't need it.
> 
> I had always assumed that a bio would either succeed or fail, and that
> no finer granularity could be available.
> 
> I think the question here is: Do filesystems need the pagecache to
> record which pages have seen an IO error?
> I think that for write errors, there is no value in recording
> block-oriented error status - only file-oriented status.
> For read errors, it might if help to avoid indefinite read retries, but
> I don't know the code well enough to be sure if this is an issue.
> 

Yeah, it might be useful for preventing failing read retries, but I
don't see that it's being used in that way today, unless I'm missing
something.

If PG_error is ultimately needed, I'd like to have some more clearly
defined semantics for it. It's sprinkled all over the place today, and
it's not clear to me that it's being used correctly everywhere.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
