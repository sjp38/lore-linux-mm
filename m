Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 335046B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 06:41:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j8so10830362pfh.13
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 03:41:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y7si283959pfl.313.2018.04.01.03.41.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Apr 2018 03:41:46 -0700 (PDT)
Subject: Re: WARNING: refcount bug in should_fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CACT4Y+aSEsoS60A0O0Ypg=kwRZV10SzUELbcG7KEkaTV7aMU5Q@mail.gmail.com>
	<94eb2c0b816e88bfc50568c6fed5@google.com>
In-Reply-To: <94eb2c0b816e88bfc50568c6fed5@google.com>
Message-Id: <201804011941.IAE69652.OHMVJLFtSOFFQO@I-love.SAKURA.ne.jp>
Date: Sun, 1 Apr 2018 19:41:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot+@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com, dvyukov@google.com
Cc: ebiederm@xmission.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, viro@zeniv.linux.org.uk

syzbot wrote:
> > On Sun, Mar 4, 2018 at 6:57 AM, Tetsuo Handa
> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >> Switching from mm to fsdevel, for this report says that put_net(net) in
> >> rpc_kill_sb() made net->count < 0 when mount_ns() failed due to
> >> register_shrinker() failure.
> 
> >> Relevant commits will be
> >> commit 9ee332d99e4d5a97 ("sget(): handle failures of  
> >> register_shrinker()") and
> >> commit d91ee87d8d85a080 ("vfs: Pass data, ns, and ns->userns to  
> >> mount_ns.").
> 
> >> When sget_userns() in mount_ns() failed, mount_ns() returns an error  
> >> code to
> >> the caller without calling fill_super(). That is, get_net(sb->s_fs_info)  
> >> was
> >> not called by rpc_fill_super() (via fill_super callback passed to  
> >> mount_ns())
> >> but put_net(sb->s_fs_info) is called by rpc_kill_sb() (via fs->kill_sb()  
> >> from
> >> deactivate_locked_super()).
> 
> >> ----------
> >> static struct dentry *
> >> rpc_mount(struct file_system_type *fs_type,
> >>                  int flags, const char *dev_name, void *data)
> >> {
> >>          struct net *net = current->nsproxy->net_ns;
> >>          return mount_ns(fs_type, flags, data, net, net->user_ns,  
> >> rpc_fill_super);
> >> }
> >> ----------
> 
> > Messed kernel output, this is definitely not in should_fail.
> 
> > #syz dup: WARNING: refcount bug in sk_alloc
> 
> Can't find the corresponding bug.
> 
I don't think this is a dup of existing bug.
We need to fix either 9ee332d99e4d5a97 or d91ee87d8d85a080.
