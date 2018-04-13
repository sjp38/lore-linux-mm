Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4DE6B0270
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:46:25 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u9so5593618qtg.2
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:46:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q91si1247313qtd.371.2018.04.13.06.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:46:24 -0700 (PDT)
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
 <20180413134047.GR17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <28ab2758-b514-fce1-0697-2df09f396972@redhat.com>
Date: Fri, 13 Apr 2018 15:46:20 +0200
MIME-Version: 1.0
In-Reply-To: <20180413134047.GR17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On 13.04.2018 15:40, Michal Hocko wrote:
> On Fri 13-04-18 15:16:26, David Hildenbrand wrote:
>> online_pages()/offline_pages() theoretically allows us to work on
>> sub-section sizes. This is especially relevant in the context of
>> virtualization. It e.g. allows us to add/remove memory to Linux in a VM in
>> 4MB chunks.
> 
> Well, theoretically possible but this would require a lot of auditing
> because the hotplug and per section assumption is quite a spread one.

Indeed. But besides changing section sizes / size of memory blocks this
seems to be the only way to do it. (btw, I think Windows allows to add
1MB chunks - e.g. 1MB DIMMs)

But as these pages "belong to nobody" nobody (besides kdump) should dare
to access the content, although the section is online.

> 
>> While the whole section is marked as online/offline, we have to know
>> the state of each page. E.g. to not read memory that is not online
>> during kexec() or to properly mark a section as offline as soon as all
>> contained pages are offline.
> 
> But you cannot use a page flag for that, I am afraid. Page flags are
> extremely scarce resource. I haven't looked at the rest of the series
> but _if_ we have a bit spare which I am not really sure about then you
> should prove there are no other ways around this.

Open for suggestions. We could remember per segment/memory block which
parts are online/offline and use that to decide if a section can go offline.

However: kdump will also have to (easily) know which pages are offline,
so it can skip reading them. (see the other patch)

>  
>> Signed-off-by: David Hildenbrand <david@redhat.com>


-- 

Thanks,

David / dhildenb
