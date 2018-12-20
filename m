Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5045A8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:57:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so2237098eda.12
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:57:33 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23-v6si370713ejr.7.2018.12.20.04.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 04:57:32 -0800 (PST)
Date: Thu, 20 Dec 2018 13:57:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] ARC: show_regs: avoid page allocator
Message-ID: <20181220125730.GA17350@dhcp22.suse.cz>
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

On Tue 18-12-18 10:53:58, Vineet Gupta wrote:
> Use on-stack smaller buffers instead of dynamic pages.
> 
> The motivation for this change was to address lockdep splat when
> signal handling code calls show_regs (with preemption disabled) and
> ARC show_regs calls into sleepable page allocator.
> 
> | potentially unexpected fatal signal 11.
> | BUG: sleeping function called from invalid context at ../mm/page_alloc.c:4317
> | in_atomic(): 1, irqs_disabled(): 0, pid: 57, name: segv
> | no locks held by segv/57.
> | Preemption disabled at:
> | [<8182f17e>] get_signal+0x4a6/0x7c4
> | CPU: 0 PID: 57 Comm: segv Not tainted 4.17.0+ #23
> |
> | Stack Trace:
> |  arc_unwind_core.constprop.1+0xd0/0xf4
> |  __might_sleep+0x1f6/0x234
> |  __get_free_pages+0x174/0xca0
> |  show_regs+0x22/0x330
> |  get_signal+0x4ac/0x7c4     # print_fatal_signals() -> preempt_disable()
> |  do_signal+0x30/0x224
> |  resume_user_mode_begin+0x90/0xd8
> 
> Despite this, lockdep still barfs (see next change), but this patch
> still has merit as in we use smaller/localized buffers now and there's
> less instructoh trace to sift thru when debugging pesky issues.

But show_regs is called from contexts which might be called from deep
call chains (e.g WARN). Is it safe to allocate such a large stack there?
-- 
Michal Hocko
SUSE Labs
