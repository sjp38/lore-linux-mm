Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39F86C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:44:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF57120856
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:44:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF57120856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75C3A6B0003; Mon,  5 Aug 2019 07:44:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E5AF6B0005; Mon,  5 Aug 2019 07:44:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AD346B0006; Mon,  5 Aug 2019 07:44:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 015C86B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 07:44:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so51357971edx.12
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 04:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RXJKfgFQf/YyXXWdja9VDU70ZZPa5lpupVYXrJjQgAI=;
        b=mN2bKkfiFWZI5SQqQNGJVi0gzDuKQbNtnNB+DaC5o+oIuA16IjKfvyEoObifKRZFWQ
         RW0pWn6woeJLn2HZU311WznqEWkPfd/Qa9z6HkRS9kCX1WsE0ebajiJhk+4cVlW88MGp
         VDe0LvxioM6JurFvR6WjqLrvO2KFMKvM/93PMYMi1r130Bpgs8j9ci2Gis+o+FfTdZAW
         NFAbRST58jk8zE4GeMkBLIDC/PgqsFBGGawa5pV9cfn1xD5hKv+eE/tLqFW4SXP/c2zM
         cQLoOzdgTEprq2bnGMdfMz2B4kTcISmBVuKWEw1AbDbTAe30kr83HuOsxFUr2CINQsel
         KsAw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXKfTXbZyGqS6c08vudXpu8j1fHs4R5Hm7YzljvKRT6VqaZNHLZ
	iHkiAb8Y59v7Vy+LliGm1ZEvy6smHNjNnJt+uUTWr2jVqYEhEA8KXzDyJSxof2JO+Mb2K4S9zw+
	3XwMfFpYxmKnyf3/Nwpfpn4VMHCS2mQ5+0I7hdNZEmEwqTchfzzUi4zjTMzC/RyE=
X-Received: by 2002:a50:b48f:: with SMTP id w15mr135013021edd.260.1565005477556;
        Mon, 05 Aug 2019 04:44:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXJual3zGrP6FGQExFkqeqpxKnWbEeMnD67v3+bWLs3IQg8XI7WIQyLoerg8AAuNVLHKZx
X-Received: by 2002:a50:b48f:: with SMTP id w15mr135012969edd.260.1565005476713;
        Mon, 05 Aug 2019 04:44:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565005476; cv=none;
        d=google.com; s=arc-20160816;
        b=jq46GmVMtE8x8ozNxWcDk+4N6WCHsP7GNGfaSfoXCYIayWo6zuK/YvihE9EKPluc6+
         Mr/N38yXpPcg2M3dN53YT3sKwTY+JasDaYmq79gBl03j52ZNZS/PidZVJJEPwBqITk86
         zHf7g8PkgY15UEC3Xcuf6KfU6GZN9PQ5haE3k5CfQsc+26o5kG/Kul3+UF3XEjPoya5K
         RK5h0ERdWZGNlCkOEF3fwTUmKWMLe+gXukQpiIMABMw4YubXMIVzu0AtWn7q8Yvihie5
         8Tk9Y0h/MKGYlZqd5IMd4HrwtMc/OHr+vMz3LdSutJlmkNhXw/HVaVQPzDHIVvTdik35
         rn6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RXJKfgFQf/YyXXWdja9VDU70ZZPa5lpupVYXrJjQgAI=;
        b=vYNsnaoF3J5cBGUdRY0jrjj+Y2lbFyrKxfSSEworXwillWYZ9jJPlQgSTfakSwl+1m
         kD6NTDzImtM1+Pq8QKxV+Ktfz9YAzcPuCdgdGLlImsKwqOD5/kVkgilvkHU6lQAYmRIK
         xg1qZhwWNGWPElGPhZbShfiyksYDxzHQdnfX6owTQJLEwWg34t3fikcE1HFT2n0VHcJl
         DH1Pf2DG7z63gOkL/9KRnt6dhG0M8QTlpeDrTcALUadqz7Zd0jKVJl6OF5Gof1CcBMFB
         fwhuSWxflRaV86THP9afiIo3gIv+QzxbTzeJ+f8Pa6nNfqC9njHL3q6Fxei2t4+/8GL+
         ufmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce10si26088188ejb.2.2019.08.05.04.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 04:44:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 26301B05E;
	Mon,  5 Aug 2019 11:44:36 +0000 (UTC)
