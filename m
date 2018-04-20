Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1578F6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:40:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y10-v6so8721482wrg.9
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 05:40:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 89si3182215edh.72.2018.04.20.05.40.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 05:40:48 -0700 (PDT)
Date: Fri, 20 Apr 2018 14:40:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <20180420124044.GA17484@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com>
 <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
 <20180418075051.GO17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
 <20180419063556.GK17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
 <20180420082349.GW17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420082349.GW17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 20-04-18 10:23:49, Michal Hocko wrote:
> On Thu 19-04-18 12:34:53, David Rientjes wrote:
[...]
> > I understand the concern, but it's the difference between the victim 
> > getting stuck in exit_mmap() and actually taking a long time to free its 
> > memory in exit_mmap().  I don't have evidence of the former.
> 
> I do not really want to repeat myself. The primary purpose of the oom
> reaper is to provide a _guarantee_ of the forward progress. I do not
> care whether there is any evidences. All I know that lock_page has
> plethora of different dependencies and we cannot clearly state this is
> safe so we _must not_ depend on it when setting MMF_OOM_SKIP.
> 
> The way how the oom path was fragile and lockup prone based on
> optimistic assumptions shouldn't be repeated.
> 
> That being said, I haven't heard any actual technical argument about why
> locking the munmap path is a wrong thing to do while the MMF_OOM_SKIP
> dependency on the page_lock really concerns me so
> 
> Nacked-by: Michal Hocko <mhocko@suse.com>
> 
> If you want to keep the current locking protocol then you really have to
> make sure that the oom reaper will set MMF_OOM_SKIP when racing with
> exit_mmap.

So here is my suggestion for the fix.
