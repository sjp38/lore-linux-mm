Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E30F7900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 19:50:47 -0400 (EDT)
Received: by qyk7 with SMTP id 7so1161997qyk.14
        for <linux-mm@kvack.org>; Wed, 10 Aug 2011 16:50:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110804143844.GQ19099@suse.de>
References: <20110804143844.GQ19099@suse.de>
Date: Thu, 11 Aug 2011 08:50:43 +0900
Message-ID: <CAEwNFnDJzXZoqsSo3p5XVZk3ux+6TfjRzWJYxgMuiUVTJYiRYQ@mail.gmail.com>
Subject: Re: MMTests 0.01
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mel,

At last, you release the great test scripts.
Awesome! I really welcome this!

We have needed standard test suite to discuss and test more easily.
And it can help to find regression through periodic test.

Of course, it would be good if LTP or autotest merge this tests.
But I think it's not bad that we maintains it with separate test for
heading goal of mm-specific standard test suite. :) For it, at least,
we need public git tree.

Anyway, Thanks for sharing your valuable knowhow, Mel.

On Thu, Aug 4, 2011 at 11:38 PM, Mel Gorman <mgorman@suse.de> wrote:
> At LSF/MM at some point a request was made that a series of tests be
> identified that were of interest to MM developers and that could be
> used for testing the Linux memory management subsystem. At the time,
> I was occasionally posting tarballs of whatever scripts I happened to
> be using at the time but they were not generally usable and tended to
> be specific to a set of patches. I promised I would produce something
> usable by others but never got around to it. Over the last four months,
> I needed a better framework when testing against both distribution
> kernels and mainline so without further ado
>
> http://www.csn.ul.ie/~mel/projects/mmtests/
> http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.01-mmtests-0.01.tar.=
gz
>
> I am not claiming that this is comprehensive in any way but it is
> almost always what I start with when testing patch sets. In preparation
> for identifying problems with backports, I also ran a series of tests
> against mainline kernels over the course of two months when machines
> were otherwise idle. I have not actually had a chance to go through
> all the results and identify each problem but I needed to have the
> raw data available for my own reference so might as well share.
>
> http://www.csn.ul.ie/~mel/projects/mmtests/results/SLES11sp1/
> http://www.csn.ul.ie/~mel/projects/mmtests/results/openSUSE11.4/
>
> The directories refer to the distribution used but not the
> kernel which is downloaded from kernel.org. Directory structure is
> distro/config/machine/comparison.html. For example a set of benchmarks
> used for evaluating the page and slab allocators on a test machine
> called "hydra" is located at
>
> http://www.csn.ul.ie/~mel/projects/mmtests/results/SLES11sp1/global-dhp__=
pagealloc-performance/hydra/comparison.html
>
> I know the report structure looks crude but I was not interested
> in making them pretty. Due to the fact that some of the scripts
> are extremely old, the quality and coding styles vary considerably.
> This may get cleaned up over time but in the meantime, try and keep
> the contents of your stomach down if you are reading the scripts.
>
> The documentation is not great and so some of the capabilities such
> as being able to reconfigure swap for a benchmark is not mentioned.
> For my own series, I'll relase the mmtests tarball I used if asked.
> If someone wants to use the tarball for their own testing but cannot
> configure it, complain on the linux-mm list and if I can, I'll offer
> suggestions.
>
> =3D=3D=3D=3D MMTests README =3D=3D=3D=3D
>
> MMTests is a configurable test suite that runs a number of common
> workloads of interest to MM developers. Ideally this would have been
> to integrated with LTP, xfstests or Phoronix Test or implemented
> with autotest. =C2=A0Unfortunately, large portions of these tests are
> cobbled together over a number of years with varying degrees of
> quality before decent test frameworks were common. =C2=A0The refactoring
> effort to integrate with another framework is significant.
>
> Organisation
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> The top-level directory has a single driver script called
> run-mmtests.sh which reads a config file that describes how the
> benchmarks should be run, configures the system and runs the requested
> tests. config also has some per-test configuration items that can be
> set depending on the test. The driver script takes the name of the
> test as a parameter. Generally, this would be a symbolic name naming
> the kernel being tested.
>
> Each test is driven by a run-single-test.sh script which reads
> the relevant driver-TESTNAME.sh script. High level items such as
> profiling are configured from the top-level script while the driver
> scripts typically convert the config parameters into switches for a
> "shellpack". A shellpack is a pair of benchmark and install scripts
> that are all stored in shellpacks/ .
>
> Monitors can be optionally configured. A full list is in monitors/
> . Care should be taken with monitors as there is a possibility that
> they introduce overhead of their own. =C2=A0Hence, for some performance
> sensitive tests it is preferable to have no monitoring.
>
> Many of the tests download external benchmarks. An attempt will be
> made to download from a mirror . To get an idea where the mirror
> should be located, grep for MIRROR_LOCATION=3D in shellpacks/.
>
> A basic invocation of the suite is
>
> <pre>
> $ cp config-global-dhp__pagealloc-performance config
> $ ./run-mmtests.sh --no-monitor 3.0-nomonitor
> $ ./run-mmtests.sh --run-monitor 3.0-runmonitor
> </pre>
>
> Configuration
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> The config file used is always called "config". A number of other
> sample configuration files are provided that have a given theme. Some
> important points of variability are;
>
> MMTESTS is a list of what tests will be run
>
> WEBROOT is the location where a number of tarballs are mirrored. For exam=
ple,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0kernbench tries to download
> =C2=A0 =C2=A0 =C2=A0 =C2=A0$WEBROOT/kernbench/linux-2.6.30.tar.gz . If th=
is is not available,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0it is downloaded from the internet. This can a=
dd delays in testing
> =C2=A0 =C2=A0 =C2=A0 =C2=A0and consumes bandwidth so is worth configuring=
.
>
> LINUX_GIT is the location of a git repo of the kernel. At the moment it's=
 only
