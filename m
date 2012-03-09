Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 859D96B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 03:19:57 -0500 (EST)
Date: Fri, 9 Mar 2012 09:19:52 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 00/11 v2] Push file_update_time() into .page_mkwrite
Message-ID: <20120309081952.GA21038@quack.suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
 <4F593CF8.2000105@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F593CF8.2000105@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jaya Kumar <jayalk@intworks.biz>, Sage Weil <sage@newdream.net>, ceph-devel@vger.kernel.org, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

  Hello,

On Thu 08-03-12 15:12:56, Andy Lutomirski wrote:
> On 03/01/2012 03:41 AM, Jan Kara wrote:
> >   Hello,
> > 
> >   to provide reliable support for filesystem freezing, filesystems need to have
> > complete control over when metadata is changed. In particular,
> > file_update_time() calls from page fault code make it impossible for
> > filesystems to prevent inodes from being dirtied while the filesystem is
> > frozen.
> > 
> > To fix the issue, this patch set changes page fault code to call
> > file_update_time() only when ->page_mkwrite() callback is not provided. If the
> > callback is provided, it is the responsibility of the filesystem to perform
> > update of i_mtime / i_ctime if needed. We also push file_update_time() call
> > to all existing ->page_mkwrite() implementations if the time update does not
> > obviously happen by other means. If you know your filesystem does not need
> > update of modification times in ->page_mkwrite() handler, please speak up and
> > I'll drop the patch for your filesystem.
> > 
> > As a side note, an alternative would be to remove call of file_update_time()
> > from page fault code altogether and require all filesystems needing it to do
> > that in their ->page_mkwrite() implementation. That is certainly possible
> > although maybe slightly inefficient and would require auditting 100+
> > vm_operations_structs *shiver*.
> 
> 
> 
> IMO updating file times should happen when changes get written out, not
> when a page is made writable, for two reasons:
> 
> 1. Correctness.  With the current approach, it's very easy for files to
> be changed after the last mtime update -- any changes between mkwrite
> and actual writeback won't affect mtime.
> 
> 2. Performance.  I have an application (presumably guessable from my
> email address) for which blocking in page_mkwrite is an absolute
> show-stopper.  (In fact it's so bad that we reverted back to running on
> Windows until I hacked up a kernel to not do this.)  I have an incorrect
> patch [1] to fix it, but I haven't gotten around to a real fix.  (I also
> have stable pages reverted in my kernel.  Some day I'll submit a patch
> to make it a filesystem option.  Or maybe it should even be a block
> device / queue property like the alignment offset and optimal io size --
> there are plenty of block device and file combinations which don't
> benefit at all from stable pages.)
> 
> I'd prefer if file_update_time in page_mkwrite didn't proliferate.  A
> better fix is probably to introduce a new inode flag, update it when a
> page is undirtied, and then dirty and write the inode from the writeback
> path.  (Kind of like my patch, but with an inode flag instead of a page
> flag, and with the file_update_time done from the fs.)
> 
> [1] http://patchwork.ozlabs.org/patch/122516/
  Andy, I'm aware of your problems. Just firstly, I wouldn't like to
complicate the filesystem freezing patch set even more by improving unrelated
things. And secondly, I think these changes won't make fixing your problem
harder. I'd even argue it will be easier because you can do conversion
filesystem by filesystem. Getting lock ordering and other things right for
all filesystems at once is much harded.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
