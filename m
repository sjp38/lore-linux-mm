Date: Tue, 22 Apr 2003 11:07:32 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: objrmap and vmtruncate
In-Reply-To: <170570000.1051021741@[10.10.2.4]>
Message-ID: <Pine.LNX.4.44.0304221032560.10400-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Apr 2003, Martin J. Bligh wrote:

> [...] I think we're optimising for the wrong case here - isn't the
> 100x100 mappings case exactly what we have sys_remap_file_pages for?

i'm inherently uncomfortable about adding any non-limited component to the
VM scanning code that deteriorates this badly by such a relatively low
level of sharing. Even with just 10 processes sharing the same inode 10
times (easily possible) causes an iteration of 100 steps for every page,
100+ cachelines touched. This brings us back to the Linux 2.0 days. It
also sends the wrong message: 'the more you share, the more we will punish
you'.

Also, the overhead pops up at the wrong place, not in the application
itself: in a central algorithm that otherwise _needs_ timely operation
just for the sake of generic system health. I might be wrong, but i very
much believe that first-class support for 'sharing as much stuff as
possible' should be a central design thing in the VM.

also, it's an inherent DoS thing. Any application that has the 'privilege'
of creating 1000 mappings in 1000 processes to the same inode (this is
already being done, and it will be commonplace in a few years) will
immediately DoS the whole VM. I might be repeating myself, but quadratic
algorithms do get linearly _worse_ as the hw evolves. The pidhash
quadratic behavior triggering the NMI watchdog on the biggest boxes is
just one example of this.

all the VM work in 2.5 has proven that the path to a good and reliable VM
is no-nonsense simplicity and basic robustness, both in algorithms and in
data structures. Queueing stuff as much as possible, avoiding extra
scanning as much as possible. And for God's sake, do not reintroduce any
quadratic algorithm, anywhere.

all this loss in quality and predictibility just to avoid some easily
calculatable RAM overhead? [which RAM overhead can be avoided by smart
applications if they want.]

where does sys_remap_file_pages() stand in this picture?

sys_remap_file_pages() could be fully substituted with mmap(): if the same
file in the same vma, using the same permissions is used with a nonlinear
offset then mmap() could decide to use the techniques of
sys_remap_file_pages() to create nonlinear ptes in that range. It's a
vma-overhead optimization for highly granular mappings.

so in theory we could do the following: if the sharing factor is less than
... 4-5 or so, then use objrmap, otherwise use nonlinear mappings. There
are a couple of problems with this hybrid approach: there is cost
associated with a 'flipover' from objrmap to nonlinear (the vmas have to
be merged, and all non-present ptes have to be fixed up to their pre-merge
offset), but it could probably be reduced and delegated to the app doing
the mapping, which would remove this cost component from the generic
scanning code.

doing the 'sharing factor of 5' flipover would address all my complaints:
nonlinear mappings can automatically solve the quadratic-algorithm
problems, and objrmap can be used whenever the sharing factor is low
enough.

ie. an app creating many mappings in many processes to the same inode
would 'magically' be presented with nonlinear mappings - without it having
to care.

can anyone see any problem with this approach?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
