Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 016186B0038
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 22:29:54 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id a20so2601658wrc.1
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 19:29:53 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id h139si5877444wme.230.2017.11.05.19.29.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Nov 2017 19:29:52 -0800 (PST)
Date: Mon, 6 Nov 2017 03:29:42 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible deadlock in generic_file_write_iter
Message-ID: <20171106032941.GR21978@ZenIV.linux.org.uk>
References: <94eb2c05f6a018dc21055d39c05b@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94eb2c05f6a018dc21055d39c05b@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com

On Sun, Nov 05, 2017 at 02:25:00AM -0800, syzbot wrote:

> loop0/2986 is trying to acquire lock:
>  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff8186f9ec>] inode_lock
> include/linux/fs.h:712 [inline]
>  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff8186f9ec>]
> generic_file_write_iter+0xdc/0x7a0 mm/filemap.c:3151
> 
> but now in release context of a crosslock acquired at the following:
>  ((complete)&ret.event){+.+.}, at: [<ffffffff822a055e>]
> submit_bio_wait+0x15e/0x200 block/bio.c:953
> 
> which lock already depends on the new lock.

Almost certainly a false positive...  lockdep can't tell ->i_rwsem of
inode on filesystem that lives on /dev/loop0 and that of inode of
the backing file of /dev/loop0.

Try and put them on different filesystem types and see if you still
can reproduce that.  We do have a partial ordering between the filesystems,
namely "(parts of) hosting device of X live in a file on Y".  It's
going to be acyclic, or you have a much worse problem.  And that's
what really orders the things here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
