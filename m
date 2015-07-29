Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 92FD16B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:36:34 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so218812843wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:36:34 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id cn4si43616778wjb.8.2015.07.29.05.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 05:36:33 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so217262044wic.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:36:32 -0700 (PDT)
Date: Wed, 29 Jul 2015 14:36:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150729123629.GI15801@dhcp22.suse.cz>
References: <cover.1437303956.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1437303956.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun 19-07-15 15:31:09, Vladimir Davydov wrote:
[...]
> ---- USER API ----
> 
> The user API consists of two new proc files:

I was thinking about this for a while. I dislike the interface.  It is
quite awkward to use - e.g. you have to read the full memory to check a
single memcg idleness. This might turn out being a problem especially on
large machines. It also provides a very low level information (per-pfn
idleness) which is inherently racy. Does anybody really require this
level of detail?

I would assume that most users are interested only in a single number
which tells the idleness of the system/memcg. Well, you have mentioned
a per-process reclaim but I am quite skeptical about this.

I guess the primary reason to rely on the pfn rather than the LRU walk,
which would be more targeted (especially for memcg cases), is that we
cannot hold lru lock for the whole LRU walk and we cannot continue
walking after the lock is dropped. Maybe we can try to address that
instead? I do not think this is easy to achieve but have you considered
that as an option?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
