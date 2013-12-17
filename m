Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f50.google.com (mail-qe0-f50.google.com [209.85.128.50])
	by kanga.kvack.org (Postfix) with ESMTP id 61E236B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:53:54 -0500 (EST)
Received: by mail-qe0-f50.google.com with SMTP id 1so5793844qec.23
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 14:53:54 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l3si15797414qac.30.2013.12.17.14.53.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 14:53:53 -0800 (PST)
Message-ID: <52B0D5F9.5030208@oracle.com>
Date: Tue, 17 Dec 2013 17:53:45 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/18] mm: numa: Avoid unnecessary disruption of NUMA
 hinting during migration
References: <1386690695-27380-1-git-send-email-mgorman@suse.de> <1386690695-27380-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

On 12/10/2013 10:51 AM, Mel Gorman wrote:
> +
> +	/* mmap_sem prevents this happening but warn if that changes */
> +	WARN_ON(pmd_trans_migrating(pmd));
> +

I seem to be hitting this warning with latest -next kernel:

[ 1704.594807] WARNING: CPU: 28 PID: 35287 at mm/huge_memory.c:887 copy_huge_pmd+0x145/
0x3a0()
[ 1704.597258] Modules linked in:
[ 1704.597844] CPU: 28 PID: 35287 Comm: trinity-main Tainted: G        W    3.13.0-rc4-
next-20131217-sasha-00013-ga878504-dirty #4149
[ 1704.599924]  0000000000000377e delta! pid slot 27 [36258]: old:2 now:537927697 diff:
537927695 ffff8803593ddb90 ffffffff8439501c ffffffff854722c1
[ 1704.604846]  0000000000000000 ffff8803593ddbd0 ffffffff8112f8ac ffff8803593ddbe0
[ 1704.606391]  ffff88034bc137f0 ffff880e41677000 8000000b47c009e4 ffff88034a638000
[ 1704.608008] Call Trace:
[ 1704.608511]  [<ffffffff8439501c>] dump_stack+0x52/0x7f
[ 1704.609699]  [<ffffffff8112f8ac>] warn_slowpath_common+0x8c/0xc0
[ 1704.612617]  [<ffffffff8112f8fa>] warn_slowpath_null+0x1a/0x20
[ 1704.614043]  [<ffffffff812b91c5>] copy_huge_pmd+0x145/0x3a0
[ 1704.615587]  [<ffffffff8127e032>] copy_page_range+0x3f2/0x560
[ 1704.616869]  [<ffffffff81199ef1>] ? rwsem_wake+0x51/0x70
[ 1704.617942]  [<ffffffff8112cf59>] dup_mmap+0x2c9/0x3d0
[ 1704.619146]  [<ffffffff8112d54d>] dup_mm+0xad/0x150
[ 1704.620051]  [<ffffffff8112e178>] copy_process+0xa68/0x12e0
[ 1704.622976]  [<ffffffff81194eda>] ? __lock_release+0x1da/0x1f0
[ 1704.624234]  [<ffffffff8112eee6>] do_fork+0x96/0x270
[ 1704.624975]  [<ffffffff81249465>] ? context_tracking_user_exit+0x195/0x1d0
[ 1704.626427]  [<ffffffff811930ed>] ? trace_hardirqs_on+0xd/0x10
[ 1704.627681]  [<ffffffff8112f0d6>] SyS_clone+0x16/0x20
[ 1704.628833]  [<ffffffff843a6309>] stub_clone+0x69/0x90
[ 1704.629672]  [<ffffffff843a6150>] ? tracesys+0xdd/0xe2


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
