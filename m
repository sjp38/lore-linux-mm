Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4D496B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 20:01:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t4-v6so6875840pgv.21
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 17:01:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u1-v6si8293413plb.253.2018.04.30.17.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 17:01:47 -0700 (PDT)
Date: Mon, 30 Apr 2018 17:01:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: access to uninitialized struct page
Message-Id: <20180430170145.544342905604331c0e1b95d9@linux-foundation.org>
In-Reply-To: <20180430195858.5242373c@gandalf.local.home>
References: <20180426202619.2768-1-pasha.tatashin@oracle.com>
	<20180430162658.598dd5dcdd0c67e36953281c@linux-foundation.org>
	<20180430195858.5242373c@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, tglx@linutronix.de, mhocko@suse.com, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, fengguang.wu@intel.com, dennisszhou@gmail.com

On Mon, 30 Apr 2018 19:58:58 -0400 Steven Rostedt <rostedt@goodmis.org> wrote:

> On Mon, 30 Apr 2018 16:26:58 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 26 Apr 2018 16:26:19 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
> > 
> > > The following two bugs were reported by Fengguang Wu:
> > > 
> > > kernel reboot-without-warning in early-boot stage, last printk:
> > > early console in setup code
> > > 
> > > http://lkml.kernel.org/r/20180418135300.inazvpxjxowogyge@wfg-t540p.sh.intel.com
> > > 
> > > ...
> > >
> > > --- a/init/main.c
> > > +++ b/init/main.c
> > > @@ -585,8 +585,8 @@ asmlinkage __visible void __init start_kernel(void)
> > >  	setup_log_buf(0);
> > >  	vfs_caches_init_early();
> > >  	sort_main_extable();
> > > -	trap_init();
> > >  	mm_init();
> > > +	trap_init();
> > >  
> > >  	ftrace_init();  
> > 
> > Gulp.  Let's hope that nothing in mm_init() requires that trap_init()
> > has been run.  What happens if something goes wrong during mm_init()
> > and the architecture attempts to raise a software exception, hits a bus
> > error, div-by-zero, etc, etc?  Might there be hard-to-discover
> > dependencies in such a case?
> 
> I mentioned the same thing.
> 

I guess the same concern applies to all the code which we've always run
before trap_init(), and that's quite a lot of stuff.  So we should be
OK.  But don't quote me ;)
