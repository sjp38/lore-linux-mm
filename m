Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED88C6B02EE
	for <linux-mm@kvack.org>; Tue,  2 May 2017 06:44:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j127so50035704pgc.10
        for <linux-mm@kvack.org>; Tue, 02 May 2017 03:44:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m80si162819pfa.28.2017.05.02.03.44.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 03:44:59 -0700 (PDT)
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
References: <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <20161129230135.GM7179@merlins.org>
 <20170502041235.zqmywvj5tiiom3jk@merlins.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <29c02986-f065-d3be-f176-0c190a72bc58@I-love.SAKURA.ne.jp>
Date: Tue, 2 May 2017 19:44:47 +0900
MIME-Version: 1.0
In-Reply-To: <20170502041235.zqmywvj5tiiom3jk@merlins.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 2017/05/02 13:12, Marc MERLIN wrote:
> Well, sadly, the problem is more or less back is 4.11.0. The system doesn't really 
> crash but it goes into an infinite loop with
> [34776.826800] BUG: workqueue lockup - pool cpus=6 node=0 flags=0x0 nice=0 stuck for 33s!

Wow, two of workqueues are reaching max active.

[34777.202267] workqueue btrfs-endio-write: flags=0xe
[34777.218313]   pwq 16: cpus=0-7 flags=0x4 nice=0 active=8/8
[34777.236548]     in-flight: 15168:btrfs_endio_write_helper, 13855:btrfs_endio_write_helper, 3360:btrfs_endio_write_helper, 14241:btrfs_endio_write_helper, 27092:btrfs_endio_write_helper, 15194:btrfs_endio_write_helper, 15169:btrfs_endio_write_helper, 27093:btrfs_endio_write_helper
[34777.316225]     delayed: btrfs_endio_write_helper, btrfs_endio_write_helper, btrfs_endio_write_helper, btrfs_endio_write_helper, btrfs_endio_write_helper, btrfs_endio_write_helper

[34777.450684] workqueue bcache: flags=0x8
[34779.956462]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=256/256
[34779.978283]     in-flight: 15320:cached_dev_read_done [bcache], 23385:cached_dev_read_done [bcache], 23371:cached_dev_read_done [bcache], 15321:cached_dev_read_done [bcache], 15395:cached_dev_read_done [bcache], 11101:cached_dev_read_done [bcache], 15300:cached_dev_read_done [bcache], 23349:cached_dev_read_done [bcache], 23425:cached_dev_read_done [bcache], 23399:cached_dev_read_done [bcache], 15293:cached_dev_read_done [bcache], 20529:cached_dev_read_done [bcache], 15402:cached_dev_read_done [bcache], 23422:cached_dev_read_done [bcache], 23417:cached_dev_read_done [bcache], 23409:cached_dev_read_done [bcache], 20539:cached_dev_read_done [bcache], 23431:cached_dev_read_done [bcache], 20544:cached_dev_read_done [bcache], 15355:cached_dev_read_done [bcache], 11085:cached_dev_read_done [bcache], 6511:cached_dev_read_done [bcache]   

Googling with btrfs_endio_write_helper shows a stuck report with 4.8-rc5, but
seems no response ( https://www.spinics.net/lists/linux-btrfs/msg58633.html ).

> Any idea what I should do next?

Maybe you can try collecting list of all in-flight allocations with backtraces
using kmallocwd patches at
http://lkml.kernel.org/r/1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
and http://lkml.kernel.org/r/201704272019.JEH26057.SHFOtMLJOOVFQF@I-love.SAKURA.ne.jp
which also tracks mempool allocations.
(Well, the

-	cond_resched();
+	//cond_resched();

change in the latter patch would not be preferable.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
