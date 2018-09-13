Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D1C998E0002
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 09:40:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z56-v6so2433531edz.10
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 06:40:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z15-v6si3232695edr.81.2018.09.13.06.40.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 06:40:34 -0700 (PDT)
Date: Thu, 13 Sep 2018 15:40:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
Message-ID: <20180913134032.GF20287@dhcp22.suse.cz>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
 <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
 <20180913090950.GD20287@dhcp22.suse.cz>
 <c70a8b7c-d1d2-66de-d87e-13a4a410335b@i-love.sakura.ne.jp>
 <20180913113538.GE20287@dhcp22.suse.cz>
 <0897639b-a1d9-2da1-0a1e-a3eeed799a0f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0897639b-a1d9-2da1-0a1e-a3eeed799a0f@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu 13-09-18 20:53:24, Tetsuo Handa wrote:
> On 2018/09/13 20:35, Michal Hocko wrote:
> >> Next question.
> >>
> >>         /* Use -1 here to ensure all VMAs in the mm are unmapped */
> >>         unmap_vmas(&tlb, vma, 0, -1);
> >>
> >> in exit_mmap() will now race with the OOM reaper. And unmap_vmas() will handle
> >> VM_HUGETLB or VM_PFNMAP or VM_SHARED or !vma_is_anonymous() vmas, won't it?
> >> Then, is it guaranteed to be safe if the OOM reaper raced with unmap_vmas() ?
> > 
> > I do not understand the question. unmap_vmas is basically MADV_DONTNEED
> > and that doesn't require the exclusive mmap_sem lock so yes it should be
> > safe those two to race (modulo bugs of course but I am not aware of any
> > there).
> >  
> 
> You need to verify that races we observed with VM_LOCKED can't happen
> for VM_HUGETLB / VM_PFNMAP / VM_SHARED / !vma_is_anonymous() cases.

Well, VM_LOCKED is kind of special because that is not a permanent state
which might change. VM_HUGETLB, VM_PFNMAP resp VM_SHARED are not changed
throughout the vma lifetime.
-- 
Michal Hocko
SUSE Labs
