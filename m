Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E444A6B0008
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 10:49:47 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 3-v6so1888408plc.18
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 07:49:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r23si11612668pgu.359.2018.11.02.07.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 07:49:46 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
 <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
 <CADF2uSorU5P+Jw--oL5huOHN1Oe+Uss+maSXy0V9GLfHWjTBbA@mail.gmail.com>
 <20181031170108.GR32673@dhcp22.suse.cz>
 <CADF2uSpE9=iS5_KwPDRCuBECE+Kp5i5yDn3Vz8A+SxGTQ=DC3Q@mail.gmail.com>
 <20181101132307.GJ23921@dhcp22.suse.cz>
 <CADF2uSqO8+_uZA5qHjWJ08UOqqH6C_d-_R+9qAAbxw5sdTYSMg@mail.gmail.com>
 <20181102080513.GB5564@dhcp22.suse.cz>
 <CADF2uSq+wP8aF=y=MgO4EHjk=ThXY22JMx81zNPy1kzheS6f3w@mail.gmail.com>
 <20181102114341.GB28039@dhcp22.suse.cz>
 <f95c4fdc-1b03-99dd-c293-3ee1e495305c@suse.cz>
 <CADF2uSqtmaqaUqFiwiXGoLdDGHbMEPX5AqoA2quibwG0egJZPA@mail.gmail.com>
 <63091aac-0caa-6740-1c91-cbc420612d74@suse.cz>
 <CADF2uSqgM8rLSpSt+Q3S4VgYqWdTcMnxVW6p2Y2MXWCmbOytKA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0a788f72-06bf-78a3-1ccf-57e268081b68@suse.cz>
Date: Fri, 2 Nov 2018 15:49:42 +0100
MIME-Version: 1.0
In-Reply-To: <CADF2uSqgM8rLSpSt+Q3S4VgYqWdTcMnxVW6p2Y2MXWCmbOytKA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On 11/2/18 2:50 PM, Marinko Catovic wrote:
> Am Fr., 2. Nov. 2018 um 14:13 Uhr schrieb Vlastimil Babka <vbabka@suse.cz>:
>>
>> On 11/2/18 1:41 PM, Marinko Catovic wrote:
>>>>>> any idea how to find out what that might be? I'd really have no idea,
>>>>>> I also wonder why this never was an issue with 3.x
>>>>>> find uses regex patterns, that's the only thing that may be unusual.
>>>>>
>>>>> The allocation tracepoint has the stack trace so that might help. This
>>>>
>>>> Well we already checked the mm_page_alloc traces and it seemed that only
>>>> THP allocations could be the culprit. But apparently defrag=defer made
>>>> no difference. I would still recommend it so we can see the effects on
>>>> the traces. And adding tracepoints
>>>> compaction/mm_compaction_try_to_compact_pages and
>>>> compaction/mm_compaction_suitable as I suggested should show which
>>>> high-order allocations actually invoke the compaction.
>>>
>>> Anything in particular I should do to figure this out?
>>
>> Setup the same monitoring as before, but with two additional tracepoints
>> (echo 1 > .../enable) and once the problem appears, provide the tracing
>> output.
> 
> I think I'll need more details about that setup  :)

It's like what you already did based on suggestion from Michal Hocko:

# mount -t tracefs none /debug/trace/
# echo stacktrace > /debug/trace/trace_options
# echo "order>0" > /debug/trace/events/kmem/mm_page_alloc/filter
# echo 1 > /debug/trace/events/kmem/mm_page_alloc/enable
# echo 1 > /debug/trace/events/compaction/mm_compaction_try_to_compact_pages
# echo 1 > /debug/trace/events/compaction/mm_compaction_suitable
# cat /debug/trace/trace_pipe | gzip > /path/to/trace_pipe.txt.gz

And later this to disable tracing.
# echo 0 > /debug/trace/events/kmem/mm_page_alloc/enable

> also, do you want the tracing output every 5sec or just once when it
> is around the worst case? what files exactly?

Collect vmstat periodically every 5 secs as you already did. Tracing is
continuous and results in the single trace_pipe.txt.gz file.
The trace should cover at least some time while you're experiencing the
too much free memory/too little pagecache phase. Might be enough to
enable the collection only after you detect the situation, and before
you e.g. drop caches to restore the system.

To remove THP allocations from the picture, it would be nice if the
system was configured with:
echo defer > /sys/kernel/mm/transparent_hugepage/defrag

Again you can do that only after detecting the problematic situation,
before starting to collect trace.
