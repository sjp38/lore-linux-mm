Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D72886B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 17:36:02 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f4so126693317qte.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:36:02 -0800 (PST)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id 102si11801668qte.37.2017.01.23.14.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 14:36:01 -0800 (PST)
Received: by mail-qt0-x244.google.com with SMTP id a29so20607639qtb.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:36:01 -0800 (PST)
Message-ID: <1485210957.2786.19.camel@poochiereds.net>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
From: Jeff Layton <jlayton@poochiereds.net>
Date: Mon, 23 Jan 2017 17:35:57 -0500
In-Reply-To: <20170123100941.GA5745@noname.redhat.com>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Wolf <kwolf@redhat.com>, Theodore Ts'o <tytso@mit.edu>
Cc: NeilBrown <neilb@suse.com>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Ric Wheeler <rwheeler@redhat.com>

On Mon, 2017-01-23 at 11:09 +0100, Kevin Wolf wrote:
> Am 23.01.2017 um 01:21 hat Theodore Ts'o geschrieben:
> > On Sun, Jan 22, 2017 at 06:31:57PM -0500, Jeff Layton wrote:
> > > 
> > > Ahh, sorry if I wasn't clear.
> > > 
> > > I know Kevin posed this topic in the context of QEMU/KVM, and I figure
> > > that running virt guests (themselves doing all sorts of workloads) is a
> > > pretty common setup these days. That was what I meant by "use case"
> > > here. Obviously there are many other workloads that could benefit from
> > > (or be harmed by) changes in this area.
> > > 
> > > Still, I think that looking at QEMU/KVM as a "application" and
> > > considering what we can do to help optimize that case could be helpful
> > > here (and might also be helpful for other workloads).
> > 
> > Well, except for QEMU/KVM, Kevin has already confirmed that using
> > Direct I/O is a completely viable solution.  (And I'll add it solves a
> > bunch of other problems, including page cache efficiency....)
> 
> Yes, "don't ever use non-O_DIRECT in production" is probably workable as
> a solution to the "state after failed fsync()" problem, as long as it is
> consistently implemented throughout the stack. That is, if we use a
> network protocol in QEMU (NFS, gluster, etc.), the server needs to use
> O_DIRECT, too, if we don't want to get the same problem one level down
> the stack. I'm not sure if that's possible with all of them, but if it
> is, it's mostly just a matter of configuring them correctly.
> 

It's actually not necessary with NFS. O_DIRECT I/O is entirely a client-
side thing. There's no support for it in the protocol (and there doesn't
really need to be).

If something happens and the server crashed before the writes were
stable, then I believe the client will reissue them.

If both the client and server crash at the same time, then all bets are
off of course. :)

> However, if we look at the greater problem of hanging requests that came
> up in the more recent emails of this thread, it is only moved rather
> than solved. Chances are that already write() would hang now instead of
> only fsync(), but we still have a hard time dealing with this.
> 

Well, it _is_ better with O_DIRECT as you can usually at least break out
of the I/O with SIGKILL.

When I last looked at this, the problem with buffered I/O was that you
often end up waiting on page bits to clear (usually PG_writeback or
PG_dirty), in non-killable sleeps for the most part.

Maybe the fix here is as simple as changing that?
-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
