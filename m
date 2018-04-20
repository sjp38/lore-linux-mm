Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 540BF6B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:55:17 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w5-v6so5356799plz.17
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:55:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f66sor1527528pgc.188.2018.04.20.10.55.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Apr 2018 10:55:16 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:55:13 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: general protection fault in kernfs_kill_sb
Message-ID: <20180420175513.GA16820@gmail.com>
References: <20180420024440.GB686@sol.localdomain>
 <20180420033450.GC686@sol.localdomain>
 <201804200529.w3K5TdvM009951@www262.sakura.ne.jp>
 <20180420073158.GS17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420073158.GS17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Al Viro <viro@ZenIV.linux.org.uk>, syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com>, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-fsdevel@vger.kernel.org

On Fri, Apr 20, 2018 at 09:31:58AM +0200, Michal Hocko wrote:
> On Fri 20-04-18 14:29:39, Tetsuo Handa wrote:
> > Eric Biggers wrote:
> > > But, there is still a related bug: when mounting sysfs, if register_shrinker()
> > > fails in sget_userns(), then kernfs_kill_sb() gets called, which frees the
> > > 'struct kernfs_super_info'.  But, the 'struct kernfs_super_info' is also freed
> > > in kernfs_mount_ns() by:
> > > 
> > >         sb = sget_userns(fs_type, kernfs_test_super, kernfs_set_super, flags,
> > >                          &init_user_ns, info);
> > >         if (IS_ERR(sb) || sb->s_fs_info != info)
> > >                 kfree(info);
> > >         if (IS_ERR(sb))
> > >                 return ERR_CAST(sb);
> > > 
> > > I guess the problem is that sget_userns() shouldn't take ownership of the 'info'
> > > if it returns an error -- but, it actually does if register_shrinker() fails,
> > > resulting in a double free.
> > > 
> > > Here is a reproducer and the KASAN splat.  This is on Linus' tree (87ef12027b9b)
> > > with vfs/for-linus merged in.
> > 
> > I'm waiting for response from Michal Hocko regarding
> > http://lkml.kernel.org/r/201804111909.EGC64586.QSFLFJFOVHOOtM@I-love.SAKURA.ne.jp .
> 
> I didn't plan to respond util all the Al's concerns with the existing
> scheme are resolved. This is not an urgent thing to fix so better fix it
> properly. Your API change is kinda ugly so it would be preferable to do
> it properly as suggested by Al. Maybe that will be more work but my
> understanding is that the resulting code would be better. If that is not
> the case then I do not really have any fundamental objection to your
> patch except it is ugly.

Okay, the fix was merged already as commit 8e04944f0ea8b8 ("mm,vmscan: Allow
preallocating memory for register_shrinker().").  Thanks Tetsuo!

- Eric
