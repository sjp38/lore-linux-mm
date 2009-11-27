Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5AF4D6B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 00:58:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAR5wVWx008136
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 27 Nov 2009 14:58:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 893C645DE4D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:58:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61B6645DE50
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:58:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE7861DB803E
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:58:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 54D831DB8042
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 14:58:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
In-Reply-To: <20091126141738.GE13095@csn.ul.ie>
References: <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com> <20091126141738.GE13095@csn.ul.ie>
Message-Id: <20091127143307.A7E1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 27 Nov 2009 14:58:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Corrado Zoccolo <czoccolo@gmail.com>, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, Nov 26, 2009 at 02:47:10PM +0100, Corrado Zoccolo wrote:
> > On Thu, Nov 26, 2009 at 1:19 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > > (cc'ing the people from the page allocator failure thread as this mig=
ht be
> > > relevant to some of their problems)
> > >
> > > I know this is very last minute but I believe we should consider disa=
bling
> > > the "low_latency" tunable for block devices by default for 2.6.32. =
=A0There was
> > > evidence that low_latency was a problem last week for page allocation=
 failure
> > > reports but the reproduction-case was unusual and involved high-order=
 atomic
> > > allocations in low-memory conditions. It took another few days to acc=
urately
> > > show the problem for more normal workloads and it's a bit more wide-s=
pread
> > > than just allocation failures.
> > >
> > > Basically, low_latency looks great as long as you have plenty of memo=
ry
> > > but in low memory situations, it appears to cause problems that manif=
est
> > > as reduced performance, desktop stalls and in some cases, page alloca=
tion
> > > failures. I think most kernel developers are not seeing the problem a=
s they
> > > tend to test on beefier machines and without hitting swap or low-memo=
ry
> > > situations for the most part. When they are hitting low-memory situat=
ions,
> > > it tends to be for stress tests where stalls and low performance are =
expected.
> >=20
> > The low latency tunable controls various policies inside cfq.
> > The one that could affect memory reclaim is:
> >         /*
> >          * Async queues must wait a bit before being allowed dispatch.
> >          * We also ramp up the dispatch depth gradually for async IO,
> >          * based on the last sync IO we serviced
> >          */
> >         if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
> >                 unsigned long last_sync =3D jiffies - cfqd->last_end_sy=
nc_rq;
> >                 unsigned int depth;
> >=20
> >                 depth =3D last_sync / cfqd->cfq_slice[1];
> >                 if (!depth && !cfqq->dispatched)
> >                         depth =3D 1;
> >                 if (depth < max_dispatch)
> >                         max_dispatch =3D depth;
> >         }
> >=20
> > here the async queues max depth is limited to 1 for up to 200 ms after
> > a sync I/O is completed.
> > Note: dirty page writeback goes through an async queue, so it is
> > penalized by this.
> >=20
> > This can affect both low and high end hardware. My non-NCQ sata disk
> > can handle a depth of 2 when writing. NCQ sata disks can handle a
> > depth up to 31, so limiting depth to 1 can cause write performance
> > drop, and this in turn will slow down dirty page reclaim, and cause
> > allocation failures.
> >=20
> > It would be good to re-test the OOM conditions with that code commented=
 out.
> >=20
>=20
> All of it or just the cfq_latency part?
>=20
> As it turns out the test machine does report for the disk NCQ (depth 31/3=
2)
> and it's the same on the laptop so slowing down dirty page cleaning
> could be impacting reclaim.
>=20
> > >
> > > To show the problem, I used an x86-64 machine booting booted with 512=
MB of
> > > memory. This is a small amount of RAM but the bug reports related to =
page
> > > allocation failures were on smallish machines and the disks in the sy=
stem
> > > are not very high-performance.
> > >
> > > I used three tests. The first was sysbench on postgres running an IO-=
heavy
> > > test against a large database with 10,000,000 rows. The second was IO=
Zone
> > > running most of the automatic tests with a record length of 4KB and t=
he
> > > last was a simulated launching of gitk with a music player running in=
 the
> > > background to act as a desktop-like scenario. The final test was simi=
lar
> > > to the test described here http://lwn.net/Articles/362184/ except tha=
t
> > > dm-crypt was not used as it has its own problems.
> >=20
> > low_latency was tested on other scenarios:
> > http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/01410.html
> > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-11/msg04855.html
> > where it improved actual and perceived performance, so disabling it
> > completely may not be good.
> >=20
>=20
> It may not indeed.
>=20
> In case you mean a partial disabling of cfq_latency, I'm try the
> following patch. The intention is to disable the low_latency logic if
> kswapd is at work and presumably needs clean pages. Alternative
> suggestions welcome.

I like treat vmscan writeout as special. because
  - vmscan use various process context. but it doesn't write own process's =
page.
    IOW, it doesn't so match cfq's io fairness logic.
  - plus, the above mean vmscan writeout doesn't need good i/o latency.
  - vmscan maintain page granularity lru list. It mean vmscan makes awful
    seekful I/O. it assume block-layer buffered much i/o request.
  - plus, the above mena vmscan. writeout need good io throughput. otherwis=
e
    system might cause hangup.

However, I don't think kswapd_awake is good choice. because
  - zone reclaim run before kswapd wakeup. iow, this patch doesn't solve hp=
c machine.
    btw, some Core i7 box (at least, Intel's reference box) also use zone r=
eclaim.
  - On large (many memory node) machine, one of much kswapd always run.


Instead, PF_MEMALLOC is good idea?


Subject: [PATCH] cfq: Do not limit the async queue depth while memory recla=
im

Not-Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> (I have=
n't test this)
---
 block/cfq-iosched.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index aa1e953..9546f64 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1308,7 +1308,8 @@ static bool cfq_may_dispatch(struct cfq_data *cfqd, s=
truct cfq_queue *cfqq)
 	 * We also ramp up the dispatch depth gradually for async IO,
 	 * based on the last sync IO we serviced
 	 */
-	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
+	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency &&
+	    !(current->flags & PF_MEMALLOC)) {
 		unsigned long last_sync =3D jiffies - cfqd->last_end_sync_rq;
 		unsigned int depth;
=20
--=20
1.6.5.2






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
