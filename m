Date: Mon, 11 Aug 2003 23:52:35 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: Is /proc/#/statm worth fixing?
Message-ID: <20030811215235.GB13180@k3.hellgate.ch>
References: <20030811090213.GA11939@k3.hellgate.ch> <20030811160222.GE3170@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030811160222.GE3170@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Aug 2003 09:02:22 -0700, William Lee Irwin III wrote:
> I've restored a number of the fields to the 2.4.x semantics in tandem

So what _are_ the semantics?

# total program size (linux-2.6.0-test3/Documentation/filesystems/proc.txt)
2.6 and I believe the first field (size) should be the same (in pages, of
course) as VmSize, but 2.4 doesn't think so.

# size of memory portions (proc.txt)
The second field (resident) is actually equal to VmRSS on both 2.4 and 2.6.
That looks okay.

# number of pages that are shared (proc.txt)
Field three (shared) is text + data for program and shared libs on 2.6, but
not on on 2.4.

# number of pages that are 'code' (proc.txt)
Field four is program text + data.

# number of pages of data/stack (proc.txt; wrong, this should be field six)
Field five is set to 0 in 2.6 (lib), and AFAICT always equals 0 on 2.4
(lrs) although it pretends to work out the libraries' size (by checking for
vm_end > 0x60000000 which seems rather odd).

# number of pages of library (proc.txt; wrong, should be field five)
Field six is text + data for program and shared libs + some anonymous
mappings for 2.6 (data), but not on 2.4 (drs).

# number of dirty pages (proc.txt)
Field seven is always 0 on 2.6, but not on 2.4 (dt).

We can get all that data from /proc/#/maps and /proc/#/status (minus the
dirty pages which are always 0 in 2.6 anyway).

Are there _any_ programs using /proc/#/statm for real and producing
meaningful data from it? I doubt it. I don't think the problem is 2.6 which
has actually more values that seem correct as it is now. Since statm has
been broken in 2.4, fixing it for 2.6 means basically _introducing_ a file
full of redundant information with unclear semantics, a file which nobody
missed in 2.4. I still think the file should die.

> I dumped the forward port of the patch into -wli, available at:
> ftp://ftp.kernel.org/pub/linux/kernel/people/wli/kernels/

Is it this one? (latest one I found)
ftp://ftp.kernel.org/pub/linux/kernel/people/wli/kernels/2.6.0-test1/2.6.0-test1-wli-1B.bz2

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
