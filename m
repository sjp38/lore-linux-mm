Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 04B066B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 12:52:24 -0500 (EST)
Received: by wmww144 with SMTP id w144so121188332wmw.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:52:23 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s10si27174425wmf.20.2015.11.16.09.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 09:52:22 -0800 (PST)
Date: Mon, 16 Nov 2015 12:52:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 05/14] net: tcp_memcontrol: protect all tcp_memcontrol
 calls by jump-label
Message-ID: <20151116175204.GA32544@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
 <20151114163309.GL31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151114163309.GL31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, Nov 14, 2015 at 07:33:10PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 12, 2015 at 06:41:24PM -0500, Johannes Weiner wrote:
> > Move the jump-label from sock_update_memcg() and sock_release_memcg()
> > to the callsite, and so eliminate those function calls when socket
> > accounting is not enabled.
> 
> I don't believe this patch's necessary, because these functions aren't
> hot paths. Neither do I think it makes the code look better. Anyway,
> it's rather a matter of personal preference, and the patch looks correct
> to me, so

Yeah, it's not a hotpath. What I like primarily about this patch I
guess is that makes it more consistent how memcg entry is gated. You
don't have to remember which functions have the checks in the caller
and which have it in the function themselves. And I really hate the

static inline void foo(void)
{
	if (foo_enabled())
		__foo()
}

in the headerfile pattern.

> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks, I appreciate you acking it despite your personal preference!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
