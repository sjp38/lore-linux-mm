Date: Tue, 16 Jan 2007 13:53:25 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC 0/8] Cpuset aware writeback
Message-Id: <20070116135325.3441f62b.akpm@osdl.org>
In-Reply-To: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

> On Mon, 15 Jan 2007 21:47:43 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:
>
> Currently cpusets are not able to do proper writeback since
> dirty ratio calculations and writeback are all done for the system
> as a whole.

We _do_ do proper writeback.  But it's less efficient than it might be, and
there's an NFS problem.

> This may result in a large percentage of a cpuset
> to become dirty without writeout being triggered. Under NFS
> this can lead to OOM conditions.

OK, a big question: is this patchset a performance improvement or a
correctness fix?  Given the above, and the lack of benchmark results I'm
assuming it's for correctness.

- Why does NFS go oom?  Because it allocates potentially-unbounded
  numbers of requests in the writeback path?

  It was able to go oom on non-numa machines before dirty-page-tracking
  went in.  So a general problem has now become specific to some NUMA
  setups.

  We have earlier discussed fixing NFS to not do that.  Make it allocate
  a fixed number of requests and to then block.  Just like
  get_request_wait().  This is one reason why block_congestion_wait() and
  friends got renamed to congestion_wait(): it's on the path to getting NFS
  better aligned with how block devices are handling this.

- There's no reason which I can see why NFS _has_ to go oom.  It could
  just fail the memory allocation for the request and then wait for the
  stuff which it _has_ submitted to complete.  We do that for block
  devices, backed by mempools.

- Why does NFS go oom if there's free memory in other nodes?  I assume
  that's what's happening, because things apparently work OK if you ask
  pdflush to do exactly the thing which the direct-reclaim process was
  attempting to do: allocate NFS requests and do writeback.

  So an obvious, equivalent and vastly simpler "fix" would be to teach
  the NFS client to go off-cpuset when trying to allocate these requests.

I suspect that if we do some or all of the above, NFS gets better and the
bug which motivated this patchset goes away.

But that being said, yes, allowing a zone to go 100% dirty like this is
bad, and it's be nice to be able to fix it.

(But is it really bad? What actual problems will it cause once NFS is fixed?)

Assuming that it is bad, yes, we'll obviously need the extra per-zone
dirty-memory accounting.




I don't understand why the proposed patches are cpuset-aware at all.  This
is a per-zone problem, and a per-zone fix would seem to be appropriate, and
more general.  For example, i386 machines can presumably get into trouble
if all of ZONE_DMA or ZONE_NORMAL get dirty.  A good implementation would
address that problem as well.  So I think it should all be per-zone?




Do we really need those per-inode cpumasks?  When page reclaim encounters a
dirty page on the zone LRU, we automatically know that page->mapping->host
has at least one dirty page in this zone, yes?  We could immediately ask
pdflush to write out some pages from that inode.  We would need to take a
ref on the inode (while the page is locked, to avoid racing with inode
reclaim) and pass that inode off to pdflush (actually pass a list of such
inodes off to pdflush, keep appending to it).

Extra refinements would include

- telling pdflush the file offset of the page so it can do writearound

- getting pdflush to deactivate any pages which it writes out, so that
  rotate_reclaimable_page() has a good chance of moving them to the tail of
  the inactive list for immediate reclaim.

But all of this is, I think, unneeded if NFS is fixed.  It's hopefully a
performance optimisation to permit writeout in a less seeky fashion. 
Unless there's some other problem with excessively dirty zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
