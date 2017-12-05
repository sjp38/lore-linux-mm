Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0326B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:14:41 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f4so650266wre.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:14:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si813495edo.285.2017.12.05.11.14.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Dec 2017 11:14:39 -0800 (PST)
Date: Tue, 5 Dec 2017 20:14:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_exit
Message-ID: <20171205191410.f2rvaluftnd6dqer@dhcp22.suse.cz>
References: <20171205145853.26614-1-mhocko@kernel.org>
 <CA+55aFw3NKzVO3xivjV1MzFH_wC1-eVAvgkHjpp7T7__CF6+eg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw3NKzVO3xivjV1MzFH_wC1-eVAvgkHjpp7T7__CF6+eg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Minchan Kim <minchan@kernel.org>, Andrea Argangeli <andrea@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 05-12-17 10:31:12, Linus Torvalds wrote:
> On Tue, Dec 5, 2017 at 6:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > This all is nice but tlb_gather users are not aware of that and this can
> > actually cause some real problems. E.g. the oom_reaper tries to reap the
> > whole address space but it might race with threads accessing the memory [1].
> > It is possible that soft-dirty handling might suffer from the same
> > problem [2] as soon as it starts supporting the feature.
> 
> So we fixed the oom reaper to just do proper TLB invalidates in commit
> 687cb0884a71 ("mm, oom_reaper: gather each vma to prevent leaking TLB
> entry").
> 
> So now "fullmm" should be the expected "exit" case, and it all should
> be unambiguous.
> 
> Do we really have any reason to apply this patch any more?

Well, the point was the clarity. The bad behavior came as a surprise for
the oom reaper and as Minchan mentioned we would see a similar problem
with soft-dirty bits as soon as they are supported on arm64 or
potentially other architectures which might do special handling for exit
case.

So strictly speaking, this doesn't fix any known bug to me. But I would
find it more robust if the very special handling was explicit.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
