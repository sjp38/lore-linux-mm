Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7382A6B0554
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 10:16:26 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id h4so1837115oic.0
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 07:16:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i185si2420823oia.354.2017.08.01.07.16.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 07:16:24 -0700 (PDT)
Subject: Re: Possible race condition in oom-killer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170728132952.GQ2274@dhcp22.suse.cz>
	<201707282255.BGI87015.FSFOVQtMOHLJFO@I-love.SAKURA.ne.jp>
	<20170728140706.GT2274@dhcp22.suse.cz>
	<201707291331.JGI18780.OtJVLFMHFOFSOQ@I-love.SAKURA.ne.jp>
	<20170801121411.GG15774@dhcp22.suse.cz>
In-Reply-To: <20170801121411.GG15774@dhcp22.suse.cz>
Message-Id: <201708012316.CFF21387.VMFtLFJHFOQOOS@I-love.SAKURA.ne.jp>
Date: Tue, 1 Aug 2017 23:16:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mjaggi@caviumnetworks.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
>                       Once we merge [1] then the oom victim wouldn't
> need to get TIF_MEMDIE to access memory reserves.
> 
> [1] http://lkml.kernel.org/r/20170727090357.3205-2-mhocko@kernel.org

False. We are not setting oom_mm to all thread groups (!CLONE_THREAD) sharing
that mm (CLONE_VM). Thus, one thread from each thread group sharing that mm
will have to call out_of_memory() in order to set oom_mm, and they will find
task_will_free_mem() returning false due to MMF_OOM_SKIP already set, and
after all goes to next OOM victim selection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
