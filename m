Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 562816B0085
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 02:05:07 -0400 (EDT)
Date: Wed, 10 Jun 2009 08:05:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 03/23] vfs: Generalize the file_list
Message-ID: <20090610060511.GA31155@wotan.suse.de>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-3-git-send-email-ebiederm@xmission.com> <20090602070642.GD31556@wotan.suse.de> <m1ab4m5vbs.fsf@fess.ebiederm.org> <20090609103832.GI14820@wotan.suse.de> <m1hbypmev0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1hbypmev0.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 11:38:59AM -0700, Eric W. Biederman wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> > On Fri, Jun 05, 2009 at 12:33:59PM -0700, Eric W. Biederman wrote:
> >> Nick Piggin <npiggin@suse.de> writes:
> >> 
> >> >> +static inline void file_list_unlock(struct file_list *files)
> >> >> +{
> >> >> +	spin_unlock(&files->lock);
> >> >> +}
> >> >
> >> > I don't really like this. It's just a list head. Get rid of
> >> > all these wrappers and crap I'd say. In fact, starting with my
> >> > patch to unexport files_lock and remove these wrappers would
> >> > be reasonable, wouldn't it?
> >> 
> >> I don't really mind killing the wrappers.
> >> 
> >> I do mind your patch because it makes the list going through
> >> the tty's something very different.  In my view of the world
> >> that is the only use case is what I'm working to move up more
> >> into the vfs layer.  So orphaning it seems wrong.
> >
> > My patch doesn't orphan it, it just makes the locking more
> > explicit and that's all so it should be easier to work with.
> > I just mean start with my patch and you could change things
> > as needed.
> 
> As I recall you weren't using the files_lock for the tty layer.  I
> seem to recall you were still walking through the same list head on
> struct file.
> 
> Regardless it sure felt like pushing the tty usage out into
> some weird special case.  My goal is to make it reasonable for
> more character drivers to use the list so it isn't an especially
> comfortable starting place for me.

I don't see the problem. It made files_lock for filesystems
and uses another lock for tty. Tty is a special case (or
different case) compared with filesystem, and how did it
make it unreasonable for character drivers to use the list?

Mandating the locking and list to be in the inode for
everyone is just bloating things up.

 
> >> > Increasing the size of the struct inode by 24 bytes hurts.
> >> > Even when you decrapify it and can reuse i_lock or something,
> >> > then it is still 16 bytes on 64-bit.
> >> 
> >> We can get it even smaller if we make it an hlist.  A hlist_head is
> >> only a single pointer.  This size growth appears to be one of the
> >> biggest weakness of the code.
> >
> > 8 bytes would be a lot better than 24.
> 
> Definitely.
> 
> >> > I haven't looked through all the patches... but this is to
> >> > speed up a slowpath operation, isn't it? Or does revoke
> >> > need to be especially performant?
> >> 
> >> This was more about simplicity rather than performance.  The
> >> performance gain is using a per inode lock instead of a global lock.
> >> Which keeps cache lines from bouncing.
> >
> > Yes but we already have such a global lock which has been
> > OK until now. Granted that some users are running into these
> > locks, but fine graining them can be considered independently
> > I think. So using per-sb lists of files and not bloating
> > struct inode any more could be a less controversial step
> > for you.
> 
> I will take a look.  Certainly doing the work in a couple
> of patches seems reasonable.  If I can move all of the list
> maintenance out of the tty layer.  That looks to be the ideal
> case.

I will wait to see. It will be nice if you have any obvious
standalone fixes or improvements then to post them first or
in front of your patchset: I'd like to make some progress
here too to help my locking patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
