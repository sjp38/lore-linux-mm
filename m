Date: Wed, 23 Apr 2003 05:37:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.68-mm2
Message-ID: <20030423123724.GC8939@holomorphy.com>
References: <20030423012046.0535e4fd.akpm@digeo.com> <200304230808.25387.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200304230808.25387.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On April 23, 2003 04:20 am, Andrew Morton wrote:
>> . I got tired of the objrmap code going BUG under stress, so it is now in
>>   disgrace in the experimental/ directory.

On Wed, Apr 23, 2003 at 08:08:25AM -0400, Ed Tomlinson wrote:
> As far as I see it there are two problems that objrmap/shpte/pgcl
> try to solve.  One is low memory pte useage, the second being to
> reduce the rmap fork overhead.

pgcl has no relation to time or space overhead for pagetables or
pte_chains. Its use for highmem is mostly for shrinking mem_map[].


On Wed, Apr 23, 2003 at 08:08:25AM -0400, Ed Tomlinson wrote:
> objrmap helps in both cases but has problem with truncate and
> intoduces a O(n^2) search into the the vm.
> shpte helps a lot with the first problem, and does not seem to do
> much for the second.  If I remember correctly it could also be a
> config option.
> pgcl should help with both to some extent but is not ready for prime
> time - yet.
> From comments recently made on lkml I believe that the first problem
> is probably more pressing.  What problems need to be resolved with
> each patch?   


I don't see that pgcl should help with either; its benefits are
increasing physical memory contiguity (good for io), larger fs
blocksize support (feature), and reduction in the number of objects
manipulated by the VM (mem_map[] size). There are no results either
way showing that it improves or degrades page replacement (and if it
improved it would be only by a linear factor, which does not repair
issues involving quadratic algorithms).

I'd love to claim as many benefits as possible for page clustering,
but these are so far outside its scope I'd like to avoid promising
things it's unlikely to deliver.

IMHO shpte, enhancing objrmap with more advanced spatial algorithms,
pagetable reclamation, and possibly even shoving pte_chains in highmem
are better directions for alleviating the space and/or time overhead of
pte_chains, in no small part because they're direct attacks on the issue.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
