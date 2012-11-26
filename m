Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id D6F9A6B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 17:09:14 -0500 (EST)
Date: Mon, 26 Nov 2012 17:09:08 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Bug 50981] generic_file_aio_read ?: No locking means DATA
 CORRUPTION read and write on same 4096 page  range
Message-ID: <20121126220908.GA20733@infradead.org>
References: <bug-50981-5823@https.bugzilla.kernel.org/>
 <20121126163328.ACEB011FE9C@bugzilla.kernel.org>
 <20121126164555.GL31891@thunk.org>
 <alpine.LNX.2.00.1211261144190.1183@eggly.anvils>
 <20121126201308.GA21050@infradead.org>
 <20121126214937.GA21590@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126214937.GA21590@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, bugzilla-daemon@bugzilla.kernel.org, meetmehiro@gmail.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Nov 26, 2012 at 04:49:37PM -0500, Theodore Ts'o wrote:
> Christoph, can you give some kind of estimate for the overhead that
> adding this locking in XFS actually costs in practice?

I don't know any real life measurements, but in terms of implementation
the over head is:

 a) taking a the rw_semaphore in shared mode for every buffered read
 b) taking the slightly slower exclusive rw_semaphore for buffered writes
    instead of the plain mutex

On the other hand it significantly simplifies the locking for direct
I/O and allows parallel direct I/O writers.

> And does XFS
> provide any kind of consistency guarantees if the reads/write overlap
> spans multiple pages?  I assume the answer to that is no, correct?

The answer is yes as the lock is taken globally on the inode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
