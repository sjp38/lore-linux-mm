Date: Sat, 5 Apr 2003 04:06:14 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: objrmap and vmtruncate
Message-Id: <20030405040614.66511e1e.akpm@digeo.com>
In-Reply-To: <20030404192401.03292293.akpm@digeo.com>
References: <20030404163154.77f19d9e.akpm@digeo.com>
	<12880000.1049508832@flay>
	<20030405024414.GP16293@dualathlon.random>
	<20030404192401.03292293.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@suse.de, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> Nobody has written an "exploit" for this yet, but it's there.

Here we go.  The test app is called `rmap-test'.  It is in ext3 CVS.  See

	http://www.zip.com.au/~akpm/linux/ext3/

It sets up N MAP_SHARED VMA's and N tasks touching them in various access
patterns.

vmm:/usr/src/ext3/tools> ./rmap-test 
Usage: ./rmap-test [-hlrvV] [-iN] [-nN] [-sN] [-tN] filename
     -h:          Pattern: half of memory is busy
     -l:          Pattern: linear
     -r:          Pattern: random
     -iN:         Number of iterations
     -nN:         Number of VMAs
     -sN:         VMA size (pages)
     -tN:         Run N tasks
     -VN:         Number of VMAs to process
     -v:          Verbose

The kernels which were compared were 2.5.66-mm4, 2.5.66-mm4+all objrmap
patches and 2.4.21-pre5aa2.  The machine has 256MB of memory, 2.7G P4,
uniprocessor, IDE disk.




The first test has 100 tasks, each of which has 100 vma's.  The 100 processes
modify their 100 vma's in a linear walk.  Total working set is 240MB
(slightly more than is available).

	./rmap-test -l -i 10 -n 100 -s 600 -t 100 foo

2.5.66-mm4:
	15.76s user 86.91s system 33% cpu 5:05.07 total
2.5.66-mm4+objrmap:
	23.07s user 1143.26s system 87% cpu 22:09.81 total
2.4.21-pre5aa2:
	14.91s user 75.30s system 24% cpu 6:15.84 total





In the second test we again have 100 tasks, each with 100 vma's but the
access pattern is random:

	./rmap-test -vv -V 2 -r -i 1 -n 100 -s 600 -t 100 foo

2.5.66-mm4:
	0.12s user 6.05s system 2% cpu 3:59.68 total
2.5.66-mm4+objrmap:
	0.12s user 2.10s system 0% cpu 4:01.15 total
2.4.21-pre5aa2:
	0.07s user 2.03s system 0% cpu 4:12.69 total


The -aa VM failed in this test.

	__alloc_pages: 0-order allocation failed (gfp=0x1d2/0)
	VM: killing process rmap-test

I'd have to call this a bug - the machine was full of reclaimable memory.

I also saw the 2.4 kernel do 705,000 context switches in a single second,
which was odd.  It only happened once.





In the third test a single task owns 10000 VMA's and walks across them in a
linear pattern:

	./rmap-test -v -l -i 10 -n 10000 -s 7 -t 1 foo

2.5.66-mm4:
	0.25s user 3.75s system 1% cpu 4:38.44 total
2.5.66-mm4+objrmap:
	0.28s user 146.45s system 16% cpu 15:14.59 total
2.4.21-pre5aa2:
	0.32s user 4.83s system 0% cpu 18:25.90 total




These are not ridiculous workloads, especially the third one.  And 10k VMA's
is by no means inconceivable.

The objrmap code will be show-stoppingly expensive at 100k vmas per file.

And as expected, the full rmap implementation gives the most stable,
predictable and highest performance result under heavy load.  That's why
we're using it.

When it comes to the VM, there is a lot of value in sturdiness under unusual
and heavy loads.

Tomorrow I'll change the test app to do nonlinear mappings too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
