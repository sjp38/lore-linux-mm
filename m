Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0476B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:36:23 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x127so105544640pgb.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:36:23 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p7si200457pfb.260.2017.03.16.11.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 11:36:22 -0700 (PDT)
Message-ID: <1489689381.2733.114.camel@linux.intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 16 Mar 2017 11:36:21 -0700
In-Reply-To: <20170316090732.GF30501@dhcp22.suse.cz>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
	 <20170315141813.GB32626@dhcp22.suse.cz>
	 <20170315154406.GF2442@aaronlu.sh.intel.com>
	 <20170315162843.GA27197@dhcp22.suse.cz>
	 <1489613914.2733.96.camel@linux.intel.com>
	 <20170316090732.GF30501@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>

On Thu, 2017-03-16 at 10:07 +0100, Michal Hocko wrote:
> On Wed 15-03-17 14:38:34, Tim Chen wrote:
> > 
> > On Wed, 2017-03-15 at 17:28 +0100, Michal Hocko wrote:
> > > 
> > > On Wed 15-03-17 23:44:07, Aaron Lu wrote:
> > > > 
> > > > 
> > > > On Wed, Mar 15, 2017 at 03:18:14PM +0100, Michal Hocko wrote:
> > > > > 
> > > > > 
> > > > > On Wed 15-03-17 16:59:59, Aaron Lu wrote:
> > > > > [...]
> > > > > > 
> > > > > > 
> > > > > > The proposed parallel free did this: if the process has many pages to be
> > > > > > freed, accumulate them in these struct mmu_gather_batch(es) one after
> > > > > > another till 256K pages are accumulated. Then take this singly linked
> > > > > > list starting from tlb->local.next off struct mmu_gather *tlb and free
> > > > > > them in a worker thread. The main thread can return to continue zap
> > > > > > other pages(after freeing pages pointed by tlb->local.pages).
> > > > > I didn't have a look at the implementation yet but there are two
> > > > > concerns that raise up from this description. Firstly how are we going
> > > > > to tune the number of workers. I assume there will be some upper bound
> > > > > (one of the patch subject mentions debugfs for tuning) and secondly
> > > > The workers are put in a dedicated workqueue which is introduced in
> > > > patch 3/5 and the number of workers can be tuned through that workqueue's
> > > > sysfs interface: max_active.
> > > I suspect we cannot expect users to tune this. What do you consider a
> > > reasonable default?
> > From Aaron's data, it seems like 4 is a reasonable value for max_active:
> > 
> > max_active:A A A time
> > 1A A A A A A A A A A A A A 8.9sA A A A+-0.5%
> > 2A A A A A A A A A A A A A 5.65sA A A+-5.5%
> > 4A A A A A A A A A A A A A 4.84sA A A+-0.16%
> > 8A A A A A A A A A A A A A 4.77sA A A+-0.97%
> > 16A A A A A A A A A A A A 4.85sA A A+-0.77%
> > 32A A A A A A A A A A A A 6.21sA A A+-0.46%
> OK, but this will depend on the HW, right? Also now that I am looking at
> those numbers more closely. This was about unmapping 320GB area and
> using 4 times more CPUs you managed to half the run time. Is this really
> worth it? Sure if those CPUs were idle then this is a clear win but if
> the system is moderately busy then it doesn't look like a clear win to
> me.

It looks like we can reduce the exit time in half by using only 2 workers
to disturb the system minimally.
Perhaps we can only do this expedited exit only when there are idle cpus around.
We can use the root sched domain's overload indicator for such a quick check.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
