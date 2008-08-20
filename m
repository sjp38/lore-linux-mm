Date: Wed, 20 Aug 2008 11:31:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
Message-Id: <20080820113131.f032c8a2.akpm@linux-foundation.org>
In-Reply-To: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Aug 2008 20:05:51 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi Cristoph,
> 
> Thank you for explain your quicklist plan at OLS.
> 
> So, I made summary to issue of quicklist.
> if you have a bit time, Could you please read this mail and patches?
> And, if possible, Could you please tell me your feeling?
> 
> 
> --------------------------------------------------------------------
> 
> Now, Quicklist store some page in each CPU as cache.
> (Each CPU has node_free_pages/16 pages)
> 
> and it is used for page table cache.
> Then, exit() increase cache, the other hand fork() spent it.
> 
> So, if apache type (one parent and many child model) middleware run,
> One CPU process fork(), Other CPU process the middleware work and exit().
> 
> At that time, One CPU don't have page table cache at all,
> Others have maximum caches.
> 
> 	QList_max = (#ofCPUs - 1) x Free / 16
> 	=> QList_max / (Free + QList_max) = (#ofCPUs - 1) / (16 + #ofCPUs - 1)
> 
> So, How much quicklist spent memory at maximum case?
> That is #CPUs proposional because it is per CPU cache but cache amount calculation doesn't use #ofCPUs.
> 
> 	Above calculation mean
> 
> 	 Number of CPUs per node            2    4    8   16
> 	 ==============================  ====================
> 	 QList_max / (Free + QList_max)   5.8%  16%  30%  48%
> 
> 
> Wow! Quicklist can spent about 50% memory at worst case.
> More unfortunately, it doesn't have any cache shrinking mechanism.
> So it cause some wrong thing.
> 
> 1. End user misunderstand to memory leak happend.
> 	=> /proc/meminfo should display amount quicklist
> 
> 2. It can cause OOM killer
> 	=> Amount of quicklists shouldn't be proposional to #ofCPUs.
> 

OK, that's a fatal bug and it's present in 2.6.25.x and 2.6.26.x.  A
serious issue.

The patches do apply to both stable kernels and I have tagged them for
backporting into them.  They're nice and small, but I didn't get a
really solid yes-this-is-what-we-should-do from Christoph?


This (from [patch 2/2]): "(Although its patch applied, quicklist can
waste 64GB on 1TB server (= 1TB / 16), it is still too much??)" is a
bit of a worry.  Yes, 64GB is too much!  But at least this is now only
a performance issue rather than a stability issue, yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
