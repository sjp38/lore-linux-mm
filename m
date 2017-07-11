Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B33896B04CD
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 20:01:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c23so129282536pfe.11
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 17:01:04 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id k69si8950415pfa.293.2017.07.10.17.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 17:01:03 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id t186so57414321pgb.1
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 17:01:03 -0700 (PDT)
Date: Mon, 10 Jul 2017 17:01:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
In-Reply-To: <201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1707101659080.55253@chino.kir.corp.google.com>
References: <20170626130346.26314-1-mhocko@kernel.org> <201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Tue, 27 Jun 2017, Tetsuo Handa wrote:

> I wonder why you prefer timeout based approach. Your patch will after all
> set MMF_OOM_SKIP if operations between down_write() and up_write() took
> more than one second. lock_anon_vma_root() from unlink_anon_vmas() from
> free_pgtables() for example calls down_write()/up_write(). unlink_file_vma()
>  from free_pgtables() for another example calls down_write()/up_write().
> This means that it might happen that exit_mmap() takes more than one second
> with mm->mmap_sem held for write, doesn't this?
> 

I certainly have no objection to increasing the timeout period or 
increasing MAX_OOM_REAP_RETRIES to be substantially higher.  All threads 
holding mm->mmap_sem should be oom killed and be able to access memory 
reserves to make forward progress if they fail to reclaim.  If we are 
truly blocked on mm->mmap_sem, waiting longer than one second to declare 
that seems justifiable to prevent the exact situation you describe.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