Date: Mon, 5 Aug 2019 13:44:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Masoud Sharbiani <msharbiani@apple.com>,
	Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
	vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190805114434.GK7597@dhcp22.suse.cz>
References: <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
 <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
 <20190805084228.GB7597@dhcp22.suse.cz>
 <7e3c0399-c091-59cd-dbe6-ff53c7c8adc9@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e3c0399-c091-59cd-dbe6-ff53c7c8adc9@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 05-08-19 20:36:05, Tetsuo Handa wrote:
> I updated the changelog.

This looks much better, thanks! One nit

> >From 80b6f63b9d30df414e468e193a7f1b40c373ed68 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 5 Aug 2019 20:28:35 +0900
> Subject: [PATCH v2] memcg, oom: don't require __GFP_FS when invoking memcg OOM killer
> 
> Masoud Sharbiani noticed that commit 29ef680ae7c21110 ("memcg, oom: move
> out_of_memory back to the charge path") broke memcg OOM called from
> __xfs_filemap_fault() path. It turned out that try_charge() is retrying
> forever without making forward progress because mem_cgroup_oom(GFP_NOFS)
> cannot invoke the OOM killer due to commit 3da88fb3bacfaa33 ("mm, oom:
> move GFP_NOFS check to out_of_memory").
> 
> Allowing forced charge due to being unable to invoke memcg OOM killer
> will lead to global OOM situation, and just returning -ENOMEM will not
> solve memcg OOM situation.

Returning -ENOMEM would effectivelly lead to triggering the oom killer
from the page fault bail out path. So effectively get us back to before
29ef680ae7c21110. But it is true that this is riskier from the
observability POV when a) the OOM path wouldn't point to the culprit and
b) it would leak ENOMEM from g-u-p path.

