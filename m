Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 320FD6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 21:15:52 -0400 (EDT)
Date: Wed, 1 Jun 2011 03:15:27 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Message-ID: <20110601011527.GN19505@random.random>
References: <4DE44333.9000903@fnarfbargle.com>
 <20110531054729.GA16852@liondog.tnic>
 <4DE4B432.1090203@fnarfbargle.com>
 <20110531103808.GA6915@eferding.osrc.amd.com>
 <4DE4FA2B.2050504@fnarfbargle.com>
 <alpine.LSU.2.00.1105311517480.21107@sister.anvils>
 <4DE589C5.8030600@fnarfbargle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DE589C5.8030600@fnarfbargle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Cc: Hugh Dickins <hughd@google.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Izik Eidus <ieidus@redhat.com>

Hello,

On Wed, Jun 01, 2011 at 08:37:25AM +0800, Brad Campbell wrote:
> On 01/06/11 06:31, Hugh Dickins wrote:
> > Brad, my suspicion is that in each case the top 16 bits of RDX have been
> > mysteriously corrupted from ffff to 0000, causing the general protection
> > faults.  I don't understand what that has to do with KSM.
> >
> > But it's only a suspicion, because I can't make sense of the "Code:"
> > lines in your traces, they have more than the expected 64 bytes, and
> > only one of them has a ">" (with no"<") to mark faulting instruction.
> >
> > I did try compiling the 2.6.39 kernel from your config, but of course
> > we have different compilers, so although I got close, it wasn't exact.
> >
> > Would you mind mailing me privately (it's about 73MB) the "objdump -trd"
> > output for your original vmlinux (with KSM on)?  (Those -trd options are
> > the ones I'm used to typing, I bet not they're not all relevant.)
> >
> > Of course, it's only a tiny fraction of that output that I need,
> > might be better to cut it down to remove_rmap_item_from_tree and
> > dup_fd and ksm_scan_thread, if you have the time to do so.
> 
> Would you believe about 20 seconds after I pressed send the kernel oopsed.
> 
> http://www.fnarfbargle.com/private/003_kernel_oops/
> 
> oops reproduced here, but an un-munged version is in that directory 
> alongside the kernel.
> 
> [36542.880228] general protection fault: 0000 [#1] SMP

Reminds me of another oops that was reported on the kvm list for
2.6.38.1 with message id 4D8C6110.6090204. There the top 16 bits of
rsi were flipped and it was a general protection too because of
hitting on the not mappable virtual range.

http://www.virtall.com/files/temp/kvm.txt
http://www.virtall.com/files/temp/config-2.6.38.1
http://virtall.com/files/temp/mmu-objdump.txt

That oops happened in kvm_unmap_rmapp though, but it looked memory
corruption (Avi suggested use after free) but it was a production
system so we couldn't debug it further.

I recommend next thing to reproduce again with 2.6.39 or
3.0.0-rc1. Let's fix your scsi trouble if needed but it's better you
test with 2.6.39.

We'd need chmod +r vmlinux on private/003_kernel_oops/

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
