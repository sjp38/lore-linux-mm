Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 05B216B0032
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:05:28 -0400 (EDT)
Received: by wgme6 with SMTP id e6so43228430wgm.2
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:05:27 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id qr7si5958042wic.24.2015.05.28.11.05.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:05:26 -0700 (PDT)
Received: by wizo1 with SMTP id o1so72407956wiz.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:05:26 -0700 (PDT)
Date: Thu, 28 May 2015 20:05:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150528180524.GB2321@dhcp22.suse.cz>
References: <201505252333.FJG56590.OOFSHQMOJtFFVL@I-love.SAKURA.ne.jp>
 <20150526170213.GB14955@dhcp22.suse.cz>
 <201505270639.JCF57366.OFVOQSFFHtJOML@I-love.SAKURA.ne.jp>
 <20150527164505.GD27348@dhcp22.suse.cz>
 <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Thu 28-05-15 06:59:32, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 27-05-15 06:39:42, Tetsuo Handa wrote:
[...]
> > > I don't think this is good, for this will omit sending SIGKILL to threads
> > > sharing p->mm ("Kill all user processes sharing victim->mm in other thread
> > > groups, if any.")
> > 
> > threads? The whole thread group will die when the fatal signal is
> > send to the group leader no? This mm sharing handling is about
> > processes which are sharing mm but they are not in the same thread group
> 
> OK. I should say "omit sending SIGKILL to processes which are sharing mm
> but they are not in the same thread group".
> 
> > (aka CLONE_VM without CLONE_SIGHAND resp. CLONE_THREAD).
> 
> clone(CLONE_SIGHAND | CLONE_VM) ?

no I meant clone(CLONE_VM | flags) where flags doesn't contain neither
CLONE_SIGHAND nor CLONE_THREAD.

[...]

> I just imagined a case where p is blocked at down_read() in acct_collect() from
> do_exit() when p is sharing mm with other processes, and other process is doing
> blocking operation with mm->mmap_sem held for writing. Is such case impossible?

It is very much possible and I have missed this case when proposing
my alternative. The other process could be doing an address space
operation e.g. mmap which requires an allocation.

We do not handle this case properly because we are doing this before
even going to select a victim.
        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                goto out;
        }

I have to think some more about a potential fix...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
