Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 25B556B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:12:16 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so4329233eaj.15
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 00:12:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si15618634eeo.44.2014.01.22.00.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 00:12:15 -0800 (PST)
Date: Wed, 22 Jan 2014 09:12:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 2/2] memcg: fix css reference leak and endless loop
 in mem_cgroup_iter
Message-ID: <20140122081212.GA18154@dhcp22.suse.cz>
References: <20140121083454.GA1894@dhcp22.suse.cz>
 <1390301143-9541-1-git-send-email-mhocko@suse.cz>
 <1390301143-9541-2-git-send-email-mhocko@suse.cz>
 <20140121114219.8c34256dfbe7c2470b36ced8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140121114219.8c34256dfbe7c2470b36ced8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 21-01-14 11:42:19, Andrew Morton wrote:
> On Tue, 21 Jan 2014 11:45:43 +0100 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > 19f39402864e (memcg: simplify mem_cgroup_iter) has reorganized
> > mem_cgroup_iter code in order to simplify it. A part of that change was
> > dropping an optimization which didn't call css_tryget on the root of
> > the walked tree. The patch however didn't change the css_put part in
> > mem_cgroup_iter which excludes root.
> > This wasn't an issue at the time because __mem_cgroup_iter_next bailed
> > out for root early without taking a reference as cgroup iterators
> > (css_next_descendant_pre) didn't visit root themselves.
> > 
> > Nevertheless cgroup iterators have been reworked to visit root by
> > bd8815a6d802 (cgroup: make css_for_each_descendant() and friends include
> > the origin css in the iteration) when the root bypass have been dropped
> > in __mem_cgroup_iter_next. This means that css_put is not called for
> > root and so css along with mem_cgroup and other cgroup internal object
> > tied by css lifetime are never freed.
> > 
> > Fix the issue by reintroducing root check in __mem_cgroup_iter_next
> > and do not take css reference for it.
> > 
> > This reference counting magic protects us also from another issue, an
> > endless loop reported by Hugh Dickins when reclaim races with root
> > removal and css_tryget called by iterator internally would fail. There
> > would be no other nodes to visit so __mem_cgroup_iter_next would return
> > NULL and mem_cgroup_iter would interpret it as "start looping from root
> > again" and so mem_cgroup_iter would loop forever internally.
> 
> I grabbed these two patches but I will sit on them for a week or so,
> pending review-n-test.

Yes, there is no rush and this needs a proper review.

> > Cc: stable@vger.kernel.org # mem_leak part 3.12+
> 
> What does this mean?

Dohh. I had both patches in one but then I decided to split it. This is
just left over. Should be 3.12+.

Sorry about the confusion.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
