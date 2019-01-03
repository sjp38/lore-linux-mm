Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4CCC8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 19:46:32 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id e185so22835900oih.18
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 16:46:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k11si14259168otl.288.2019.01.02.16.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 16:46:31 -0800 (PST)
Subject: Re: INFO: task hung in generic_file_write_iter
References: <0000000000009ce88d05714242a8@google.com>
 <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
 <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz>
 <e8a23623-feaf-7730-5492-b329cb0daa21@i-love.sakura.ne.jp>
 <20190102144015.GA23089@quack2.suse.cz>
 <275523c6-f750-44c2-a8a4-f3825eeab788@i-love.sakura.ne.jp>
 <20190102172636.GA29127@quack2.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <12239545-7d8a-820f-48ba-952e2e98a05c@i-love.sakura.ne.jp>
Date: Thu, 3 Jan 2019 09:46:07 +0900
MIME-Version: 1.0
In-Reply-To: <20190102172636.GA29127@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, linux-mm@kvack.org, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com, jlayton@redhat.com, linux-kernel@vger.kernel.org, mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 2019/01/03 2:26, Jan Kara wrote:
> On Thu 03-01-19 01:07:25, Tetsuo Handa wrote:
>> On 2019/01/02 23:40, Jan Kara wrote:
>>> I had a look into this and the only good explanation for this I have is
>>> that sb->s_blocksize is different from (1 << sb->s_bdev->bd_inode->i_blkbits).
>>> If that would happen, we'd get exactly the behavior syzkaller observes
>>> because grow_buffers() would populate different page than
>>> __find_get_block() then looks up.
>>>
>>> However I don't see how that's possible since the filesystem has the block
>>> device open exclusively and blkdev_bszset() makes sure we also have
>>> exclusive access to the block device before changing the block device size.
>>> So changing block device block size after filesystem gets access to the
>>> device should be impossible. 
>>>
>>> Anyway, could you perhaps add to your debug patch a dump of 'size' passed
>>> to __getblk_slow() and bdev->bd_inode->i_blkbits? That should tell us
>>> whether my theory is right or not. Thanks!
>>>
>>
>> OK. Andrew, will you add (or fold into) this change?
>>
>> From e6f334380ad2c87457bfc2a4058316c47f75824a Mon Sep 17 00:00:00 2001
>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Date: Thu, 3 Jan 2019 01:03:35 +0900
>> Subject: [PATCH] fs/buffer.c: dump more info for __getblk_gfp() stall problem
>>
>> We need to dump more variables on top of
>> "fs/buffer.c: add debug print for __getblk_gfp() stall problem".
>>
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Cc: Jan Kara <jack@suse.cz>
>> ---
>>  fs/buffer.c | 9 +++++++--
>>  1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/buffer.c b/fs/buffer.c
>> index 580fda0..a50acac 100644
>> --- a/fs/buffer.c
>> +++ b/fs/buffer.c
>> @@ -1066,9 +1066,14 @@ static sector_t blkdev_max_block(struct block_device *bdev, unsigned int size)
>>  #ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
>>  		if (!time_after(jiffies, current->getblk_stamp + 3 * HZ))
>>  			continue;
>> -		printk(KERN_ERR "%s(%u): getblk(): executed=%x bh_count=%d bh_state=%lx\n",
>> +		printk(KERN_ERR "%s(%u): getblk(): executed=%x bh_count=%d bh_state=%lx "
>> +		       "bdev_super_blocksize=%lu size=%u "
>> +		       "bdev_super_blocksize_bits=%u bdev_inode_blkbits=%u\n",
>>  		       current->comm, current->pid, current->getblk_executed,
>> -		       current->getblk_bh_count, current->getblk_bh_state);
>> +		       current->getblk_bh_count, current->getblk_bh_state,
>> +		       bdev->bd_super->s_blocksize, size,
>> +		       bdev->bd_super->s_blocksize_bits,
>> +		       bdev->bd_inode->i_blkbits);
> 
> Well, bd_super may be NULL if there's no filesystem mounted so it would be
> safer to check for this rather than blindly dereferencing it... Otherwise
> the change looks good to me.

I see. Let's be cautious here.

>From 317a0d0002b3d2cadae606055ad50f2926ca62d2 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 3 Jan 2019 09:42:02 +0900
Subject: [PATCH v2] fs/buffer.c: dump more info for __getblk_gfp() stall problem

We need to dump more variables on top of
"fs/buffer.c: add debug print for __getblk_gfp() stall problem".

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Jan Kara <jack@suse.cz>
---
 fs/buffer.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 580fda0..784de3d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1066,9 +1066,15 @@ static sector_t blkdev_max_block(struct block_device *bdev, unsigned int size)
 #ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
 		if (!time_after(jiffies, current->getblk_stamp + 3 * HZ))
 			continue;
-		printk(KERN_ERR "%s(%u): getblk(): executed=%x bh_count=%d bh_state=%lx\n",
+		printk(KERN_ERR "%s(%u): getblk(): executed=%x bh_count=%d bh_state=%lx bdev_super_blocksize=%ld size=%u bdev_super_blocksize_bits=%d bdev_inode_blkbits=%d\n",
 		       current->comm, current->pid, current->getblk_executed,
-		       current->getblk_bh_count, current->getblk_bh_state);
+		       current->getblk_bh_count, current->getblk_bh_state,
+		       IS_ERR_OR_NULL(bdev->bd_super) ? -1L :
+		       bdev->bd_super->s_blocksize, size,
+		       IS_ERR_OR_NULL(bdev->bd_super) ? -1 :
+		       bdev->bd_super->s_blocksize_bits,
+		       IS_ERR_OR_NULL(bdev->bd_inode) ? -1 :
+		       bdev->bd_inode->i_blkbits);
 		current->getblk_executed = 0;
 		current->getblk_bh_count = 0;
 		current->getblk_bh_state = 0;
-- 
1.8.3.1
