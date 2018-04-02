Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 707736B000E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 16:32:07 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 1-v6so6548974plv.6
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 13:32:07 -0700 (PDT)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id p7si735709pgq.8.2018.04.02.13.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 13:32:06 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <CACT4Y+aSEsoS60A0O0Ypg=kwRZV10SzUELbcG7KEkaTV7aMU5Q@mail.gmail.com>
	<94eb2c0b816e88bfc50568c6fed5@google.com>
	<201804011941.IAE69652.OHMVJLFtSOFFQO@I-love.SAKURA.ne.jp>
Date: Mon, 02 Apr 2018 15:30:56 -0500
In-Reply-To: <201804011941.IAE69652.OHMVJLFtSOFFQO@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Sun, 1 Apr 2018 19:41:06 +0900")
Message-ID: <87lge5z6yn.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: WARNING: refcount bug in should_fail
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: syzbot+@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com, dvyukov@google.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, viro@zeniv.linux.org.uk

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> syzbot wrote:
>> > On Sun, Mar 4, 2018 at 6:57 AM, Tetsuo Handa
>> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> >> Switching from mm to fsdevel, for this report says that put_net(net) in
>> >> rpc_kill_sb() made net->count < 0 when mount_ns() failed due to
>> >> register_shrinker() failure.
>> 
>> >> Relevant commits will be
>> >> commit 9ee332d99e4d5a97 ("sget(): handle failures of  
>> >> register_shrinker()") and
>> >> commit d91ee87d8d85a080 ("vfs: Pass data, ns, and ns->userns to  
>> >> mount_ns.").
>> 
>> >> When sget_userns() in mount_ns() failed, mount_ns() returns an error  
>> >> code to
>> >> the caller without calling fill_super(). That is, get_net(sb->s_fs_info)  
>> >> was
>> >> not called by rpc_fill_super() (via fill_super callback passed to  
>> >> mount_ns())
>> >> but put_net(sb->s_fs_info) is called by rpc_kill_sb() (via fs->kill_sb()  
>> >> from
>> >> deactivate_locked_super()).
>> 
>> >> ----------
>> >> static struct dentry *
>> >> rpc_mount(struct file_system_type *fs_type,
>> >>                  int flags, const char *dev_name, void *data)
>> >> {
>> >>          struct net *net = current->nsproxy->net_ns;
>> >>          return mount_ns(fs_type, flags, data, net, net->user_ns,  
>> >> rpc_fill_super);
>> >> }
>> >> ----------
>> 
>> > Messed kernel output, this is definitely not in should_fail.
>> 
>> > #syz dup: WARNING: refcount bug in sk_alloc
>> 
>> Can't find the corresponding bug.
>> 
> I don't think this is a dup of existing bug.
> We need to fix either 9ee332d99e4d5a97 or d91ee87d8d85a080.

Even if expanding mount_ns to more filesystems was magically fixed,
proc would still have this issue with the pid namespace rather than
the net namespace.

This is a mess.  I will take a look and see if I can see a a fix.

Eric
