Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA2E6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 08:44:54 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p144so3002138itc.9
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:44:54 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a12si1388204ioc.14.2017.11.29.05.44.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 05:44:52 -0800 (PST)
Subject: Re: [PATCH v2 1/2] mm,vmscan: Make unregister_shrinker() no-op if register_shrinker() failed.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
	<201711242221.BJD26077.SFOtVQJMFHOOFL@I-love.SAKURA.ne.jp>
	<20171124132857.vi4t7szmbknywng7@dhcp22.suse.cz>
	<201711251040.IHJ00547.FOFStVJOOMHFLQ@I-love.SAKURA.ne.jp>
	<20171127082936.27yt7sn2ucatvben@dhcp22.suse.cz>
In-Reply-To: <20171127082936.27yt7sn2ucatvben@dhcp22.suse.cz>
Message-Id: <201711292244.BHF26553.MOFQFtVJHOOFSL@I-love.SAKURA.ne.jp>
Date: Wed, 29 Nov 2017 22:44:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com, syzkaller@googlegroups.com

Michal Hocko wrote:
> On Sat 25-11-17 10:40:13, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 24-11-17 22:21:55, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > > Since we can encourage register_shrinker() callers to check for failure
> > > > > > by marking register_shrinker() as __must_check, unregister_shrinker()
> > > > > > can stay silent.
> > > > > 
> > > > > I am not sure __must_check is the right way. We already do get
> > > > > allocation warning if the registration fails so silent unregister is
> > > > > acceptable. Unchecked register_shrinker is a bug like any other
> > > > > unchecked error path.
> > > > 
> > > > I consider that __must_check is the simplest way to find all of
> > > > unchecked register_shrinker bugs. Why not to encourage users to fix?
> > > 
> > > because git grep doesn't require to patch the kernel and still provide
> > > the information you want.
> > 
> > I can't interpret this line. How git grep relevant?
> 
> you do not have to compile to see who is checking the return value.
> Seriously there is no need to overcomplicate this. Newly added shrinkers
> know the function returns might fail so we just have to handle existing
> users and there are not all that many of those.

Newly added shrinker users are not always careful. See commit f2517eb76f1f2f7f
("android: binder: Add global lru shrinker to binder") for example.
Unless we send __must_check change to linux.git, people won't notice it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
