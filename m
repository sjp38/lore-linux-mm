Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BEBD6B0267
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 10:25:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e3so12716689wme.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:25:06 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id l185si43492935wmf.120.2016.06.01.07.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 07:25:05 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id a136so185192803wme.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:25:04 -0700 (PDT)
Date: Wed, 1 Jun 2016 16:25:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Message-ID: <20160601142502.GY26601@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-5-git-send-email-mhocko@kernel.org>
 <201606012312.BIF26006.MLtFVQSJOHOFOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606012312.BIF26006.MLtFVQSJOHOFOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Wed 01-06-16 23:12:20, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > vforked tasks are not really sitting on any memory. They are sharing
> > the mm with parent until they exec into a new code. Until then it is
> > just pinning the address space. OOM killer will kill the vforked task
> > along with its parent but we still can end up selecting vforked task
> > when the parent wouldn't be selected. E.g. init doing vfork to launch
> > a task or vforked being a child of oom unkillable task with an updated
> > oom_score_adj to be killable.
> > 
> > Make sure to not select vforked task as an oom victim by checking
> > vfork_done in oom_badness.
> 
> While vfork()ed task cannot modify userspace memory, can't such task
> allocate significant amount of kernel memory inside execve() operation
> (as demonstrated by CVE-2010-4243 64bit_dos.c )?
> 
> It is possible that killing vfork()ed task releases a lot of memory,
> isn't it?

I am not familiar with the above CVE but doesn't that allocated memory
come after flush_old_exec (and so mm_release)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
