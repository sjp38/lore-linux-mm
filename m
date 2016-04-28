Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33E706B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:17:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so140056904pfe.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 22:17:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id h9si9449631pap.227.2016.04.27.22.17.14
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 22:17:14 -0700 (PDT)
Date: Thu, 28 Apr 2016 13:17:08 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [LKP] [lkp] [mm, oom] faad2185f4: vm-scalability.throughput
 -11.8% regression
Message-ID: <20160428051659.GA10843@aaronlu.sh.intel.com>
References: <20160427031556.GD29014@yexl-desktop>
 <20160427073617.GA2179@dhcp22.suse.cz>
 <87fuu7iht0.fsf@yhuang-dev.intel.com>
 <20160427083733.GE2179@dhcp22.suse.cz>
 <87bn4vigpc.fsf@yhuang-dev.intel.com>
 <20160427091718.GG2179@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427091718.GG2179@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, kernel test robot <xiaolong.ye@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, lkp@01.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, Apr 27, 2016 at 11:17:19AM +0200, Michal Hocko wrote:
> On Wed 27-04-16 16:44:31, Huang, Ying wrote:
> > Michal Hocko <mhocko@kernel.org> writes:
> > 
> > > On Wed 27-04-16 16:20:43, Huang, Ying wrote:
> > >> Michal Hocko <mhocko@kernel.org> writes:
> > >> 
> > >> > On Wed 27-04-16 11:15:56, kernel test robot wrote:
> > >> >> FYI, we noticed vm-scalability.throughput -11.8% regression with the following commit:
> > >> >
> > >> > Could you be more specific what the test does please?
> > >> 
> > >> The sub-testcase of vm-scalability is swap-w-rand.  An RAM emulated pmem
> > >> device is used as a swap device, and a test program will allocate/write
> > >> anonymous memory randomly to exercise page allocation, reclaiming, and
> > >> swapping in code path.
> > >
> > > Can I download the test with the setup to play with this?
> > 
> > There are reproduce steps in the original report email.
> > 
> > To reproduce:
> > 
> >         git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
> >         cd lkp-tests
> >         bin/lkp install job.yaml  # job file is attached in this email
> >         bin/lkp run     job.yaml
> > 
> > 
> > The job.yaml and kconfig file are attached in the original report email.
> 
> Thanks for the instructions. My bad I have overlooked that in the
> initial email. I have checked the configuration file and it seems rather
> hardcoded for a particular HW. It expects a machine with 128G and
> reserves 96G!4G which might lead to different amount of memory in the
> end depending on the particular memory layout.

Indeed, the job file needs manual change.
The attached job file is the one we used on the test machine.

> 
> Before I go and try to recreate a similar setup, how stable are the
> results from this test. Random access pattern sounds like rather
> volatile to be consider for a throughput test. Or is there any other
> side effect I am missing and something fails which didn't use to
> previously.

I have the same doubt too, but the results look really stable(only for
commit 0da9597ac9c0, see below for more explanation).
We did 8 runs for this report and the standard deviation(represented by
the %stddev shown in the original report) is used to show exactly this.

I just checked the results again and found that the 8 runs for your
commit faad2185f482 all OOMed, only 1 of them is able to finish the test
before the OOM occur and got a throughput value of 38653.

The source code for this test is here:
https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/tree/usemem.c
And it's started as:
./usemem --runtime 300 -n 16 --random 6368538624
which means to fork 16 processes, each dealing with 6GiB around data. By
dealing here, I mean the process each will mmap an anonymous region of
6GiB size and then write data to that area at random place, thus will
trigger swapouts and swapins after the memory is used up(since the
system has 128GiB memory and 96GiB is used by the pmem driver as swap
space, the memory will be used up after a little while).

So I guess the question here is, after the OOM rework, is the OOM
expected for such a case? If so, then we can ignore this report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
