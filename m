Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5870C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 00:46:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E8820815
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 00:46:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E8820815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0193A8E0051; Wed,  2 Jan 2019 19:46:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0A7F8E0002; Wed,  2 Jan 2019 19:46:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E21BD8E0051; Wed,  2 Jan 2019 19:46:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4CCC8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 19:46:32 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id e185so22835900oih.18
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 16:46:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0VshrFVarjlglp1rVCtZLxzDXPmPtj/9tZyOAK9iQIA=;
        b=FE05G7+pzA6dvh3YCec6UYD9hMT0Kz8+VDNpePcl40H96aMVeQ+Okj4VRU1wzawj45
         sc8mtvu/2JF4hUw42Bj5/+5tcCbrrRKErBDA/JT5U19FAid8EhKiAzM2gfBEwLAQ3/b4
         /Fk0eY6M3veVU9YkZUP09rCsJpX5x+Au93QbQF0mbnvtPMPIcP8jUVhki3gLoBDrFA31
         egHqPNdOTfQYkkfbhz3KfXG4AIXSFtzZ6uk/oliDpYCH3G/NcYFr0kh2nh0kpq9QyxJp
         2SJqysYmGya7lpi/tV1yK34NUMNMePgtc/qJaVDE9lKz2bE+szR5Mq7y65Smoh6ak/m2
         g2Jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUuke4cSFKpjfUcbm3ji5Rs3qAb5p7kn9+oaMo301h4utu1etofzH9
	FbXgIN6n8Ch7+g8xpfJu8JNP/2ucr+NWwiFl+G4zJHxTTqUwLS5tj65b2vO4gWM8EXVUEVXtftj
	7VbjAY0U0nr7aoudTKkmS6id9PXluMUs0RKGmWlnSDN6n/qQdeiRfOuqkhTT2JLTVsg==
X-Received: by 2002:a9d:1e86:: with SMTP id n6mr34201265otn.9.1546476392439;
        Wed, 02 Jan 2019 16:46:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6+e2CKjC2JhsT4ujYMV2v79bEf+LiahcaqsxsS2hqiilN/ryu7VfkexUaXfKRNPmpv8Oxh
X-Received: by 2002:a9d:1e86:: with SMTP id n6mr34201250otn.9.1546476391668;
        Wed, 02 Jan 2019 16:46:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546476391; cv=none;
        d=google.com; s=arc-20160816;
        b=FUd8AiX7r24cFUnx1IzdUKCxOA/FPY4mMJG7RXRieSxKv8zGpe1aCCJvzROhzq7Pea
         xEBHZEW7ACeMwYhxQtvfBc5QwcjlTHOX76vxX8MivMMnXkGVNPGpXvfnWncpJWiSsOoV
         MUtvjs1wyuOA5GMdBDMHAmnVjR7mA74BaM1aCMEDzXxEy4pgFHmCL3klS3n16/BEWLCZ
         gdGOuawWHMXkiqaDErqUPKdH9HJgH4NNSGk+eDU8A0y4EDa4sMnKjZn5B86G/Y7xGUIR
         CyGqrMuMUAwvR4MosPdEfSSSnlia8m/f1RoH3UyKTUIAefJTLQc3DvDV7byb2eHM7N7E
         bK0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0VshrFVarjlglp1rVCtZLxzDXPmPtj/9tZyOAK9iQIA=;
        b=d+d5DB63+qH9Bm2Dci6KpCTL6NoywDSi20G/rVuqOCFICyZVjTnf1ARhH0TBnXoJSh
         T1EDzDco4apO/JvByxpL3fLuarRITU/P+mApaGWzQHhxK47cGQKt+mUQoxVeta//DMTh
         5f8XcIusqfMQ+ljtbOqYDjTgT32ubnwMAYmUrQNoDMcfP9wJWiajBQPuUGCvon9OVPJv
         B5VrvqPkSueGyzAbx2IU4AREEbGJ4+CWNenHB7+A1mhGt37vWTBFIOLJdhtTr3xsW/q/
         qAXNQ4USxlpmLWmjMHbcfdwNU1j53Lry2VALgP06XMoX06HwTvuvW4ZIeXWn+QIcgUkV
         12qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k11si14259168otl.288.2019.01.02.16.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 16:46:31 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x030kBcl009804;
	Thu, 3 Jan 2019 09:46:11 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Thu, 03 Jan 2019 09:46:11 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x030k6KR009661
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Thu, 3 Jan 2019 09:46:11 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: INFO: task hung in generic_file_write_iter
To: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>,
        linux-mm@kvack.org, mgorman@techsingularity.net,
        Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com,
        jlayton@redhat.com, linux-kernel@vger.kernel.org,
        mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com,
        tim.c.chen@linux.intel.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
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
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190102172636.GA29127@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103004607.7p_PwoWtcsIO7XExTx8y-QjhY5QLnAq9ZNwHQkmGDfY@z>

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

From 317a0d0002b3d2cadae606055ad50f2926ca62d2 Mon Sep 17 00:00:00 2001
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

