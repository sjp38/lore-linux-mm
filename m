Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 093C26B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 03:32:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so7707620wrg.11
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 00:32:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si737354edr.146.2018.04.20.00.32.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 00:32:01 -0700 (PDT)
Date: Fri, 20 Apr 2018 09:31:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: general protection fault in kernfs_kill_sb
Message-ID: <20180420073158.GS17484@dhcp22.suse.cz>
References: <20180420024440.GB686@sol.localdomain>
 <20180420033450.GC686@sol.localdomain>
 <201804200529.w3K5TdvM009951@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201804200529.w3K5TdvM009951@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Eric Biggers <ebiggers3@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, syzbot <syzbot+151de3f2be6b40ac8026@syzkaller.appspotmail.com>, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-fsdevel@vger.kernel.org

On Fri 20-04-18 14:29:39, Tetsuo Handa wrote:
> Eric Biggers wrote:
> > But, there is still a related bug: when mounting sysfs, if register_shrinker()
> > fails in sget_userns(), then kernfs_kill_sb() gets called, which frees the
> > 'struct kernfs_super_info'.  But, the 'struct kernfs_super_info' is also freed
> > in kernfs_mount_ns() by:
> > 
> >         sb = sget_userns(fs_type, kernfs_test_super, kernfs_set_super, flags,
> >                          &init_user_ns, info);
> >         if (IS_ERR(sb) || sb->s_fs_info != info)
> >                 kfree(info);
> >         if (IS_ERR(sb))
> >                 return ERR_CAST(sb);
> > 
> > I guess the problem is that sget_userns() shouldn't take ownership of the 'info'
> > if it returns an error -- but, it actually does if register_shrinker() fails,
> > resulting in a double free.
> > 
> > Here is a reproducer and the KASAN splat.  This is on Linus' tree (87ef12027b9b)
> > with vfs/for-linus merged in.
> 
> I'm waiting for response from Michal Hocko regarding
> http://lkml.kernel.org/r/201804111909.EGC64586.QSFLFJFOVHOOtM@I-love.SAKURA.ne.jp .

I didn't plan to respond util all the Al's concerns with the existing
scheme are resolved. This is not an urgent thing to fix so better fix it
properly. Your API change is kinda ugly so it would be preferable to do
it properly as suggested by Al. Maybe that will be more work but my
understanding is that the resulting code would be better. If that is not
the case then I do not really have any fundamental objection to your
patch except it is ugly.
-- 
Michal Hocko
SUSE Labs
