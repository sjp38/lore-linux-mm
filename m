From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: PERF: performance tests with the split LRU VM in -mm
References: <20080724222510.3bbbbedc@bree.surriel.com>
Date: Tue, 29 Jul 2008 15:51:16 +0200
In-Reply-To: <20080724222510.3bbbbedc@bree.surriel.com> (Rik van Riel's
	message of "Thu, 24 Jul 2008 22:25:10 -0400")
Message-ID: <87tze84x4b.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi,

Rik van Riel <riel@redhat.com> writes:

> In order to get the performance of the split LRU VM (in -mm) better,
> I have performed several performance tests with the following kernels:
> - 2.6.26                                                    "2.6.26"
> - 2.6.26-rc8-mm1                                            "-mm"
> - 2.6.26-rc8-mm1 w/ "evict streaming IO cache first" patch  "stream"
>       Patch at: http://lkml.org/lkml/2008/7/15/465
> - 2.6.26-rc8-mm1 w/ "fix swapout on sequential IO" patch    "noforce"
>       Patch at: http://marc.info/?l=linux-mm&m=121683855132630&w=2
>
> I have run the performance tests on a Dell pe1950 system
> with 2 quad-core CPUs, 16GB of RAM and a hardware RAID 1
> array of 146GB disks.
>
> The tests are fairly simple, but took a fair amount of time to
> run due to the size of the data set involved (full disk for dd,
> 55GB innodb file for the database tests).
>
>
>   TEST 1: dd if=/dev/sda of=/dev/null bs=1M
>
> kernel  speed    swap used
>
> 2.6.26  111MB/s  500kB
> -mm     110MB/s  59MB     (ouch, system noticably slower)
> noforce	111MB/s  128kB
> stream  108MB/s  0        (slight regression, not sure why yet)
>
> This patch shows that the split LRU VM in -mm has a problem
> with large streaming IOs: the working set gets pushed out of
> memory, which makes doing anything else during the big streaming
> IO kind of painful.
>
> However, either of the two patches posted fixes that problem,
> though at a slight performance penalty for the "stream" patch.

Btw, my desktop machine runs -mm (+ the patch I have posted later in
this thread) for over a week now and I have not yet encountered any
notable regressions in normal usage patterns.

I have not collected hard numbers but just tried to work normally with
it.

I also employed a massive memory eater (besides emacs and firefox) that
spawns children that eat, serialized, ~120% of RAM each.

Continuing normal work on both kernels was a bit harder, sure, but not
impossible.

The box never died on me nor did it thrash perceivably harder/longer
near oom than .26.  The oom killer was never invoked.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
