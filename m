Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id EBFB86B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 08:38:18 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id q58so13665449wes.30
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 05:38:18 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id t2si898053wiz.3.2013.12.03.05.38.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 05:38:18 -0800 (PST)
Date: Tue, 3 Dec 2013 13:37:55 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v12 05/18] fs: do not use destroy_super() in
 alloc_super() fail path
Message-ID: <20131203133755.GJ10323@ZenIV.linux.org.uk>
References: <cover.1385974612.git.vdavydov@parallels.com>
 <af90b79aebe9cd9f6e1d35513f2618f4e9888e9b.1385974612.git.vdavydov@parallels.com>
 <20131203090041.GB8803@dastard>
 <529DA2F5.1040602@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <529DA2F5.1040602@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Dave Chinner <david@fromorbit.com>, hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org

On Tue, Dec 03, 2013 at 01:23:01PM +0400, Vladimir Davydov wrote:

> Actually, I'm not going to modify the list_lru structure, because I
> think it's good as it is. I'd like to substitute it with a new
> structure, memcg_list_lru, only in those places where this functionality
> (per-memcg scanning) is really needed. This new structure would look
> like this:
> 
> struct memcg_list_lru {
>     struct list_lru global_lru;
>     struct list_lru **memcg_lrus;
>     struct list_head list;
>     void *old_lrus;
> }
> 
> Since old_lrus and memcg_lrus can be NULL under normal operation, in
> memcg_list_lru_destroy() I'd have to check either the list or the
> global_lru field, i.e. it would look like:
> 
> if (!list.next)
>     /* has not been initialized */
>     return;
> 
> or

... or just use hlist_head.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
