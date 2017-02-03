Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4FF96B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 01:17:40 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 204so12404966pge.5
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 22:17:40 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 33si24576334plg.204.2017.02.02.22.17.38
        for <linux-mm@kvack.org>;
        Thu, 02 Feb 2017 22:17:39 -0800 (PST)
Date: Fri, 3 Feb 2017 15:17:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170203061737.GA32372@bbox>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170202104422.GF22806@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 02, 2017 at 11:44:22AM +0100, Michal Hocko wrote:
> On Tue 31-01-17 14:32:08, Vinayak Menon wrote:
> > During global reclaim, the nr_reclaimed passed to vmpressure
> > includes the pages reclaimed from slab. But the corresponding
> > scanned slab pages is not passed. This can cause total reclaimed
> > pages to be greater than scanned, causing an unsigned underflow
> > in vmpressure resulting in a critical event being sent to root
> > cgroup. So do not consider reclaimed slab pages for vmpressure
> > calculation. The reclaimed pages from slab can be excluded because
> > the freeing of a page by slab shrinking depends on each slab's
> > object population, making the cost model (i.e. scan:free) different
> > from that of LRU.
> 
> This might be true but what happens if the slab reclaim contributes
> significantly to the overal reclaim? This would be quite rare but not
> impossible.

Of course, it is better for vmpressure to cover slab but it's not
easy without page-based shrinking model, I think. It wold make
vmpressure higher easily due to low reclaim efficiency compared to
LRU pages. Yeah, vmpressure is not a perfect but no need to add
more noises, either. It's regression since 6b4f7799c6a5 so I think
this patch should go first and if someone want to cover slab really,
he should spend a time to work it well. It's too much that Vinayak
shuld make a effort for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
