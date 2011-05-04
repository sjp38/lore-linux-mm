Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5DBE16B0023
	for <linux-mm@kvack.org>; Wed,  4 May 2011 00:23:50 -0400 (EDT)
Date: Wed, 4 May 2011 12:23:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110504042345.GA12336@localhost>
References: <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <BANLkTimpT-N5--3QjcNg8CyNNwfEWxFyKA@mail.gmail.com>
 <BANLkTi=q6oKMewfWAN+2UgEmaVt03W_gLQ@mail.gmail.com>
 <20110504025609.GA8532@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110504025609.GA8532@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On Wed, May 04, 2011 at 10:56:09AM +0800, Wu Fengguang wrote:
> On Wed, May 04, 2011 at 10:32:01AM +0800, Dave Young wrote:
> > On Wed, May 4, 2011 at 9:56 AM, Dave Young <hidave.darkstar@gmail.com> wrote:
> > > On Thu, Apr 28, 2011 at 9:36 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > >> Concurrent page allocations are suffering from high failure rates.
> > >>
> > >> On a 8p, 3GB ram test box, when reading 1000 sparse files of size 1GB,
> > >> the page allocation failures are
> > >>
> > >> nr_alloc_fail 733 A  A  A  # interleaved reads by 1 single task
> > >> nr_alloc_fail 11799 A  A  # concurrent reads by 1000 tasks
> > >>
> > >> The concurrent read test script is:
> > >>
> > >> A  A  A  A for i in `seq 1000`
> > >> A  A  A  A do
> > >> A  A  A  A  A  A  A  A truncate -s 1G /fs/sparse-$i
> > >> A  A  A  A  A  A  A  A dd if=/fs/sparse-$i of=/dev/null &
> > >> A  A  A  A done
> > >>
> > >
> > > With Core2 Duo, 3G ram, No swap partition I can not produce the alloc fail
> > 
> > unset CONFIG_SCHED_AUTOGROUP and CONFIG_CGROUP_SCHED seems affects the
> > test results, now I see several nr_alloc_fail (dd is not finished
> > yet):
> > 
> > dave@darkstar-32:$ grep fail /proc/vmstat:
> > nr_alloc_fail 4
> > compact_pagemigrate_failed 0
> > compact_fail 3
> > htlb_buddy_alloc_fail 0
> > thp_collapse_alloc_fail 4
> > 
> > So the result is related to cpu scheduler.
> 
> Good catch! My kernel also disabled CONFIG_CGROUP_SCHED and
> CONFIG_SCHED_AUTOGROUP.

I tried enable the two options and find that "ps ax" runs much faster
when the 1000 dd's are running. And test results in base kernel are:

start time: 287
total time: 499
nr_alloc_fail 5075
allocstall 20658
LOC:     502393     501303     500813     503814     501972     501775     501949     501143   Local timer interrupts
RES:       5716       8584       7603       2699       7972      15383       8921       4345   Rescheduling interrupts
CAL:       1543       1731       1733       1809       1692       1715       1765       1753   Function call interrupts
TLB:        132         27         31         21         70        175         68         46   TLB shootdowns

CPU             count     real total  virtual total    delay total  delay average
                  916     2803573792     2785739581   200248952651        218.612ms
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                   15      234623427             15ms
dd: read=0, write=0, cancelled_write=0

Comparing to the cgroup-sched disabled results (cited below), the
allocstall is reduced to 1.3% and CALs are mostly eliminated.
nr_alloc_fail is cut down by almost 2/3. RECLAIM delay is reduced
from 29ms to 15ms. Virtually everything improved considerably!

Thanks,
Fengguang
---

start time: 245
total time: 526
nr_alloc_fail 14586
allocstall 1578343
LOC:     533981     529210     528283     532346     533392     531314     531705     528983   Local timer interrupts
RES:       3123       2177       1676       1580       2157       1974       1606       1696   Rescheduling interrupts
CAL:     218392     218631     219167     219217     218840     218985     218429     218440   Function call interrupts
TLB:        175         13         21         18         62        309        119         42   TLB shootdowns


CPU             count     real total  virtual total    delay total
                 1122     3676441096     3656793547   274182127286
IO              count    delay total  delay average
                    3      291765493             97ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1350    39229752193             29ms
dd: read=45056, write=0, cancelled_write=0

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
