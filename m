Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C220A6B0010
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 19:21:54 -0500 (EST)
Date: Tue, 22 Jan 2013 22:08:20 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 5/5] fix kvm's use of __pa() on percpu areas
Message-ID: <20130123000820.GA27204@amt.cnet>
References: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
 <20130122212435.4905663F@kernel.stglabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130122212435.4905663F@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Rik van Riel <riel@redhat.com>

On Tue, Jan 22, 2013 at 01:24:35PM -0800, Dave Hansen wrote:
> 
> In short, it is illegal to call __pa() on an address holding
> a percpu variable.  This replaces those __pa() calls with
> slow_virt_to_phys().  All of the cases in this patch are
> in boot time (or CPU hotplug time at worst) code, so the
> slow pagetable walking in slow_virt_to_phys() is not expected
> to have a performance impact.
> 
> The times when this actually matters are pretty obscure
> (certain 32-bit NUMA systems), but it _does_ happen.  It is
> important to keep KVM guests working on these systems because
> the real hardware is getting harder and harder to find.
> 
> This bug manifested first by me seeing a plain hang at boot
> after this message:
> 
> 	CPU 0 irqstacks, hard=f3018000 soft=f301a000
> 
> or, sometimes, it would actually make it out to the console:
> 
> [    0.000000] BUG: unable to handle kernel paging request at ffffffff
> 
> I eventually traced it down to the KVM async pagefault code.
> This can be worked around by disabling that code either at
> compile-time, or on the kernel command-line.
> 
> The kvm async pagefault code was injecting page faults in
> to the guest which the guest misinterpreted because its
> "reason" was not being properly sent from the host.
> 
> The guest passes a physical address of an per-cpu async page
> fault structure via an MSR to the host.  Since __pa() is
> broken on percpu data, the physical address it sent was
> bascially bogus and the host went scribbling on random data.
> The guest never saw the real reason for the page fault (it
> was injected by the host), assumed that the kernel had taken
> a _real_ page fault, and panic()'d.  The behavior varied,
> though, depending on what got corrupted by the bad write.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> 
>  linux-2.6.git-dave/arch/x86/kernel/kvm.c      |    9 +++++----
>  linux-2.6.git-dave/arch/x86/kernel/kvmclock.c |    4 ++--
>  2 files changed, 7 insertions(+), 6 deletions(-)
 

Reviewed-by: Marcelo Tosatti <mtosatti@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
