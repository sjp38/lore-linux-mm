Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAAE6B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 19:32:11 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so3182789pbb.10
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:32:10 -0700 (PDT)
Date: Sat, 28 Sep 2013 09:32:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Mapping range locking and related stuff
Message-ID: <20130927233202.GY26872@dastard>
References: <20130927204214.GA6445@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130927204214.GA6445@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: dchinner@redhat.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Sep 27, 2013 at 10:42:14PM +0200, Jan Kara wrote:
>   Hello,
> 
>   so recently I've spent some time rummaging in get_user_pages(), fault
> code etc. The use of mmap_sem is really messy in some places (like V4L
> drivers, infiniband,...). It is held over a deep & wide call chains and
> it's not clear what's protected by it, just in the middle of that is a call
> to get_user_pages(). Anyway that's mostly a side note.
> 
> The main issue I found is with the range locking itself. Consider someone
> doing:
>   fd = open("foo", O_RDWR);
>   base = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
>   write(fd, base, 4096);
> 
> The write() is an interesting way to do nothing but if the mapping range
> lock will be acquired early (like in generic_file_aio_write()), then this
> would deadlock because generic_perform_write() will try to fault in
> destination buffer and that will try to get the range lock for the same
> range again.

Quite frankly, I'd like to see EFAULT or EDEADLOCK returned to the
caller doing something like this. It's a stupid thing to do, and
while I beleive in giving people enough rope to hang themselves,
the contortions we are going through here to provide that rope
doesn't seem worthwhile at all.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
