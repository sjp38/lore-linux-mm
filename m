Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4D06B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 06:13:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j19-v6so757817oii.11
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 03:13:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e64-v6si386201ote.244.2018.04.27.03.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 03:13:19 -0700 (PDT)
Date: Fri, 27 Apr 2018 06:13:18 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <503481697.20310393.1524823998160.JavaMail.zimbra@redhat.com>
In-Reply-To: <978702110.19841228.1524666829157.JavaMail.zimbra@redhat.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com> <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com> <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com> <20180424132057.GE17484@dhcp22.suse.cz> <20180424134148.qkvqqa4c37l6irvg@armageddon.cambridge.arm.com> <482146467.19754107.1524649841393.JavaMail.zimbra@redhat.com> <20180425125154.GA29722@MBP.local> <978702110.19841228.1524666829157.JavaMail.zimbra@redhat.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Chunyu Hu <chuhu.ncepu@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>



----- Original Message -----
> From: "Chunyu Hu" <chuhu@redhat.com>
> To: "Catalin Marinas" <catalin.marinas@arm.com>
> Cc: "Michal Hocko" <mhocko@kernel.org>, "Chunyu Hu" <chuhu.ncepu@gmail.com>, "Dmitry Vyukov" <dvyukov@google.com>,
> "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
> Sent: Wednesday, April 25, 2018 10:33:49 PM
> Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
> 
> 
> 
> ----- Original Message -----
> > From: "Catalin Marinas" <catalin.marinas@arm.com>
> > To: "Chunyu Hu" <chuhu@redhat.com>
> > Cc: "Michal Hocko" <mhocko@kernel.org>, "Chunyu Hu"
> > <chuhu.ncepu@gmail.com>, "Dmitry Vyukov" <dvyukov@google.com>,
> > "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
> > Sent: Wednesday, April 25, 2018 8:51:55 PM
> > Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
> > gfp_kmemleak_mask
> > 
> > On Wed, Apr 25, 2018 at 05:50:41AM -0400, Chunyu Hu wrote:
> > > ----- Original Message -----
> > > > From: "Catalin Marinas" <catalin.marinas@arm.com>
> > > > On Tue, Apr 24, 2018 at 07:20:57AM -0600, Michal Hocko wrote:
> > > > > On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
> > > > > [...]
> > > > > > So if there is a new flag, it would be the 25th bits.
> > > > > 
> > > > > No new flags please. Can you simply store a simple bool into
> > > > > fail_page_alloc
> > > > > and have save/restore api for that?
> > > > 
> > > > For kmemleak, we probably first hit failslab. Something like below may
> > > > do the trick:
> > > > 
> > > > diff --git a/mm/failslab.c b/mm/failslab.c
> > > > index 1f2f248e3601..63f13da5cb47 100644
> > > > --- a/mm/failslab.c
> > > > +++ b/mm/failslab.c
> > > > @@ -29,6 +29,9 @@ bool __should_failslab(struct kmem_cache *s, gfp_t
> > > > gfpflags)
> > > >  	if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
> > > >  		return false;
> > > >  
> > > > +	if (s->flags & SLAB_NOLEAKTRACE)
> > > > +		return false;
> > > > +
> > > >  	return should_fail(&failslab.attr, s->object_size);
> > > >  }

Looks like if just for this slab fault inject issue, and when fail page
alloc is not enabled, this should be enough to make the warning go away.

And for page allocate fail part,  per task handling is an option way, without
introducing GFP new flag for fault injection. 

