Date: Sat, 5 Apr 2003 23:42:06 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030406074206.GF1828@holomorphy.com>
References: <20030405195501.028ca5d8.akpm@digeo.com> <74210000.1049602103@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <74210000.1049602103@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, andrea@suse.de, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, akpm wrote:
>> remap_file_pages() would work OK for this, yes.  Bit sad that an application
>> which runs OK on 2.4 would need recoding to work acceptably under 2.5 though.

On Sat, Apr 05, 2003 at 08:08:25PM -0700, Martin J. Bligh wrote:
> You mean like trying to run Oracle Apps or something? ;-)
> 5000 tasks, 2Gb shmem segment = 10Gb of PTE chains (I think).
> In ZONE_NORMAL.
> Somehow.
> Both regular rmap and partial objrmap have their corner cases. Both are
> fairly easily avoidable. Both may require some app tweaks. I'd argue
> that partial objrmap's bad cases are actually more obscure. And it does
> better in the common case ... I think that's important.
> regular rmap + shared pagetables is more workable than without.

There were 10GB of PTE's on 2.4.x too, which was not acceptable. A
constant factor more or less doesn't make or break the algorithm. The
pagetable space consumption alone, even if highmem, is beyond reason.
The fact the additional load comes from lowmem is fatal so we are of
course in a quandary, but none of this is remotely new.

I'd like to get it addressed but have serious doubts that dragging it
into this discussion is productive, for AIUI we began with the premise
that both objrmap (fobjrmap?) and sys_remap_file_pages() are desirable
but raise serious implementation difficulties when combined.

If I can reiterate the topic of the thread, objrmap needs to address
its cpu performance corner cases and sys_remap_file_pages() needs bits
of bugfixing around the VM for correctness. I think we need code to
address these things as opposed to a further protracted discussion,
as akpm and hugh have partially identified the areas in need of work to
fix sys_remap_file_pages()' issues and akpm has written testcases to
measure the performance of objrmap in its corner cases.

I think the only thing "up in the air" is that we would take a
significant code complexity hit (presumably maintenance load and
maintainer preference being the main factors) in fixing these issues
while retaining both, and people are at least weighing the code
simplification benefits of dropping one or the other or restricting the
usage of sys_remap_file_pages() to avoid the code complexity hit, and
are reexamining things to determine which (if either) to drop or change.

In the spirit of fixing bugs, are there testcases to determine whether
the vmtruncate() vs. sys_remap_file_pages() bugs are fixed or to
otherwise try to trigger them?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
