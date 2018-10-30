Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 573076B04CA
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:31:40 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c6-v6so8466689pls.15
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 23:31:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 202-v6si22937025pgb.63.2018.10.29.23.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 23:31:39 -0700 (PDT)
Date: Tue, 30 Oct 2018 07:31:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 3/3] mm, oom: hand over MMF_OOM_SKIP to exit path
 if it is guranteed to finish
Message-ID: <20181030063136.GU32673@dhcp22.suse.cz>
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181025082403.3806-4-mhocko@kernel.org>
 <201810300445.w9U4jMhu076672@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201810300445.w9U4jMhu076672@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 30-10-18 13:45:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > @@ -3156,6 +3166,13 @@ void exit_mmap(struct mm_struct *mm)
> >                 vma = remove_vma(vma);
> >         }
> >         vm_unacct_memory(nr_accounted);
> > +
> > +       /*
> > +        * Now that the full address space is torn down, make sure the
> > +        * OOM killer skips over this task
> > +        */
> > +       if (oom)
> > +               set_bit(MMF_OOM_SKIP, &mm->flags);
> >  }
> > 
> >  /* Insert vm structure into process list sorted by address
> 
> I don't like setting MMF_OOF_SKIP after remove_vma() loop. 50 users might
> call vma->vm_ops->close() from remove_vma(). Some of them are doing fs
> writeback, some of them might be doing GFP_KERNEL allocation from
> vma->vm_ops->open() with a lock also held by vma->vm_ops->close().
> 
> I don't think that waiting for completion of remove_vma() loop is safe.

What do you mean by 'safe' here?
-- 
Michal Hocko
SUSE Labs