> > > 
> > > This maybe is the easy enough way for skipping fault injection for
> > > kmemleak slab object.
> > 
> > This was added to avoid kmemleak tracing itself, so could be used for
> > other kmemleak-related cases.
> > 
> > > > Can we get a second should_fail() via should_fail_alloc_page() if a new
> > > > slab page is allocated?
> > > 
> > > looking at code path below, what do you mean by getting a second
> > > should_fail() via fail_alloc_page?
> > 
> > Kmemleak calls kmem_cache_alloc() on a cache with SLAB_LEAKNOTRACE, so the
> > first point of failure injection is __should_failslab() which we can
> > handle with the slab flag. The slab allocator itself ends up calling
> > alloc_pages() to allocate a slab page (and __GFP_NOFAIL is explicitly
> > cleared). Here we have the second potential failure injection via
> 
> Indeed.
> 
> > fail_alloc_page(). That's unless the order < fail_page_alloc.min_order
> > which I think is the default case (min_order = 1 while the slab page
> > allocation for kmemleak would need an order of 0. It's not ideal but we
> > may get away with it.
> 
> In my workstation, I checked the value shown is order=2
> 
> [mm]# cat /sys/kernel/slab/kmemleak_object/order
> 2
> [mm]# uname -r
> 4.17.0-rc1.syzcaller+
> 
> 
> If order is 2, then not into the branch, no false is returned, so not
> skipped..
> static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
> {
>     if (order < fail_page_alloc.min_order)
>         return false;
> 
> 
> > 
> > > Seems we need to insert the flag between alloc_slab_page and
> > > alloc_pages()? Without GFP flag, it's difficult to pass info to
> > > should_fail_alloc_page and keep simple at same time.
> > 
> > Indeed.
> > 
> > > Or as Michal suggested, completely disabling page alloc fail injection
> > > when kmemleak enabled. And enable it again when kmemleak off.
> > 
> > Dmitry's point was that kmemleak is still useful to detect leaks on the
> > error path where errors are actually introduced by the fault injection.
> > Kmemleak cannot cope with allocation failures as it needs a pretty
> > precise tracking of the allocated objects.
> 
> understand.
> 
> > 
> > An alternative could be to not free the early_log buffer in kmemleak and
> > use that memory in an emergency when allocation fails (though I don't
> > particularly like this).

This is still an option. 

> > 
> > Yet another option is to use NOFAIL and remove NORETRY in kmemleak when
> > fault injection is enabled.
> 
> I'm going to have a try this way to see if any warning can be seen when
> running.
> This should be the best if it works fine.

NOFAIL has a strict requirement that it must direct_reclaimable, otherwise, the
warning still will be seen, though 'use NOFAIL and remove NORETRY' as you
suggested.  so this is not an option.

mm/page_alloc.c
4256     if (gfp_mask & __GFP_NOFAIL) {                                                                                                                                      
4257         /*
4258          * All existing users of the __GFP_NOFAIL are blockable, so warn
4259          * of any new users that actually require GFP_NOWAIT
4260          */
4261         if (WARN_ON_ONCE(!can_direct_reclaim))
4262             goto fail;

So I also tried to add DIRECT_RECLAIM and NOFAIL together, and no  doubt, it will
sleep in irq, so don't work.

[  168.802049] BUG: sleeping function called from invalid context at mm/slab.h:421
[  168.802937] in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper/2
[  168.803701] INFO: lockdep is turned off.
[  168.804162] Preemption disabled at:
[  168.804171] [<ffffffff8111ee71>] start_secondary+0x141/0x5f0
[  168.805259] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G        W         4.17.0-rc2.syzcaller+ #18
[  168.806267] Hardware name: Red Hat KVM, BIOS 0.0.0 02/06/2015
[  168.806928] Call Trace:
[  168.807211]  <IRQ>
[  168.807456]  dump_stack+0x11b/0x1be
[  168.807854]  ? show_regs_print_info+0x12/0x12
[  168.808347]  ? start_secondary+0x141/0x5f0
[  168.808845]  ? create_object+0xa6/0xaf0
[  168.809284]  ___might_sleep+0x3a6/0x5d0
[  168.809732]  kmem_cache_alloc+0x2d0/0x580
[  168.810186]  ? update_sd_lb_stats+0x3080/0x3080
[  168.810727]  ? __netif_receive_skb_core+0x15a3/0x3400
[  168.811293]  ? __build_skb+0x86/0x3b0
[  168.811698]  create_object+0xa6/0xaf0



> 
> > 
> > --
> > Catalin
> > 
> 
> --
> Regards,
> Chunyu Hu
> 
> 

-- 
Regards,
Chunyu Hu
