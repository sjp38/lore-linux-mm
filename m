Date: Sat, 18 Oct 2008 21:45:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: no way to swapoff a deleted swap file?
In-Reply-To: <20081018051800.GO24654@1wt.eu>
Message-ID: <Pine.LNX.4.64.0810182058120.7154@blonde.site>
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it>
 <bnJFK-3bu-7@gated-at.bofh.it> <bnR0A-4kq-1@gated-at.bofh.it>
 <E1KqkZK-0001HO-WF@be1.7eggert.dyndns.org> <Pine.LNX.4.64.0810171250410.22374@blonde.site>
 <20081018003117.GC26067@cordes.ca> <20081018051800.GO24654@1wt.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: Peter Cordes <peter@cordes.ca>, Bodo Eggert <7eggert@gmx.de>, David Newall <davidn@davidnewall.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 18 Oct 2008, Willy Tarreau wrote:
> (...)
> I have another idea which might be simpler to implement in userspace.
> What happened to you is a typical accident, you did not run on purpose
> on a deleted swap file. So we should at least ensure that such types
> of accidents could not happen easily.
> 
> If swapon did set the immutable bit on a file just after enabling swap
> to it, it would at least prevent accidental removal of that file. Swapoff
> would have to clean that bit, and swapon would have to clean it upon
> startup too (in case of unplanned reboots).
> 
> That way, you could still remove such files on purpose provided you do
> a preliminary "chattr -i" on them, but "rm -rf" would keep them intact.

That's a good idea, thank you Willy:
much more to my taste than previous suggestions.

But I'm still not tempted to build it into the swapon and swapoff,
neither at the command nor at the kernel level.  Let's leave it as
advice to sufferers on how to address the issue if it troubles them.

I did play with immutable on swapfiles back around 2.6.8.  Prior
to that we left i_sem downed on a swapfile to protect it against
truncation (freeing its pages!) while in use - which caused
anyone idly touching it to hang, not very nice.

I experimented with setting immutable in sys_swapon, clearing it
in sys_swapoff, but I see from old mails that I didn't find that
satisfactory: I haven't actually recorded why not, but I think it
was partly a difficulty in getting the locking right, and partly
what happened if the user also made it immutable while swapped on -
oh, yes, and immutable gets written back to the filesystem which is
inconvenient when we crash, as you observe.  So we ended up adding
an additional swapfile flag just at the VFS level.

Hmm, I suppose it would be very easy to make that additional swapfile
flag prohibit unlinking just as immutable does: patch below should do
that.  What do you guys think - should we include this?  It does then
(barring races which I don't propose to worry about) make an unlinked
swapfile impossible, which earlier had seemed a reasonable option.

> It would also prevent accidental modifications, such as "ls .>swapfile"
> instead of "ls ./swapfile".

That we do already protect against with the swapfile flag: we don't
actually protect against writing (that's just a permission thing,
same as when swapping to block device), but we do protect against
truncation, which would otherwise end up with swap corrupting
blocks of other files.

Hugh

--- 2.6.27/fs/namei.c	2008-10-09 23:13:53.000000000 +0100
+++ linux/fs/namei.c	2008-10-18 21:33:01.000000000 +0100
@@ -1407,7 +1407,7 @@ static int may_delete(struct inode *dir,
 	if (IS_APPEND(dir))
 		return -EPERM;
 	if (check_sticky(dir, victim->d_inode)||IS_APPEND(victim->d_inode)||
-	    IS_IMMUTABLE(victim->d_inode))
+	    IS_IMMUTABLE(victim->d_inode) || IS_SWAPFILE(victim->d_inode))
 		return -EPERM;
 	if (isdir) {
 		if (!S_ISDIR(victim->d_inode->i_mode))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
