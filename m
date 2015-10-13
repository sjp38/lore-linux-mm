Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 206D76B0255
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:33:52 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so21867681pad.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 06:33:51 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id ty7si5245079pab.20.2015.10.13.06.33.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 06:33:51 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so89714667wic.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 06:33:02 -0700 (PDT)
Date: Tue, 13 Oct 2015 15:32:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silent hang up caused by pages being not scanned?
Message-ID: <20151013133225.GA31034@dhcp22.suse.cz>
References: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Tue 13-10-15 00:25:53, Tetsuo Handa wrote:
[...]
> What is strange, the values printed by this debug printk() patch did not
> change as time went by. Thus, I think that this is not a problem of lack of
> CPU time for scanning pages. I suspect that there is a bug that nobody is
> scanning pages.
> 
> ----------
> [   66.821450] zone_reclaimable returned 1 at line 2646
> [   66.823020] (ACTIVE_FILE=26+INACTIVE_FILE=10) * 6 > PAGES_SCANNED=32
> [   66.824935] shrink_zones returned 1 at line 2706
> [   66.826392] zones_reclaimable=1 at line 2765
> [   66.827865] do_try_to_free_pages returned 1 at line 2938
> [   67.102322] __perform_reclaim returned 1 at line 2854
> [   67.103968] did_some_progress=1 at line 3301
> (...snipped...)
> [  281.439977] zone_reclaimable returned 1 at line 2646
> [  281.439977] (ACTIVE_FILE=26+INACTIVE_FILE=10) * 6 > PAGES_SCANNED=32
> [  281.439978] shrink_zones returned 1 at line 2706
> [  281.439978] zones_reclaimable=1 at line 2765
> [  281.439979] do_try_to_free_pages returned 1 at line 2938
> [  281.439979] __perform_reclaim returned 1 at line 2854
> [  281.439980] did_some_progress=1 at line 3301

This is really interesting because even with reclaimable LRUs this low
we should eventually scan them enough times to convince zone_reclaimable
to fail. PAGES_SCANNED in your logs seems to be constant, though, which
suggests somebody manages to free a page every time before we get down
to priority 0 and manage to scan something finally. This is pretty much
pathological behavior and I have hard time to imagine how would that be
possible but it clearly shows that zone_reclaimable heuristic is not
working properly.

I can see two options here. Either we teach zone_reclaimable to be less
fragile or remove zone_reclaimable from shrink_zones altogether. Both of
them are risky because we have a long history of changes in this areas
which made other subtle behavior changes but I guess that the first
option should be less fragile. What about the following patch? I am not
happy about it because the condition is rather rough and a deeper
inspection is really needed to check all the call sites but it should be
good for testing.
--- 
