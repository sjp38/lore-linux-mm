Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B84366B01F2
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 09:19:43 -0400 (EDT)
Date: Mon, 30 Aug 2010 15:19:29 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] writeback: Record if the congestion was unnecessary
Message-ID: <20100830131929.GA28652@cmpxchg.org>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
 <1282835656-5638-3-git-send-email-mel@csn.ul.ie>
 <20100826182904.GC6805@cmpxchg.org>
 <20100826203130.GL20944@csn.ul.ie>
 <20100827081648.GD6805@cmpxchg.org>
 <20100827092415.GB19556@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LQksG6bCIzRHxTLp"
Content-Disposition: inline
In-Reply-To: <20100827092415.GB19556@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 27, 2010 at 10:24:16AM +0100, Mel Gorman wrote:
> On Fri, Aug 27, 2010 at 10:16:48AM +0200, Johannes Weiner wrote:
> > On Thu, Aug 26, 2010 at 09:31:30PM +0100, Mel Gorman wrote:
> > > On Thu, Aug 26, 2010 at 08:29:04PM +0200, Johannes Weiner wrote:
> > > > On Thu, Aug 26, 2010 at 04:14:15PM +0100, Mel Gorman wrote:
> > > > > If congestion_wait() is called when there is no congestion, the caller
> > > > > will wait for the full timeout. This can cause unreasonable and
> > > > > unnecessary stalls. There are a number of potential modifications that
> > > > > could be made to wake sleepers but this patch measures how serious the
> > > > > problem is. It keeps count of how many congested BDIs there are. If
> > > > > congestion_wait() is called with no BDIs congested, the tracepoint will
> > > > > record that the wait was unnecessary.
> > > > 
> > > > I am not convinced that unnecessary is the right word.  On a workload
> > > > without any IO (i.e. no congestion_wait() necessary, ever), I noticed
> > > > the VM regressing both in time and in reclaiming the right pages when
> > > > simply removing congestion_wait() from the direct reclaim paths (the
> > > > one in __alloc_pages_slowpath and the other one in
> > > > do_try_to_free_pages).
> > > > 
> > > > So just being stupid and waiting for the timeout in direct reclaim
> > > > while kswapd can make progress seemed to do a better job for that
> > > > load.
> > > > 
> > > > I can not exactly pinpoint the reason for that behaviour, it would be
> > > > nice if somebody had an idea.
> > > > 
> > > 
> > > There is a possibility that the behaviour in that case was due to flusher
> > > threads doing the writes rather than direct reclaim queueing pages for IO
> > > in an inefficient manner. So the stall is stupid but happens to work out
> > > well because flusher threads get the chance to do work.
> > 
> > The workload was accessing a large sparse-file through mmap, so there
> > wasn't much IO in the first place.
> > 
> 
> Then waiting on congestion was the totally wrong thing to do. We were
> effectively calling sleep(HZ/10) and magically this was helping in some
> undefined manner. Do you know *which* called of congestion_wait() was
> the most important to you?

Removing congestion_wait() in do_try_to_free_pages() definitely
worsens reclaim behaviour for this workload:

1. wallclock time of the testrun increases by 11%

2. the scanners do a worse job and go for the wrong zone:

-pgalloc_dma 79597
-pgalloc_dma32 134465902
+pgalloc_dma 297089
+pgalloc_dma32 134247237

-pgsteal_dma 77501
-pgsteal_dma32 133939446
+pgsteal_dma 294998
+pgsteal_dma32 133722312

-pgscan_kswapd_dma 145897
-pgscan_kswapd_dma32 266141381
+pgscan_kswapd_dma 287981
+pgscan_kswapd_dma32 186647637

-pgscan_direct_dma 9666
-pgscan_direct_dma32 1758655
+pgscan_direct_dma 302495
+pgscan_direct_dma32 80947179

-pageoutrun 1768531
-allocstall 614
+pageoutrun 1927451
+allocstall 8566

I attached the full vmstat contents below.  Also the test program,
which I ran in this case as: ./mapped-file-stream 1 $((512 << 30))

> > > > So personally I think it's a good idea to get an insight on the use of
> > > > congestion_wait() [patch 1] but I don't agree with changing its
> > > > behaviour just yet, or judging its usefulness solely on whether it
> > > > correctly waits for bdi congestion.
> > > > 
> > > 
> > > Unfortunately, I strongly suspect that some of the desktop stalls seen during
> > > IO (one of which involved no writes) were due to calling congestion_wait
> > > and waiting the full timeout where no writes are going on.
> > 
> > Oh, I am in full agreement here!  Removing those congestion_wait() as
> > described above showed a reduction in peak latency.  The dilemma is
> > only that it increased the overall walltime of the load.
> > 
> 
> Do you know why because leaving in random sleeps() hardly seems to be
> the right approach?

I am still trying to find out what's going wrong.

> > And the scanning behaviour deteriorated, as in having increased
> > scanning pressure on other zones than the unpatched kernel did.
> > 
> 
> Probably because it was scanning more but not finding what it needed.
> There is a condition other than congestion it is having trouble with. In
> some respects, I think if we change congestion_wait() as I propose,
> we may see a case where CPU usage is higher because it's now
> encountering the unspecified reclaim problem we have.

