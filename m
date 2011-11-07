Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 016856B006C
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 07:47:00 -0500 (EST)
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0LUA00L8AJHMFG10@damascus.uab.es> for
 linux-mm@kvack.org; Mon, 07 Nov 2011 13:46:34 +0100 (CET)
Received: from aomail.uab.es ([158.109.65.1])
 by damascus.uab.es (Sun Java	System Messaging Server 6.1 HotFix 0.10 (builtJan
 6 2005)) with ESMTP id	<0LUA00582JHL1V70@damascus.uab.es>
 forlinux-mm@kvack.org; Mon, 07 Nov 2011 13:46:34 +0100 (CET)
Date: Mon, 07 Nov 2011 15:49:17 +0100
From: Davidlohr Bueso <dave@gnu.org>
Subject: Re: [RFC PATCH] tmpfs: support user quotas
In-reply-to: <25866.1320657093@turing-police.cc.vt.edu>
Message-id: <1320677357.2330.7.camel@offworld>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7BIT
References: <1320614101.3226.5.camel@offbook>
 <25866.1320657093@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Hugh Dickins <hughd@google.com>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 2011-11-07 at 04:11 -0500, Valdis.Kletnieks@vt.edu wrote:
> On Sun, 06 Nov 2011 18:15:01 -0300, Davidlohr Bueso said:
> 
> > @@ -1159,7 +1159,12 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
> >  			struct page **pagep, void **fsdata)
> 
> > +	if (atomic_long_read(&user->shmem_bytes) + len > 
> > +	    rlimit(RLIMIT_TMPFSQUOTA))
> > +		return -ENOSPC;
> 
> Is this a per-process or per-user limit?  If it's per-process, it doesn't
> really do much good, because a user can use multiple processes to over-run the
> limit (either intentionally or accidentally).

This is a per-user limit.
> 
> > @@ -1169,10 +1174,12 @@ shmem_write_end(struct file *file, struct address_space *mapping,
> >  			struct page *page, void *fsdata)
> 
> > +	if (pos + copied > inode->i_size) {
> >  		i_size_write(inode, pos + copied);
> > +		atomic_long_add(copied, &user->shmem_bytes);
> > +	}
> If this is per-user, it's racy with shmem_write_begin() - two processes can hit
> the write_begin(), be under quota by (say) 1M, but by the time they both
> complete the user is 1M over the quota.
> 
I guess using a spinlock instead of atomic operations would serve the
purpose.

> >  @@ -1535,12 +1542,15 @@ static int shmem_unlink(struct inode *dir, struct dentry *dentry)
> > +	struct user_struct *user = current_user();
> > +	atomic_long_sub(inode->i_size, &user->shmem_bytes);
> 
> What happens here if user 'fred' creates a file on a tmpfs, and then logs out so he has
> no processes running, and then root does a 'find tmpfs -user fred -exec rm {} \;' to clean up?
> We just decremented root's quota, not fred's....
> 
Would the same would occur with mqueues? I haven't tested it but I don't
see anywhere that user->mq_bytes is decreased like this.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
