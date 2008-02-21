From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps (f.e. for XPmem)
Date: Thu, 21 Feb 2008 15:20:02 +1100
References: <20080215064859.384203497@sgi.com> <200802201451.46069.nickpiggin@yahoo.com.au> <20080220090035.GG11391@sgi.com>
In-Reply-To: <20080220090035.GG11391@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802211520.03529.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wednesday 20 February 2008 20:00, Robin Holt wrote:
> On Wed, Feb 20, 2008 at 02:51:45PM +1100, Nick Piggin wrote:
> > On Wednesday 20 February 2008 14:12, Robin Holt wrote:
> > > For XPMEM, we do not currently allow file backed
> > > mapping pages from being exported so we should never reach this
> > > condition. It has been an issue since day 1.  We have operated with
> > > that assumption for 6 years and have not had issues with that
> > > assumption.  The user of xpmem is MPT and it controls the communication
> > > buffers so it is reasonable to expect this type of behavior.
> >
> > OK, that makes things simpler.
> >
> > So why can't you export a device from your xpmem driver, which
> > can be mmap()ed to give out "anonymous" memory pages to be used
> > for these communication buffers?
>
> Because we need to have heap and stack available as well.  MPT does
> not control all the communication buffer areas.  I haven't checked, but
> this is the same problem that IB will have.  I believe they are actually
> allowing any memory region be accessible, but I am not sure of that.

Then you should create a driver that the user program can register
and unregister regions of their memory with. The driver can do a
get_user_pages to get the pages, and then you'd just need to set up
some kind of mapping so that userspace can unmap pages / won't leak
memory (and an exit_mm notifier I guess).

Because you don't need to swap, you don't need coherency, and you
are in control of the areas, then this seems like the best choice.
It would allow you to use heap, stack, file-backed, anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
