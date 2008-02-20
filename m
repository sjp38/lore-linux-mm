From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps (f.e. for XPmem)
Date: Wed, 20 Feb 2008 14:51:45 +1100
References: <20080215064859.384203497@sgi.com> <200802201055.21343.nickpiggin@yahoo.com.au> <20080220031221.GE11391@sgi.com>
In-Reply-To: <20080220031221.GE11391@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802201451.46069.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wednesday 20 February 2008 14:12, Robin Holt wrote:
> For XPMEM, we do not currently allow file backed
> mapping pages from being exported so we should never reach this condition.
> It has been an issue since day 1.  We have operated with that assumption
> for 6 years and have not had issues with that assumption.  The user of
> xpmem is MPT and it controls the communication buffers so it is reasonable
> to expect this type of behavior.

OK, that makes things simpler.

So why can't you export a device from your xpmem driver, which
can be mmap()ed to give out "anonymous" memory pages to be used
for these communication buffers?

I guess you may also want an "munmap/mprotect" callback, which
we don't have in the kernel right now... but at least you could
prototype it easily by having an ioctl to be called before
munmapping or mprotecting (eg. the ioctl could prevent new TLB
setup for the region, and shoot down existing ones).

This is actually going to be much faster for you if you use any
threaded applications, because you will be able to do all the
shootdown round trips outside mmap_sem, and so you will be able
to have other threads faulting and even mmap()ing / munmaping
at the same time as the shootdown is happening.

I guess there is some catch...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
