Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA1CC6B025E
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:02:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z14so7208770wrb.12
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 00:02:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si336241edd.79.2017.11.23.00.02.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 00:02:33 -0800 (PST)
Date: Thu, 23 Nov 2017 09:02:31 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Message-ID: <20171123080231.lea6gzushqjjonsz@dhcp22.suse.cz>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
 <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
 <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
 <20171122203907.GI4094@dastard>
 <201711231534.BBI34381.tJOOHLQMOFVFSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711231534.BBI34381.tJOOHLQMOFVFSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.com, pbonzini@redhat.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On Thu 23-11-17 15:34:13, Tetsuo Handa wrote:
> Dave Chinner wrote:
[...]
> > Just fix the numa aware shrinkers, as they are the only ones that
> > will have this problem. There are only 6 of them, and only the 3
> > that existed at the time that register_shrinker() was changed to
> > return an error fail to check for an error. i.e. the superblock
> > shrinker, the XFS dquot shrinker and the XFS buffer cache shrinker.

Absolutely agreed! I haven't checked other shrinkers but those should be
quite easy to fix as well.

> You are assuming the "too small to fail" memory-allocation rule
> by ignoring that this problem is caused by fault injection.

Which is a non-argument because _nobody_ sane runs fault injection on
production systems.

[...]

> We need to make sure that all shrinkers are ready to handle allocation request,
> or make register_shrinker() never fail, or (a different approach shown below)
> let register_shrinker() fallback to numa unaware if memory allocation request
> failed (because Michal is assuming that most architectures do not have that
> many numa nodes to care which means that kmalloc() unlikely fails).

This is just insane.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
