Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACF46B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:08:26 -0500 (EST)
Received: by padhx2 with SMTP id hx2so197812856pad.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:08:26 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id v13si12283481pas.84.2015.11.30.14.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 14:08:25 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so197825946pac.3
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:08:25 -0800 (PST)
Date: Mon, 30 Nov 2015 14:08:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] bugfix oom kill init lead panic
In-Reply-To: <565BC23F.6070302@huawei.com>
Message-ID: <alpine.DEB.2.10.1511301407080.10460@chino.kir.corp.google.com>
References: <1448880869-20506-1-git-send-email-chenjie6@huawei.com> <20151129190802.dc66cf35.akpm@linux-foundation.org> <565BC23F.6070302@huawei.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-637148115-1448921304=:10460"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chenjie (K)" <chenjie6@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, lizefan@huawei.com, stable@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-637148115-1448921304=:10460
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Mon, 30 Nov 2015, Chenjie (K) wrote:

> My kernel version is 3.10 ,but the 4.3 is the same
> and the newest code is
> 
> 	for_each_process(p) {
> 		if (!process_shares_mm(p, mm))
> 			continue;
> 		if (same_thread_group(p, victim))
> 			continue;
> 		if (unlikely(p->flags & PF_KTHREAD))
> 			continue;
> 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> 			continue;
> 
> so this not add the i 1/4 ?is_global_init also.
> 
> when we vfork (CLONE_VM) a process,the copy_mm
> 	if (clone_flags & CLONE_VM) {
> 		atomic_inc(&oldmm->mm_users);
> 		mm = oldmm;
> 		goto good_mm;
> 	}
> use the parent mm.
> 

I think it might be a legitimate fix, but if the oom killer is killing pid 
9134 in your log then I assume the next call to the oom killer will panic 
the system anyway unless there is actually a process using less memory 
that can be killed.  Would you mind enabling vm.oom_dump_tasks (it should 
default to enabled) and post the entire oom killer log?
--397176738-637148115-1448921304=:10460--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
