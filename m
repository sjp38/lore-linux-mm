Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C70066B0072
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 04:36:48 -0400 (EDT)
Date: Mon, 8 Apr 2013 09:36:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130408083645.GC2623@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130402151436.GC31577@thunk.org>
 <20130402181940.GA4936@thunk.org>
 <y0mwqsehuj9.fsf@fche.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <y0mwqsehuj9.fsf@fche.csb>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Cc: Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Sun, Apr 07, 2013 at 05:59:06PM -0400, Frank Ch. Eigler wrote:
> 
> Hi -
> 
> 
> tytso wrote:
> 
> > So I tried to reproduce the problem, and so I installed systemtap
> > (bleeding edge, since otherwise it won't work with development
> > kernel), and then rebuilt a kernel with all of the necessary CONFIG
> > options enabled:
> >
> > 	CONFIG_DEBUG_INFO, CONFIG_KPROBES, CONFIG_RELAY, CONFIG_DEBUG_FS,
> > 	CONFIG_MODULES, CONFIG_MODULE_UNLOAD
> > [...]
> 
> That sounds about right.
> 
> 
> > I then pulled down mmtests, and tried running watch-dstate.pl, which
> > is what I assume you were using [...]
> 
> I just took a look at the mmtests, particularly the stap-fix.sh stuff.
> The heroics therein are really not called for.  git kernel developers
> should use git systemtap, as has always been the case.  All
> compatibility hacks in stap-fix.sh have already been merged, in many
> cases for months.
> 

At one point in the past this used to be the case but then systemtap had to
be compiled as part of automated tests across different kernel versions. It
could have been worked around in various ways or even installed manually
when machines were deployed but stap-fix.sh generally took less time to
keep working.

> 
> > [...]
> > semantic error: while resolving probe point: identifier 'kprobe' at /tmp/stapdjN4_l:18:7
> >         source: probe kprobe.function("get_request_wait")
> >                       ^
> > Pass 2: analysis failed.  [man error::pass2]
> > Unexpected exit of STAP script at ./watch-dstate.pl line 296.
> > I have no clue what to do next.  Can you give me a hint?
> 
> You should see the error::pass2 man page, which refers to
> error::reporting, which refers to involving stap folks and running
> stap-report to gather needed info.
> 
> But in this case, that's unnecessary: the problem is most likely that
> the get_request_wait function does not actually exist any longer, since
> 
> commit a06e05e6afab70b4b23c0a7975aaeae24b195cd6
> Author: Tejun Heo <tj@kernel.org>
> Date:   Mon Jun 4 20:40:55 2012 -0700
> 
>     block: refactor get_request[_wait]()
> 

Yes, this was indeed the problem. The next version of watch-dstate.pl
treated get_request_wait() as a function that may or may not exist. It
uses /proc/kallsyms to figure it out.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
