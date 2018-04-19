Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA7BE6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 08:48:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o16-v6so2484842wri.8
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 05:48:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3si731885edd.382.2018.04.19.05.48.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 05:48:10 -0700 (PDT)
Date: Thu, 19 Apr 2018 14:48:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <20180419124807.GR17484@dhcp22.suse.cz>
References: <20180418075051.GO17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
 <20180419063556.GK17484@dhcp22.suse.cz>
 <201804191945.BBF87517.FVMLOQFOHSFJOt@I-love.SAKURA.ne.jp>
 <20180419110419.GQ17484@dhcp22.suse.cz>
 <201804192051.JDE35992.OLFOQFMOtJHFSV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201804192051.JDE35992.OLFOQFMOtJHFSV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 19-04-18 20:51:45, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > We need to teach the OOM reaper stop reaping as soon as entering exit_mmap().
> > > Maybe let the OOM reaper poll for progress (e.g. none of get_mm_counter(mm, *)
> > > decreased for last 1 second) ?
> > 
> > Can we start simple and build a more elaborate heuristics on top _please_?
> > In other words holding the mmap_sem for write for oom victims in
> > exit_mmap should handle the problem. We can then enhance this to probe
> > for progress or any other clever tricks if we find out that the race
> > happens too often and we kill more than necessary.
> > 
> > Let's not repeat the error of trying to be too clever from the beginning
> > as we did previously. This are is just too subtle and obviously error
> > prone.
> > 
> Something like this?

Not really. This is still building on the tricky locking protocol we
have and proven to be error prone.  Can we simply take the mmap_sem for
write for oom victims before munlocking and release it after munmapping?
 
I am OK with building on the current protocol if taking the mmap_sem for
the whole section has some serious down sides but I haven't heard any
yet, to be honest.
-- 
Michal Hocko
SUSE Labs
