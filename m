Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E127B6B0085
	for <linux-mm@kvack.org>; Wed,  1 May 2013 12:07:44 -0400 (EDT)
Subject: Re: [PATCH 2/2] Make batch size for memory accounting configured
 according to size of memory
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <5180A37E.8010701@gmail.com>
References: 
	 <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
	 <8c9bc7d4646d48154604820a3ec5952ba8949de4.1367254913.git.tim.c.chen@linux.intel.com>
	 <5180A37E.8010701@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 May 2013 09:07:34 -0700
Message-ID: <1367424454.27102.204.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 2013-05-01 at 13:09 +0800, Ric Mason wrote:
> Hi Tim,
> On 04/30/2013 01:12 AM, Tim Chen wrote:
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
> 
> If large batch size will lead to global counter more inaccurate?
> 

I've kept the error tolerance fairly small (0.4%), so it should not be
an issue.

If this is a concern, we can switch to percpu_counter_compare that will
use the global counter quick compare and switch to accurate compare if
needed (like the following).

index d1e4124..c78be36 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -187,7 +187,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
        if (mm)
                allowed -= mm->total_vm / 32;
 
-       if (percpu_counter_read_positive(&vm_committed_as) < allowed)
+       if (percpu_counter_compare(&vm_committed_as, allowed) < 0)
                return 0;
 error:
        vm_unacct_memory(pages);


Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
