Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 45AFE6B0055
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 06:05:52 -0400 (EDT)
Date: Tue, 9 Jun 2009 12:38:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 03/23] vfs: Generalize the file_list
Message-ID: <20090609103832.GI14820@wotan.suse.de>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-3-git-send-email-ebiederm@xmission.com> <20090602070642.GD31556@wotan.suse.de> <m1ab4m5vbs.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1ab4m5vbs.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 05, 2009 at 12:33:59PM -0700, Eric W. Biederman wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> >> +static inline void file_list_unlock(struct file_list *files)
> >> +{
> >> +	spin_unlock(&files->lock);
> >> +}
> >
> > I don't really like this. It's just a list head. Get rid of
> > all these wrappers and crap I'd say. In fact, starting with my
> > patch to unexport files_lock and remove these wrappers would
> > be reasonable, wouldn't it?
> 
> I don't really mind killing the wrappers.
> 
> I do mind your patch because it makes the list going through
> the tty's something very different.  In my view of the world
> that is the only use case is what I'm working to move up more
> into the vfs layer.  So orphaning it seems wrong.

My patch doesn't orphan it, it just makes the locking more
explicit and that's all so it should be easier to work with.
I just mean start with my patch and you could change things
as needed.

 
> > Increasing the size of the struct inode by 24 bytes hurts.
> > Even when you decrapify it and can reuse i_lock or something,
> > then it is still 16 bytes on 64-bit.
> 
> We can get it even smaller if we make it an hlist.  A hlist_head is
> only a single pointer.  This size growth appears to be one of the
> biggest weakness of the code.

8 bytes would be a lot better than 24.


> > I haven't looked through all the patches... but this is to
> > speed up a slowpath operation, isn't it? Or does revoke
> > need to be especially performant?
> 
> This was more about simplicity rather than performance.  The
> performance gain is using a per inode lock instead of a global lock.
> Which keeps cache lines from bouncing.

Yes but we already have such a global lock which has been
OK until now. Granted that some users are running into these
locks, but fine graining them can be considered independently
I think. So using per-sb lists of files and not bloating
struct inode any more could be a less controversial step
for you.


> > So this patch is purely a perofrmance improvement? Then I think
> > it needs to be justified with numbers and the downsides (bloating
> > struct inode in particulra) to be changelogged.
> 
> Certainly the cost.
> 
> One of the things I have discovered since I wrote this patch is the
> i_devices list.  Which means we don't necessarily need to have heads
> in places other than struct inode.  A character device driver (aka the
> tty code) can walk it's inode list and from each inode walk the file
> list.  I need to check the locking on that one.
> 
> If that simplification works we can move all maintenance of the file
> list into the vfs and not need a separate file list concept.  I will
> take a look.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
