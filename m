Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41C1E6B0253
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:31:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so16144309pgb.3
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:31:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w61si4489276plb.277.2017.09.17.23.31.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:31:46 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:31:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcg: avoid page count check for zone device
Message-ID: <20170918063141.6coovns7cb45bfly@dhcp22.suse.cz>
References: <20170914190011.5217-1-jglisse@redhat.com>
 <20170915070100.2vuxxxk2zf2yceca@dhcp22.suse.cz>
 <20170917174534.GC11906@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170917174534.GC11906@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Sun 17-09-17 10:45:34, Jerome Glisse wrote:
> On Fri, Sep 15, 2017 at 09:01:00AM +0200, Michal Hocko wrote:
> > On Thu 14-09-17 15:00:11, jglisse@redhat.com wrote:
> > > From: Jerome Glisse <jglisse@redhat.com>
> > > 
> > > Fix for 4.14, zone device page always have an elevated refcount
> > > of one and thus page count sanity check in uncharge_page() is
> > > inappropriate for them.
> > > 
> > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > Reported-by: Evgeny Baskakov <ebaskakov@nvidia.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > Side note. Wouldn't it be better to re-organize the check a bit? It is
> > true that this is VM_BUG so it is not usually compiled in but when it
> > preferably checks for unlikely cases first while the ref count will be
> > 0 in the prevailing cases. So can we have
> > 	VM_BUG_ON_PAGE(page_count(page) && !is_zone_device_page(page) &&
> > 			!PageHWPoison(page), page);
> > 
> > I would simply fold this nano optimization into the patch as you are
> > touching it already. Not sure it is worth a separate commit.
> 
> I am traveling sorry for late answer. This nano optimization make sense
> Andrew do you want me to respin or should we leave it be ? I don't mind
> either way.

Andrew, could you fold this into the patch then?
---
