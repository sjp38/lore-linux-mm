Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D34A6B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 06:37:06 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g6-v6so8445829iti.7
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:37:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m125-v6si1219200iof.217.2018.07.20.03.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 03:37:04 -0700 (PDT)
Subject: Re: INFO: task hung in generic_file_write_iter
References: <0000000000009ce88d05714242a8@google.com>
 <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
Date: Fri, 20 Jul 2018 19:36:23 +0900
MIME-Version: 1.0
In-Reply-To: <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, linux-mm@kvack.org, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 2018/07/18 19:28, Tetsuo Handa wrote:
> There are many reports which are stalling inside __getblk_gfp().

Currently 18 reports out of 65 "INFO: task hung in " reports.

  INFO: task hung in aead_recvmsg
  INFO: task hung in inode_sleep_on_writeback
  INFO: task hung in __writeback_inodes_sb_nr
  INFO: task hung in __blkdev_get (2)
  INFO: task hung in lookup_slow
  INFO: task hung in iterate_supers
  INFO: task hung in flush_work
  INFO: task hung in vfs_setxattr
  INFO: task hung in lock_mount
  INFO: task hung in __get_super
  INFO: task hung in do_unlinkat
  INFO: task hung in fat_fallocate
  INFO: task hung in generic_file_write_iter
  INFO: task hung in d_alloc_parallel
  INFO: task hung in __fdget_pos (2)
  INFO: task hung in path_openat
  INFO: task hung in do_truncate
  INFO: task hung in filename_create

> And there is horrible comment for __getblk_gfp():
> 
>   /*
>    * __getblk_gfp() will locate (and, if necessary, create) the buffer_head
>    * which corresponds to the passed block_device, block and size. The
>    * returned buffer has its reference count incremented.
>    *
>    * __getblk_gfp() will lock up the machine if grow_dev_page's
>    * try_to_free_buffers() attempt is failing.  FIXME, perhaps?
>    */
> 
> This report is stalling after mount() completed and process used remap_file_pages().
> I think that we might need to use debug printk(). But I don't know what to examine.
> 

Andrew, can you pick up this debug printk() patch?
I guess we can get the result within one week.
