From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH 0/2] Updating ctime and mtime for memory-mapped files [try #4]
Date: Tue, 15 Jan 2008 19:02:43 +0300
Message-Id: <12004129652397-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

1. Introduction

This is the fourth version of my solution for the bug #2645:

http://bugzilla.kernel.org/show_bug.cgi?id=2645

Changes since the previous version:

1) the case of retouching an already-dirty page pointed out
  by Miklos Szeredi has been addressed;

2) the file metadata are updated using the page modification time
  instead of the time of syncing data;

3) a few small corrections according to the latest feedback.

Brief explanation of these changes as well as some design considerations
are given below.

2. The case of retouching an already-dirtied page

Miklos Szeredi gave the following feedback on the previous version:

> I suspect your patch is ignoring writes after the first msync, but
> then why care about msync at all?  What's so special about the _first_
> msync?  Is it just that most test programs only check this, and not
> what happens if msync is called more than once?  That would be a bug
> in the test cases.

This version adds handling of the case of multiple msync() calls. Before
going on with the explanaion, I'll quote a remark by Peter Zijlstra:

> I must agree, doing the mmap dirty, MS_ASYNC, mmap retouch, MS_ASYNC
> case correctly would need a lot more code which I doubt is worth the
> effort.
>
> It would require scanning the PTEs and marking them read-only again on
> MS_ASYNC, and some more logic in set_page_dirty() because that currently
> bails out early if the page in question is already dirty.

Indeed, the following logic of the __set_pages_dirty_nobuffers() function:

if (!TestSetPageDirty(page)) {
       mapping = page_mapping(page);

       if (!mapping)
               return 1;

       /* critical section */

       if (mapping->host) {
               __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
               set_bit(AS_MCTIME, &mapping->flags);
       }
       return 1;
}
return 0;

made it difficult to account for the case of the already-dirty page
retouch after the call to msync(MS_ASYNC).

In this version of my solution, I redesigned the logic of the same
function as follows:

mapping = page_mapping(page);

if (!mapping)
       return 1;

set_bit(AS_MCTIME, &mapping->flags);

if (TestSetPageDirty(page))
       return 0;

/* critical section */

if (mapping->host) {
       __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);

return 1;

This allows us to set the AS_MCTIME bit independently of whether the page
had already been dirtied or not. Besides, such change makes the logic of
the topmost "if" in this function straight thus improving readability.
Finally, we already have the __set_page_dirty() routine with almost
identical functionality. My redesign of __set_pages_dirty_nobuffers()
is based on how the __set_page_dirty() routine is implemented.

Miklos gave an example of a scenario, where the previous version of
my solution would fail:

http://lkml.org/lkml/2008/1/14/100

Here is how it looks in the version I am sending now:

 1 page is dirtied through mapping
       => the AS_MCTIME bit turned on
 2 app calls msync(MS_ASYNC)
       => inode's times updated, the AS_MCTIME bit turned off
 3 page is written again through mapping
       => the AS_MCTIME bit turned on again
 4 app calls msync(MS_ASYNC)
       => inode's times updated, the AS_MCTIME bit turned off
 5 ...
 6 page is written back
       => ... by this moment, the either the msync(MS_ASYNC) has
          taken care of updating the file times, or the AS_MCTIME
          bit is on.

I think that the feedback about writes after the first msync(MS_ASYNC)
has thereby been addressed.

3. Updating the time stamps of the block device special files

As for the block device case, let's start from the following assumption:

if the block device data changes, we should do our best to tell the world
that this has happened.

This is how I approach this requirement:

1) if the block device is active, this is done at next *sync() through
  calling the bd_inode_update_time() helper function.

2) if the block device is not active, this is done during the block
  device file deactivation in the unlink_file_vma() routine.

Removing either of these actions would leave a possibility of losing
information about the block device data update. That is why I am keeping
both.

4. Recording the time was the file data changed

Finally, I noticed yet another issue with the previous version of my patch.
Specifically, the time stamps were set to the current time of the moment
when syncing but not the write reference was being done. This led to the
following adverse effect on my development system:

1) a text file A was updated by process B;
2) process B exits without calling any of the *sync() functions;
3) vi editor opens the file A;
4) file data synced, file times updated;
5) vi is confused by "thinking" that the file was changed after 3).

This version overcomes this problem by introducing another field into the
address_space structure. This field is used to "remember" the time of
dirtying, and then this time value is propagated to the file metadata.

This approach is based upon the following suggestion given by Peter
Staubach during one of our previous discussions:

http://lkml.org/lkml/2008/1/9/267

> A better architecture would be to arrange for the file times
> to be updated when the page makes the transition from being
> unmodified to modified.  This is not straightforward due to
> the current locking, but should be doable, I think.  Perhaps
> recording the current time and then using it to update the
> file times at a more suitable time (no pun intended) might
> work.

The solution I propose now proves the viability of the latter
approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