Exactly.

> > So I think very much that we need a fix.  congestion_wait() causes
> > stalls and relying on random sleeps for the current reclaim behaviour
> > can not be the solution, at all.
> > 
> > I just don't think we can remove it based on the argument that it
> > doesn't do what it is supposed to do, when it does other things right
> > that it is not supposed to do ;-)
> > 
> 
> We are not removing it, we are just stopping it going to sleep for
> stupid reasons. If we find that wall time is increasing as a result, we
> have a path to figuring out what the real underlying problem is instead
> of sweeping it under the rug.

Well, for that testcase it is in effect the same as a removal as
there's never congestion.

But again: I agree with your changes per-se, I just don't think they
should get merged as long as they knowingly catalyze a problem that
has yet to be identified.

--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mapped-file-stream.c"

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <limits.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>

static int start_process(unsigned long nr_bytes)
{
	char filename[] = "/tmp/clog-XXXXXX";
	unsigned long i;
	char *map;
	int fd;

	fd = mkstemp(filename);
	unlink(filename);
	if (fd == -1) {
		perror("mkstemp()");
		return -1;
	}

	if (ftruncate(fd, nr_bytes)) {
		perror("ftruncate()");
		return -1;
	}

	map = mmap(NULL, nr_bytes, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (map == MAP_FAILED) {
		perror("mmap()");
		return -1;
	}

	if (madvise(map, nr_bytes, MADV_RANDOM)) {
		perror("madvise()");
		return -1;
	}

	kill(getpid(), SIGSTOP);

	for (i = 0; i < nr_bytes; i += 4096)
		((volatile char *)map)[i];

	close(fd);
	return 0;
}

static int do_test(unsigned long nr_procs, unsigned long nr_bytes)
{
	pid_t procs[nr_procs];
	unsigned long i;
	int dummy;

	for (i = 0; i < nr_procs; i++) {
		switch ((procs[i] = fork())) {
		case -1:
			kill(0, SIGKILL);
			perror("fork()");
			return -1;
		case 0:
			return start_process(nr_bytes);
		default:
			waitpid(procs[i], &dummy, WUNTRACED);
			break;
		}
	}

	kill(0, SIGCONT);

	for (i = 0; i < nr_procs; i++)
		waitpid(procs[i], &dummy, 0);

	return 0;
}

static int xstrtoul(const char *str, unsigned long *valuep)
{
	unsigned long value;
	char *endp;

	value = strtoul(str, &endp, 0);
	if (*endp || (value == ULONG_MAX && errno == ERANGE))
		return -1;
	*valuep = value;
	return 0;
}

int main(int ac, char **av)
{
	unsigned long nr_procs, nr_bytes;

	if (ac != 3)
		goto usage;
	if (xstrtoul(av[1], &nr_procs))
		goto usage;
	if (xstrtoul(av[2], &nr_bytes))
		goto usage;
	setbuf(stdout, NULL);
	setbuf(stderr, NULL);
	return !!do_test(nr_procs, nr_bytes);
usage:
	fprintf(stderr, "usage: %s nr_procs nr_bytes\n", av[0]);
	return 1;
}

--LQksG6bCIzRHxTLp
Content-Type: application/x-troff-man
Content-Disposition: attachment; filename="vmstat.a.2"
Content-Transfer-Encoding: quoted-printable

nr_free_pages 474460=0Anr_inactive_anon 440=0Anr_active_anon 490=0Anr_inact=
ive_file 472=0Anr_active_file 1179=0Anr_unevictable 0=0Anr_mlock 0=0Anr_ano=
n_pages 903=0Anr_mapped 743=0Anr_file_pages 1680=0Anr_dirty 0=0Anr_writebac=
k 0=0Anr_slab_reclaimable 474=0Anr_slab_unreclaimable 1320=0Anr_page_table_=
pages 214=0Anr_kernel_stack 54=0Anr_unstable 0=0Anr_bounce 0=0Anr_vmscan_wr=
ite 0=0Anr_writeback_temp 0=0Anr_isolated_anon 0=0Anr_isolated_file 0=0Anr_=
shmem 27=0Anuma_hit 134544040=0Anuma_miss 0=0Anuma_foreign 0=0Anuma_interle=
ave 2402=0Anuma_local 134544040=0Anuma_other 0=0Apgpgin 34264=0Apgpgout 616=
=0Apswpin 0=0Apswpout 0=0Apgalloc_dma 79597=0Apgalloc_dma32 134465902=0Apga=
lloc_normal 0=0Apgalloc_movable 0=0Apgfree 135020217=0Apgactivate 2002=0Apg=
deactivate 416=0Apgfault 134346107=0Apgmajfault 134218014=0Apgrefill_dma 0=
=0Apgrefill_dma32 416=0Apgrefill_normal 0=0Apgrefill_movable 0=0Apgsteal_dm=
a 77501=0Apgsteal_dma32 133939446=0Apgsteal_normal 0=0Apgsteal_movable 0=0A=
pgscan_kswapd_dma 145897=0Apgscan_kswapd_dma32 266141381=0Apgscan_kswapd_no=
rmal 0=0Apgscan_kswapd_movable 0=0Apgscan_direct_dma 9666=0Apgscan_direct_d=
ma32 1758655=0Apgscan_direct_normal 0=0Apgscan_direct_movable 0=0Azone_recl=
aim_failed 0=0Apginodesteal 0=0Aslabs_scanned 2304=0Akswapd_steal 133994020=
=0Akswapd_inodesteal 711=0Akswapd_low_wmark_hit_quickly 201624=0Akswapd_hig=
h_wmark_hit_quickly 4=0Akswapd_skip_congestion_wait 8050=0Apageoutrun 17685=
31=0Aallocstall 614=0Apgrotated 0=0Acompact_blocks_moved 0=0Acompact_pages_=
moved 0=0Acompact_pagemigrate_failed 0=0Acompact_stall 0=0Acompact_fail 0=
=0Acompact_success 0=0Ahtlb_buddy_alloc_success 0=0Ahtlb_buddy_alloc_fail 0=
=0Aunevictable_pgs_culled 0=0Aunevictable_pgs_scanned 0=0Aunevictable_pgs_r=
escued 0=0Aunevictable_pgs_mlocked 0=0Aunevictable_pgs_munlocked 0=0Aunevic=
table_pgs_cleared 0=0Aunevictable_pgs_stranded 0=0Aunevictable_pgs_mlockfre=
ed 0=0A
--LQksG6bCIzRHxTLp
Content-Type: application/x-troff-man
Content-Disposition: attachment; filename="vmstat.b.2"
Content-Transfer-Encoding: quoted-printable

nr_free_pages 474483=0Anr_inactive_anon 440=0Anr_active_anon 502=0Anr_inact=
ive_file 427=0Anr_active_file 1178=0Anr_unevictable 0=0Anr_mlock 0=0Anr_ano=
n_pages 915=0Anr_mapped 743=0Anr_file_pages 1648=0Anr_dirty 0=0Anr_writebac=
k 0=0Anr_slab_reclaimable 474=0Anr_slab_unreclaimable 1342=0Anr_page_table_=
pages 213=0Anr_kernel_stack 54=0Anr_unstable 0=0Anr_bounce 0=0Anr_vmscan_wr=
ite 0=0Anr_writeback_temp 0=0Anr_isolated_anon 0=0Anr_isolated_file 0=0Anr_=
shmem 27=0Anuma_hit 134542888=0Anuma_miss 0=0Anuma_foreign 0=0Anuma_interle=
ave 2402=0Anuma_local 134542888=0Anuma_other 0=0Apgpgin 34148=0Apgpgout 592=
=0Apswpin 0=0Apswpout 0=0Apgalloc_dma 297089=0Apgalloc_dma32 134247237=0Apg=
alloc_normal 0=0Apgalloc_movable 0=0Apgfree 135019047=0Apgactivate 1997=0Ap=
gdeactivate 416=0Apgfault 134344164=0Apgmajfault 134218018=0Apgrefill_dma 0=
=0Apgrefill_dma32 416=0Apgrefill_normal 0=0Apgrefill_movable 0=0Apgsteal_dm=
a 294998=0Apgsteal_dma32 133722312=0Apgsteal_normal 0=0Apgsteal_movable 0=
=0Apgscan_kswapd_dma 287981=0Apgscan_kswapd_dma32 186647637=0Apgscan_kswapd=
_normal 0=0Apgscan_kswapd_movable 0=0Apgscan_direct_dma 302495=0Apgscan_dir=
ect_dma32 80947179=0Apgscan_direct_normal 0=0Apgscan_direct_movable 0=0Azon=
e_reclaim_failed 0=0Apginodesteal 426=0Aslabs_scanned 2304=0Akswapd_steal 1=
33647322=0Akswapd_inodesteal 284=0Akswapd_low_wmark_hit_quickly 213970=0Aks=
wapd_high_wmark_hit_quickly 1=0Akswapd_skip_congestion_wait 12633=0Apageout=
run 1927451=0Aallocstall 8566=0Apgrotated 0=0Acompact_blocks_moved 0=0Acomp=
act_pages_moved 0=0Acompact_pagemigrate_failed 0=0Acompact_stall 0=0Acompac=
t_fail 0=0Acompact_success 0=0Ahtlb_buddy_alloc_success 0=0Ahtlb_buddy_allo=
c_fail 0=0Aunevictable_pgs_culled 0=0Aunevictable_pgs_scanned 0=0Aunevictab=
le_pgs_rescued 0=0Aunevictable_pgs_mlocked 0=0Aunevictable_pgs_munlocked 0=
=0Aunevictable_pgs_cleared 0=0Aunevictable_pgs_stranded 0=0Aunevictable_pgs=
_mlockfreed 0=0A
--LQksG6bCIzRHxTLp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
