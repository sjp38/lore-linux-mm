Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id F2DA36B0062
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 15:46:47 -0400 (EDT)
Date: Tue, 18 Sep 2012 12:46:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: qemu-kvm loops after kernel udpate
Message-Id: <20120918124646.02aaee4f.akpm@linux-foundation.org>
In-Reply-To: <5058CE2F.7030302@suse.cz>
References: <504F7ED8.1030702@suse.cz>
	<20120911190303.GA3626@amt.cnet>
	<504F93F1.2060005@suse.cz>
	<50504299.2050205@redhat.com>
	<50504439.3050700@suse.cz>
	<5050453B.6040702@redhat.com>
	<5050D048.4010704@suse.cz>
	<5051AE8B.7090904@redhat.com>
	<5058CE2F.7030302@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Avi Kivity <avi@redhat.com>, Jiri Slaby <jirislaby@gmail.com>, Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Haggai Eran <haggaie@mellanox.com>, linux-mm@kvack.org, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>

On Tue, 18 Sep 2012 21:40:31 +0200
Jiri Slaby <jslaby@suse.cz> wrote:

> On 09/13/2012 11:59 AM, Avi Kivity wrote:
> > On 09/12/2012 09:11 PM, Jiri Slaby wrote:
> >> On 09/12/2012 10:18 AM, Avi Kivity wrote:
> >>> On 09/12/2012 11:13 AM, Jiri Slaby wrote:
> >>>>
> >>>>>   Please provide the output of vmxcap
> >>>>> (http://goo.gl/c5lUO),
> >>>>
> >>>>    Unrestricted guest                       no
> >>>
> >>> The big real mode fixes.
> >>>
> >>>
> >>>>
> >>>>> and a snapshot of kvm_stat while the guest is hung.
> >>>>
> >>>> kvm statistics
> >>>>
> >>>>   exits                                      6778198  615942
> >>>>   host_state_reload                             1988     187
> >>>>   irq_exits                                     1523     138
> >>>>   mmu_cache_miss                                   4       0
> >>>>   fpu_reload                                       1       0
> >>>
> >>> Please run this as root so we get the tracepoint based output; and press
> >>> 'x' when it's running so we get more detailed output.
> >>
> >> kvm statistics
> >>
> >>   kvm_exit                                  13798699  330708
> >>   kvm_entry                                 13799110  330708
> >>   kvm_page_fault                            13793650  330604
> >>   kvm_exit(EXCEPTION_NMI)                    6188458  330604
> >>   kvm_exit(EXTERNAL_INTERRUPT)                  2169     105
> >>   kvm_exit(TPR_BELOW_THRESHOLD)                   82       0
> >>   kvm_exit(IO_INSTRUCTION)                         6       0
> >
> > Strange, it's unable to fault in the very first page.
> 
> I bisected that. Note the bisection log. I have never seen something 
> like that :D:
> git bisect start
> git bisect bad 3de9d1a1500472bc80478bd75e33fa9c1eba1422
> git bisect good fea7a08acb13524b47711625eebea40a0ede69a0
> git bisect good 95a2fe4baa1ad444df5f94bfc9416fc6b4b34cef
> git bisect good f42c0d57a5a60da03c705bdea9fbba381112dd60
> git bisect good 31a2e241a9e37a133278959044960c229acc5714
> git bisect good f15fb01c5593fa1b58cc7a8a9c59913e2625bf2e
> git bisect good 16d21ff46f5d50e311d07406c31f96916e5e8e1a
> git bisect good 0b84592f458b4e8567aa7d803aff382c1d3b64fd
> git bisect bad b955428e7f14cd29fe9d8059efa3ea4be679c83d
> git bisect bad 20c4da4f68fcade05eda9c9b7dbad0a78cc5efe8
> git bisect bad 31b90ed2a90f80fb528ac55ee357a815e1dedc36
> git bisect bad b273fe14ee5b38cecc7bce94f7777f35a0bf9ee4
> git bisect bad de426dbe9a60706b91b40397f69f819a39a06b6b
> git bisect bad 6b998094ec50248e72b9f251d0607b58b18dba38
> git bisect bad cf9b81d47a89f5d404a0cd8013b461617751e520
> 
> === 8< ===
> 
> Reverting cf9b81d47a89 (mm: wrap calls to set_pte_at_notify with 
> invalidate_range_start and invalidate_range_end) on the top of today's 
> -next fixes the issue.

hm, thanks.  This will probably take some time to resolve so I think
I'll drop

mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock.patch
mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix.patch
mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock-fix-fix.patch
mm-wrap-calls-to-set_pte_at_notify-with-invalidate_range_start-and-invalidate_range_end.patch
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
