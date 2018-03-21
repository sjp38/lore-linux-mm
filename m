Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64D9A6B0028
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:14:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r29so2543164wra.13
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 06:14:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i136si2896910wmd.193.2018.03.21.06.14.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 06:14:51 -0700 (PDT)
Date: Wed, 21 Mar 2018 14:14:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
Message-ID: <20180321131449.GN23100@dhcp22.suse.cz>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 21-03-18 05:31:19, Yang Shi wrote:
> When running some mmap/munmap scalability tests with large memory (i.e.
> > 300GB), the below hung task issue may happen occasionally.
> 
> INFO: task ps:14018 blocked for more than 120 seconds.
>        Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> message.
>  ps              D    0 14018      1 0x00000004
>   ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>   ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>   00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>  Call Trace:
>   [<ffffffff817154d0>] ? __schedule+0x250/0x730
>   [<ffffffff817159e6>] schedule+0x36/0x80
>   [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>   [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>   [<ffffffff81717db0>] down_read+0x20/0x40
>   [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0

Slightly off-topic:
Btw. this sucks as well. Do we really need to take mmap_sem here? Do any
of
	arg_start = mm->arg_start;
	arg_end = mm->arg_end;
	env_start = mm->env_start;
	env_end = mm->env_end;

change after exec or while the pid is already visible in proc? If yes
maybe we can use a dedicated lock.
-- 
Michal Hocko
SUSE Labs
