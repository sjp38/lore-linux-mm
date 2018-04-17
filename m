Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B783C6B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:50:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z128so12316326qka.8
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:50:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x20si18521642qtb.365.2018.04.17.04.50.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 04:50:09 -0700 (PDT)
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
 <20180413134047.GR17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <86717b44-7aad-19d9-b55f-7f9eb40bcaa1@redhat.com>
Date: Tue, 17 Apr 2018 13:50:01 +0200
MIME-Version: 1.0
In-Reply-To: <20180413134047.GR17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
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

BTW, looking at the possible layouts of page->flags, I don't think it
will be a problem adding this flag. Especially if we compile this flag
only if really needed.

We could glue this flag to CONFIG_MEMORY_HOTPLUG_SUBSECTION to something
like that, that will be set when our new driver is compiled. So this
would not affect anybody just wanting to use ordinary DIMM based hotplug
(CONFIG_MEMORY_HOTPLUG).

But I am open for other suggestions. I don't think PG_reserved is the
right thing to use. And storing for each section which parts are
online/offline is also something I would like to avoid.

-- 

Thanks,

David / dhildenb
