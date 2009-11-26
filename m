Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B66A6B00A1
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 08:47:13 -0500 (EST)
Received: by gxk24 with SMTP id 24so675441gxk.6
        for <linux-mm@kvack.org>; Thu, 26 Nov 2009 05:47:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091126121945.GB13095@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie>
Date: Thu, 26 Nov 2009 14:47:10 +0100
Message-ID: <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 26, 2009 at 1:19 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> (cc'ing the people from the page allocator failure thread as this might b=
e
> relevant to some of their problems)
>
> I know this is very last minute but I believe we should consider disablin=
g
> the "low_latency" tunable for block devices by default for 2.6.32. =C2=A0=
There was
> evidence that low_latency was a problem last week for page allocation fai=
lure
> reports but the reproduction-case was unusual and involved high-order ato=
mic
> allocations in low-memory conditions. It took another few days to accurat=
ely
> show the problem for more normal workloads and it's a bit more wide-sprea=
d
> than just allocation failures.
>
> Basically, low_latency looks great as long as you have plenty of memory
> but in low memory situations, it appears to cause problems that manifest
> as reduced performance, desktop stalls and in some cases, page allocation
> failures. I think most kernel developers are not seeing the problem as th=
ey
> tend to test on beefier machines and without hitting swap or low-memory
> situations for the most part. When they are hitting low-memory situations=
,
> it tends to be for stress tests where stalls and low performance are expe=
cted.

The low latency tunable controls various policies inside cfq.
The one that could affect memory reclaim is:
        /*
         * Async queues must wait a bit before being allowed dispatch.
         * We also ramp up the dispatch depth gradually for async IO,
         * based on the last sync IO we serviced
         */
        if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
                unsigned long last_sync =3D jiffies - cfqd->last_end_sync_r=
q;
                unsigned int depth;

                depth =3D last_sync / cfqd->cfq_slice[1];
                if (!depth && !cfqq->dispatched)
                        depth =3D 1;
                if (depth < max_dispatch)
                        max_dispatch =3D depth;
        }

here the async queues max depth is limited to 1 for up to 200 ms after
a sync I/O is completed.
Note: dirty page writeback goes through an async queue, so it is
penalized by this.

This can affect both low and high end hardware. My non-NCQ sata disk
can handle a depth of 2 when writing. NCQ sata disks can handle a
depth up to 31, so limiting depth to 1 can cause write performance
drop, and this in turn will slow down dirty page reclaim, and cause
allocation failures.

It would be good to re-test the OOM conditions with that code commented out=
.

>
> To show the problem, I used an x86-64 machine booting booted with 512MB o=
f
> memory. This is a small amount of RAM but the bug reports related to page
> allocation failures were on smallish machines and the disks in the system
> are not very high-performance.
>
> I used three tests. The first was sysbench on postgres running an IO-heav=
y
> test against a large database with 10,000,000 rows. The second was IOZone
> running most of the automatic tests with a record length of 4KB and the
> last was a simulated launching of gitk with a music player running in the
> background to act as a desktop-like scenario. The final test was similar
> to the test described here http://lwn.net/Articles/362184/ except that
> dm-crypt was not used as it has its own problems.

low_latency was tested on other scenarios:
http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/01410.html
http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-11/msg04855.html
where it improved actual and perceived performance, so disabling it
completely may not be good.

Thanks,
Corrado

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
