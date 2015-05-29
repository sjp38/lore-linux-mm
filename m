Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 044F36B0080
	for <linux-mm@kvack.org>; Fri, 29 May 2015 02:55:08 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so7785752wic.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 23:55:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2si7996576wjw.208.2015.05.28.23.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 May 2015 23:55:06 -0700 (PDT)
Date: Fri, 29 May 2015 08:55:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not call reclaim if !__GFP_WAIT
Message-ID: <20150529065504.GA22728@dhcp22.suse.cz>
References: <1432833966-25538-1-git-send-email-vdavydov@parallels.com>
 <20150528125934.198f57db4c5daf19dd15b184@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150528125934.198f57db4c5daf19dd15b184@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu 28-05-15 12:59:34, Andrew Morton wrote:
> On Thu, 28 May 2015 20:26:06 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > When trimming memcg consumption excess (see memory.high), we call
> > try_to_free_mem_cgroup_pages without checking if we are allowed to sleep
> > in the current context, which can result in a deadlock. Fix this.
> 
> Why does it deadlock?  try_to_free_mem_cgroup_pages() is passed the
> gfp_mask and should honour its __GFP_WAIT setting?

The only instance of __GFP_WAIT check in vmscan code is in zone_reclaim.
Page allocations and memcg reclaim avoids calling reclaim if __GFP_WAIT
is not set. Maybe we can move the check to do_try_to_free_pages?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
