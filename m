Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A60886B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 06:52:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r71so33063877ioi.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 03:52:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f27si6743764ioi.41.2016.07.19.03.52.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 03:52:47 -0700 (PDT)
Subject: Re: oom-reaper choosing wrong processes.
References: <20160718231850.GA23178@codemonkey.org.uk>
 <20160719090857.GB9490@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <c77149ec-960c-d10a-0410-d09fe47bb14f@I-love.SAKURA.ne.jp>
Date: Tue, 19 Jul 2016 19:52:28 +0900
MIME-Version: 1.0
In-Reply-To: <20160719090857.GB9490@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Dave Jones <davej@codemonkey.org.uk>
Cc: linux-mm@kvack.org

On 2016/07/19 8:18, Dave Jones wrote:
> Whoa. Why did it pick systemd-journal ?

I guess that it is because all trinity processes' mm already had MMF_OOM_REAPED set.

The OOM reaper sets MMF_OOM_REAPED when OOM reap operation succeeded. But
"[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name" listing
includes processes whose mm already has MMF_OOM_REAPED set. As a result, trinity-c15 and
trinity-c4 are shown again in the listing. While I can't confirm that trinity-c10, trinity-c2,
trinity-c0 and trinity-c11 are already OOM killed, I guess they are already OOM killed and
their mm already had MMF_OOM_REAPED set.

> My 'skip over !trinity processes' code kicks in, and it then kills the right processes, and the box lives on,
> but if I hadn't have had that diff, the wrong process would have been killed.

As of Linux 4.7, processes whose mm already has MMF_OOM_REAPED can be selected for many
times due to not checking MMF_OOM_REAPED when using task_will_free_mem() shortcut in
out_of_memory(). (It will be fixed in Linux 4.8.) That is, I guess that your system had
already hit

  panic("Out of memory and no killable processes...\n")

if trinity processes with MMF_OOM_REAPED mm were not selected again and again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
