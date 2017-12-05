Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9C46B0271
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 04:41:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id 80so185wmb.7
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 01:41:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d38si20986ede.45.2017.12.05.01.41.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 01:41:53 -0800 (PST)
Date: Tue, 5 Dec 2017 10:41:50 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: possible deadlock in generic_file_write_iter (2)
Message-ID: <20171205094150.GA6076@quack2.suse.cz>
References: <94eb2c0d010a4e7897055f70535b@google.com>
 <20171204083339.GF8365@quack2.suse.cz>
 <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Jan Kara <jack@suse.cz>, syzbot <bot+045a1f65bdea780940bf0f795a292f4cd0b773d1@syzkaller.appspotmail.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, peterz@infradead.org, kernel-team@lge.com


Hello Byungchul,

On Tue 05-12-17 13:58:09, Byungchul Park wrote:
> On 12/4/2017 5:33 PM, Jan Kara wrote:
> >adding Peter and Byungchul to CC since the lockdep report just looks
> >strange and cross-release seems to be involved. Guys, how did #5 get into
> >the lock chain and what does put_ucounts() have to do with sb_writers
> >there? Thanks!
> 
> Hello Jan,
> 
> In order to get full stack of #5, we have to pass a boot param,
> "crossrelease_fullstack", to the kernel. Now that it only informs
> put_ucounts() in the call trace, it's hard to find out what exactly
> happened at that time, but I can tell #5 shows:

OK, thanks for the tip.

> When acquire(sb_writers) in put_ucounts(), it was on the way to
> complete((completion)&req.done) of wait_for_completion() in
> devtmpfs_create_node().
> 
> If acquire(sb_writers) in put_ucounts() is stuck, then
> wait_for_completion() in devtmpfs_create_node() would be also
> stuck, since complete() being in the context of acquire(sb_writers)
> cannot be called.

But this is something I don't get: There aren't sb_writers anywhere near
put_ucounts(). So why the heck did lockdep think that sb_writers are
acquired by put_ucounts()?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
