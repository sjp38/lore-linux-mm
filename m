Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02D8C6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 17:40:23 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id k15so126874915qtg.5
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:40:22 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id m13si11809128qtg.54.2017.01.23.14.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 14:40:22 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id l7so20676438qtd.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:40:22 -0800 (PST)
Message-ID: <1485211219.2786.20.camel@poochiereds.net>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
From: Jeff Layton <jlayton@poochiereds.net>
Date: Mon, 23 Jan 2017 17:40:19 -0500
In-Reply-To: <20170123172500.itzbe7qgzcs6kgh2@thunk.org>
References: <20170113110959.GA4981@noname.redhat.com>
	 <20170113142154.iycjjhjujqt5u2ab@thunk.org>
	 <20170113160022.GC4981@noname.redhat.com>
	 <87mveufvbu.fsf@notabene.neil.brown.name>
	 <1484568855.2719.3.camel@poochiereds.net>
	 <87o9yyemud.fsf@notabene.neil.brown.name>
	 <1485127917.5321.1.camel@poochiereds.net>
	 <20170123002158.xe7r7us2buc37ybq@thunk.org>
	 <20170123100941.GA5745@noname.redhat.com>
	 <1485173400.2786.5.camel@poochiereds.net>
	 <20170123172500.itzbe7qgzcs6kgh2@thunk.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Kevin Wolf <kwolf@redhat.com>, NeilBrown <neilb@suse.com>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Ric Wheeler <rwheeler@redhat.com>

On Mon, 2017-01-23 at 12:25 -0500, Theodore Ts'o wrote:
> On Mon, Jan 23, 2017 at 07:10:00AM -0500, Jeff Layton wrote:
> > > > Well, except for QEMU/KVM, Kevin has already confirmed that using
> > > > Direct I/O is a completely viable solution.  (And I'll add it solves a
> > > > bunch of other problems, including page cache efficiency....)
> > 
> > Sure, O_DIRECT does make this simpler (though it's not always the most
> > efficient way to do I/O). I'm more interested in whether we can improve
> > the error handling with buffered I/O.
> 
> I just want to make sure we're designing a solution that will actually
> be _used_, because it is a good fit for at least one real-world use
> case.
> 

Exactly. Asking how the QEMU folks would like to be able to interact
with the kernel is not the same as promising to implement said solution.
Still, I think it's a valid question, and I'll pose it in terms of NFS
though I think the semantics apply to other situations as well.

I'm mostly just asking to get a better idea of what the KVM folks would
really like to have happen in this situation. I don't think they want to
error out on every network blip, but in the face of a hung mount that
isn't making progress in writeback, what would they like to be able to
do to resolve it?

For instance, With NFS you can generally send a SIGKILL to the process
to make it abandon O_DIRECT writes. But, tasks accessing NFS mounts
still seem to get stuck in buffered writeback if the server goes away,
generally waiting on the page bits to clear in uninterruptible sleeps.

Would better handling of SIGKILL when waiting on buffered writeback be
what QEMU devs would like? That seems like a reasonable thing to
consider.

> Is QEMU/KVM using volumes that are stored over NFS really used in the
real world?  Especially one where you want a huge amount of
reliability and recovery after some kind network failure?  If we are
talking about customers who are going to suspend the VM and restart it
on another server, that presumes a fairly large installation size and
enough servers that would they *really* want to use a single point of
failure such as an NFS filer?  Even if it was a proprietary
> purpose-built NFS filer?  Why wouldn't they be using RADOS and Cephinstead, for example?

Nothing specific about NFS in what I was asking. I think cephfs has
similar behavior in the face of the client not being able to reach any
of its MDS', for instance.


-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
