Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9386D6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:00:52 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id x64so70732869qkb.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:00:52 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id o36si15453431qta.179.2017.01.25.05.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 05:00:50 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id a29so31120836qtb.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:00:50 -0800 (PST)
Message-ID: <1485349246.2736.1.camel@poochiereds.net>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
From: Jeff Layton <jlayton@poochiereds.net>
Date: Wed, 25 Jan 2017 08:00:46 -0500
In-Reply-To: <87y3y0glx7.fsf@notabene.neil.brown.name>
References: <20170110160224.GC6179@noname.redhat.com>
	 <87k2a2ig2c.fsf@notabene.neil.brown.name>
	 <20170113110959.GA4981@noname.redhat.com>
	 <20170113142154.iycjjhjujqt5u2ab@thunk.org>
	 <20170113160022.GC4981@noname.redhat.com>
	 <87mveufvbu.fsf@notabene.neil.brown.name>
	 <1484568855.2719.3.camel@poochiereds.net>
	 <87o9yyemud.fsf@notabene.neil.brown.name>
	 <1485127917.5321.1.camel@poochiereds.net>
	 <20170123002158.xe7r7us2buc37ybq@thunk.org>
	 <20170123100941.GA5745@noname.redhat.com>
	 <1485210957.2786.19.camel@poochiereds.net>
	 <1485212994.3722.1.camel@primarydata.com>
	 <878tq1ia6l.fsf@notabene.neil.brown.name>
	 <1485218787.2786.23.camel@poochiereds.net>
	 <87y3y0glx7.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, Trond Myklebust <trondmy@primarydata.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Wed, 2017-01-25 at 08:58 +1100, NeilBrown wrote:
> On Mon, Jan 23 2017, Jeff Layton wrote:
> 
> > On Tue, 2017-01-24 at 11:16 +1100, NeilBrown wrote:
> > > On Mon, Jan 23 2017, Trond Myklebust wrote:
> > > 
> > > > On Mon, 2017-01-23 at 17:35 -0500, Jeff Layton wrote:
> > > > > On Mon, 2017-01-23 at 11:09 +0100, Kevin Wolf wrote:
> > > > > > 
> > > > > > However, if we look at the greater problem of hanging requests that
> > > > > > came
> > > > > > up in the more recent emails of this thread, it is only moved
> > > > > > rather
> > > > > > than solved. Chances are that already write() would hang now
> > > > > > instead of
> > > > > > only fsync(), but we still have a hard time dealing with this.
> > > > > > 
> > > > > 
> > > > > Well, it _is_ better with O_DIRECT as you can usually at least break
> > > > > out
> > > > > of the I/O with SIGKILL.
> > > > > 
> > > > > When I last looked at this, the problem with buffered I/O was that
> > > > > you
> > > > > often end up waiting on page bits to clear (usually PG_writeback or
> > > > > PG_dirty), in non-killable sleeps for the most part.
> > > > > 
> > > > > Maybe the fix here is as simple as changing that?
> > > > 
> > > > At the risk of kicking off another O_PONIES discussion: Add an
> > > > open(O_TIMEOUT) flag that would let the kernel know that the
> > > > application is prepared to handle timeouts from operations such as
> > > > read(), write() and fsync(), then add an ioctl() or syscall to allow
> > > > said application to set the timeout value.
> > > 
> > > I was thinking on very similar lines, though I'd use 'fcntl()' if
> > > possible because it would be a per-"file description" option.
> > > This would be a function of the page cache, and a filesystem wouldn't
> > > need to know about it at all.  Once enable, 'read', 'write', or 'fsync'
> > > would return EWOULDBLOCK rather than waiting indefinitely.
> > > It might be nice if 'select' could then be used on page-cache file
> > > descriptors, but I think that is much harder.  Support O_TIMEOUT would
> > > be a practical first step - if someone agreed to actually try to use it.
> > > 
> > 
> > Yeah, that does seem like it might be worth exploring.A 
> > 
> > That said, I think there's something even simpler we can do to make
> > things better for a lot of cases, and it may even help pave the way for
> > the proposal above.
> > 
> > Looking closer and remembering more, I think the main problem area when
> > the pages are stuck in writeback is the wait_on_page_writeback call in
> > places like wait_for_stable_page and __filemap_fdatawait_range.
> 
> I can't see wait_for_stable_page() being very relevant.  That only
> blocks on backing devices which have requested stable pages.
> raid5 sometimes does that.  Some scsi/sata devices can somehow.
> And rbd (part of ceph) sometimes does.  I don't think NFS ever will.
> wait_for_stable_page() doesn't currently return an error, so getting to
> abort in SIGKILL would be a lot of work.
> 

Ahh right, I missed that it only affects pages backed by a BDI that has
BDI_CAP_STABLE_WRITES. Good.


> filemap_fdatawait_range() is much easier.
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index b772a33ef640..2773f6dde1da 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -401,7 +401,9 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
>  			if (page->index > end)
>  				continue;
>  
> -			wait_on_page_writeback(page);
> +			if (PageWriteback(page))
> +				if (wait_on_page_bit_killable(page, PG_writeback))
> +					err = -ERESTARTSYS;
>  			if (TestClearPageError(page))
>  				ret = -EIO;
>  		}
> 
> That isn't a complete solution. There is code in f2fs which doesn't
> check the return value and probably should.  And gfs2 calls
> 	mapping_set_error(mapping, error);
> with the return value, with we probably don't want in the ERESTARTSYS case.
> There are some usages in btrfs that I'd need to double-check too.
> 
> But it looks to be manageable. 
> 
> Thanks,
> NeilBrown
> 

Yeah, it does. The main worry I have is that this function is called all
over the place in fairly deep call chains. It definitely needs review
and testing (and probably a lot of related fixes like you mention).

We should also note that this is not really a fix for applications,
per-se. It's more of an administrative improvement, to allow admins to
kill off processes stuck waiting for an inode to finish writeback.

I think there may still be room for an interface like you and Trond were
debating. But, I think this might be a good first step and would improve
a lot of hung mount situations.
-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
