Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 04F8E620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 22:29:09 -0500 (EST)
Received: by ywh3 with SMTP id 3so8066088ywh.22
        for <linux-mm@kvack.org>; Wed, 23 Dec 2009 19:29:08 -0800 (PST)
Message-ID: <4B32DF97.5060400@vflare.org>
Date: Thu, 24 Dec 2009 08:57:19 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: Tmem [PATCH 0/5] (Take 3): Transcendent memory
References: <ff435130-98a2-417c-8109-9dd029022a91@default>
In-Reply-To: <ff435130-98a2-417c-8109-9dd029022a91@default>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Dan,

On 12/23/2009 10:45 PM, Dan Magenheimer wrote:

 
> I'm definitely OK with exploring alternatives.  I just think that
> existing kernel mechanisms are very firmly rooted in the notion
> that either the kernel owns the memory/cache or an asynchronous
> device owns it.  Tmem falls somewhere in between and is very
> carefully designed to maximize memory flexibility *outside* of
> the kernel -- across all guests in a virtualized environment --
> with minimal impact to the kernel, while still providing the
> kernel with the ability to use -- but not own, directly address,
> or control -- additional memory when conditions allow.  And
> these conditions are not only completely invisible to the kernel,
> but change frequently and asynchronously from the kernel,
> unlike most external devices for which the kernel can "reserve"
> space and use it asynchronously later.
> 
> Maybe ramzswap and FS-cache could be augmented to have similar
> advantages in a virtualized environment, but I suspect they'd
> end up with something very similar to tmem.  Since the objective
> of both is to optimize memory that IS owned (used, directly
> addressable, and controlled) by the kernel, they are entirely
> complementary with tmem.
> 

What we want is surely tmem but attempt is to better integrate with
existing infrastructure. Please give me few days as I try to develop
a prototype.

>> Swapping to hypervisor is mainly useful to overcome
>> 'static partitioning' problem you mentioned in article:
>> http://oss.oracle.com/projects/tmem/
>> ...such 'para-swap' can shrink/expand outside of VM constraints.
> 
> Frontswap is very different than "hypervisor swapping" as what's
> done by VMware as a side-effect of transparent page-sharing.  With
> frontswap, the kernel still decides which pages are swapped out.
> If frontswap says there is space, the swap goes "fast" to tmem;
> if not, the kernel writes it to its own swapdisk.  So there's
> no "double paging" or random page selection/swapping.  On
> the downside, kernels must have real swap configured and,
> to avoid DoS issues, frontswap is limited by the same constraint
> as ballooning (ie. can NOT expand outside of VM constraints).
> 

I think I did not explain my point regarding "para-swap" correctly.
What I meant was a virtual swap device which appears as swap disk
to kernel. Kernel swaps to this disk as usual (hence the kernel decides
what pages to swap out). This device tries to send these pages to hvisor
but if that fails, it will fall back to swapping inside guest only. There
is no double swapping. I think this correctly explains purpose of Frontswap.

>> ...such 'para-swap' can shrink/expand outside of VM constraints.
<snip>
> frontswap is limited by the same constraint
> as ballooning (ie. can NOT expand outside of VM constraints).
> 

What I meant was: A VM can have 512M of memory while this "para swap" disk
can have any size, say 1G. Now kernel can swapout 1G worth of data to this
swap which can (potentially) send all these pages to hvisor. In future, if
we want even more RAM for this VM, we can add another such swap device to guest.
Thus, in a way, we are able to overcome rigid static partitioning of VMs w.r.t.
memory resource.


> 
> P.S.  If you want to look at implementing FS-cache or ramzswap
> on top of tmem, I'd be happy to help, but I'll bet your concern:
> 
>> we might later encounter some hidder/dangerous problems :)
> 
> will prove to be correct.
> 

Please allow me few days to experiment with 'virtswap' which will
be virtualization aware ramzswap driver. This will help us understand
problems we might face with such an approach. I am new to this virtio thing,
so it might take some time.

If we find virtswap to be feasible with virtio, we can go for fs-cache
backend we talked about.


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
