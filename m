Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC904C43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 16:07:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C511218A4
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 16:07:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C511218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34AFD8E0029; Wed,  2 Jan 2019 11:07:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FB0A8E0002; Wed,  2 Jan 2019 11:07:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C2D68E0029; Wed,  2 Jan 2019 11:07:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E37698E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 11:07:51 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id x21so2702582oto.12
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 08:07:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1zU9bfKdo+xsW77l1L0dovKzOgCkMAPqn71V7vCgMTw=;
        b=g2s8YnGKVDMSGvh0Tgqf1OO7UK871ny2J+Z2YGWOXNmh0OIxLB7YwI6QEW0awp2kMJ
         pnAI7MBJiBj/aXrr0xPc6s/Qifr84/njhu14yjJNLCvtPVP9mo1DX9/gXfBAlN4ScPpx
         0Y3nw5jUGSoHClZhIHvua9ECewIQRy4uv3xT1txapn/eIrG2jR+5ilmhppW7yTbJNMvt
         tXamSfyKmd+13i/vay+1g705/QxHHxCJlqu+NOW6q929IpmuScTppjTSC+xizDmqrlXY
         VEgr22uT8CZ9fKjAMzVM5PFiD1rhh4W1dd+Ca2fnHTFOnxK3l/yyjn/bqosFQdk6Noz1
         1huA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukcnj0W4HlJbjyZXsbAvPTfuHMY+1y0hLlyB39N2/6j7x5nEj9IB
	z156kY6C+6gIvvZcvYeb8B+7KHr8ErwhUTznrgbo3E6anbT2RiI8qKOhJ9blLIGDJzMINJpRB7l
	kbk4DBvea+N2KLmBA789+NjmUXC4loNtsXx7nDfI3fI2mTW2wHtluTlPWTkr2z9KseA==
X-Received: by 2002:a9d:2d81:: with SMTP id g1mr28984661otb.111.1546445271629;
        Wed, 02 Jan 2019 08:07:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7SajIASxX2F4WU01ECR3U1QhT1X96fotpy7Qt3hZMG4rT5MMmjArjtoJObCi3iK7alMg9U
X-Received: by 2002:a9d:2d81:: with SMTP id g1mr28984638otb.111.1546445270969;
        Wed, 02 Jan 2019 08:07:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546445270; cv=none;
        d=google.com; s=arc-20160816;
        b=xa8JFrRAyrkEsvtjd/zLmgSWysaWXSoiKKpSU4grNAeSp0TTYxig2WcQg9Z0KC6vk8
         2aMPgw7DPjSt0+gGyCkD3v9+C2bqa9RnAZioq0WdIoAYQLqYm5pR2h3LAg8/YPhaR70I
         wGHFF7ADhabF9I8MQteBeMamEyHgHduumu/jr41frxZY43XhffpKF9BIE0ejcqHk1Znf
         bAoGetlRW7gimvjqrAuI1gzjfw5O2V+kGQ2sIJgDY3FfmhJF/ZzkvlMnv79yHaHz41G9
         dWc/Ly30A55DoP40XdLbmS7GzXXdOy4yen0s0hvAKBqypQm9kcWf4OQ2sKRsdNZ+fz9Z
         3OgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1zU9bfKdo+xsW77l1L0dovKzOgCkMAPqn71V7vCgMTw=;
        b=bfmgzurnOUJFxx2NDhpuYkMSTt1q1yEo1PWjCBNUMu5ZVUd1slOjPE5aBZizrlzbM8
         MgA484bPwE2X5F3IS/Kgh6FR4ypPEj3Ek/dAP3qXazTh5maUidLu+ZzVMrHxvl0WObww
         J9Cg9hxXXsm/f3/H8FLalgsbYiNZKrHX85jt24TOAejGHV7UDjZ4W+ujg3sAo0P4pSwS
         oh+JDeBet+gNt1vBAW3YBZ+LWcrgLsBxwCO78758PHwW4RVTjK9HMOC+VRJclAoTVC1V
         n5I2tAi6J2DAYxzGLiYYGOqkmKYc8sOHAGQyyD7QLMoAgoHfRJTg9DGy6qFRSYrTd6WP
         xBHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v126si17373006oig.266.2019.01.02.08.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 08:07:50 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x02G7RLg093476;
	Thu, 3 Jan 2019 01:07:27 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav401.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp);
 Thu, 03 Jan 2019 01:07:27 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x02G7P2k093463
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Thu, 3 Jan 2019 01:07:26 +0900 (JST)
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
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <275523c6-f750-44c2-a8a4-f3825eeab788@i-love.sakura.ne.jp>
Date: Thu, 3 Jan 2019 01:07:25 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190102144015.GA23089@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102160725.agELLrj9QH6lVY09nR6F8PKiC2-91pcdULJ4H0zRy1M@z>

On 2019/01/02 23:40, Jan Kara wrote:
> I had a look into this and the only good explanation for this I have is
> that sb->s_blocksize is different from (1 << sb->s_bdev->bd_inode->i_blkbits).
> If that would happen, we'd get exactly the behavior syzkaller observes
> because grow_buffers() would populate different page than
> __find_get_block() then looks up.
> 
> However I don't see how that's possible since the filesystem has the block
> device open exclusively and blkdev_bszset() makes sure we also have
> exclusive access to the block device before changing the block device size.
> So changing block device block size after filesystem gets access to the
> device should be impossible. 
> 
> Anyway, could you perhaps add to your debug patch a dump of 'size' passed
> to __getblk_slow() and bdev->bd_inode->i_blkbits? That should tell us
> whether my theory is right or not. Thanks!
> 

OK. Andrew, will you add (or fold into) this change?

From e6f334380ad2c87457bfc2a4058316c47f75824a Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 3 Jan 2019 01:03:35 +0900
Subject: [PATCH] fs/buffer.c: dump more info for __getblk_gfp() stall problem

We need to dump more variables on top of
"fs/buffer.c: add debug print for __getblk_gfp() stall problem".

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Jan Kara <jack@suse.cz>
---
 fs/buffer.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 580fda0..a50acac 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1066,9 +1066,14 @@ static sector_t blkdev_max_block(struct block_device *bdev, unsigned int size)
 #ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
 		if (!time_after(jiffies, current->getblk_stamp + 3 * HZ))
 			continue;
-		printk(KERN_ERR "%s(%u): getblk(): executed=%x bh_count=%d bh_state=%lx\n",
+		printk(KERN_ERR "%s(%u): getblk(): executed=%x bh_count=%d bh_state=%lx "
+		       "bdev_super_blocksize=%lu size=%u "
+		       "bdev_super_blocksize_bits=%u bdev_inode_blkbits=%u\n",
 		       current->comm, current->pid, current->getblk_executed,
-		       current->getblk_bh_count, current->getblk_bh_state);
+		       current->getblk_bh_count, current->getblk_bh_state,
+		       bdev->bd_super->s_blocksize, size,
+		       bdev->bd_super->s_blocksize_bits,
+		       bdev->bd_inode->i_blkbits);
 		current->getblk_executed = 0;
 		current->getblk_bh_count = 0;
 		current->getblk_bh_state = 0;
-- 
1.8.3.1


