Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id EEF386B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 21:03:47 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so1466574qcz.19
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 18:03:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u5si13555262qas.116.2014.12.19.18.03.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 18:03:47 -0800 (PST)
Date: Sat, 20 Dec 2014 13:03:31 +1100
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20141220020331.GM1942@devil.localdomain>
References: <20141216124714.GF22914@dhcp22.suse.cz>
 <201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
 <20141217130807.GB24704@dhcp22.suse.cz>
 <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
 <20141218153341.GB832@dhcp22.suse.cz>
 <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, david@fromorbit.com

On Fri, Dec 19, 2014 at 09:22:49PM +0900, Tetsuo Handa wrote:
> (Renamed thread's title and invited Dave Chinner. A memory stressing program
> at http://marc.info/?l=linux-mm&m=141890469424353&w=2 can trigger stalls on
> a system with 4 CPUs/2048MB of RAM/no swap. I want to hear your opinion.)
> 
> Michal Hocko wrote:
> > > My question is quite simple. How can we avoid memory allocation stalls when
> > >
> > >   System has 2048MB of RAM and no swap.
> > >   Memcg1 for task1 has quota 512MB and 400MB in use.
> > >   Memcg2 for task2 has quota 512MB and 400MB in use.
> > >   Memcg3 for task3 has quota 512MB and 400MB in use.
> > >   Memcg4 for task4 has quota 512MB and 400MB in use.
> > >   Memcg5 for task5 has quota 512MB and 1MB in use.
> > >
> > > and task5 launches below memory consumption program which would trigger
> > > the global OOM killer before triggering the memcg OOM killer?
> > >
> > [...]
> > > The global OOM killer will try to kill this program because this program
> > > will be using 400MB+ of RAM by the time the global OOM killer is triggered.
> > > But sometimes this program cannot be terminated by the global OOM killer
> > > due to XFS lock dependency.
> > >
> > > You can see what is happening from OOM traces after uptime > 320 seconds of
> > > http://I-love.SAKURA.ne.jp/tmp/serial-20141213.txt.xz though memcg is not
> > > configured on this program.
> >
> > This is clearly a separate issue. It is a lock dependency and that alone
> > _cannot_ be handled from OOM killer as it doesn't understand lock
> > dependencies. This should be addressed from the xfs point of view IMHO
> > but I am not familiar with this filesystem to tell you how or whether it
> > is possible.

What XFS lock dependency? I see nothing in that output file that indicates a
lock dependency problem - can you point out what the issue is here?

> Then, let's ask Dave Chinner whether he can address it. My opinion is that
> everybody is doing __GFP_WAIT memory allocation without understanding the
> entire dependencies. Everybody is only prepared for allocation failures
> because everybody is expecting that the OOM killer shall somehow solve the
> OOM condition (except that some are expecting that memory stress that will
> trigger the OOM killer must not be given). I am neither familiar with XFS,
> but I don't think this issue can be addressed from the XFS point of view.

Well, I can't comment (nor am I going to waste time speculating)
until someone actually explains the XFS lock dependency that is
apparently causing reclaim problems.

Has lockdep reported any problems?

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
