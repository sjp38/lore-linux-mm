Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C27806B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:55:35 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id q18-v6so1755846pll.3
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 04:55:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3-v6si2336432plz.93.2018.06.20.04.55.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 04:55:34 -0700 (PDT)
Date: Wed, 20 Jun 2018 13:55:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180620115531.GL13685@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 20-06-18 20:20:38, Tetsuo Handa wrote:
> Sleeping with oom_lock held can cause AB-BA lockup bug because
> __alloc_pages_may_oom() does not wait for oom_lock. Since
> blocking_notifier_call_chain() in out_of_memory() might sleep, sleeping
> with oom_lock held is currently an unavoidable problem.

Could you be more specific about the potential deadlock? Sleeping while
holding oom lock is certainly not nice but I do not see how that would
result in a deadlock assuming that the sleeping context doesn't sleep on
the memory allocation obviously.

> As a preparation for not to sleep with oom_lock held, this patch brings
> OOM notifier callbacks to outside of OOM killer, with two small behavior
> changes explained below.

Can we just eliminate this ugliness and remove it altogether? We do not
have that many notifiers. Is there anything fundamental that would
prevent us from moving them to shrinkers instead?
-- 
Michal Hocko
SUSE Labs
