Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m5A8dim1173730
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 08:39:44 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5A8dhFl1712140
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 10:39:43 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5A8dhoZ027692
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 10:39:43 +0200
In-Reply-To: <20080609220149.d930d141.akpm@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: 2.6.26-rc5-mm1
Message-ID: <OF18B05E59.2D95953A-ONC1257464.00296BEB-C1257464.002F94B3@de.ibm.com>
From: Peter 1 Oberparleiter <Peter.Oberparleiter@de.ibm.com>
Date: Tue, 10 Jun 2008 10:39:42 +0200
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, Mariusz Kozlowski <m.kozlowski@tuxland.pl>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> wrote on 10.06.2008 07:01:49:
> On Tue, 10 Jun 2008 06:57:02 +0200 Mariusz Kozlowski <m.
> kozlowski@tuxland.pl> wrote:
> 
> > Witam, 
> > 
> > > On Mon, 9 Jun 2008 21:14:54 +0200
> > > Mariusz Kozlowski <m.kozlowski@tuxland.pl> wrote:
> > > 
> > > > Hello Balbir,
> > > > 
> > > > > Andrew Morton wrote:
> > > > > > Temporarily at
> > > > > > 
> > > > > >   http://userweb.kernel.org/~akpm/2.6.26-rc5-mm1/
> > > > > > 
> > > > > 
> > > > > I've hit a segfault, the last few lines on my console are
> > > > > 
> > > > > 
> > > > > Testing -fstack-protector-all feature
> > > > > registered taskstats version 1
> > > > > debug: unmapping init memory ffffffff80c03000..ffffffff80dd8000
> > > > > init[1]: segfault at 7fff701fe880 ip 7fff701fee5e sp 
> 7fff7006e6d0 error 7
> > > > > 
> > > > > With absolutely no stack trace. I'll dig deeper.
> > > > 
> > > > Hey, I see something similar and I actually have a stack 
> trace. Here it goes:
> > > > 
> > > > bash[498] segfault at ffffffff80868b58 ip ffffffffff600412 sp 
> 7fffa3d010f0 error 7
> > > > init[1] segfault at ffffffff80868b58 ip ffffffffff600412 sp 
> 7fff9e97f640 error 7
> > > > init[1] segfault at ffffffff80868b58 ip ffffffffff600412 sp 
> 7fff9e97eed0 error 7
> > > > Kernel panic - not syncing: Attemted to kill init!
> > > > Pid 1, comm: init Not tainted 2.6.26-rc5-mm1 #1
> > > > 
> > > > Call Trace:
> > > > [<ffffffff80254632>] panic+0xe2/0x260
> > > > [<ffffffff802fa8ba>] ? __slab_free+0x10a/0x630
> > > > [<ffffffff80265a8e>] ? __sigqueue_free+0x5e/0x70
> > > > [<ffffffff802851eb>] ? trace_hardirqs_off+0x1b/0x30
> > > > [<ffffffff802851eb>] ? trace_hardirqs_off+0x1b/0x30
> > > > [<ffffffff80259b54>] do_exit+0xb84/0xc30
> > > > [<ffffffff80259c5a>] do_group_exit+0x5a/0x110
> > > > [<ffffffff8026a3b5>] get_signal_to_deliver+0x2c5/0x620
> > > > [<ffffffff8020bb3b>] do_notify_resume+0x11b/0xd10
> > > > [<ffffffff8028da5b>] ? trace_hardirqs_on+0x1b/0x30
> > > > [<ffffffff805cd0f3>] ? _spin_unlock_irqrestore+0x93/0x130
> > > > [<ffffffff8026865c>] ? force_sig_info+0x10c/0x130
> > > > [<ffffffff8022fb9c>] ? force_sig_info_fault+0x2c/0x40
> > > > [<ffffffff802dd7dd>] ? print_vma_addr+0x10d/0x1d0
> > > > [<ffffffff805cbb67>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> > > > [<ffffffff8028d8da>] ? trace_hardirqs_on_caller+0x15a/0x2c0
> > > > [<ffffffff8020d4c9>] retint_signal+0x46/0x8d
> > > > 
> > > > This was copied manually so typos are possible.
> > > > 
> > > 
> > > Thanks.  Could someone send a config please?  Or a bisection result 
;)
> > 
> > In my case it turns out to be gcov patches - in which I'm interested
> > in to see (and play with) the tests coverage.
> > 
> > #
> > # gcov
> > #
> > kernel-call-constructors.patch
> > kernel-introduce-gcc_version_lower-macro.patch
> > seq_file-add-function-to-write-binary-data.patch
> > GOOD
> > gcov-add-gcov-profiling-infrastructure.patch
> > GOOD
> > gcov-create-links-to-gcda-files-in-build-directory.patch
> > gcov-architecture-specific-compile-flag-adjustments.patch
> > BAD
> > 
> > I can not bisect between the last two due to build error. Config 
> is attached.
> > 
> 
> (cc Peter)

Thanks for the report. These look like the "known architecture problems"
that I've hinted at in the gcov announcement post (I'm assuming this is
x86_64 as I've seem similar reports in the past).

Possible reasons:

1) initrd overwrites kernel: When kernel and initrd are loaded to static
addresses, the oversized gcov kernel may overlap with the initrd load
address. Solution: move initrd loading address.

2) out-of-memory: Kernel plus profiling code may just not fit into a
minimal memory configuration any more. Solution: add memory.

3) write-protection of kernel code: gcc keeps profiling code and data
close together in the .text section. Solution: any mechanism that
protects .text against writes should be disabled when running a
profiled kernel.

4) as of yet undiscovered incompatibilities between arch-dependent code
and gcc's -fprofile-arcs option. Examples would be:

 * code which is run before memory access preparations were made
 * hard coded section sizes
 * relative address displacements which are out of range

Unfortunately I neither have access to a machine nor the skill to debug
4) myself, so if 1)-3) can be ruled out, I'd like to ask for more help
on this one:

First off, someone needs to track down the offending file(s). This is
done by putting a line containing "GCOV := n" in all Makefiles below
arch/x86_64 (or go one step further back and set
CONFIG_GCOV_PROFILE_ALL=n). If my assumption is correct, then the
kernel should boot fine afterwards. In that case, remove the lines
again one-by-one, while compiling and booting after each change. If the
problem can be narrowed down to a single Makefile, replace the single
"GCOV := n" line with multiple "GCOV_file.o := n" lines, one for each
generated object file. Then again, same approach as before: remove
those lines, compile and boot until it breaks. Finally post your
results.

At this point we would need someone with x86_64 arch skills to look at
the file and find out why this code is broken with "-fprofile-arcs"
enabled (on s390 we discovered at least one actual code bug this way,
so the analysis might just be of general use). Alternatively we can
just keep these files from being profiled.


Regards,
  Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
