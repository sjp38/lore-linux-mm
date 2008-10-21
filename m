Date: Tue, 21 Oct 2008 14:38:14 +0100
From: steve@chygwyn.com
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081021133814.GA26942@fogou.chygwyn.com>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 21, 2008 at 03:14:48PM +0200, Miklos Szeredi wrote:
> On Tue, 21 Oct 2008, steve@chygwyn.com
> > > Is there a case where retrying in case of !PageUptodate() makes any
> > > sense?
> > >
> > Yes... cluster filesystems. Its very important in case a readpage
> > races with a lock demotion. Since the introduction of page_mkwrite
> > that hasn't worked quite right, but by retrying when the page is
> > not uptodate, that should fix the problem,
> 
> I see.
> 
> Could you please give some more details?  In particular I don't know
> what's lock demotion in this context.  And how page_mkwrite() come
> into the picture?
> 
> Thanks,
> Miklos

page_mkwrite is only in the picture really because its the last
time that code was changed. At that point GFS2 adopted
->filemap_fault() rather than using its own page fault
routine.

So here are the basics of locking, so far as GFS2 goes, although
other cluster filesystems are similar. Lets suppose that on
node A, an inode is in cache and its being read/written and
on node B, another process wants to perform some operation
(read/write/etc) on the same inode.

Node B requests a lock via the dlm which causes Node A to
receive a callback. The callback sets a flag in the glock[*]
state on Node A corresponding to the inode in question. This
results in all future requests for that particular lock on
Node A blocking. Also at that time, we unmap any mapped pages
relating to that inode, flush any dirty data back onto the
disk (and if the request was for an exclusive lock, invalidate
the pages as well). So thats what I was refering to above as
lock demotion.

Once thats done, the dlm/glock is dropped (again notification is via
the dlm) and if Node A has outstanding requests queued up, it
re-requests the glock. This is a slightly simplified explanation
but, I hope it gives the general drift.

So to return to the original subject, in order to allow all
this locking to occur with no lock ordering problems, we have
to define a suitable ordering of page locks vs. glocks, and the
ordering that we use is that glocks must come before page locks. The
full ordering of locks in GFS2 is in Documentation/filesystems/gfs2-glocks.txt

As a result of that, the VFS needs reads (and page_mkwrite) to
retry when !PageUptodate() in case the returned page has been
invalidated at any time when the page lock has been dropped.

Obviously we hope that this doesn't happen too often since its
very inefficient (and we have a system to try and reduce the
frequency of such events) but it can and does happen at more
or less any time, so the vfs needs to take that into account.

I hope that makes some kind of sense... let me know if its
not clear,

Steve.

[*] The glock layer is a state machine which is associated with each
dlm lock and performs the required actions is response to dlm messages
and filesystem requests to keep the page cache coherent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
