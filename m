Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id AA67D6B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 13:10:16 -0400 (EDT)
Message-ID: <517028F1.6000002@sr71.net>
Date: Thu, 18 Apr 2013 10:10:09 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 00/15][Sorted-buddy] mm: Memory Power Management
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/09/2013 02:45 PM, Srivatsa S. Bhat wrote:
> 2. Performance overhead is expected to be low: Since we retain the simplicity
>    of the algorithm in the page allocation path, page allocation can
>    potentially remain as fast as it would be without memory regions. The
>    overhead is pushed to the page-freeing paths which are not that critical.

Numbers, please.  The problem with pushing the overhead to frees is that
they, believe it or not, actually average out to the same as the number
of allocs.  Think kernel compile, or a large dd.  Both of those churn
through a lot of memory, and both do an awful lot of allocs _and_ frees.
 We need to know both the overhead on a system that does *no* memory
power management, and the overhead on a system which is carved and
actually using this code.

> Kernbench results didn't show any noticeable performance degradation with
> this patchset as compared to vanilla 3.9-rc5.

Surely this code isn't magical and there's overhead _somewhere_, and
such overhead can be quantified _somehow_.  Have you made an effort to
find those cases, even with microbenchmarks?

I still also want to see some hard numbers on:
> However, memory consumes a significant amount of power, potentially upto
> more than a third of total system power on server systems.
and
> It had been demonstrated on a Samsung Exynos board
> (with 2 GB RAM) that upto 6 percent of total system power can be saved by
> making the Linux kernel MM subsystem power-aware[4]. 

That was *NOT* with this code, and it's nearing being two years old.
What can *this* *patch* do?

I think there are three scenarios to look at.  Let's say you have an 8GB
system with 1GB regions:
1. Normal unpatched kernel, booted with  mem=1G...8G (in 1GB increments
   perhaps) running some benchmark which sees performance scale with
   the amount of memory present in the system.
2. Kernel patched with this set, running the same test, but with single
   memory regions.
3. Kernel patched with this set.  But, instead of using mem=, you run
   it trying to evacuate equivalent amount of memory to the amounts you
   removed using mem=.

That will tell us both what the overhead is, and how effective it is.
I'd much rather see actual numbers and a description of the test than
some hand waving that it "didn't show any noticeable performance
degradation".

The amount of code here isn't huge.  But, it sucks that it's bloating
the already quite plump page_alloc.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
