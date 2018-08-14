Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82A0C6B0269
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 05:44:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d18-v6so15353059qtj.20
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:44:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n83-v6si2716126qki.267.2018.08.14.02.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 02:44:53 -0700 (PDT)
Subject: Re: [PATCH v2 2/3] mm/memory_hotplug: Drop mem_blk check from
 unregister_mem_sect_under_nodes
References: <20180813154639.19454-1-osalvador@techadventures.net>
 <20180813154639.19454-3-osalvador@techadventures.net>
 <82148bc6-672d-6610-757f-d910a17d23c6@redhat.com>
 <20180814093652.GA6878@techadventures.net>
From: David Hildenbrand <david@redhat.com>
Message-ID: <39454952-f8c9-4ded-acb5-02192e889de0@redhat.com>
Date: Tue, 14 Aug 2018 11:44:50 +0200
MIME-Version: 1.0
In-Reply-To: <20180814093652.GA6878@techadventures.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 14.08.2018 11:36, Oscar Salvador wrote:
> On Tue, Aug 14, 2018 at 11:30:51AM +0200, David Hildenbrand wrote:
> 
>>
>> While it is correct in current code, I wonder if this sanity check
>> should stay. I would completely agree if it would be a static function.
> 
> Hi David,
> 
> Well, unregister_mem_sect_under_nodes() __only__ gets called from remove_memory_section().
> But remove_memory_section() only calls unregister_mem_sect_under_nodes() IFF mem_blk
> is not NULL:
> 
> static int remove_memory_section
> {
> 	...
> 	mem = find_memory_block(section);
> 	if (!mem)
> 		goto out_unlock;
> 
> 	unregister_mem_sect_under_nodes(mem, __section_nr(section));
> 	...
> }

Yes I know, as I said, if it would be local to a file I would not care.
Making this functions never return an error is nice, though (and as you
noted, the return value is never checked).

I am a friend of stating which conditions a function expects to hold if
a function can be called from other parts of the system. Usually I
prefer to use BUG_ONs for that (whoever decides to call it can directly
see what he as to check before calling) or comments. But comments tend
to become obsolete.

> 
> So, to me keeping the check is redundant, as we already check for it before calling in.
> 
> Thanks
> 


-- 

Thanks,

David / dhildenb
