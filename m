Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A29C6B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 01:32:57 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id h64so5036362itb.6
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 22:32:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m69sor4590324ith.144.2017.11.05.22.32.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 Nov 2017 22:32:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171106032941.GR21978@ZenIV.linux.org.uk>
References: <94eb2c05f6a018dc21055d39c05b@google.com> <20171106032941.GR21978@ZenIV.linux.org.uk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Nov 2017 09:32:35 +0300
Message-ID: <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
Subject: Re: possible deadlock in generic_file_write_iter
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com

On Mon, Nov 6, 2017 at 6:29 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, Nov 05, 2017 at 02:25:00AM -0800, syzbot wrote:
>
>> loop0/2986 is trying to acquire lock:
>>  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff8186f9ec>] inode_lock
>> include/linux/fs.h:712 [inline]
>>  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff8186f9ec>]
>> generic_file_write_iter+0xdc/0x7a0 mm/filemap.c:3151
>>
>> but now in release context of a crosslock acquired at the following:
>>  ((complete)&ret.event){+.+.}, at: [<ffffffff822a055e>]
>> submit_bio_wait+0x15e/0x200 block/bio.c:953
>>
>> which lock already depends on the new lock.
>
> Almost certainly a false positive...  lockdep can't tell ->i_rwsem of
> inode on filesystem that lives on /dev/loop0 and that of inode of
> the backing file of /dev/loop0.
>
> Try and put them on different filesystem types and see if you still
> can reproduce that.  We do have a partial ordering between the filesystems,
> namely "(parts of) hosting device of X live in a file on Y".  It's
> going to be acyclic, or you have a much worse problem.  And that's
> what really orders the things here.


Should we annotate these inodes with different lock types? Or use
nesting annotations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