> Therefore, invoking memcg OOM killer (despite
> GFP_NOFS) will be the only choice we can choose for now.
> 
> Until 29ef680ae7c21110~1, we were able to invoke memcg OOM killer when
> GFP_KERNEL reclaim failed [1]. But since 29ef680ae7c21110, we need to
> invoke memcg OOM killer when GFP_NOFS reclaim failed [2]. Although in
> the past we did invoke memcg OOM killer for GFP_NOFS [3], we might get
> pre-mature memcg OOM reports due to this patch.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Reported-and-tested-by: Masoud Sharbiani <msharbiani@apple.com>
> Bisected-by: Masoud Sharbiani <msharbiani@apple.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Fixes: 3da88fb3bacfaa33 # necessary after 29ef680ae7c21110
> Cc: <stable@vger.kernel.org> # 4.19+
> 
> 
> [1]
> 
>  leaker invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
>  CPU: 0 PID: 2746 Comm: leaker Not tainted 4.18.0+ #19
>  Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
>  Call Trace:
>   dump_stack+0x63/0x88
>   dump_header+0x67/0x27a
>   ? mem_cgroup_scan_tasks+0x91/0xf0
>   oom_kill_process+0x210/0x410
>   out_of_memory+0x10a/0x2c0
>   mem_cgroup_out_of_memory+0x46/0x80
>   mem_cgroup_oom_synchronize+0x2e4/0x310
>   ? high_work_func+0x20/0x20
>   pagefault_out_of_memory+0x31/0x76
>   mm_fault_error+0x55/0x115
>   ? handle_mm_fault+0xfd/0x220
>   __do_page_fault+0x433/0x4e0
>   do_page_fault+0x22/0x30
>   ? page_fault+0x8/0x30
>   page_fault+0x1e/0x30
>  RIP: 0033:0x4009f0
>  Code: 03 00 00 00 e8 71 fd ff ff 48 83 f8 ff 49 89 c6 74 74 48 89 c6 bf c0 0c 40 00 31 c0 e8 69 fd ff ff 45 85 ff 7e 21 31 c9 66 90 <41> 0f be 14 0e 01 d3 f7 c1 ff 0f 00 00 75 05 41 c6 04 0e 2a 48 83
>  RSP: 002b:00007ffe29ae96f0 EFLAGS: 00010206
>  RAX: 000000000000001b RBX: 0000000000000000 RCX: 0000000001ce1000
>  RDX: 0000000000000000 RSI: 000000007fffffe5 RDI: 0000000000000000
>  RBP: 000000000000000c R08: 0000000000000000 R09: 00007f94be09220d
>  R10: 0000000000000002 R11: 0000000000000246 R12: 00000000000186a0
>  R13: 0000000000000003 R14: 00007f949d845000 R15: 0000000002800000
>  Task in /leaker killed as a result of limit of /leaker
>  memory: usage 524288kB, limit 524288kB, failcnt 158965
>  memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
>  kmem: usage 2016kB, limit 9007199254740988kB, failcnt 0
>  Memory cgroup stats for /leaker: cache:844KB rss:521136KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:132KB writeback:0KB inactive_anon:0KB active_anon:521224KB inactive_file:1012KB active_file:8KB unevictable:0KB
>  Memory cgroup out of memory: Kill process 2746 (leaker) score 998 or sacrifice child
>  Killed process 2746 (leaker) total-vm:536704kB, anon-rss:521176kB, file-rss:1208kB, shmem-rss:0kB
>  oom_reaper: reaped process 2746 (leaker), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
> 
> [2]
> 
>  leaker invoked oom-killer: gfp_mask=0x600040(GFP_NOFS), nodemask=(null), order=0, oom_score_adj=0
>  CPU: 1 PID: 2746 Comm: leaker Not tainted 4.18.0+ #20
>  Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
>  Call Trace:
>   dump_stack+0x63/0x88
>   dump_header+0x67/0x27a
>   ? mem_cgroup_scan_tasks+0x91/0xf0
>   oom_kill_process+0x210/0x410
>   out_of_memory+0x109/0x2d0
>   mem_cgroup_out_of_memory+0x46/0x80
>   try_charge+0x58d/0x650
>   ? __radix_tree_replace+0x81/0x100
>   mem_cgroup_try_charge+0x7a/0x100
>   __add_to_page_cache_locked+0x92/0x180
>   add_to_page_cache_lru+0x4d/0xf0
>   iomap_readpages_actor+0xde/0x1b0
>   ? iomap_zero_range_actor+0x1d0/0x1d0
>   iomap_apply+0xaf/0x130
>   iomap_readpages+0x9f/0x150
>   ? iomap_zero_range_actor+0x1d0/0x1d0
>   xfs_vm_readpages+0x18/0x20 [xfs]
>   read_pages+0x60/0x140
>   __do_page_cache_readahead+0x193/0x1b0
>   ondemand_readahead+0x16d/0x2c0
>   page_cache_async_readahead+0x9a/0xd0
>   filemap_fault+0x403/0x620
>   ? alloc_set_pte+0x12c/0x540
>   ? _cond_resched+0x14/0x30
>   __xfs_filemap_fault+0x66/0x180 [xfs]
>   xfs_filemap_fault+0x27/0x30 [xfs]
>   __do_fault+0x19/0x40
>   __handle_mm_fault+0x8e8/0xb60
>   handle_mm_fault+0xfd/0x220
>   __do_page_fault+0x238/0x4e0
>   do_page_fault+0x22/0x30
>   ? page_fault+0x8/0x30
>   page_fault+0x1e/0x30
>  RIP: 0033:0x4009f0
>  Code: 03 00 00 00 e8 71 fd ff ff 48 83 f8 ff 49 89 c6 74 74 48 89 c6 bf c0 0c 40 00 31 c0 e8 69 fd ff ff 45 85 ff 7e 21 31 c9 66 90 <41> 0f be 14 0e 01 d3 f7 c1 ff 0f 00 00 75 05 41 c6 04 0e 2a 48 83
>  RSP: 002b:00007ffda45c9290 EFLAGS: 00010206
>  RAX: 000000000000001b RBX: 0000000000000000 RCX: 0000000001a1e000
>  RDX: 0000000000000000 RSI: 000000007fffffe5 RDI: 0000000000000000
>  RBP: 000000000000000c R08: 0000000000000000 R09: 00007f6d061ff20d
>  R10: 0000000000000002 R11: 0000000000000246 R12: 00000000000186a0
>  R13: 0000000000000003 R14: 00007f6ce59b2000 R15: 0000000002800000
>  Task in /leaker killed as a result of limit of /leaker
>  memory: usage 524288kB, limit 524288kB, failcnt 7221
>  memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
>  kmem: usage 1944kB, limit 9007199254740988kB, failcnt 0
>  Memory cgroup stats for /leaker: cache:3632KB rss:518232KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB inactive_anon:0KB active_anon:518408KB inactive_file:3908KB active_file:12KB unevictable:0KB
>  Memory cgroup out of memory: Kill process 2746 (leaker) score 992 or sacrifice child
>  Killed process 2746 (leaker) total-vm:536704kB, anon-rss:518264kB, file-rss:1188kB, shmem-rss:0kB
>  oom_reaper: reaped process 2746 (leaker), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> 
> 
> [3]
> 
>  leaker invoked oom-killer: gfp_mask=0x50, order=0, oom_score_adj=0
>  leaker cpuset=/ mems_allowed=0
>  CPU: 1 PID: 3206 Comm: leaker Not tainted 3.10.0-957.27.2.el7.x86_64 #1
>  Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
>  Call Trace:
>   [<ffffffffaf364147>] dump_stack+0x19/0x1b
>   [<ffffffffaf35eb6a>] dump_header+0x90/0x229
>   [<ffffffffaedbb456>] ? find_lock_task_mm+0x56/0xc0
>   [<ffffffffaee32a38>] ? try_get_mem_cgroup_from_mm+0x28/0x60
>   [<ffffffffaedbb904>] oom_kill_process+0x254/0x3d0
>   [<ffffffffaee36c36>] mem_cgroup_oom_synchronize+0x546/0x570
>   [<ffffffffaee360b0>] ? mem_cgroup_charge_common+0xc0/0xc0
>   [<ffffffffaedbc194>] pagefault_out_of_memory+0x14/0x90
>   [<ffffffffaf35d072>] mm_fault_error+0x6a/0x157
>   [<ffffffffaf3717c8>] __do_page_fault+0x3c8/0x4f0
>   [<ffffffffaf371925>] do_page_fault+0x35/0x90
>   [<ffffffffaf36d768>] page_fault+0x28/0x30
>  Task in /leaker killed as a result of limit of /leaker
>  memory: usage 524288kB, limit 524288kB, failcnt 20628
>  memory+swap: usage 524288kB, limit 9007199254740988kB, failcnt 0
>  kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
>  Memory cgroup stats for /leaker: cache:840KB rss:523448KB rss_huge:0KB mapped_file:0KB swap:0KB inactive_anon:0KB active_anon:523448KB inactive_file:464KB active_file:376KB unevictable:0KB
>  Memory cgroup out of memory: Kill process 3206 (leaker) score 970 or sacrifice child
>  Killed process 3206 (leaker) total-vm:536692kB, anon-rss:523304kB, file-rss:412kB, shmem-rss:0kB
> 
> ---
>  mm/oom_kill.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a..26804ab 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1068,9 +1068,10 @@ bool out_of_memory(struct oom_control *oc)
>  	 * The OOM killer does not compensate for IO-less reclaim.
>  	 * pagefault_out_of_memory lost its gfp context so we have to
>  	 * make sure exclude 0 mask - all other users should have at least
> -	 * ___GFP_DIRECT_RECLAIM to get here.
> +	 * ___GFP_DIRECT_RECLAIM to get here. But mem_cgroup_oom() has to
> +	 * invoke the OOM killer even if it is a GFP_NOFS allocation.
>  	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS) && !is_memcg_oom(oc))
>  		return true;
>  
>  	/*
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

