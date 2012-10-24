Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id CF7EB6B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 15:22:55 -0400 (EDT)
Date: Wed, 24 Oct 2012 12:22:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-Id: <20121024122253.5ecea992.akpm@linux-foundation.org>
In-Reply-To: <20121023233801.GA21591@shutemov.name>
References: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1350280859-18801-11-git-send-email-kirill.shutemov@linux.intel.com>
	<20121018164502.b32791e7.akpm@linux-foundation.org>
	<20121018235941.GA32397@shutemov.name>
	<20121023063532.GA15870@shutemov.name>
	<20121022234349.27f33f62.akpm@linux-foundation.org>
	<20121023070018.GA18381@otc-wbsnb-06>
	<20121023155915.7d5ef9d1.akpm@linux-foundation.org>
	<20121023233801.GA21591@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Wed, 24 Oct 2012 02:38:01 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Oct 23, 2012 at 03:59:15PM -0700, Andrew Morton wrote:
> > On Tue, 23 Oct 2012 10:00:18 +0300
> > "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> > 
> > > > Well, how hard is it to trigger the bad behavior?  One can easily
> > > > create a situation in which that page's refcount frequently switches
> > > > from 0 to 1 and back again.  And one can easily create a situation in
> > > > which the shrinkers are being called frequently.  Run both at the same
> > > > time and what happens?
> > > 
> > > If the goal is to trigger bad behavior then:
> > > 
> > > 1. read from an area where a huge page can be mapped to get huge zero page
> > >    mapped. hzp is allocated here. refcounter == 2.
> > > 2. write to the same page. refcounter == 1.
> > > 3. echo 3 > /proc/sys/vm/drop_caches. refcounter == 0 -> free the hzp.
> > > 4. goto 1.
> > > 
> > > But it's unrealistic. /proc/sys/vm/drop_caches is only root-accessible.
> > 
> > Yes, drop_caches is uninteresting.
> > 
> > > We can trigger shrinker only under memory pressure. But in this, most
> > > likely we will get -ENOMEM on hzp allocation and will go to fallback path
> > > (4k zero page).
> > 
> > I disagree.  If, for example, there is a large amount of clean
> > pagecache being generated then the shrinkers will be called frequently
> > and memory reclaim will be running at a 100% success rate.  The
> > hugepage allocation will be successful in such a situation?
> 
> Yes.
> 
> Shrinker callbacks are called from shrink_slab() which happens after page
> cache reclaim, so on next reclaim round page cache will reclaim first and
> we will avoid frequent alloc-free pattern.

I don't understand this.  If reclaim is running continuously (which can
happen pretty easily: "dd if=/fast-disk/large-file") then the zero page
will be whipped away very shortly after its refcount has fallen to
zero.

> One more thing we can do: increase shrinker->seeks to something like
> DEFAULT_SEEKS * 4. In this case shrink_slab() will call our callback after
> callbacks with DEFAULT_SEEKS.

It would be useful if you could try to make this scenario happen.  If
for some reason it doesn't happen then let's understand *why* it
doesn't happen.

I'm thinking that such a workload would be the above dd in parallel
with a small app which touches the huge page and then exits, then gets
executed again.  That "small app" sounds realistic to me.  Obviously
one could exercise the zero page's refcount at higher frequency with a
tight map/touch/unmap loop, but that sounds less realistic.  It's worth
trying that exercise as well though.

Or do something else.  But we should try to probe this code's
worst-case behaviour, get an understanding of its effects and then
decide whether any such workload is realisic enough to worry about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
