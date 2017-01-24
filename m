Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 345A06B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 19:46:34 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id x49so129988748qtc.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:46:34 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id m82si2903568qkh.115.2017.01.23.16.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 16:46:32 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id n13so21311071qtc.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:46:32 -0800 (PST)
Message-ID: <1485218787.2786.23.camel@poochiereds.net>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
From: Jeff Layton <jlayton@poochiereds.net>
Date: Mon, 23 Jan 2017 19:46:27 -0500
In-Reply-To: <878tq1ia6l.fsf@notabene.neil.brown.name>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, Trond Myklebust <trondmy@primarydata.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "hch@infradead.org" <hch@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Tue, 2017-01-24 at 11:16 +1100, NeilBrown wrote:
> On Mon, Jan 23 2017, Trond Myklebust wrote:
> 
> > On Mon, 2017-01-23 at 17:35 -0500, Jeff Layton wrote:
> > > On Mon, 2017-01-23 at 11:09 +0100, Kevin Wolf wrote:
> > > > 
> > > > However, if we look at the greater problem of hanging requests that
> > > > came
> > > > up in the more recent emails of this thread, it is only moved
> > > > rather
> > > > than solved. Chances are that already write() would hang now
> > > > instead of
> > > > only fsync(), but we still have a hard time dealing with this.
> > > > 
> > > 
> > > Well, it _is_ better with O_DIRECT as you can usually at least break
> > > out
> > > of the I/O with SIGKILL.
> > > 
> > > When I last looked at this, the problem with buffered I/O was that
> > > you
> > > often end up waiting on page bits to clear (usually PG_writeback or
> > > PG_dirty), in non-killable sleeps for the most part.
> > > 
> > > Maybe the fix here is as simple as changing that?
> > 
> > At the risk of kicking off another O_PONIES discussion: Add an
> > open(O_TIMEOUT) flag that would let the kernel know that the
> > application is prepared to handle timeouts from operations such as
> > read(), write() and fsync(), then add an ioctl() or syscall to allow
> > said application to set the timeout value.
> 
> I was thinking on very similar lines, though I'd use 'fcntl()' if
> possible because it would be a per-"file description" option.
> This would be a function of the page cache, and a filesystem wouldn't
> need to know about it at all.  Once enable, 'read', 'write', or 'fsync'
> would return EWOULDBLOCK rather than waiting indefinitely.
> It might be nice if 'select' could then be used on page-cache file
> descriptors, but I think that is much harder.  Support O_TIMEOUT would
> be a practical first step - if someone agreed to actually try to use it.
> 

Yeah, that does seem like it might be worth exploring.A 

That said, I think there's something even simpler we can do to make
things better for a lot of cases, and it may even help pave the way for
the proposal above.

Looking closer and remembering more, I think the main problem area when
the pages are stuck in writeback is the wait_on_page_writeback call in
places like wait_for_stable_page and __filemap_fdatawait_range.

That uses an uninterruptible sleep and it's common to see applications
stuck there in these situations. They're unkillable too so your only
recourse is to hard reset the box when you can't reestablish
connectivity.

I think it might be good to consider making some of those sleeps
TASK_KILLABLE. For instance, both of the above callers of those
functions are int return functions. It may be possible to return
ERESTARTSYS when the task catches a signal.

-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
