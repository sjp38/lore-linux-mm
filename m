Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 188046B0038
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 03:39:54 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id cs9so40652376lbb.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 00:39:54 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y9si6890529lbf.18.2015.12.17.00.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 00:39:52 -0800 (PST)
Date: Thu, 17 Dec 2015 11:39:31 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: clean up alloc, online, offline, free
 functions fix
Message-ID: <20151217083931.GM28521@esperanza>
References: <1450312460-27582-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1450312460-27582-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Dec 16, 2015 at 07:34:20PM -0500, Johannes Weiner wrote:
> Fixlets based on review feedback from Vladimir:
> 
> 1. The memcg_create_mutex is to stabilize a cgroup's hereditary
>    settings that are not allowed to change once the cgroup has
>    children: kmem accounting and hierarchy mode. However, the cleanup
>    patch moves inheritance of these settings from onlining time to
>    allocation time, before the new child will show up in the parent's
>    list of children, and this opens a race window where the parent can
>    change a setting that has been passed on to a new child already.
> 
>    That being said, this rule for kmem and hierarchy mode is somewhat
>    gratuitous: there is no strong reason why these configurations
>    shouldn't exist, and the outcome of a race is not harmful. It's
>    also unlikely that somebody will even trigger this race because we
>    don't expect anybody to flip-flop either settings while creating
>    child groups. So instead of readding complexity to close an
>    unlikely race window that doesn't do any harm, simply remove the
>    now pointless mutex as a follow-up cleanup.
> 
> 2. Kmem initialization consists of several steps that are undone in
>    both css_offline() and css_free(). However, if css allocation fails
>    later on then css_offline() is never called and we don't properly
>    free the kmem state. Let css_free() detect this and call kmem
>    offlining itself.
> 
> 3. Children in !use_hierarchy mode would inherit the OOM killer
>    setting from their physical parent rather than the logical parent,
>    rootmemcg.  This is silly, but no reason to change the semantics as
>    part of this cleanup patch, so restore it.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
