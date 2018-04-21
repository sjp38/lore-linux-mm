Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6586B0007
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 19:15:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g15so4966567pfi.8
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 16:15:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b186si7271063pgc.569.2018.04.21.16.15.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 21 Apr 2018 16:15:37 -0700 (PDT)
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
 <20180413171120.GA1245@bombadil.infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <89329958-2ff8-9447-408e-fd478b914ec4@suse.cz>
Date: Sat, 21 Apr 2018 18:52:18 +0200
MIME-Version: 1.0
In-Reply-To: <20180413171120.GA1245@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On 04/13/2018 07:11 PM, Matthew Wilcox wrote:
> On Fri, Apr 13, 2018 at 03:16:26PM +0200, David Hildenbrand wrote:
>> online_pages()/offline_pages() theoretically allows us to work on
>> sub-section sizes. This is especially relevant in the context of
>> virtualization. It e.g. allows us to add/remove memory to Linux in a VM in
>> 4MB chunks.
>>
>> While the whole section is marked as online/offline, we have to know
>> the state of each page. E.g. to not read memory that is not online
>> during kexec() or to properly mark a section as offline as soon as all
>> contained pages are offline.
> 
> Can you not use PG_reserved for this purpose?

Sounds like your newly introduced "page types" could be useful here? I
don't suppose those offline pages would be using mapcount which is
aliased there?

>> + * PG_offline indicates that a page is offline and the backing storage
>> + * might already have been removed (virtualization). Don't touch!
> 
>  * PG_reserved is set for special pages, which can never be swapped out. Some
>  * of them might not even exist...
> 
> They seem pretty congruent to me.
> 
