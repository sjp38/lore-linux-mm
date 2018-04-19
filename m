Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1D46B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 06:45:51 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p131-v6so2431178oig.10
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 03:45:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f30-v6si1111216otb.411.2018.04.19.03.45.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 03:45:50 -0700 (PDT)
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
	<alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
	<20180418075051.GO17484@dhcp22.suse.cz>
	<alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
	<20180419063556.GK17484@dhcp22.suse.cz>
In-Reply-To: <20180419063556.GK17484@dhcp22.suse.cz>
Message-Id: <201804191945.BBF87517.FVMLOQFOHSFJOt@I-love.SAKURA.ne.jp>
Date: Thu, 19 Apr 2018 19:45:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> > exit_mmap() does not block before set_bit(MMF_OOM_SKIP) once it is 
> > entered.
> 
> Not true. munlock_vma_pages_all might take page_lock which can have
> unpredictable dependences. This is the reason why we are ruling out
> mlocked VMAs in the first place when reaping the address space.

Wow! Then,

> While you are correct, strictly speaking, because unmap_vmas can race
> with the oom reaper. With the lock held during the whole operation we
> can indeed trigger back off in the oom_repaer. It will keep retrying but
> the tear down can take quite some time. This is a fair argument. On the
> other hand your lock protocol introduces the MMF_OOM_SKIP problem I've
> mentioned above and that really worries me. The primary objective of the
> reaper is to guarantee a forward progress without relying on any
> externalities. We might kill another OOM victim but that is safer than
> lock up.

current code has a possibility that the OOM reaper is disturbed by
unpredictable dependencies, like I worried that

  I think that there is a possibility that the OOM reaper tries to reclaim
  mlocked pages as soon as exit_mmap() cleared VM_LOCKED flag by calling
  munlock_vma_pages_all().

when current approach was proposed. We currently have the MMF_OOM_SKIP problem.
We need to teach the OOM reaper stop reaping as soon as entering exit_mmap().
Maybe let the OOM reaper poll for progress (e.g. none of get_mm_counter(mm, *)
decreased for last 1 second) ?
