Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 07CCB6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 18:32:01 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4VMVwTM000835
	for <linux-mm@kvack.org>; Tue, 31 May 2011 15:31:58 -0700
Received: from pvc12 (pvc12.prod.google.com [10.241.209.140])
	by wpaz37.hot.corp.google.com with ESMTP id p4VMV9ek026991
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 May 2011 15:31:57 -0700
Received: by pvc12 with SMTP id 12so2796812pvc.14
        for <linux-mm@kvack.org>; Tue, 31 May 2011 15:31:53 -0700 (PDT)
Date: Tue, 31 May 2011 15:31:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
In-Reply-To: <4DE4FA2B.2050504@fnarfbargle.com>
Message-ID: <alpine.LSU.2.00.1105311517480.21107@sister.anvils>
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <lists2009@fnarfbargle.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>

On Tue, 31 May 2011, Brad Campbell wrote:
> On 31/05/11 18:38, Borislav Petkov wrote:
> > On Tue, May 31, 2011 at 05:26:10PM +0800, Brad Campbell wrote:
> > > On 31/05/11 13:47, Borislav Petkov wrote:
> > > > Looks like a KSM issue. Disabling CONFIG_KSM should at least stop your
> > > > machine from oopsing.
> > > > 
> > > > Adding linux-mm.
> > > > 
> > > 
> > > I initially thought that, so the second panic was produced with KSM
> > > disabled from boot.
> > > 
> > > echo 0>  /sys/kernel/mm/ksm/run
> > > 
> > > If you still think that compiling ksm out of the kernel will prevent
> > > it then I'm willing to give it a go.
> > 
> > Ok, from looking at the code, when KSM inits, it starts the ksm kernel
> > thread and it looks like your oops comes from the function that is run
> > in the kernel thread - ksm_scan_thread.
> > 
> > So even if you disable it from sysfs, it runs at least once.
> > 
> 
> Just to confirm, I recompiled 2.6.38.7 without KSM enabled and I've been
> unable to reproduce the bug, so it looks like you were on the money.
> 
> I've moved back to 2.6.38.7 as 2.6.39 has a painful SCSI bug that panics
> about 75% of boots, and the reboot cycle required to get luck my way into a
> working kernel is just too much hassle.
> 
> It would appear that XP zero's its memory space on bootup, so there would be
> lots of pages to merge with a couple of relatively freshly booted XP
> machines running.

Thanks for the Cc, Borislav.

Brad, my suspicion is that in each case the top 16 bits of RDX have been
mysteriously corrupted from ffff to 0000, causing the general protection
faults.  I don't understand what that has to do with KSM.

But it's only a suspicion, because I can't make sense of the "Code:"
lines in your traces, they have more than the expected 64 bytes, and
only one of them has a ">" (with no "<") to mark faulting instruction.

I did try compiling the 2.6.39 kernel from your config, but of course
we have different compilers, so although I got close, it wasn't exact.

Would you mind mailing me privately (it's about 73MB) the "objdump -trd"
output for your original vmlinux (with KSM on)?  (Those -trd options are
the ones I'm used to typing, I bet not they're not all relevant.)

Of course, it's only a tiny fraction of that output that I need,
might be better to cut it down to remove_rmap_item_from_tree and
dup_fd and ksm_scan_thread, if you have the time to do so.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
