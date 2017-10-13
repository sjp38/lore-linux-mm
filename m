Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28ABF6B0038
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:07:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r68so9393031wmr.6
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:07:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b191si840502wma.214.2017.10.13.05.07.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 05:07:57 -0700 (PDT)
Date: Fri, 13 Oct 2017 14:07:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, page_alloc: fail has_unmovable_pages when seeing
 reserved pages
Message-ID: <20171013120756.jeopthigbmm3c7bl@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171013120013.698-2-mhocko@kernel.org>
 <d98bfc90-e857-4bbe-bfbc-ee69dc310cc0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d98bfc90-e857-4bbe-bfbc-ee69dc310cc0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-10-17 14:04:08, Vlastimil Babka wrote:
> On 10/13/2017 02:00 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Reserved pages should be completely ignored by the core mm because they
> > have a special meaning for their owners. has_unmovable_pages doesn't
> > check those so we rely on other tests (reference count, or PageLRU) to
> > fail on such pages. Althought this happens to work it is safer to simply
> > check for those explicitly and do not rely on the owner of the page
> > to abuse those fields for special purposes.
> > 
> > Please note that this is more of a further fortification of the code
> > rahter than a fix of an existing issue.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index ad0294ab3e4f..a8800b0a5619 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7365,6 +7365,9 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >  
> >  		page = pfn_to_page(check);
> >  
> > +		if (PageReferenced(page))
> 
> "Referenced" != "Reserved"

Dohh, you are right of course. I blame auto-completion ;) but I am lame
in fact...
---
