Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80CD46B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 10:12:07 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so19145318wjc.4
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 07:12:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n124si8412976wmg.96.2017.02.06.07.12.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 07:12:05 -0800 (PST)
Date: Mon, 6 Feb 2017 16:12:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2 RESEND] mm: vmpressure: fix sending wrong events on
 underflow
Message-ID: <20170206151203.GF10298@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <1486383850-30444-2-git-send-email-vinmenon@codeaurora.org>
 <20170206124037.GA10298@dhcp22.suse.cz>
 <CAOaiJ-kf+1xO9R5u33-JADpNpHiyyfbq0CKY014E8L+ErKioDA@mail.gmail.com>
 <20170206132410.GC10298@dhcp22.suse.cz>
 <CAOaiJ-ksqOr8T0KRN8eP-YmvCsXOwF6_z=gvQEtaC5mhMt7tvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-ksqOr8T0KRN8eP-YmvCsXOwF6_z=gvQEtaC5mhMt7tvA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon 06-02-17 20:05:21, vinayak menon wrote:
[...]
> By scan I meant pages scanned by shrink_node_memcg/shrink_list
> which is passed as nr_scanned to vmpressure.  The calculation of
> pressure for tree is done at the end of vmpressure_win and it is
> that calculation which underflows. With this patch we want only the
> underflow to be avoided. But if we make (reclaimed = scanned) in
> vmpressure(), we change the vmpressure value even when there is no
> underflow right ?
>
> Rewriting the above e.g again.  First call to vmpressure with
> nr_scanned=1 and nr_reclaimed=512 (THP) Second call to vmpressure
> with nr_scanned=511 and nr_reclaimed=0 In the second call
> vmpr->tree_scanned becomes equal to vmpressure_win and the work
> is scheduled and it will calculate the vmpressure as 0 because
> tree_reclaimed = 512
>
> Similarly, if scanned is made equal to reclaimed in vmpressure()
> itself as you had suggested, First call to vmpressure with
> nr_scanned=1 and nr_reclaimed=512 (THP) And in vmpressure, we
> make nr_scanned=1 and nr_reclaimed=1 Second call to vmpressure
> with nr_scanned=511 and nr_reclaimed=0 In the second call
> vmpr->tree_scanned becomes equal to vmpressure_win and the work is
> scheduled and it will calculate the vmpressure as critical, because
> tree_reclaimed = 1
> 
> So it makes a difference, no?

OK, I see what you meant. Thanks for the clarification. And you are
right that normalizing nr_reclaimed to nr_scanned is a wrong thing to
do because that just doesn't aggregate the real work done. Normalizing
nr_scanned to nr_reclaimed should be better - or it would be even better
to count the scanned pages properly...

My main concern of doing this normalization late on aggregated numbers
is just weird. We are mixing numbers from parallel reclaimers and that
might just add more confusion. It is better to do the fixup as soon as
possible when we still have at least an idea that this was a THP page
scanned and reclaimed.

If we get back to your example it works as you expect just due to good
luck. Just make your nr_scanned=511 and nr_reclaimed=0 be a separate
event and you have your critical event. You have no real control over
when a new event is fired because parallel reclaimers are basically
unpredictable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
