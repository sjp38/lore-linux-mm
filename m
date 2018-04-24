Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0071A6B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:02:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z7-v6so22473889wrg.11
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 10:02:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g12si740607edm.273.2018.04.24.10.02.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 10:02:42 -0700 (PDT)
Date: Tue, 24 Apr 2018 11:02:39 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
Message-ID: <20180424170239.GP17484@dhcp22.suse.cz>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
 <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
 <20180422125141.GF17484@dhcp22.suse.cz>
 <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
 <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
 <20180424132057.GE17484@dhcp22.suse.cz>
 <850575801.19606468.1524588530119.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <850575801.19606468.1524588530119.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: Chunyu Hu <chuhu.ncepu@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue 24-04-18 12:48:50, Chunyu Hu wrote:
> 
> 
> ----- Original Message -----
> > From: "Michal Hocko" <mhocko@kernel.org>
> > To: "Chunyu Hu" <chuhu.ncepu@gmail.com>
> > Cc: "Dmitry Vyukov" <dvyukov@google.com>, "Catalin Marinas" <catalin.marinas@arm.com>, "Chunyu Hu"
> > <chuhu@redhat.com>, "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
> > Sent: Tuesday, April 24, 2018 9:20:57 PM
> > Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
> > 
> > On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
> > [...]
> > > So if there is a new flag, it would be the 25th bits.
> > 
> > No new flags please. Can you simply store a simple bool into fail_page_alloc
> > and have save/restore api for that?
> 
> Hi Michal,
> 
> I still don't get your point. The original NOFAIL added in kmemleak was 
> for skipping fault injection in page/slab  allocation for kmemleak object, 
> since kmemleak will disable itself until next reboot, whenever it hit an 
> allocation failure, in that case, it will lose effect to check kmemleak 
> in errer path rose by fault injection. But NOFAULT's effect is more than 
> skipping fault injection, it's also for hard allocation. So a dedicated flag
> for skipping fault injection in specified slab/page allocation was mentioned.

I am not familiar with the kmemleak all that much, but fiddling with the
gfp_mask is a wrong way to achieve kmemleak specific action. I might be
easilly wrong but I do not see any code that would restore the original
gfp_mask down the kmem_cache_alloc path.

> d9570ee3bd1d ("kmemleak: allow to coexist with fault injection") 
>   
> Do you mean something like below, with the save/store api? But looks like
> to make it possible to skip a specified allocation, not global disabling,
> a bool is not enough, and a gfp_flag is also needed. Maybe I missed something?

Yes, this is essentially what I meant. It is still a global thing which
is not all that great and if it matters then you can make it per
task_struct. That really depends on the code flow here.

-- 
Michal Hocko
SUSE Labs
