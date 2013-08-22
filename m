Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id D70826B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 09:33:34 -0400 (EDT)
Subject: Re: [PATCH] mm, fs: avoid page allocation beyond i_size on read
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20130822130527.71C0AE0090@blue.fi.intel.com>
References: 
	 <1377099441-2224-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1377100012.2738.28.camel@menhir>
	 <20130821160817.940D3E0090@blue.fi.intel.com>
	 <1377103332.2738.37.camel@menhir>
	 <20130821135821.fc8f5a2551a28c9ce9c4b049@linux-foundation.org>
	 <1377163725.2720.18.camel@menhir>
	 <20130822130527.71C0AE0090@blue.fi.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Aug 2013 14:33:40 +0100
Message-ID: <1377178420.2720.51.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, NeilBrown <neilb@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Hi,

On Thu, 2013-08-22 at 16:05 +0300, Kirill A. Shutemov wrote:
> Steven Whitehouse wrote:
> > Hi,
> > 
> > On Wed, 2013-08-21 at 13:58 -0700, Andrew Morton wrote:
> > > On Wed, 21 Aug 2013 17:42:12 +0100 Steven Whitehouse <swhiteho@redhat.com> wrote:
> > > 
> > > > > I don't think the change is harmful. The worst case scenario is race with
> > > > > write or truncate, but it's valid to return EOF in this case.
> > > > > 
> > > > > What scenario do you have in mind?
> > > > > 
> > > > 
> > > > 1. File open on node A
> > > > 2. Someone updates it on node B by extending the file
> > > > 3. Someone reads the file on node A beyond end of original file size,
> > > > but within end of new file size as updated by node B. Without the patch
> > > > this works, with it, it will fail. The reason being the i_size would not
> > > > be up to date until after readpage(s) has been called.
> 
> CC: +linux-fsdevel@
> 
> So in this case node A will see the file like it was never touched by
> node B. It's okay, if new i_size will eventually reach node A.
> 
> Is ->readpage() the only way to get i_size updated on node A or it will be
> eventually updated without it?
> 
It will be updated by anything which takes a glock in the gfs2 case.
Note that ->readpage() is not a very frequently used aop. For any
filesystem with ->readpages() this should cover almost all calls to the
fs for reading, with ->readpage() only used for some corner cases. So
from a performance point of view, it is ->readpages() which matters
most.

There is no time based updating of the inode information - it relies
entirely upon the locking/cache control provided by the glock layer.

> If it's the only way, we need add a explicit way to initiate i_size sync
> between nodes on read. Probably, distributed filesystems should provide own
> ->aio_read() which deal i_size as the filesystem need.
> 
I'd rather not do that, if we can avoid it. The current system has been
carefully designed so that all the cluster fs knowledge can be hidden in
the layer below the page cache. That means for a read which can be
satisfied from just the page cache, cluster filesystems are the same
speed as local file systems, since it is the same code path. Only when a
page doesn't exist in the cache do we need to take cluster locks in
order to check the file size, etc.

Taking cluster locks can be expensive, since in the worst case it can
involve both the local glock and dlm state machines, and remote dlm and
glock state machines, network communication, and waiting for disk i/o
and log flushes on (a) remote node(s).

Andrew's proposed solution makes sense to me, and is probably the
easiest way to solve this.

> > > > I think this is likely to be an issue for any distributed fs using
> > > > do_generic_file_read(), although it would certainly affect GFS2, since
> > > > the locking is done at page cache level,
> > > 
> > > Boy, that's rather subtle.  I'm surprised that the generic filemap.c
> > > stuff works at all in that sort of scenario.
> > > 
> > > Can we put the i_size check down in the no_cached_page block?  afaict
> > > that will solve the problem without breaking GFS2 and is more
> > > efficient?
> > > 
> > 
> > Well I think is even more subtle, since it relies on ->readpages
> > updating the file size, even if it has failed to actually read the
> > required pages :-) Having said that, we do rely on ->readpages updating
> > the inode size elsewhere in this function, as per the block comment
> > immediately following the page_ok label. 
> 
> That i_size recheck was invented to cover different use case: read vs.
> truncate race. Userspace should not see truncate-caused zeros in buffer.
> It's not to prevent file extending vs. read() race. This usually harmless:
> data is consistent.
> 

Yes, it is a different use case, but the same issue applies that without
a prior call to ->readpage() or ->readpages() then i_size may not be
correct. The comment mentions that there needs to be an uptodate page in
existence in order for i_size to be valid, and that is, at least in the
GFS2 case, an equivalent condition since it implies that ->readpage() or
->readpages() must have been called since the address space was last
invalidated (or alternatively that the page was populated from a local
write, but the effect is the same)

This is only true though, since GFS2 does its locking/caching on a
per-inode basis - it someone wanted to implement a filesystem which
worked on a per-page (for example) basis then the uptodate page criteria
would not necessarily mean that the i_size was also uptodate.

I hope that helps clarify things a bit,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
