Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0DA6B025F
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 08:55:03 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o20so1967470wro.8
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:55:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a17si1344549wmg.219.2017.11.29.05.55.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 05:55:01 -0800 (PST)
Date: Wed, 29 Nov 2017 14:55:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm,vmscan: Make unregister_shrinker() no-op if
 register_shrinker() failed.
Message-ID: <20171129135500.3gak5kmtf4ho5ckj@dhcp22.suse.cz>
References: <20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
 <201711242221.BJD26077.SFOtVQJMFHOOFL@I-love.SAKURA.ne.jp>
 <20171124132857.vi4t7szmbknywng7@dhcp22.suse.cz>
 <201711251040.IHJ00547.FOFStVJOOMHFLQ@I-love.SAKURA.ne.jp>
 <20171127082936.27yt7sn2ucatvben@dhcp22.suse.cz>
 <201711292244.BHF26553.MOFQFtVJHOOFSL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711292244.BHF26553.MOFQFtVJHOOFSL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com, syzkaller@googlegroups.com

On Wed 29-11-17 22:44:45, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 25-11-17 10:40:13, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Fri 24-11-17 22:21:55, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > > Since we can encourage register_shrinker() callers to check for failure
> > > > > > > by marking register_shrinker() as __must_check, unregister_shrinker()
> > > > > > > can stay silent.
> > > > > > 
> > > > > > I am not sure __must_check is the right way. We already do get
> > > > > > allocation warning if the registration fails so silent unregister is
> > > > > > acceptable. Unchecked register_shrinker is a bug like any other
> > > > > > unchecked error path.
> > > > > 
> > > > > I consider that __must_check is the simplest way to find all of
> > > > > unchecked register_shrinker bugs. Why not to encourage users to fix?
> > > > 
> > > > because git grep doesn't require to patch the kernel and still provide
> > > > the information you want.
> > > 
> > > I can't interpret this line. How git grep relevant?
> > 
> > you do not have to compile to see who is checking the return value.
> > Seriously there is no need to overcomplicate this. Newly added shrinkers
> > know the function returns might fail so we just have to handle existing
> > users and there are not all that many of those.
> 
> Newly added shrinker users are not always careful. See commit f2517eb76f1f2f7f
> ("android: binder: Add global lru shrinker to binder") for example.
> Unless we send __must_check change to linux.git, people won't notice it.

Crap code doesn't really warrant special handling. This is a failure of
reviewers...

Really, if we start abusing __must_check for non-fatal paths then it
will turn into an ignored class of warnings or find workarounds to
silent false positives.

Look, I will not lose more time discussing this borderline thing with
you even though obviously consider this the number one problem. But you
should really think more from a wider perspective rather than
obsessively focus into a unlikely corner case and beat the soul out of
it.

I really do appreciate you started fixing the remaining places of
course, that is the usual way to deal with these issues. But placing
__must_check around is just pointless. If Andrew thinks this is really
worth it, I will not object...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
