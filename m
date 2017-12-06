Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 954986B0345
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 00:34:26 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id f15so359988plr.16
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 21:34:26 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j185si1281997pgc.455.2017.12.05.21.34.24
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 21:34:25 -0800 (PST)
Date: Wed, 6 Dec 2017 14:34:03 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: possible deadlock in generic_file_write_iter (2)
Message-ID: <20171206053402.GB5260@X58A-UD3R>
References: <94eb2c0d010a4e7897055f70535b@google.com>
 <20171204083339.GF8365@quack2.suse.cz>
 <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
 <20171205094150.GA6076@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205094150.GA6076@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: syzbot <bot+045a1f65bdea780940bf0f795a292f4cd0b773d1@syzkaller.appspotmail.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, peterz@infradead.org, kernel-team@lge.com

On Tue, Dec 05, 2017 at 10:41:50AM +0100, Jan Kara wrote:
> 
> Hello Byungchul,
> 
> On Tue 05-12-17 13:58:09, Byungchul Park wrote:
> > On 12/4/2017 5:33 PM, Jan Kara wrote:
> > >adding Peter and Byungchul to CC since the lockdep report just looks
> > >strange and cross-release seems to be involved. Guys, how did #5 get into
> > >the lock chain and what does put_ucounts() have to do with sb_writers
> > >there? Thanks!
> > 
> > Hello Jan,
> > 
> > In order to get full stack of #5, we have to pass a boot param,
> > "crossrelease_fullstack", to the kernel. Now that it only informs
> > put_ucounts() in the call trace, it's hard to find out what exactly
> > happened at that time, but I can tell #5 shows:
> 
> OK, thanks for the tip.
> 
> > When acquire(sb_writers) in put_ucounts(), it was on the way to
> > complete((completion)&req.done) of wait_for_completion() in
> > devtmpfs_create_node().
> > 
> > If acquire(sb_writers) in put_ucounts() is stuck, then
> > wait_for_completion() in devtmpfs_create_node() would be also
> > stuck, since complete() being in the context of acquire(sb_writers)
> > cannot be called.
> 
> But this is something I don't get: There aren't sb_writers anywhere near
> put_ucounts(). So why the heck did lockdep think that sb_writers are
> acquired by put_ucounts()?

I also think it looks so weird. I just record _RET_IP_ or _THIS_IP_ when
acquire(sb_writers). Is it possible to get wrong _RET_IP_ or _THIS_IP_ by
any chance?

> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
