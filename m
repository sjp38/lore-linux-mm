Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6156E6B0007
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 17:52:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x20so1508312wmc.0
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 14:52:24 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id r12si947174wmc.134.2018.04.02.14.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 14:52:22 -0700 (PDT)
Date: Mon, 2 Apr 2018 22:52:12 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: WARNING: refcount bug in should_fail
Message-ID: <20180402215212.GF30522@ZenIV.linux.org.uk>
References: <CACT4Y+aSEsoS60A0O0Ypg=kwRZV10SzUELbcG7KEkaTV7aMU5Q@mail.gmail.com>
 <94eb2c0b816e88bfc50568c6fed5@google.com>
 <201804011941.IAE69652.OHMVJLFtSOFFQO@I-love.SAKURA.ne.jp>
 <87lge5z6yn.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lge5z6yn.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot+@syzkaller.appspotmail.com, syzkaller-bugs@googlegroups.com, dvyukov@google.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org

On Mon, Apr 02, 2018 at 03:30:56PM -0500, Eric W. Biederman wrote:
> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> > I don't think this is a dup of existing bug.
> > We need to fix either 9ee332d99e4d5a97 or d91ee87d8d85a080.
> 
> Even if expanding mount_ns to more filesystems was magically fixed,
> proc would still have this issue with the pid namespace rather than
> the net namespace.
> 
> This is a mess.  I will take a look and see if I can see a a fix.

It's trivially fixable, and there's no need to modify mount_ns() at
all.

All we need is for rpc_kill_sb() to recognize whether we are already
through the point in rpc_fill_super() where the refcount is bumped.
That's it.

The most trivial way to do that is to move
	net = get_net(sb->s_fs_info);
past
        if (!root)
                return -ENOMEM;
in the latter and have
out:
	if (!sb->s_root)
		net = NULL;
        kill_litter_super(sb);
	if (net)
		put_net(net);
in the end of the former.  And similar changes in other affected
instances.
