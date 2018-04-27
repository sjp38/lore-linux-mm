Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1E336B0007
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 06:17:14 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id y49-v6so898329oti.11
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 03:17:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z47-v6si397611otz.421.2018.04.27.03.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 03:17:13 -0700 (PDT)
Date: Fri, 27 Apr 2018 06:17:12 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <1591480647.20311538.1524824232546.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180426125634.uybpbbk5puee7fsg@armageddon.cambridge.arm.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com> <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com> <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com> <20180424132057.GE17484@dhcp22.suse.cz> <850575801.19606468.1524588530119.JavaMail.zimbra@redhat.com> <20180424170239.GP17484@dhcp22.suse.cz> <732114897.20075296.1524745398991.JavaMail.zimbra@redhat.com> <20180426125634.uybpbbk5puee7fsg@armageddon.cambridge.arm.com>
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
> To: "Chunyu Hu" <chuhu@redhat.com>
> Cc: "Michal Hocko" <mhocko@kernel.org>, "Chunyu Hu" <chuhu.ncepu@gmail.com>, "Dmitry Vyukov" <dvyukov@google.com>,
> "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
> Sent: Thursday, April 26, 2018 8:56:35 PM
> Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
> 
> On Thu, Apr 26, 2018 at 08:23:19AM -0400, Chunyu Hu wrote:
> > kmemleak is using kmem_cache to record every pointers returned from kernel
> > mem
> > allocation activities such as kmem_cache_alloc(). every time an object from
> > slab allocator is returned, a following new kmemleak object is allocated.
> > 
> > And when a slab object is freed, then the kmemleak object which contains
> > the ptr will also be freed.
> > 
> > and kmemleak scan thread will run in period to scan the kernel data, stack,
> > and per cpu areas to check that every pointers recorded by kmemleak has at
> > least
> > one reference in those areas beside the one recorded by kmemleak. If there
> > is no place in the memory acreas recording the ptr, then it's possible a
> > leak.
> > 
> > so once a kmemleak object allocation failed, it has to disable itself,
> > otherwise
> > it would lose track of some object pointers, and become less meaningful to
> > continue record and scan the kernel memory for the pointers. So disable
> > it forever. so this is why kmemleak can't tolerate a slab alloc fail (from
> > fault injection)
> > 
> > @Catalin,
> > 
> > Is this right? If something not so correct or precise, please correct me.
> 
> That's a good description, thanks.
> 
> > I'm thinking about, is it possible that make kmemleak don't disable itself
> > when fail_page_alloc is enabled?  I can't think clearly what would happen
> > if several memory allocation missed by kmelkeak trace, what's the bad
> > result?
> 
> Take for example a long linked list. If kmemleak doesn't track an object
> in such list (because the metadata allocation failed), such list_head is
> never scanned and the subsequent objects in the list (pointed at by
> 'next') will be reported as leaks. Kmemleak pretty much becomes unusable
> with a high number of false positives.

Thanks for the example, one object may contain many pointers, so loose one,
means many false reports. I'm clear now. 

> 
> --
> Catalin
> 

-- 
Regards,
Chunyu Hu
