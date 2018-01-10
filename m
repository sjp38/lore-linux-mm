Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81AFA6B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 08:37:56 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id c9so102798plr.10
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 05:37:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v4si10000365pgs.426.2018.01.10.05.37.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 05:37:55 -0800 (PST)
Subject: Re: [mm? 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801052345.JBJ82317.tJVHFFOMOLFOQS@I-love.SAKURA.ne.jp>
	<201801091939.JDJ64598.HOMFQtOFSOVLFJ@I-love.SAKURA.ne.jp>
	<201801102049.BGJ13564.OOOMtJLSFQFVHF@I-love.SAKURA.ne.jp>
	<20180110124519.GU1732@dhcp22.suse.cz>
In-Reply-To: <20180110124519.GU1732@dhcp22.suse.cz>
Message-Id: <201801102237.BED34322.QOOJMFFFHVLSOt@I-love.SAKURA.ne.jp>
Date: Wed, 10 Jan 2018 22:37:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Wed 10-01-18 20:49:56, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > I can hit this bug with Linux 4.11 and 4.8. (i.e. at least all 4.8+ have this bug.)
> > > So far I haven't hit this bug with Linux 4.8-rc3 and 4.7.
> > > Does anyone know what is happening?
> > 
> > I simplified the reproducer and succeeded to reproduce this bug with both
> > i7-2630QM (8 core) and i5-4440S (4 core). Thus, I think that this bug is
> > not architecture specific.
> 
> Can you see the same with 64b kernel?

No. I can hit this bug with only x86_32 kernels.
But if the cause is not specific to 32b, this might be silent memory corruption.

> It smells like a ref count imbalance and premature page free to me. Can
> you try to bisect this?

Too difficult to bisect, but at least I can hit this bug with 4.8+ kernels.

The XXX in "count:XXX mapcount:XXX mapping:XXX index:XXX" are rather random
as if they are overwritten.

[   44.103192] page:5a5a0697 count:-1055023618 mapcount:-1055030029 mapping:26f4be11 index:0xc11d7c83
[   44.103196] flags: 0xc10528fe(waiters|error|referenced|uptodate|dirty|lru|active|reserved|private_2|mappedtodisk|swapbacked)
[   44.103200] raw: c10528fe c114fff7 c11d7c83 c11d84f2 c11d9dfe c11daa34 c11daaa0 c13e65df
[   44.103201] raw: c13e4a1c c13e4c62
[   44.103202] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) <= 0)
[   44.103203] page->mem_cgroup:35401b27

[  192.152510] BUG: Bad page state in process a.out  pfn:18566
[  192.152513] page:f72997f0 count:0 mapcount:8 mapping:f118f5a4 index:0x0
[  192.152516] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
[  192.152520] raw: 19010019 f118f5a4 00000000 00000007 00000000 f7299804 f7299804 00000000
[  192.152521] raw: 00000000 00000000
[  192.152521] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[  192.152522] bad because of flags: 0x1(locked)

[   77.872133] BUG: Bad page state in process a.out  pfn:1873a
[   77.872136] page:f729e110 count:0 mapcount:6 mapping:f1187224 index:0x0
[   77.872138] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
[   77.872141] raw: 19010019 f1187224 00000000 00000005 00000000 f729e124 f729e124 00000000
[   77.872141] raw: 00000000 00000000
[   77.872142] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[   77.872142] bad because of flags: 0x1(locked)

[  188.992549] BUG: Bad page state in process a.out  pfn:197ea
[  188.992551] page:f72c7c90 count:0 mapcount:12 mapping:f11b8ca4 index:0x0
[  188.992554] flags: 0x19010019(locked|uptodate|dirty|mappedtodisk)
[  188.992557] raw: 19010019 f11b8ca4 00000000 0000000b 00000000 f72c7ca4 f72c7ca4 00000000
[  188.992557] raw: 00000000 00000000
[  188.992558] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[  188.992559] bad because of flags: 0x1(locked)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
