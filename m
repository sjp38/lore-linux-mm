From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 1/1] cpusets/sched_domain reconciliation
Date: Thu, 13 Sep 2007 17:39:22 +1000
References: <20070907210704.E6BE02FC059@attica.americas.sgi.com> <20070913154607.9c49e1c7.akpm@linux-foundation.org>
In-Reply-To: <20070913154607.9c49e1c7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709131739.22588.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cliff Wickman <cpw@sgi.com>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Friday 14 September 2007 08:46, Andrew Morton wrote:
> On Fri, 07 Sep 2007 16:07:04 -0500
>
> cpw@sgi.com (Cliff Wickman) wrote:
> > Re-send of patch sent 8/23/2007, but refreshed for 2.6.23-rc5.
> >
> > This patch reconciles cpusets and sched_domains that get out of sync
> > due to disabling and re-enabling cpu's.
> >
> > This is still a problem in the 2.6.23-rc5 kernel.
> >
> > Here is an example of how the problem can occur:
> >
> >    system of cpu's   0 1 2 3 4 5
> >    create cpuset /x      2 3 4 5
> >    create cpuset /x/y    2 3
> >    all cpusets are cpu_exclusive
> >
> >    disable cpu 3
> >      x is now            2   4 5
> >      x/y is now          2
> >    enable cpu 3
> >      cpusets x and x/y are unchanged
> >
> >    to restore the cpusets:
> >      echo 2-5 > /dev/cpuset/x
> >      echo 2-3 > /dev/cpuset/x/y
> >
> >    At the first echo, which restores 3 to cpuset x, update_cpu_domains()
> > is called for cpuset x/.
> >    system of cpu's   0 1 2 3 4 5
> >    x is now              2 3 4 5
> >    x/y is now            2
> >
> >    The system is partitioned between:
> > 	its parent, the root cpuset, minus its child (x/ is 2-5): 0-1
> >         and x/ (2-5) , minus its child (x/y/ 2): 3-5
> >
> >    The sched_domain's for parent 0-1 are updated.
> >    The sched_domain's for current 3-5 are updated.
> >
> >    But 2 has been untouched.
> >    As a result, 3's SD points to sched_group_phys[3] which is the only
> >    sched_group_phys on 3's list.  It points to itself.
> >    But 2's SD points to sched_group_phys[2], which still points to
> >    sched_group_phys[3].
> >    When cpu 2 executes find_busiest_group() it will hang on the non-
> >    circular sched_group list.
> >
> > cpuset.c:
> >
> > This solution is to update the sched_domain's for the cpuset
> > whose cpu's were changed and, in addition, all its children.
> > Instead of calling update_cpu_domains(), call update_cpu_domains_tree(),
> > which calls update_cpu_domains() for every node from the one specified
> > down to all its children.
> >
> > The extra sched_domain reconstruction is overhead, but only at the
> > frequency of administrative change to the cpusets.
> >
> > There seems to be no administrative procedural work-around.  In the
> > example above one could not reverse the two echo's and set x/y before
> > x/.  It is not logical, so not allowed (Permission denied).
> >
> > Thus the patch to cpuset.c makes the sched_domain's correct.
> >
> > sched.c:
> >
> > The patch to sched.c prevents the cpu hangs that otherwise occur
> > until the sched_domain's are made correct.
> >
> > It puts checks into find_busiest_group() and find_idlest_group()
> > that break from their loops on a sched_group that points to itself.
> > This is needed because cpu's are going through load balancing before all
> > sched_domains have been reconstructed (see the example above).
> >
> > This is admittedly a kludge. I leave it to the scheduler gurus to
> > recommend a better way update the sched_domains or to keep cpus out of
> > the sched_domains while they are being reconstructed.
>
> You should cc scheduler gurus when hoping things about them ;)
>
> I suspect your change is fundamentally incompatible with, and perhaps
> obsoleted by
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.
>6.23-rc4-mm1/broken-out/cpuset-remove-sched-domain-hooks-from-cpusets.patch
>
> Problem is, cpuset-remove-sched-domain-hooks-from-cpusets.patch has been
> hanging around in -mm for a year while Paul makes up his mind about it.
>
> Can we please get all this sorted out??

cpus_exclusive is supposed to partition the system (like a dynamically
configurable isolcpus=). However the exact semantics of it IIRC are
defined such that it is pretty well unusable.

IIRC I have a patch that converts it to sane semantics and does
opportunistic sched domains partitioning and of course fixes the hotplug
issue as well... but Paul didn't like it for some reason.

Anyway, until there is some very clear semantic for what cpus_exclusive
does, then it is silly to retain the broken sched-domains code. I don't know
why that patch isn't merged, but it should be... (I thought it was when this
last came up ages ago).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
