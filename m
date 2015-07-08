Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9A16B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:37:52 -0400 (EDT)
Received: by igoe12 with SMTP id e12so2559906igo.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:37:52 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id qd10si4004353icb.35.2015.07.08.16.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:37:52 -0700 (PDT)
Received: by igoe12 with SMTP id e12so2559788igo.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:37:52 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:37:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] oom: Do not invoke oom notifiers on sysrq+f
In-Reply-To: <1436360661-31928-3-git-send-email-mhocko@suse.com>
Message-ID: <alpine.DEB.2.10.1507081636180.16585@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-3-git-send-email-mhocko@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 8 Jul 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.cz>
> 
> A github user rfjakob has reported the following issue via IRC.
> <rfjakob> Manually triggering the OOM killer does not work anymore in 4.0.5
> <rfjakob> This is what it looks like: https://gist.github.com/rfjakob/346b7dc611fc3cdf4011
> <rfjakob> Basically, what happens is that the GPU driver frees some memory, that satisfies the OOM killer
> <rfjakob> But the memory is allocated immediately again, and in the, no processes are killed no matter how often you trigger the oom killer
> <rfjakob> "in the end"
> 
> Quoting from the github:
> "
> [19291.202062] sysrq: SysRq : Manual OOM execution
> [19291.208335] Purging GPU memory, 74399744 bytes freed, 8728576 bytes still pinned.
> [19291.390767] sysrq: SysRq : Manual OOM execution
> [19291.396792] Purging GPU memory, 74452992 bytes freed, 8728576 bytes still pinned.
> [19291.560349] sysrq: SysRq : Manual OOM execution
> [19291.566018] Purging GPU memory, 75489280 bytes freed, 8728576 bytes still pinned.
> [19291.729944] sysrq: SysRq : Manual OOM execution
> [19291.735686] Purging GPU memory, 74399744 bytes freed, 8728576 bytes still pinned.
> [19291.918637] sysrq: SysRq : Manual OOM execution
> [19291.924299] Purging GPU memory, 74403840 bytes freed, 8728576 bytes still pinned.
> "
> 
> The issue is that sysrq+f (force_kill) gets confused by the regular OOM
> heuristic which tries to prevent from OOM killer if some of the oom
> notifier can relase a memory. The heuristic doesn't make much sense for
> the sysrq+f path because this one is used by the administrator to kill
> a memory hog.
> 
> Reported-by: Jakob Unterwurzacher <jakobunt@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Nack, the oom notify list has no place in the oom killer, it should be 
called in the page allocator before calling out_of_memory().  
out_of_memory() should serve a single, well defined purpose: kill a 
process.  If this were done, you wouldn't need random hacks like this in 
place.  This also shouldn't be included in a patchset that redefines the 
semantics of a forced oom kill, which is quite separate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
