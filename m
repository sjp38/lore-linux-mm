Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56A436B0005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:56:42 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id 36-v6so4442433oth.17
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 05:56:42 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l74-v6si7196284otl.102.2018.04.26.05.56.39
        for <linux-mm@kvack.org>;
        Thu, 26 Apr 2018 05:56:39 -0700 (PDT)
Date: Thu, 26 Apr 2018 13:56:35 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
Message-ID: <20180426125634.uybpbbk5puee7fsg@armageddon.cambridge.arm.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
 <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
 <20180422125141.GF17484@dhcp22.suse.cz>
 <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
 <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
 <20180424132057.GE17484@dhcp22.suse.cz>
 <850575801.19606468.1524588530119.JavaMail.zimbra@redhat.com>
 <20180424170239.GP17484@dhcp22.suse.cz>
 <732114897.20075296.1524745398991.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <732114897.20075296.1524745398991.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Chunyu Hu <chuhu.ncepu@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Apr 26, 2018 at 08:23:19AM -0400, Chunyu Hu wrote:
> kmemleak is using kmem_cache to record every pointers returned from kernel mem 
> allocation activities such as kmem_cache_alloc(). every time an object from
> slab allocator is returned, a following new kmemleak object is allocated.  
> 
> And when a slab object is freed, then the kmemleak object which contains
> the ptr will also be freed. 
> 
> and kmemleak scan thread will run in period to scan the kernel data, stack, 
> and per cpu areas to check that every pointers recorded by kmemleak has at least
> one reference in those areas beside the one recorded by kmemleak. If there
> is no place in the memory acreas recording the ptr, then it's possible a leak.
> 
> so once a kmemleak object allocation failed, it has to disable itself, otherwise
> it would lose track of some object pointers, and become less meaningful to 
> continue record and scan the kernel memory for the pointers. So disable
> it forever. so this is why kmemleak can't tolerate a slab alloc fail (from fault injection)
> 
> @Catalin,
> 
> Is this right? If something not so correct or precise, please correct me.

That's a good description, thanks.

> I'm thinking about, is it possible that make kmemleak don't disable itself
> when fail_page_alloc is enabled?  I can't think clearly what would happen
> if several memory allocation missed by kmelkeak trace, what's the bad result? 

Take for example a long linked list. If kmemleak doesn't track an object
in such list (because the metadata allocation failed), such list_head is
never scanned and the subsequent objects in the list (pointed at by
'next') will be reported as leaks. Kmemleak pretty much becomes unusable
with a high number of false positives.

-- 
Catalin
