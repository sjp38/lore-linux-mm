Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id F20CA6B00E8
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:08:50 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1740478pbc.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 12:08:50 -0700 (PDT)
Date: Fri, 20 Apr 2012 12:08:44 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120420190844.GH32324@google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
 <20120420133441.GA7035@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120420133441.GA7035@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

Hello, Fengguang.

On Fri, Apr 20, 2012 at 09:34:41PM +0800, Fengguang Wu wrote:
> >   Yup. This just shows that you have to have per-cgroup dirty limits. Once
> > you have those, things start working again.
> 
> Right. I think Tejun was more of less aware of this.

I'm fairly sure I'm on the "less" side of it.

> I was rather upset by this per-memcg dirty_limit idea indeed. I never
> expect it to work well when used extensively. My plan was to set the
> default memcg dirty_limit high enough, so that it's not hit in normal.
> Then Tejun came and proposed to (mis-)use dirty_limit as the way to
> convert the dirty pages' backpressure into real dirty throttling rate.
> No, that's just crazy idea!

I'll tell you what's crazy.

We're not gonna cut three more kernel releases and then change jobs.
Some of the stuff we put in the kernel ends up staying there for over
a decade.  While ignoring fundamental designs and violating layers may
look like rendering a quick solution.  They tend to come back and bite
our collective asses.  Ask Vivek.  The iosched / blkcg API was messed
up to the extent that bugs were so difficult to track down and it was
nearly impossible to add new features, let alone new blkcg policy or
elevator and people did suffer for that for long time.  I ended up
cleaning up the mess.  It took me longer than three months and even
then we have to carry on with a lot of ugly stuff for compatibility.

Unfortunately, your proposed solution is far worse than blkcg was or
ever could be.  It's not even contained in a single subsystem and it's
not even clear what it achieves.  Neither weight or hard limit can be
properly enforced without another layer of controlling at the block
layer (some use cases do expect strict enforcement) and we're baking
assumptions about use cases, interfaces and underlying hardware across
multiple subsystems (some ssds work fine with per-iops switching).
For your suggested solution, the moment it's best fit is now and it'll
be a long painful way down until someone snaps and reimplements the
whole thing.

The kernel is larger than balance_dirty_pages() or writeback.  Each
subsystem should do what it's supposed to do.  Let's solve problems
where they belong and pay overheads where they're due.  Let's not
contort the whole stack for the short term goal of shoving writeback
support into the existing, still-developing, blkcg cfq proportional IO
implementation.  Because that's pure insanity.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
