Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6A7B66B0047
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 11:48:33 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Date: Fri, 20 Mar 2009 02:48:21 +1100
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <alpine.LFD.2.00.0903181634500.17240@localhost.localdomain> <604427e00903181654y308d57d8w2cb32eab831cf45a@mail.gmail.com>
In-Reply-To: <604427e00903181654y308d57d8w2cb32eab831cf45a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903200248.22623.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>, Jan Kara <jack@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thursday 19 March 2009 10:54:33 Ying Han wrote:
> On Wed, Mar 18, 2009 at 4:36 PM, Linus Torvalds
>
> <torvalds@linux-foundation.org> wrote:
> > On Wed, 18 Mar 2009, Ying Han wrote:
> >> > Can you say what filesystem, and what mount-flags you use? Iirc, last
> >> > time we had MAP_SHARED lost writes it was at least partly triggered by
> >> > the filesystem doing its own flushing independently of the VM (ie ext3
> >> > with "data=journal", I think), so that kind of thing does tend to
> >> > matter.
> >>
> >> /etc/fstab
> >> "/dev/hda1 / ext2 defaults 1 0"
> >
> > Sadly, /etc/fstab is not necessarily accurate for the root filesystem. At
> > least Fedora will ignore the flags in it.
> >
> > What does /proc/mounts say? That should be a more reliable indication of
> > what the kernel actually does.
>
> "/dev/root / ext2 rw,errors=continue 0 0"

No luck with finding the problem yet.

But I think we do have a race in __set_page_dirty_buffers():

The page may not have buffers between the mapping->private_lock
critical section and the __set_page_dirty call there. So between
them, another thread might do a create_empty_buffers which can
see !PageDirty and thus it will create clean buffers. The page
will get dirtied by the original thread, but if the buffers are
clean it can be cleaned without writing out buffers.

Holding mapping->private_lock over the __set_page_dirty should
fix it, although I guess you'd want to release it before calling
__mark_inode_dirty so as not to put inode_lock under there. I
have a patch for this if it sounds reasonable.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
