Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C72D06B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 11:36:43 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id r97so14747027lfi.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 08:36:43 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id b18si17285342lfb.149.2016.07.19.08.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 08:36:42 -0700 (PDT)
Date: Tue, 19 Jul 2016 11:36:37 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: oom-reaper choosing wrong processes.
Message-ID: <20160719153637.GB11863@codemonkey.org.uk>
References: <20160718231850.GA23178@codemonkey.org.uk>
 <20160719090857.GB9490@dhcp22.suse.cz>
 <c77149ec-960c-d10a-0410-d09fe47bb14f@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c77149ec-960c-d10a-0410-d09fe47bb14f@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Tue, Jul 19, 2016 at 07:52:28PM +0900, Tetsuo Handa wrote:
 > On 2016/07/19 8:18, Dave Jones wrote:
 > > Whoa. Why did it pick systemd-journal ?
 > 
 > I guess that it is because all trinity processes' mm already had MMF_OOM_REAPED set.
 > 
 > The OOM reaper sets MMF_OOM_REAPED when OOM reap operation succeeded. But
 > "[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name" listing
 > includes processes whose mm already has MMF_OOM_REAPED set. As a result, trinity-c15 and
 > trinity-c4 are shown again in the listing. While I can't confirm that trinity-c10, trinity-c2,
 > trinity-c0 and trinity-c11 are already OOM killed, I guess they are already OOM killed and
 > their mm already had MMF_OOM_REAPED set.

That still doesn't explain why it picked the journal process, instead of waiting until
the previous reaping operation had actually killed those Trinity tasks.

 > > My 'skip over !trinity processes' code kicks in, and it then kills the right processes, and the box lives on,
 > > but if I hadn't have had that diff, the wrong process would have been killed.
 > 
 > As of Linux 4.7, processes whose mm already has MMF_OOM_REAPED can be selected for many
 > times due to not checking MMF_OOM_REAPED when using task_will_free_mem() shortcut in
 > out_of_memory(). (It will be fixed in Linux 4.8.) That is, I guess that your system had
 > already hit
 > 
 >   panic("Out of memory and no killable processes...\n")
 > 
 > if trinity processes with MMF_OOM_REAPED mm were not selected again and again.

That panic was not hit. The machine continued running after killing the right tasks.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
