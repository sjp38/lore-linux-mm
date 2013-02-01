Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 769AA6B000A
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 19:07:59 -0500 (EST)
Date: Thu, 31 Jan 2013 16:07:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6 RFC] Mapping range lock
Message-Id: <20130131160757.06d7f1c2.akpm@linux-foundation.org>
In-Reply-To: <1359668994-13433-1-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Jan 2013 22:49:48 +0100
Jan Kara <jack@suse.cz> wrote:

> There are several different motivations for implementing mapping range
> locking:
> 
> a) Punch hole is currently racy wrt mmap (page can be faulted in in the
>    punched range after page cache has been invalidated) leading to nasty
>    results as fs corruption (we can end up writing to already freed block),
>    user exposure of uninitialized data, etc. To fix this we need some new
>    mechanism of serializing hole punching and page faults.

This one doesn't seem very exciting - perhaps there are local fixes
which can be made?

> b) There is an uncomfortable number of mechanisms serializing various paths
>    manipulating pagecache and data underlying it. We have i_mutex, page lock,
>    checks for page beyond EOF in pagefault code, i_dio_count for direct IO.
>    Different pairs of operations are serialized by different mechanisms and
>    not all the cases are covered. Case (a) above is likely the worst but DIO
>    vs buffered IO isn't ideal either (we provide only limited consistency).
>    The range locking should somewhat simplify serialization of pagecache
>    operations. So i_dio_count can be removed completely, i_mutex to certain
>    extent (we still need something for things like timestamp updates,
>    possibly for i_size changes although those can be dealt with I think).

Those would be nice cleanups and simplifications, to make kernel
developers' lives easier.  And there is value in this, but doing this
means our users incur real costs.

I'm rather uncomfortable changes which make our lives easier at the
expense of our users.  If we had an infinite amount of labor, we
wouldn't do this.  In reality we have finite labor, but a small cost
dispersed amongst millions or billions of users becomes a very large
cost.

> c) i_mutex doesn't allow any paralellism of operations using it and some
>    filesystems workaround this for specific cases (e.g. DIO reads). Using
>    range locking allows for concurrent operations (e.g. writes, DIO) on
>    different parts of the file. Of course, range locking itself isn't
>    enough to make the parallelism possible. Filesystems still have to
>    somehow deal with the concurrency when manipulating inode allocation
>    data. But the range locking at least provides a common VFS mechanism for
>    serialization VFS itself needs and it's upto each filesystem to
>    serialize more if it needs to.

That would be useful to end-users, but I'm having trouble predicting
*how* useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
