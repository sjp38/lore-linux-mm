Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 190BC6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 05:50:44 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x134-v6so12435024oif.19
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 02:50:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f15-v6si4899883otj.28.2018.04.25.02.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 02:50:42 -0700 (PDT)
Date: Wed, 25 Apr 2018 05:50:41 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <482146467.19754107.1524649841393.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180424134148.qkvqqa4c37l6irvg@armageddon.cambridge.arm.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com> <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com> <20180422125141.GF17484@dhcp22.suse.cz> <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com> <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com> <20180424132057.GE17484@dhcp22.suse.cz> <20180424134148.qkvqqa4c37l6irvg@armageddon.cambridge.arm.com>
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
> From: "Catalin Marinas" <catalin.marinas@arm.com>
> To: "Michal Hocko" <mhocko@kernel.org>
> Cc: "Chunyu Hu" <chuhu.ncepu@gmail.com>, "Dmitry Vyukov" <dvyukov@google.com>, "Chunyu Hu" <chuhu@redhat.com>, "LKML"
> <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
> Sent: Tuesday, April 24, 2018 9:41:48 PM
> Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
> 
> On Tue, Apr 24, 2018 at 07:20:57AM -0600, Michal Hocko wrote:
> > On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
> > [...]
> > > So if there is a new flag, it would be the 25th bits.
> > 
> > No new flags please. Can you simply store a simple bool into
> > fail_page_alloc
> > and have save/restore api for that?
> 
> For kmemleak, we probably first hit failslab. Something like below may
> do the trick:
> 
> diff --git a/mm/failslab.c b/mm/failslab.c
> index 1f2f248e3601..63f13da5cb47 100644
> --- a/mm/failslab.c
> +++ b/mm/failslab.c
> @@ -29,6 +29,9 @@ bool __should_failslab(struct kmem_cache *s, gfp_t
> gfpflags)
>  	if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
>  		return false;
>  
> +	if (s->flags & SLAB_NOLEAKTRACE)
> +		return false;
> +
>  	return should_fail(&failslab.attr, s->object_size);
>  }

This maybe is the easy enough way for skipping fault injection for kmemleak slab object. 
 
>  
> 
> Can we get a second should_fail() via should_fail_alloc_page() if a new
> slab page is allocated?

looking at code path blow, what do you mean by getting a second should_fail() via
fail_alloc_page?  Seems we need to insert the flag between alloc_slab_page and 
alloc_pages()? Without GFP flag, it's difficult to pass info to should_fail_alloc_page
and keep simple at same time. 

Or as Michal suggested, completely disabling page alloc fail injection when kmemleak
enabled. And enable it again when kmemleak off. 

 alloc_slab_page   
          <========= flag to change the behavior of should_fail_alloc_page
     alloc_pages
         alloc_pages_current
             __alloc_pages_nodemask
                 prepare_alloc_pages
                     should_fail_alloc_page

> 
> --
> Catalin
> 

-- 
Regards,
Chunyu Hu
