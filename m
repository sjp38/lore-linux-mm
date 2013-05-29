Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A4A936B0123
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:20:11 -0400 (EDT)
Subject: Re: [PATCH v2 1/2] Make the batch size of the percpu_counter
 configurable
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20130529122605.082cbb1ad8f5cbc9e82e7b16@linux-foundation.org>
References: 
	 <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
	 <20130521134122.4d8ea920c0f851fc2d97abc9@linux-foundation.org>
	 <1369178849.27102.330.camel@schen9-DESK>
	 <20130521164154.bed705c6e117ceb76205cd65@linux-foundation.org>
	 <1369183390.27102.337.camel@schen9-DESK>
	 <20130522002020.60c3808f.akpm@linux-foundation.org>
	 <1369265838.27102.351.camel@schen9-DESK>
	 <20130529122605.082cbb1ad8f5cbc9e82e7b16@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 May 2013 14:20:12 -0700
Message-ID: <1369862412.27102.368.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 2013-05-29 at 12:26 -0700, Andrew Morton wrote:
> On Wed, 22 May 2013 16:37:18 -0700 Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > Currently the per cpu counter's batch size for memory accounting is
> > configured as twice the number of cpus in the system.  However,
> > for system with very large memory, it is more appropriate to make it
> > proportional to the memory size per cpu in the system.
> > 
> > For example, for a x86_64 system with 64 cpus and 128 GB of memory,
> > the batch size is only 2*64 pages (0.5 MB).  So any memory accounting
> > changes of more than 0.5MB will overflow the per cpu counter into
> > the global counter.  Instead, for the new scheme, the batch size
> > is configured to be 0.4% of the memory/cpu = 8MB (128 GB/64 /256),
> > which is more inline with the memory size.
> 
> I renamed the patch to "mm: tune vm_committed_as percpu_counter
> batching size".
> 
> Do we have any performance testing results?  They're pretty important
> for a performance-improvement patch ;)
> 

I've done a repeated brk test of 800KB (from will-it-scale test suite)
with 80 concurrent processes on a 4 socket Westmere machine with a 
total of 40 cores.  Without the patch, about 80% of cpu is spent on
spin-lock contention within the vm_committed_as counter. With the patch,
there's a 73x speedup on the benchmark and the lock contention drops off
almost entirely.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
