Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DAF36B0007
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:49:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g5-v6so1461150pgv.12
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:49:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v2-v6si20068980plg.12.2018.07.11.15.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 15:49:55 -0700 (PDT)
Date: Wed, 11 Jul 2018 15:49:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-Id: <20180711154954.afe001e284574cd5d4c3ec89@linux-foundation.org>
In-Reply-To: <20180711103312.GH20050@dhcp22.suse.cz>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
	<20180711103312.GH20050@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 11 Jul 2018 12:33:12 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > Approach:
> > Zapping pages is the most time consuming part, according to the suggestion from
> > Michal Hocko [1], zapping pages can be done with holding read mmap_sem, like
> > what MADV_DONTNEED does. Then re-acquire write mmap_sem to cleanup vmas.
> > 
> > But, we can't call MADV_DONTNEED directly, since there are two major drawbacks:
> >   * The unexpected state from PF if it wins the race in the middle of munmap.
> >     It may return zero page, instead of the content or SIGSEGV.
> >   * Cana??t handle VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe mappings, which
> >     is a showstopper from akpm
> 
> I do not really understand why this is a showstopper. This is a mere
> optimization. VM_LOCKED ranges are usually not that large. VM_HUGETLB
> can be quite large alright but this should be doable on top. Is there
> any reason to block any "cover most mappings first" patch?

Somebody somewhere is going to want to unmap vast mlocked regions and
they're going to report softlockup warnings.  So we shouldn't implement
something which can't address these cases.  Maybe it doesn't do so in
the first version, but we should at least have a plan to handle all
cases.
