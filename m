Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28A8E6B0033
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 05:08:05 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so12046386wre.9
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 02:08:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x20si6623497wmc.1.2017.12.12.02.07.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Dec 2017 02:07:59 -0800 (PST)
Date: Tue, 12 Dec 2017 11:07:57 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: use ALLOC_OOM for OOM victim's last second
 allocation
Message-ID: <20171212100757.GB11108@dhcp22.suse.cz>
References: <20171207115127.GH20234@dhcp22.suse.cz>
 <201712072059.HAJ04643.QSJtVMFLFOOOHF@I-love.SAKURA.ne.jp>
 <20171207122249.GI20234@dhcp22.suse.cz>
 <201712081958.EBB43715.FOVJQFtFLOMOSH@I-love.SAKURA.ne.jp>
 <20171211114229.GA4779@dhcp22.suse.cz>
 <201712121709.CCD95874.OHLOFQFFMVJOtS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712121709.CCD95874.OHLOFQFFMVJOtS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

On Tue 12-12-17 17:09:36, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > That being said, I will keep refusing other such tweaks unless you have
> > a sound usecase behind. If you really _want_ to help out here then you
> > can focus on the reaping of the mlock memory.
> 
> Not the reaping of the mlock'ed memory. Although Manish's report was mlock'ed
> case, there are other cases (e.g. MAP_SHARED, mmu_notifier, mmap_sem held for
> write) which can lead to this race condition.

Could you actually start thinking in a bigger picture rather than
obsessively check the code? If MAP_SHARED is file backed then it should
be reclaimable. If it is memory backed then we are screwed with
insufficient sized swap partition. I've seen that David is already
looking at the mmu_notifier. Well and the mmap_sem, sure that can happen
but as long we do not see excessive OOM events out there I would rather
leave it alone.

> If we think about artificial case,
> it would be possible to run 1024 threads not sharing signal_struct but consume
> almost 0KB memory (i.e. written without using C library) and many of them are
> running between __gfp_pfmemalloc_flags() and mutex_trylock() waiting for
> ALLOC_OOM.

Sigh... Nobody is arguing that the race is impossible. Just read what
I've wrote. I recognize the race but I am not willing to add kludges
into an already complicated code if it doesn't matter _practically_.
A malicious user can DOS the system by other means and you have to
configure your system carefully to prevent from that.

So all I care about is to see whether these races happen out there in
natural workloads and then we can more heuristics.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
