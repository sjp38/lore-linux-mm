Date: Thu, 31 Jul 2008 14:16:10 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: memory hotplug: hot-remove fails on lowest chunk in ZONE_MOVABLE
In-Reply-To: <1217420161.4545.10.camel@localhost.localdomain>
References: <20080730110444.27DE.E1E9C6FF@jp.fujitsu.com> <1217420161.4545.10.camel@localhost.localdomain>
Message-Id: <20080731134956.2A3B.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2008-07-30 at 12:16 +0900, Yasunori Goto wrote:
> > Well, I didn't mean changing pages_min value. There may be side effect as
> > you are saying.
> > I meant if some pages were MIGRATE_RESERVE attribute when hot-remove are
> > -executing-, their attribute should be changed.
> > 
> > For example, how is like following dummy code?  Is it impossible?
> > (Not only here, some places will have to be modified..)
> 
> Right, this should be possible. I was somewhat wandering from the subject,
> because I noticed that there may be a bigger problem with MIGRATE_RESERVE
> pages in ZONE_MOVABLE, and that we may not want to have them in the first
> place.
> 
> The more memory we add to ZONE_MOVABLE, the less reserved pages will
> remain to the other zones. In setup_per_zone_pages_min(), min_free_kbytes
> will be redistributed to a zone where the kernel cannot make any use of
> it, effectively reducing the available min_free_kbytes. This just doesn't
> sound right. I believe that a similar situation is the reason why highmem
> pages are skipped in the calculation and I think that we need that for
> ZONE_MOVABLE too. Any thoughts on that problem?
> 
> Setting pages_min to 0 for ZONE_MOVABLE, while not capping pages_low
> and pages_high, could be an option. I don't have a sufficient memory
> managment overview to tell if that has negative side effects, maybe
> someone with a deeper insight could comment on that.

At least, pages_min should not be 0. It is used as watermark when
memory shortage situation. If it is 0, kernel will misunderstand
shortage situation. Certainly, pages_min value may be not appropriate value
for ZONE_MOVABLE. But it is not memory-hotplug issue.

True your question is why ZONE_MOVABLE has MIGRATE_RESREVE pages, right?
However, I think it is intended for emergency pool of memory shortage situation
for ZONE_MOVABLE via fallback[]. If not, these MIGRATE_RESERVE pages are not made
originally.
It is why I wrote previous mail.

Mel Gormal-san knows around here very well. He may explain its detail more.

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
