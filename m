Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE376B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:45:30 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id v73so82922259ywg.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:45:30 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id u123si1828361ybf.159.2017.01.11.07.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 07:45:29 -0800 (PST)
Date: Wed, 11 Jan 2017 10:45:26 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170111154526.tlydtezw5akf72c2@thunk.org>
References: <20170110160224.GC6179@noname.redhat.com>
 <20170111050356.ldlx73n66zjdkh6i@thunk.org>
 <20170111094729.GH16116@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170111094729.GH16116@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Kevin Wolf <kwolf@redhat.com>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Ric Wheeler <rwheeler@redhat.com>

On Wed, Jan 11, 2017 at 10:47:29AM +0100, Jan Kara wrote:
> Well, as Neil pointed out, the problem is that once the data hits page
> cache, we lose the association with a file descriptor. So for example
> background writeback or sync(2) can find the dirty data and try to write
> it, get EIO, and then you have to do something about it because you don't
> know whether fsync(2) is coming or not.

We could solve that by being able to track the number of open file
descriptors in struct inode.  We have i_writecount and i_readcount (if
CONFIG_IMA is defined).  So we can *almost* do this already.  If we
always tracked i_readcount, then we would have the count of all struct
files opened that are writeable or read-only.  So we *can* know
whether or not the page is backed by an inode that has an open file
descriptor.

So the hueristic I'm suggesting is "if i_writecount + i_readcount is
non-zero, then keep the pages".  The pages would be marked with the
error flag, so fsync() can harvest the fact that there was an error,
but afterwards, the pages would be left marked dirty.  After the last
file descriptor is closed, on the next attempt to writeback those
pages, if the I/O error is still occuring, we can make the pages go
away.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
