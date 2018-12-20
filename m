Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A92418E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:58:06 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so2739899edf.17
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:58:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25-v6sor5914891eja.49.2018.12.20.07.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 07:58:05 -0800 (PST)
Date: Thu, 20 Dec 2018 15:58:03 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181220155803.m4ebl6euq2yq4ezu@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219095715.73x6hvmndyku2rec@d104.suse.de>
 <20181219135307.bjd6rckseczpfeae@master>
 <20181219141343.GN5758@dhcp22.suse.cz>
 <20181219143327.wdsufbn2oh6ygnne@master>
 <20181219143927.GO5758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219143927.GO5758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, david@redhat.com

On Wed, Dec 19, 2018 at 03:39:27PM +0100, Michal Hocko wrote:
>On Wed 19-12-18 14:33:27, Wei Yang wrote:
>[...]
>> Then I am confused about the objection to this patch. Finally, we drain
>> all the pages in pcp list and the range is isolated.
>
>Please read my emails more carefully. As I've said, the only reason to
>do care about draining is to remove it from where it doesn't belong.

I go through the thread again and classify two main opinions from you
and Oscar.

1) We can still allocate pages in a specific range from pcp list even we
   have already isolate this range.
2) We shouldn't rely on caller to drain pages and
   set_migratetype_isolate() may handle a range cross zones.

I understand the second one and agree it is not proper to rely on caller
and make the assumption on range for set_migratetype_isolate().

My confusion comes from the first one. As you and Oscar both mentioned
this and Oscar said "I had the same fear", this makes me think current
implementation is buggy. But your following reply said this is not. This
means current approach works fine.

If the above understanding is correct, and combining with previous
discussion, the improvement we can do is to remove the drain_all_pages()
in __offline_pages()/alloc_contig_range(). By doing so, the pcp list
drain doesn't rely on caller and the isolation/drain on each pageblock
ensures pcp list will not contain any page in this range now and future.
This imply the drain_all_pages() in
__offline_pages()/alloc_contig_range() is not necessary.

Is my understanding correct?

>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
