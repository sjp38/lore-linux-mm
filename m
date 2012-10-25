Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 52EAB6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 17:05:26 -0400 (EDT)
Date: Thu, 25 Oct 2012 14:05:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-Id: <20121025140524.17083937.akpm@linux-foundation.org>
In-Reply-To: <20121025204959.GA27251@otc-wbsnb-06>
References: <20121018164502.b32791e7.akpm@linux-foundation.org>
	<20121018235941.GA32397@shutemov.name>
	<20121023063532.GA15870@shutemov.name>
	<20121022234349.27f33f62.akpm@linux-foundation.org>
	<20121023070018.GA18381@otc-wbsnb-06>
	<20121023155915.7d5ef9d1.akpm@linux-foundation.org>
	<20121023233801.GA21591@shutemov.name>
	<20121024122253.5ecea992.akpm@linux-foundation.org>
	<20121024194552.GA24460@otc-wbsnb-06>
	<20121024132552.5f9a5f5b.akpm@linux-foundation.org>
	<20121025204959.GA27251@otc-wbsnb-06>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Thu, 25 Oct 2012 23:49:59 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> On Wed, Oct 24, 2012 at 01:25:52PM -0700, Andrew Morton wrote:
> > On Wed, 24 Oct 2012 22:45:52 +0300
> > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > On Wed, Oct 24, 2012 at 12:22:53PM -0700, Andrew Morton wrote:
> > > > 
> > > > I'm thinking that such a workload would be the above dd in parallel
> > > > with a small app which touches the huge page and then exits, then gets
> > > > executed again.  That "small app" sounds realistic to me.  Obviously
> > > > one could exercise the zero page's refcount at higher frequency with a
> > > > tight map/touch/unmap loop, but that sounds less realistic.  It's worth
> > > > trying that exercise as well though.
> > > > 
> > > > Or do something else.  But we should try to probe this code's
> > > > worst-case behaviour, get an understanding of its effects and then
> > > > decide whether any such workload is realisic enough to worry about.
> > > 
> > > Okay, I'll try few memory pressure scenarios.
> 
> A test program:
> 
>         while (1) {
>                 posix_memalign((void **)&p, 2 * MB, 2 * MB);
>                 assert(*p == 0);
>                 free(p);
>         }
> 
> With this code in background we have pretty good chance to have huge zero
> page freeable (refcount == 1) when shrinker callback called - roughly one
> of two.
> 
> Pagecache hog (dd if=hugefile of=/dev/null bs=1M) creates enough pressure
> to get shrinker callback called, but it was only asked about cache size
> (nr_to_scan == 0).
> I was not able to get it called with nr_to_scan > 0 on this scenario, so
> hzp never freed.

hm.  It's odd that the kernel didn't try to shrink slabs in this case. 
Why didn't it??

> I also tried another scenario: usemem -n16 100M -r 1000. It creates real
> memory pressure - no easy reclaimable memory. This time callback called
> with nr_to_scan > 0 and we freed hzp. Under pressure we fails to allocate
> hzp and code goes to fallback path as it supposed to.
> 
> Do I need to check any other scenario?

I'm thinking that if we do hit problems in this area, we could avoid
freeing the hugepage unless the scan_control.priority is high enough. 
That would involve adding a magic number or a tunable to set the
threshold.

Also, it would be beneficial if we can monitor this easily.  Perhaps
add a counter to /proc/vmstat which tells us how many times that page
has been reallocated?  And perhaps how many times we tried to allocate
it but failed?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
