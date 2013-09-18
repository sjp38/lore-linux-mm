Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F0F906B005A
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 10:33:11 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl13so8283871pab.20
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 07:33:11 -0700 (PDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Wed, 18 Sep 2013 16:33:06 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130916140607.GC3674@dhcp22.suse.cz>, <20130916161316.5113F6E7@pobox.sk>, <20130916145744.GE3674@dhcp22.suse.cz>, <20130916170543.77F1ECB4@pobox.sk>, <20130916152548.GF3674@dhcp22.suse.cz>, <20130916225246.A633145B@pobox.sk>, <20130917000244.GD3278@cmpxchg.org>, <20130917131535.94E0A843@pobox.sk>, <20130917141013.GA30838@dhcp22.suse.cz>, <20130918160304.6EDF2729@pobox.sk> <20130918142400.GA3421@dhcp22.suse.cz>
In-Reply-To: <20130918142400.GA3421@dhcp22.suse.cz>
MIME-Version: 1.0
Message-Id: <20130918163306.3620C973@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

> CC: "Johannes Weiner" <hannes@cmpxchg.org>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>On Wed 18-09-13 16:03:04, azurIt wrote:
>[..]
>> I was finally able to get stack of problematic process :) I saved it
>> two times from the same process, as Michal suggested (i wasn't able to
>> take more). Here it is:
>> 
>> First (doesn't look very helpfull):
>> [<ffffffffffffffff>] 0xffffffffffffffff
>
>No it is not.
> 
>> Second:
>> [<ffffffff810e17d1>] shrink_zone+0x481/0x650
>> [<ffffffff810e2ade>] do_try_to_free_pages+0xde/0x550
>> [<ffffffff810e310b>] try_to_free_pages+0x9b/0x120
>> [<ffffffff81148ccd>] free_more_memory+0x5d/0x60
>> [<ffffffff8114931d>] __getblk+0x14d/0x2c0
>> [<ffffffff8114c973>] __bread+0x13/0xc0
>> [<ffffffff811968a8>] ext3_get_branch+0x98/0x140
>> [<ffffffff81197497>] ext3_get_blocks_handle+0xd7/0xdc0
>> [<ffffffff81198244>] ext3_get_block+0xc4/0x120
>> [<ffffffff81155b8a>] do_mpage_readpage+0x38a/0x690
>> [<ffffffff81155ffb>] mpage_readpages+0xfb/0x160
>> [<ffffffff811972bd>] ext3_readpages+0x1d/0x20
>> [<ffffffff810d9345>] __do_page_cache_readahead+0x1c5/0x270
>> [<ffffffff810d9411>] ra_submit+0x21/0x30
>> [<ffffffff810cfb90>] filemap_fault+0x380/0x4f0
>> [<ffffffff810ef908>] __do_fault+0x78/0x5a0
>> [<ffffffff810f2b24>] handle_pte_fault+0x84/0x940
>> [<ffffffff810f354a>] handle_mm_fault+0x16a/0x320
>> [<ffffffff8102715b>] do_page_fault+0x13b/0x490
>> [<ffffffff815cb87f>] page_fault+0x1f/0x30
>> [<ffffffffffffffff>] 0xffffffffffffffff
>
>This is the direct reclaim path. You are simply running out of memory
>globaly. There is no memcg specific code in that trace.


No, i'm not. Here is htop and server graphs from this case:
http://watchdog.sk/lkml/htop3.jpg (here you can see actual memory usage)
http://watchdog.sk/lkml/server01.jpg

If i was really having global OOM (which i'm not for 101%) where that i/o comes from? I have no swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
