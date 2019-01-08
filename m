Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD5198E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:49:21 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id p21so3007308itb.8
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:49:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor17875107itx.25.2019.01.08.03.49.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 03:49:20 -0800 (PST)
MIME-Version: 1.0
References: <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
 <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz> <e8a23623-feaf-7730-5492-b329cb0daa21@i-love.sakura.ne.jp>
 <20190102144015.GA23089@quack2.suse.cz> <275523c6-f750-44c2-a8a4-f3825eeab788@i-love.sakura.ne.jp>
 <20190102172636.GA29127@quack2.suse.cz> <bf209c90-3624-68cd-c0db-86a91210f873@i-love.sakura.ne.jp>
 <20190108112425.GC8076@quack2.suse.cz>
In-Reply-To: <20190108112425.GC8076@quack2.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Jan 2019 12:49:08 +0100
Message-ID: <CACT4Y+bxUJ-6dLch+orY0AcjrvJhXq1=ELvHciX5M-gd5bdPpA@mail.gmail.com>
Subject: Re: INFO: task hung in generic_file_write_iter
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andi Kleen <ak@linux.intel.com>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Jan 8, 2019 at 12:24 PM Jan Kara <jack@suse.cz> wrote:
>
> On Tue 08-01-19 19:04:06, Tetsuo Handa wrote:
> > On 2019/01/03 2:26, Jan Kara wrote:
> > > On Thu 03-01-19 01:07:25, Tetsuo Handa wrote:
> > >> On 2019/01/02 23:40, Jan Kara wrote:
> > >>> I had a look into this and the only good explanation for this I have is
> > >>> that sb->s_blocksize is different from (1 << sb->s_bdev->bd_inode->i_blkbits).
> > >>> If that would happen, we'd get exactly the behavior syzkaller observes
> > >>> because grow_buffers() would populate different page than
> > >>> __find_get_block() then looks up.
> > >>>
> > >>> However I don't see how that's possible since the filesystem has the block
> > >>> device open exclusively and blkdev_bszset() makes sure we also have
> > >>> exclusive access to the block device before changing the block device size.
> > >>> So changing block device block size after filesystem gets access to the
> > >>> device should be impossible.
> > >>>
> > >>> Anyway, could you perhaps add to your debug patch a dump of 'size' passed
> > >>> to __getblk_slow() and bdev->bd_inode->i_blkbits? That should tell us
> > >>> whether my theory is right or not. Thanks!
> > >>>
> >
> > Got two reports. 'size' is 512 while bdev->bd_inode->i_blkbits is 12.
> >
> > https://syzkaller.appspot.com/text?tag=CrashLog&x=1237c3ab400000
> >
> > [  385.723941][  T439] kworker/u4:3(439): getblk(): executed=9 bh_count=0 bh_state=0 bdev_super_blocksize=512 size=512 bdev_super_blocksize_bits=9 bdev_inode_blkbits=12
> > (...snipped...)
> > [  568.159544][  T439] kworker/u4:3(439): getblk(): executed=9 bh_count=0 bh_state=0 bdev_super_blocksize=512 size=512 bdev_super_blocksize_bits=9 bdev_inode_blkbits=12
>
> Right, so indeed the block size in the superblock and in the block device
> gets out of sync which explains why we endlessly loop in the buffer cache
> code. The superblock uses blocksize of 512 while the block device thinks
> the set block size is 4096.
>
> And after staring into the code for some time, I finally have a trivial
> reproducer:
>
> truncate -s 1G /tmp/image
> losetup /dev/loop0 /tmp/image
> mkfs.ext4 -b 1024 /dev/loop0
> mount -t ext4 /dev/loop0 /mnt
> losetup -c /dev/loop0
> l /mnt
> <hangs>
>
> And the problem is that LOOP_SET_CAPACITY ioctl ends up reseting block
> device block size to 4096 by calling bd_set_size(). I have to think how to
> best fix this...
>
> Thanks for your help with debugging this!

Wow! I am very excited.
We have 587 open "task hung" reports, I suspect this explains lots of them.
What would be some pattern that we can use to best-effort distinguish
most manifestations? Skimming through few reports I see "inode_lock",
"get_super", "blkdev_put" as common indicators. Anything else?
