Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 505966B0371
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 07:39:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1-v6so9028862eds.15
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 04:39:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r14-v6si3257893edl.68.2018.10.30.04.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 04:39:18 -0700 (PDT)
Date: Tue, 30 Oct 2018 12:39:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 3/3] mm, oom: hand over MMF_OOM_SKIP to exit path
 if it is guranteed to finish
Message-ID: <20181030113915.GB32673@dhcp22.suse.cz>
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181025082403.3806-4-mhocko@kernel.org>
 <201810300445.w9U4jMhu076672@www262.sakura.ne.jp>
 <20181030063136.GU32673@dhcp22.suse.cz>
 <95cb93ec-2421-3c5d-fd1e-91d9696b0f5a@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <95cb93ec-2421-3c5d-fd1e-91d9696b0f5a@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 30-10-18 18:47:43, Tetsuo Handa wrote:
> On 2018/10/30 15:31, Michal Hocko wrote:
> > On Tue 30-10-18 13:45:22, Tetsuo Handa wrote:
> >> Michal Hocko wrote:
> >>> @@ -3156,6 +3166,13 @@ void exit_mmap(struct mm_struct *mm)
> >>>                 vma = remove_vma(vma);
> >>>         }
> >>>         vm_unacct_memory(nr_accounted);
> >>> +
> >>> +       /*
> >>> +        * Now that the full address space is torn down, make sure the
> >>> +        * OOM killer skips over this task
> >>> +        */
> >>> +       if (oom)
> >>> +               set_bit(MMF_OOM_SKIP, &mm->flags);
> >>>  }
> >>>
> >>>  /* Insert vm structure into process list sorted by address
> >>
> >> I don't like setting MMF_OOF_SKIP after remove_vma() loop. 50 users might
> >> call vma->vm_ops->close() from remove_vma(). Some of them are doing fs
> >> writeback, some of them might be doing GFP_KERNEL allocation from
> >> vma->vm_ops->open() with a lock also held by vma->vm_ops->close().
> >>
> >> I don't think that waiting for completion of remove_vma() loop is safe.
> > 
> > What do you mean by 'safe' here?
> > 
> 
> safe = "Does not cause OOM lockup."
> 
> remove_vma() is allowed to sleep, and some users might depend on memory
> allocation when the OOM killer is waiting for remove_vma() to complete.

But MMF_OOF_SKIP is set after we are done with remove_vma. In fact it is
the very last thing in exit_mmap. So I do not follow what you mean.

-- 
Michal Hocko
SUSE Labs