> =C2=A0 =C2=A0 =C2=A0 =C2=A0used during report generation
>
> SKIP_*PROFILE
> =C2=A0 =C2=A0 =C2=A0 =C2=A0These parameters determine what profiling runs=
 are done. Even with
> =C2=A0 =C2=A0 =C2=A0 =C2=A0profiling enabled, a non-profile run can be us=
ed to ensure that
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the profile and non-profile runs are comparabl=
e.
>
> SWAP_CONFIGURATION
> SWAP_PARTITIONS
> SWAP_SWAPFILE_SIZEMB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0It's possible to use a different swap configur=
ation than what is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0provided by default.
>
> TESTDISK_RAID_PARTITIONS
> TESTDISK_RAID_DEVICE
> TESTDISK_RAID_OFFSET
> TESTDISK_RAID_SIZE
> TESTDISK_RAID_TYPE
> =C2=A0 =C2=A0 =C2=A0 =C2=A0If the target machine has partitions suitable =
for configuring RAID,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0they can be specified here. This RAID partitio=
n is then used for
> =C2=A0 =C2=A0 =C2=A0 =C2=A0all the tests
>
> TESTDISK_PARTITION
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Use this partition for all tests
>
> TESTDISK_FILESYSTEM
> TESTDISK_MKFS_PARAM
> TESTDISK_MOUNT_ARGS
> =C2=A0 =C2=A0 =C2=A0 =C2=A0The filesystem, mkfs parameters and mount argu=
ments for the test
> =C2=A0 =C2=A0 =C2=A0 =C2=A0partitions
>
> Available tests
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> Note the ones that are marked untested. These have been ported from other
> test suites but no guarantee they actually work correctly here. If you wa=
nt
> to run these tests and run into a problem, report a bug.
>
> kernbench
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Builds a kernel 5 times recording the time tak=
en to completion.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0An average time is stored. This is sensitive t=
o the overall
> =C2=A0 =C2=A0 =C2=A0 =C2=A0performance of the system as it hits a number =
of subsystems.
>
> multibuild
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Similar to kernbench except it runs a number o=
f kernel compiles
> =C2=A0 =C2=A0 =C2=A0 =C2=A0in parallel. Can be useful for stressing the s=
ystem and seeing
> =C2=A0 =C2=A0 =C2=A0 =C2=A0how well it deals with simple fork-based paral=
lelism.
>
> aim9
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Runs a short version of aim9 by default. Each =
test runs for 60
> =C2=A0 =C2=A0 =C2=A0 =C2=A0seconds. This is a micro-benchmark of a number=
 of VM operations. It's
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sensitive to changes in the allocator paths fo=
r example.
>
> vmr-stream
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Runs the STREAM benchmark a number of times fo=
r varying sizes. An
> =C2=A0 =C2=A0 =C2=A0 =C2=A0average is recorded. This can be used to measu=
re approximate memory
> =C2=A0 =C2=A0 =C2=A0 =C2=A0throughput or the average cost of a number of =
basic operations. It is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sensitive to cache layout used for page faults=
.
>
> vmr-cacheeffects (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Performs linear and random walks on nodes of d=
ifferent sizes stored in
> =C2=A0 =C2=A0 =C2=A0 =C2=A0a large amount of memory. Sensitive to cache f=
ootprint and layout.
>
> vmr-createdelete (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0A micro-benchmark that measures the time taken=
 to create and delete
> =C2=A0 =C2=A0 =C2=A0 =C2=A0file or anonymous mappings of increasing sizes=
. Sensitive to changes
> =C2=A0 =C2=A0 =C2=A0 =C2=A0in the page fault path performance.
>
> iozone
> =C2=A0 =C2=A0 =C2=A0 =C2=A0A basic filesystem benchmark.
>
> fsmark
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This tests write workloads varying the number =
of files and directory
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depth.
>
> hackbench-*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Hackbench is generally a scheduler benchmark b=
ut is also sensitive to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0overhead in the allocators and to a lesser ext=
ent the fault paths.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Can be run for either sockets or pipes.
>
> largecopy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This is a simple single-threaded benchmark tha=
t downloads a large
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tar file, expands it a number of times, create=
s a new tar and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0expands it again. Each operation is timed and =
is aimed at shaking
> =C2=A0 =C2=A0 =C2=A0 =C2=A0out stall-related bugs when copying large amou=
nts of data
>
> largedd
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Similar to largecopy except it uses dd instead=
 of cp.
>
> libreofficebuild
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This downloads and builds libreoffice. It is a=
 more aggressive
> =C2=A0 =C2=A0 =C2=A0 =C2=A0compile-orientated test. This is a very downlo=
ad-intensive
> =C2=A0 =C2=A0 =C2=A0 =C2=A0benchmark and was only created as a reproducti=
on case for
> =C2=A0 =C2=A0 =C2=A0 =C2=A0a bug.
>
> nas-*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0The NAS Parallel Benchmarks for the serial and=
 openmp versions of
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the test.
>
> netperf-*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Runs the netperf benchmark for *_STREAM on the=
 local machine.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Sensitive to cache usage and allocator costs. =
To test for cache line
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bouncing, the test can be configured to bind t=
o certain processors.
>
> postmark
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Run the postmark benchmark. Optionally a progr=
am can be run in
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the background that consumes anonymous memory.=
 The background
> =C2=A0 =C2=A0 =C2=A0 =C2=A0program is vary rarely needed except when tryi=
ng to identify
> =C2=A0 =C2=A0 =C2=A0 =C2=A0desktop stalls during heavy IO.
>
> speccpu (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0SPECcpu, what else can be said. A restriction =
is that you must have
> =C2=A0 =C2=A0 =C2=A0 =C2=A0a mirrored copy of the tarball as it is not pu=
blicly available.
>
> specjvm (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0SPECjvm. Same story as speccpu
>
> specomp (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0SPEComp. Same story as speccpu
>
> sysbench
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Runs the complex workload for sysbench backed =
by postgres. Running
> =C2=A0 =C2=A0 =C2=A0 =C2=A0this test requires a significant build environ=
ment on the test
> =C2=A0 =C2=A0 =C2=A0 =C2=A0machine. It can run either read-only or read/w=
rite tests.
>
> simple-writeback
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This is a simple writeback test based on dd. I=
t's meant to be
> =C2=A0 =C2=A0 =C2=A0 =C2=A0easy to understand and quick to run. Useful fo=
r measuring page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0writeback changes.
>
> ltp (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0The LTP benchmark. What it is testing depends =
on exactly which of the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0suite is configured to run.
>
> ltp-pounder (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ltp pounder is a non-default test that exists =
in LTP. It's used by
> =C2=A0 =C2=A0 =C2=A0 =C2=A0IBM for hardware certification to hammer a mac=
hine for a configured
> =C2=A0 =C2=A0 =C2=A0 =C2=A0number of hours. Typically, they expect it to =
run for 72 hours
> =C2=A0 =C2=A0 =C2=A0 =C2=A0without major errors. =C2=A0Useful for testing=
 general VM stability in
> =C2=A0 =C2=A0 =C2=A0 =C2=A0high-pressure low-memory situations.
>
> stress-highalloc
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This test requires that the system not have to=
o much memory and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0that systemtap is available. Typically, it's t=
ested with 3GB of
> =C2=A0 =C2=A0 =C2=A0 =C2=A0RAM. It builds a number of kernels in parallel=
 such that total
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memory usage is 1.5 times physical memory. Whe=
n this is running
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for 5 minutes, it tries to allocate a large pe=
rcentage of memory
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(e.g. 95%) as huge pages recording the latency=
 of each operation as it
> =C2=A0 =C2=A0 =C2=A0 =C2=A0goes. It does this twice. It then cancels the =
kernel compiles, cleans
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the system and tries to allocate huge pages at=
 rest again. It's a
> =C2=A0 =C2=A0 =C2=A0 =C2=A0basic test for fragmentation avoidance and the=
 performance of huge
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page allocation.
>
> xfstests (untested)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0This is still at prototype level and aimed at =
running testcase 180
> =C2=A0 =C2=A0 =C2=A0 =C2=A0initially to reproduce some figures provided b=
y the filesystems people.
>
> Reporting
> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> For reporting, there is a basic compare-kernels.sh script. It must be upd=
ated
> with a list of kernels you want to compare and in what order. It generate=
s a
> table for each test, operation and kernel showing the relative performanc=
e
> of each. The test reporting scripts are in subreports/. compare-kernel.sh
> should be run from the path storing the test logs. By default this is
> work/log. If you are automating tests from an external source, work/log i=
s
> what you should be capturing after a set of tests complete.
>
> If monitors are configured such as ftrace, there are additional
> processing scripts. They can be activated by setting FTRACE_ANALYSERS in
> compare-kernels.sh. A basic post-process script is mmtests-duration which
> simply reports how long an individual test took and what its CPU usage wa=
s.
>
> There are a limited number of graphing scripts included in report/
>
> TODO
> =3D=3D=3D=3D
>
> o Add option to test on filesystem loopback device stored on tmpfs
> o Add volanomark
> o Create config-* set suitable for testing scheduler to isolate situation=
s
> =C2=A0where the scheduler was the main cause of a regression
>
> --
> Mel Gorman
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
