Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 192736B0007
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:07:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i19-v6so2313643eds.20
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 06:07:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5-v6si6297378edg.99.2018.06.25.06.07.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 06:07:57 -0700 (PDT)
Date: Mon, 25 Jun 2018 15:07:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180625130756.GK28965@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180620115531.GL13685@dhcp22.suse.cz>
 <3d27f26e-68ba-d3c0-9518-cebeb2689aec@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3d27f26e-68ba-d3c0-9518-cebeb2689aec@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Mon 25-06-18 15:03:40, peter enderborg wrote:
> On 06/20/2018 01:55 PM, Michal Hocko wrote:
> > On Wed 20-06-18 20:20:38, Tetsuo Handa wrote:
> >> Sleeping with oom_lock held can cause AB-BA lockup bug because
> >> __alloc_pages_may_oom() does not wait for oom_lock. Since
> >> blocking_notifier_call_chain() in out_of_memory() might sleep, sleeping
> >> with oom_lock held is currently an unavoidable problem.
> > Could you be more specific about the potential deadlock? Sleeping while
> > holding oom lock is certainly not nice but I do not see how that would
> > result in a deadlock assuming that the sleeping context doesn't sleep on
> > the memory allocation obviously.
> 
> It is a mutex you are supposed to be able to sleep.  It's even exported.

What do you mean? oom_lock is certainly not exported for general use. It
is not local to oom_killer.c just because it is needed in other _mm_
code.
 
> >> As a preparation for not to sleep with oom_lock held, this patch brings
> >> OOM notifier callbacks to outside of OOM killer, with two small behavior
> >> changes explained below.
> > Can we just eliminate this ugliness and remove it altogether? We do not
> > have that many notifiers. Is there anything fundamental that would
> > prevent us from moving them to shrinkers instead?
> 
> 
> @Hocko Do you remember the lowmemorykiller from android? Some things
> might not be the right thing for shrinkers.

Just that lmk did it wrong doesn't mean others have to follow.

-- 
Michal Hocko
SUSE Labs
