Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 106406B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 07:09:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u63so24993078wmu.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 04:09:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si11965219wms.53.2017.02.07.04.09.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 04:09:55 -0800 (PST)
Date: Tue, 7 Feb 2017 13:09:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2 RESEND] mm: vmpressure: fix sending wrong events on
 underflow
Message-ID: <20170207120954.GL5065@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <1486383850-30444-2-git-send-email-vinmenon@codeaurora.org>
 <20170206124037.GA10298@dhcp22.suse.cz>
 <CAOaiJ-kf+1xO9R5u33-JADpNpHiyyfbq0CKY014E8L+ErKioDA@mail.gmail.com>
 <20170206132410.GC10298@dhcp22.suse.cz>
 <CAOaiJ-ksqOr8T0KRN8eP-YmvCsXOwF6_z=gvQEtaC5mhMt7tvA@mail.gmail.com>
 <20170206151203.GF10298@dhcp22.suse.cz>
 <CAOaiJ-kehYcq=XSS+J2p-tZbPWa_Z33Pey9Af-EhWMop-P7Q=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-kehYcq=XSS+J2p-tZbPWa_Z33Pey9Af-EhWMop-P7Q=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue 07-02-17 16:47:18, vinayak menon wrote:
> On Mon, Feb 6, 2017 at 8:42 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 06-02-17 20:05:21, vinayak menon wrote:
> > [...]
> >> By scan I meant pages scanned by shrink_node_memcg/shrink_list
> >> which is passed as nr_scanned to vmpressure.  The calculation of
> >> pressure for tree is done at the end of vmpressure_win and it is
> >> that calculation which underflows. With this patch we want only the
> >> underflow to be avoided. But if we make (reclaimed = scanned) in
> >> vmpressure(), we change the vmpressure value even when there is no
> >> underflow right ?
> >>
> >> Rewriting the above e.g again.  First call to vmpressure with
> >> nr_scanned=1 and nr_reclaimed=512 (THP) Second call to vmpressure
> >> with nr_scanned=511 and nr_reclaimed=0 In the second call
> >> vmpr->tree_scanned becomes equal to vmpressure_win and the work
> >> is scheduled and it will calculate the vmpressure as 0 because
> >> tree_reclaimed = 512
> >>
> >> Similarly, if scanned is made equal to reclaimed in vmpressure()
> >> itself as you had suggested, First call to vmpressure with
> >> nr_scanned=1 and nr_reclaimed=512 (THP) And in vmpressure, we
> >> make nr_scanned=1 and nr_reclaimed=1 Second call to vmpressure
> >> with nr_scanned=511 and nr_reclaimed=0 In the second call
> >> vmpr->tree_scanned becomes equal to vmpressure_win and the work is
> >> scheduled and it will calculate the vmpressure as critical, because
> >> tree_reclaimed = 1
> >>
> >> So it makes a difference, no?
> >
> > OK, I see what you meant. Thanks for the clarification. And you are
> > right that normalizing nr_reclaimed to nr_scanned is a wrong thing to
> > do because that just doesn't aggregate the real work done. Normalizing
> > nr_scanned to nr_reclaimed should be better - or it would be even better
> > to count the scanned pages properly...
> >
> With the slab reclaimed issue fixed separately, only the THP case exists AFAIK.
> In the case of THP, as I understand from one of Minchan's reply, the scan is
> actually 1. i.e. Only a single huge page is scanned to get 512 reclaimed pages.
> So the cost involved was scanning a single page.
> In that case, there is no need to normalize the nr_scanned, no?

Strictly speaking it is not but it has weird side effects when we
basically lie about vmpressure_win.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
