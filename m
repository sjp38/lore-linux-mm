Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25AC86B025E
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 15:06:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f64so5608948pfd.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 12:06:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y128si1922124pfy.128.2017.11.30.12.06.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 12:06:13 -0800 (PST)
Date: Thu, 30 Nov 2017 21:06:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171130200610.uoeentyd2hgxnx62@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
 <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
 <425a8947-d32a-d6bb-3a0a-2e30275c64c9@oracle.com>
 <20171130075742.3exagxg6y4j427ut@dhcp22.suse.cz>
 <e23f971e-cd62-afea-6567-0873a3e48db7@oracle.com>
 <20171130195743.52vc6enr3rnivtdx@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130195743.52vc6enr3rnivtdx@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 30-11-17 20:57:43, Michal Hocko wrote:
> On Thu 30-11-17 11:35:11, Mike Kravetz wrote:
> > On 11/29/2017 11:57 PM, Michal Hocko wrote:
> > > On Wed 29-11-17 11:52:53, Mike Kravetz wrote:
> > >> On 11/29/2017 01:22 AM, Michal Hocko wrote:
> > >>> What about this on top. I haven't tested this yet though.
> > >>
> > >> Yes, this would work.
> > >>
> > >> However, I think a simple modification to your previous free_huge_page
> > >> changes would make this unnecessary.  I was confused in your previous
> > >> patch because you decremented the per-node surplus page count, but not
> > >> the global count.  I think it would have been correct (and made this
> > >> patch unnecessary) if you decremented the global counter there as well.
> > > 
> > > We cannot really increment the global counter because the over number of
> > > surplus pages during migration doesn't increase.
> > 
> > I was not suggesting we increment the global surplus count.  Rather,
> > your previous patch should have decremented the global surplus count in
> > free_huge_page.  Something like:
> 
> sorry I meant to say decrement. The point is that overal suprlus count
> doesn't change after the migration. The only thing that _might_ change
> is the per node distribution of surplus pages. That is why I think we
> should handle that during the migration.

Let me clarify. The migration context is the only place where we have
both the old and new page so this sounds like the only place to know
that we need to transfer the per-node surplus state.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
