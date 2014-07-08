Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3DAAD6B0037
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 18:19:14 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so6563743wes.21
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 15:19:13 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l14si4982277wiw.91.2014.07.08.15.19.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 15:19:13 -0700 (PDT)
Date: Tue, 8 Jul 2014 18:19:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 0/8] memcg: reparent kmem on css offline
Message-ID: <20140708221906.GC29639@cmpxchg.org>
References: <cover.1404733720.git.vdavydov@parallels.com>
 <20140707142506.GB1149@cmpxchg.org>
 <53BAD567.8060506@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BAD567.8060506@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 07, 2014 at 09:14:15PM +0400, Vladimir Davydov wrote:
> 07.07.2014 18:25, Johannes Weiner:
> >In addition, Tejun made offlined css iterable and split css_tryget()
> >and css_tryget_online(), which would allow memcg to pin the css until
> >the last charge is gone while continuing to iterate and reclaim it on
> >hierarchical pressure, even after it was offlined.
> 
> One more question.
> 
> With reparenting enabled, the number of cgroups (lruvecs) that must be
> iterated on global reclaim is bound by the number of live containers,
> while w/o reparenting it's practically unbound, isn't it? Won't it be
> the source of latency spikes?

It might deteriorate a little bit, but it is a self-correcting problem
as soon as memory pressure kicks.  Creating and destroying cgroups is
serialized at a global level, so I would expect the cost of doing that
at a high rate to become a problem before the csss become an issue for
the reclaim scanner.

At some point we will probably have to make the global reclaim cgroup
walk in shrink_zone() intermittent, but I'm not aware of any problems
with it so far.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
