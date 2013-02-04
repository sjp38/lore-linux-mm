Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 30C0A6B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 07:38:35 -0500 (EST)
Date: Mon, 4 Feb 2013 13:38:31 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/6 RFC] Mapping range lock
Message-ID: <20130204123831.GE7523@quack.suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
 <20130131160757.06d7f1c2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130131160757.06d7f1c2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu 31-01-13 16:07:57, Andrew Morton wrote:
> On Thu, 31 Jan 2013 22:49:48 +0100
> Jan Kara <jack@suse.cz> wrote:
> 
> > There are several different motivations for implementing mapping range
> > locking:
> > 
> > a) Punch hole is currently racy wrt mmap (page can be faulted in in the
> >    punched range after page cache has been invalidated) leading to nasty
> >    results as fs corruption (we can end up writing to already freed block),
> >    user exposure of uninitialized data, etc. To fix this we need some new
> >    mechanism of serializing hole punching and page faults.
> 
> This one doesn't seem very exciting - perhaps there are local fixes
> which can be made?
  I agree this probably won't be triggered by accident since punch hole
uses are limited. But a malicious user is a different thing...

Regarding local fix - local in what sense? We could fix it inside each
filesystem separately but the number of filesystems supporting punch hole
is growing so I don't think it's a good decision for each of them to devise
their own synchronization mechanisms. Fixing 'locally' in a sence that we
fix just the mmap vs punch hole race is possible but we need some
synchronisation of page fault and punch hole - likely in a form of rwsem
where page fault will take a reader side and punch hole a writer side. So
this "minimal" fix requires additional rwsem in struct address_space and
also incurs some cost to page fault path. It is likely a lower cost than
the one of range locking but there is some.

> > b) There is an uncomfortable number of mechanisms serializing various paths
> >    manipulating pagecache and data underlying it. We have i_mutex, page lock,
> >    checks for page beyond EOF in pagefault code, i_dio_count for direct IO.
> >    Different pairs of operations are serialized by different mechanisms and
> >    not all the cases are covered. Case (a) above is likely the worst but DIO
> >    vs buffered IO isn't ideal either (we provide only limited consistency).
> >    The range locking should somewhat simplify serialization of pagecache
> >    operations. So i_dio_count can be removed completely, i_mutex to certain
> >    extent (we still need something for things like timestamp updates,
> >    possibly for i_size changes although those can be dealt with I think).
> 
> Those would be nice cleanups and simplifications, to make kernel
> developers' lives easier.  And there is value in this, but doing this
> means our users incur real costs.
> 
> I'm rather uncomfortable changes which make our lives easier at the
> expense of our users.  If we had an infinite amount of labor, we
> wouldn't do this.  In reality we have finite labor, but a small cost
> dispersed amongst millions or billions of users becomes a very large
> cost.
  I agree there's a cost (as with everything) and personally I feel the
cost is larger than I'd like so we mostly agree on that. OTOH I don't quite
buy the argument "multiplied by millions or billions of users" - the more
machines running the code, the more wealth these machines hopefully
generate ;-). So where the additional cost starts mattering is when it is
making the code not worth it for some purposes. But this is really
philosophy :)

> > c) i_mutex doesn't allow any paralellism of operations using it and some
> >    filesystems workaround this for specific cases (e.g. DIO reads). Using
> >    range locking allows for concurrent operations (e.g. writes, DIO) on
> >    different parts of the file. Of course, range locking itself isn't
> >    enough to make the parallelism possible. Filesystems still have to
> >    somehow deal with the concurrency when manipulating inode allocation
> >    data. But the range locking at least provides a common VFS mechanism for
> >    serialization VFS itself needs and it's upto each filesystem to
> >    serialize more if it needs to.
> 
> That would be useful to end-users, but I'm having trouble predicting
> *how* useful.
  As Zheng said, there are people interested in this for DIO. Currently
filesystems each invent their own tweaks to avoid the serialization at
least for the easiest cases.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
