Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3B43D6B0036
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 16:42:19 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so3261538pab.31
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 13:42:18 -0700 (PDT)
Date: Fri, 27 Sep 2013 22:42:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Mapping range locking and related stuff
Message-ID: <20130927204214.GA6445@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

  Hello,

  so recently I've spent some time rummaging in get_user_pages(), fault
code etc. The use of mmap_sem is really messy in some places (like V4L
drivers, infiniband,...). It is held over a deep & wide call chains and
it's not clear what's protected by it, just in the middle of that is a call
to get_user_pages(). Anyway that's mostly a side note.

The main issue I found is with the range locking itself. Consider someone
doing:
  fd = open("foo", O_RDWR);
  base = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  write(fd, base, 4096);

The write() is an interesting way to do nothing but if the mapping range
lock will be acquired early (like in generic_file_aio_write()), then this
would deadlock because generic_perform_write() will try to fault in
destination buffer and that will try to get the range lock for the same
range again.

Prefaulting buffer before we get the range lock isn't really an option
since the write(2) can be rather large. So we really either have to lock
page faults differently or use per page locking as I originally wanted.
I'm still thinking what would be the best solution for this. Ideas are
welcome.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
