Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB3EC6B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 06:54:22 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so88259277wmw.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 03:54:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 67si81511954wmt.21.2017.01.05.03.54.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 03:54:21 -0800 (PST)
Date: Thu, 5 Jan 2017 12:54:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
Message-ID: <20170105115418.GN21618@dhcp22.suse.cz>
References: <20170103084211.GB30111@dhcp22.suse.cz>
 <201701032338.EFH69294.VOMSHFLOFOtQFJ@I-love.SAKURA.ne.jp>
 <20170103204014.GA13873@dhcp22.suse.cz>
 <201701042322.EEG05759.FOMOVLSFJFHOQt@I-love.SAKURA.ne.jp>
 <20170104152043.GQ25453@dhcp22.suse.cz>
 <201701051950.EAB48947.FFVSHOOQMJtLFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701051950.EAB48947.FFVSHOOQMJtLFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 05-01-17 19:50:23, Tetsuo Handa wrote:
[...]
> Anyway, I suggest merging description update shown below into this series and
> getting confirmation from all existing __GFP_NOFAIL users. If all existing
> __GFP_NOFAIL users are OK with this series (in other words, informed the risk
> caused by this series), I'm also OK with this series.
> 
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -135,16 +135,24 @@
>   * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
>   *   _might_ fail.  This depends upon the particular VM implementation.
>   *
> - * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
> - *   cannot handle allocation failures. New users should be evaluated carefully
> - *   (and the flag should be used only when there is no reasonable failure
> - *   policy) but it is definitely preferable to use the flag rather than
> - *   opencode endless loop around allocator.
> - *
> - * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
> - *   return NULL when direct reclaim and memory compaction have failed to allow
> - *   the allocation to succeed.  The OOM killer is not called with the current
> - *   implementation.
> + * __GFP_NOFAIL: The VM implementation must not give up even after direct
> + *   reclaim and memory compaction have failed to allow the allocation to
> + *   succeed. Note that since the OOM killer is not called with the current
> + *   implementation when direct reclaim and memory compaction have failed to
> + *   allow the allocation to succeed unless __GFP_FS is also used (and some
> + *   other conditions are met), e.g. GFP_NOFS | __GFP_NOFAIL allocation has
> + *   possibility of lockup. To reduce the possibility of lockup, __GFP_HIGH is
> + *   implicitly granted by the current implementation if __GFP_NOFAIL is used.
> + *   New users of __GFP_NOFAIL should be evaluated carefully (and __GFP_NOFAIL
> + *   should be used only when there is no reasonable failure policy) but it is
> + *   definitely preferable to use __GFP_NOFAIL rather than opencode endless
> + *   loop around allocator, for a stall detection check inside allocator will
> + *   likely be able to emit possible lockup warnings unless __GFP_NOWARN is
> + *   also used.

This is both wrong and unnecessarily describing implementation details.
Non-failing allocation which must not give up can lockup pretty much by
definition. IMHO the current description is sufficient.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
