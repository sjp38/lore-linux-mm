Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4204B6B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:23:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id f139-v6so1183981oig.15
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 05:23:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c141-v6si1716442oig.338.2018.04.26.05.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 05:23:20 -0700 (PDT)
Date: Thu, 26 Apr 2018 08:23:19 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <732114897.20075296.1524745398991.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180424170239.GP17484@dhcp22.suse.cz>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com> <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com> <20180422125141.GF17484@dhcp22.suse.cz> <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com> <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com> <20180424132057.GE17484@dhcp22.suse.cz> <850575801.19606468.1524588530119.JavaMail.zimbra@redhat.com> <20180424170239.GP17484@dhcp22.suse.cz>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chunyu Hu <chuhu.ncepu@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>



----- Original Message -----
> From: "Michal Hocko" <mhocko@kernel.org>
> To: "Chunyu Hu" <chuhu@redhat.com>
> Cc: "Chunyu Hu" <chuhu.ncepu@gmail.com>, "Dmitry Vyukov" <dvyukov@google.com>, "Catalin Marinas"
> <catalin.marinas@arm.com>, "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
> Sent: Wednesday, April 25, 2018 1:02:39 AM
> Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
> 
> On Tue 24-04-18 12:48:50, Chunyu Hu wrote:
> > 
> > 
> > ----- Original Message -----
> > > From: "Michal Hocko" <mhocko@kernel.org>
> > > To: "Chunyu Hu" <chuhu.ncepu@gmail.com>
> > > Cc: "Dmitry Vyukov" <dvyukov@google.com>, "Catalin Marinas"
> > > <catalin.marinas@arm.com>, "Chunyu Hu"
> > > <chuhu@redhat.com>, "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM"
> > > <linux-mm@kvack.org>
> > > Sent: Tuesday, April 24, 2018 9:20:57 PM
> > > Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
> > > gfp_kmemleak_mask
> > > 
> > > On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
> > > [...]
> > > > So if there is a new flag, it would be the 25th bits.
> > > 
> > > No new flags please. Can you simply store a simple bool into
> > > fail_page_alloc
> > > and have save/restore api for that?
> > 
> > Hi Michal,
> > 
> > I still don't get your point. The original NOFAIL added in kmemleak was
> > for skipping fault injection in page/slab  allocation for kmemleak object,
> > since kmemleak will disable itself until next reboot, whenever it hit an
> > allocation failure, in that case, it will lose effect to check kmemleak
> > in errer path rose by fault injection. But NOFAULT's effect is more than
> > skipping fault injection, it's also for hard allocation. So a dedicated
> > flag
> > for skipping fault injection in specified slab/page allocation was
> > mentioned.
> 
> I am not familiar with the kmemleak all that much, but fiddling with the

kmemleak is using kmem_cache to record every pointers returned from kernel mem 
allocation activities such as kmem_cache_alloc(). every time an object from
slab allocator is returned, a following new kmemleak object is allocated.  

And when a slab object is freed, then the kmemleak object which contains
the ptr will also be freed. 

and kmemleak scan thread will run in period to scan the kernel data, stack, 
and per cpu areas to check that every pointers recorded by kmemleak has at least
one reference in those areas beside the one recorded by kmemleak. If there
is no place in the memory acreas recording the ptr, then it's possible a leak.

so once a kmemleak object allocation failed, it has to disable itself, otherwise
it would lose track of some object pointers, and become less meaningful to 
continue record and scan the kernel memory for the pointers. So disable
it forever. so this is why kmemleak can't tolerate a slab alloc fail (from fault injection)

@Catalin,

Is this right? If something not so correct or precise, please correct me.
I'm thinking about, is it possible that make kmemleak don't disable itself
when fail_page_alloc is enabled?  I can't think clearly what would happen
if several memory allocation missed by kmelkeak trace, what's the bad result? 


> gfp_mask is a wrong way to achieve kmemleak specific action. I might be

As Dmirty explained, this is in fact for fault injection providing a method
to make some debug feature be able to not be injected fault by the 'fault injection'.

Some other features beside kmemleak I can think out is ftrace will also 
hard disable itself when page allocation failed (not sure about slab)

> easilly wrong but I do not see any code that would restore the original
> gfp_mask down the kmem_cache_alloc path.

looks like currently flag __GFP_NOFAIL can go very deep to where before new slab 
needed to be allocated. So what's a pity is when CONFIG_FAIL_PAGE_ALLOC is 
defined, when new slab is created, this flag will be filtered out. So
GFP_NOFAIL currently is used by two meanings, first is allocation 
can't fail, second is meaning not fault injection, but page allocator
don't accept the second meaning. 

So there is a real need for the 'avoid-fault' meaning, though I agree, 
current there is only limited user/market, kmemleak, it just don't have api
to avoid being fault injected. But I think there will be other debug
feature who can be used during fault injection works.

> 
> > d9570ee3bd1d ("kmemleak: allow to coexist with fault injection")

even use GFP_NOFAIL, when new slab needs to be allocated, and when
CONFIG_FAIL_PAGE_ALLOC yes, it still can't avoid hurting by fault injection. 
as GFP_NOFAIL is filtered out in first fast path of allocate_slab.  

> >   
> > Do you mean something like below, with the save/store api? But looks like
> > to make it possible to skip a specified allocation, not global disabling,
> > a bool is not enough, and a gfp_flag is also needed. Maybe I missed
> > something?
> 
> Yes, this is essentially what I meant. It is still a global thing which
> is not all that great and if it matters then you can make it per
> task_struct. That really depends on the code flow here.

Thank you Michal for this suggestion. What I can imagine this  seems would be
very complicated. You know memory allocation is very frequent, and some memory 
allocation can sleep, and some not. Also there are complicated kernel threads.  

If I got your point correctly, a member added in task_struct, then every mem
allocation, needs to touch the member, and needs lock to protect the member.
Also it needs to interact with kmemleak structure. I'm still not very clear and
still thinking about it. @Dmitry know more about this? 


> 
> --
> Michal Hocko
> SUSE Labs
> 

-- 
Regards,
Chunyu Hu
