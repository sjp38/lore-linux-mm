Date: Mon, 11 Aug 2003 15:16:46 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Is /proc/#/statm worth fixing?
Message-ID: <20030811221646.GF3170@holomorphy.com>
References: <20030811090213.GA11939@k3.hellgate.ch> <20030811160222.GE3170@holomorphy.com> <20030811215235.GB13180@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030811215235.GB13180@k3.hellgate.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Aug 2003 09:02:22 -0700, William Lee Irwin III wrote:
>> I've restored a number of the fields to the 2.4.x semantics in tandem

On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> So what _are_ the semantics?
> # total program size (linux-2.6.0-test3/Documentation/filesystems/proc.txt)
> 2.6 and I believe the first field (size) should be the same (in pages, of
> course) as VmSize, but 2.4 doesn't think so.

The 2.4.x behavior is a bug; it's counting ptes beneath vmas in already-
instantiated pagetable pages, which are frequently an underestimate.


On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> # size of memory portions (proc.txt)
> The second field (resident) is actually equal to VmRSS on both 2.4 and 2.6.
> That looks okay.

This one's hard to screw up.


On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> # number of pages that are shared (proc.txt)
> Field three (shared) is text + data for program and shared libs on 2.6, but
> not on on 2.4.

2.4.x semantics are unclear; it's counting ptes pointing to pages with
page_count(page) > 1; this is somewhat ugly (and in fact is buggy on
various discontiguous memory machines and others where iospace isn't
covered by mem_map[]) and can misclassify pages with reference counts
elevated due to the buffer cache or other operations as shared.


On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> # number of pages that are 'code' (proc.txt)
> Field four is program text + data.

Odd that "code" should include non-executable data.


On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> # number of pages of data/stack (proc.txt; wrong, this should be field six)
> Field five is set to 0 in 2.6 (lib), and AFAICT always equals 0 on 2.4
> (lrs) although it pretends to work out the libraries' size (by checking for
> vm_end > 0x60000000 which seems rather odd).

0x60000000 should be TASK_UNMAPPED_BASE for starters, but it's unclear
why 2.4.x thinks all of this is "library".


On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> # number of pages of library (proc.txt; wrong, should be field five)
> Field six is text + data for program and shared libs + some anonymous
> mappings for 2.6 (data), but not on 2.4 (drs).

This should be "data" of some kind. Apparently 2.6.x got a bit liberal.


On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> # number of dirty pages (proc.txt)
> Field seven is always 0 on 2.6, but not on 2.4 (dt).

This is hard to count; the O(1) proc_pid_statm() patch ticks a counter
every time a pte is set dirty, which is better than scanning but still
not accurate.


On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> We can get all that data from /proc/#/maps and /proc/#/status (minus the
> dirty pages which are always 0 in 2.6 anyway).
> Are there _any_ programs using /proc/#/statm for real and producing
> meaningful data from it? I doubt it. I don't think the problem is 2.6 which
> has actually more values that seem correct as it is now. Since statm has
> been broken in 2.4, fixing it for 2.6 means basically _introducing_ a file
> full of redundant information with unclear semantics, a file which nobody
> missed in 2.4. I still think the file should die.

Not entirely unreasonable.


On Mon, 11 Aug 2003 09:02:22 -0700, William Lee Irwin III wrote:
>> I dumped the forward port of the patch into -wli, available at:
>> ftp://ftp.kernel.org/pub/linux/kernel/people/wli/kernels/

On Mon, Aug 11, 2003 at 11:52:35PM +0200, Roger Luethi wrote:
> Is it this one? (latest one I found)
> ftp://ftp.kernel.org/pub/linux/kernel/people/wli/kernels/2.6.0-test1/2.6.0-test1-wli-1B.bz2

It's better to look at the tarballs; the patches are broken out in them,
which will help isolate it from the other changes.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
