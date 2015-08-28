Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 990F86B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 16:46:11 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so73368712pac.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:46:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id v8si11775294pdm.155.2015.08.28.13.46.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 13:46:10 -0700 (PDT)
Date: Fri, 28 Aug 2015 23:45:54 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828204554.GM9610@esperanza>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828171322.GC21463@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150828171322.GC21463@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 28, 2015 at 07:13:22PM +0200, Michal Hocko wrote:
...
> > * If the allocation doesn't have __GFP_WAIT, direct reclaim is
> >   skipped.  If a process performs only speculative allocations, it can
> >   blow way past the high limit.  This is actually easily reproducible
> >   by simply doing "find /".  VFS tries speculative !__GFP_WAIT
> >   allocations first, so as long as there's memory which can be
> >   consumed without blocking, it can keep allocating memory regardless
> >   of the high limit.
> 
> It is a bit confusing that you are talking about direct reclaim but in
> fact mean high limit reclaim. But yeah, you are right there is no
> protection against GFP_NOWAIT allocations there.

Actually, memory.high by itself *is* the protection against GFP_NOWAIT
allocations, similarly to zone watermarks. W/o it we would have no other
choice but fail a GFP_NOWAIT allocation on hitting memory.max. One
should just set it so that

  memory.max - memory.high > [max sum size of !__GFP_WAIT allocations
                              that can normally occur in a row]

That being said, currently I don't see any point in making memory.high
!__GFP_WAIT-safe.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
