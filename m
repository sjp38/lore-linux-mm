Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5056B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 12:25:15 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so5813243pbc.3
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 09:25:15 -0700 (PDT)
Date: Mon, 30 Sep 2013 18:25:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Mapping range locking and related stuff
Message-ID: <20130930162509.GB800@quack.suse.cz>
References: <20130927204214.GA6445@quack.suse.cz>
 <20130927233202.GY26872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130927233202.GY26872@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, dchinner@redhat.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sat 28-09-13 09:32:02, Dave Chinner wrote:
> On Fri, Sep 27, 2013 at 10:42:14PM +0200, Jan Kara wrote:
> >   Hello,
> > 
> >   so recently I've spent some time rummaging in get_user_pages(), fault
> > code etc. The use of mmap_sem is really messy in some places (like V4L
> > drivers, infiniband,...). It is held over a deep & wide call chains and
> > it's not clear what's protected by it, just in the middle of that is a call
> > to get_user_pages(). Anyway that's mostly a side note.
> > 
> > The main issue I found is with the range locking itself. Consider someone
> > doing:
> >   fd = open("foo", O_RDWR);
> >   base = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
> >   write(fd, base, 4096);
> > 
> > The write() is an interesting way to do nothing but if the mapping range
> > lock will be acquired early (like in generic_file_aio_write()), then this
> > would deadlock because generic_perform_write() will try to fault in
> > destination buffer and that will try to get the range lock for the same
> > range again.
> 
> Quite frankly, I'd like to see EFAULT or EDEADLOCK returned to the
> caller doing something like this. It's a stupid thing to do, and
> while I beleive in giving people enough rope to hang themselves,
> the contortions we are going through here to provide that rope
> doesn't seem worthwhile at all.
  Well, what I wrote above was kind of minimal example. But if you would
like to solve all deadlocks of this kind (when more processes are
involved), you would have to forbid giving any file mapping (private or
shared) as a buffer for IO. And I'm afraid we cannot really afford that
because there may be reasonable uses for that.

Standards conformant solution would be to prefault a chunk of pages and
return short IO as soon as we hit unmapped page in the buffer. But I was
already fending off application developers complaining Linux returns short
write when you try to write more than 2 GB. So I'm *sure* we would break a
lot of userspace if we suddently start returning short writes for much
smaller requests. Crappy userspace ;)

I have a way to make things work but it doesn't make the locking simpler
from the current situation which is sad. The logic is as follows:

We will have range lock (basically a range-equivalent of current i_mutex).
Each range can also have a flag set saying that pages cannot be inserted in
a given range. 

Punch hole / truncate lock the range with the flag set.
Write & direct IO lock the range without the flag set.
Read & page fault work on per-page basis and create page for given index
only after waiting for held range locks with flag set covering that index.

This achieves:
1) Exclusion among punch hole, truncate, writes, direct IO.
2) Exclusion between punch hole, truncate and page creation in given range.
3) Exclusion among reads, page faults, writes is achieved by PageLock as
currently.

Direct IO write will have the same consistency problems with mmap as it
currently has.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
