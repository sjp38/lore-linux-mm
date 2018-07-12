Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 948DD6B0269
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 04:15:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l1-v6so2967373edi.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 01:15:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r26-v6si6808248edm.42.2018.07.12.01.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 01:15:25 -0700 (PDT)
Date: Thu, 12 Jul 2018 10:15:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-ID: <20180712081524.GE32648@dhcp22.suse.cz>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711103312.GH20050@dhcp22.suse.cz>
 <20180711154954.afe001e284574cd5d4c3ec89@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180711154954.afe001e284574cd5d4c3ec89@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-07-18 15:49:54, Andrew Morton wrote:
> On Wed, 11 Jul 2018 12:33:12 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > > Approach:
> > > Zapping pages is the most time consuming part, according to the suggestion from
> > > Michal Hocko [1], zapping pages can be done with holding read mmap_sem, like
> > > what MADV_DONTNEED does. Then re-acquire write mmap_sem to cleanup vmas.
> > > 
> > > But, we can't call MADV_DONTNEED directly, since there are two major drawbacks:
> > >   * The unexpected state from PF if it wins the race in the middle of munmap.
> > >     It may return zero page, instead of the content or SIGSEGV.
> > >   * Cana??t handle VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe mappings, which
> > >     is a showstopper from akpm
> > 
> > I do not really understand why this is a showstopper. This is a mere
> > optimization. VM_LOCKED ranges are usually not that large. VM_HUGETLB
> > can be quite large alright but this should be doable on top. Is there
> > any reason to block any "cover most mappings first" patch?
> 
> Somebody somewhere is going to want to unmap vast mlocked regions and
> they're going to report softlockup warnings. So we shouldn't implement
> something which can't address these cases.  Maybe it doesn't do so in
> the first version, but we should at least have a plan to handle all
> cases.

Absolutely. I was just responding to the "showstopper" part. This is
improving some cases but it shouldn't make others worse so going
incremental should be perfectly reasonable.
-- 
Michal Hocko
SUSE Labs
