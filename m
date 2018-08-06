Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 755676B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:09:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21-v6so3834881edp.23
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:09:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36-v6si6572100edn.295.2018.08.06.03.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 03:09:35 -0700 (PDT)
Date: Mon, 6 Aug 2018 12:09:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: INFO: task hung in generic_file_write_iter
Message-ID: <20180806100928.x7anab3c3y5q4ssa@quack2.suse.cz>
References: <0000000000009ce88d05714242a8@google.com>
 <4b349bff-8ad4-6410-250d-593b13d8d496@I-love.SAKURA.ne.jp>
 <9b9fcdda-c347-53ee-fdbb-8a7d11cf430e@I-love.SAKURA.ne.jp>
 <20180720130602.f3d6dc4c943558875a36cb52@linux-foundation.org>
 <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a2df1f24-f649-f5d8-0b2d-66d45b6cb61f@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>, linux-mm@kvack.org, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ak@linux.intel.com, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, mawilcox@microsoft.com, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue 31-07-18 00:07:22, Tetsuo Handa wrote:
> On 2018/07/21 5:06, Andrew Morton wrote:
> > On Fri, 20 Jul 2018 19:36:23 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > 
> >>>
> >>> This report is stalling after mount() completed and process used remap_file_pages().
> >>> I think that we might need to use debug printk(). But I don't know what to examine.
> >>>
> >>
> >> Andrew, can you pick up this debug printk() patch?
> >> I guess we can get the result within one week.
> > 
> > Sure, let's toss it in -next for a while.
> > 
> >> >From 8f55e00b21fefffbc6abd9085ac503c52a302464 Mon Sep 17 00:00:00 2001
> >> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Date: Fri, 20 Jul 2018 19:29:06 +0900
> >> Subject: [PATCH] fs/buffer.c: add debug print for __getblk_gfp() stall problem
> >>
> >> Among syzbot's unresolved hung task reports, 18 out of 65 reports contain
> >> __getblk_gfp() line in the backtrace. Since there is a comment block that
> >> says that __getblk_gfp() will lock up the machine if try_to_free_buffers()
> >> attempt from grow_dev_page() is failing, let's start from checking whether
> >> syzbot is hitting that case. This change will be removed after the bug is
> >> fixed.
> > 
> > I'm not sure that grow_dev_page() is hanging.  It has often been
> > suspected, but always is proven innocent.  Lets see.
> 
> syzbot reproduced this problem ( https://syzkaller.appspot.com/text?tag=CrashLog&x=11f2fc44400000 ) .
> It says that grow_dev_page() is returning 1 but __find_get_block() is failing forever. Any idea?

Looks like some kind of a race where device block size gets changed while
getblk() runs (and creates buffers for underlying page). I don't have time
to nail it down at this moment can have a look into it later unless someone
beats me to it.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
