Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 527756B0006
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 04:17:23 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a70-v6so10468567qkb.16
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 01:17:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l6-v6si9710948qvi.12.2018.07.30.01.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 01:17:22 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <f8d7b5f9-e5ee-0625-f53d-50d1841e1388@redhat.com>
 <20180724072237.GA28386@dhcp22.suse.cz>
 <e5264f8e-2bb5-7a9b-6352-ad18f04d49c2@redhat.com>
 <20180726083042.GC28386@dhcp22.suse.cz>
 <21c31952-7632-b8e1-aa33-d124ce96b88e@redhat.com>
 <20180726125013.ea82bfa3194386733b3943ab@linux-foundation.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <22a1eb66-0263-a23e-eddf-eb15ac6ebf99@redhat.com>
Date: Mon, 30 Jul 2018 10:17:16 +0200
MIME-Version: 1.0
In-Reply-To: <20180726125013.ea82bfa3194386733b3943ab@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 26.07.2018 21:50, Andrew Morton wrote:
> On Thu, 26 Jul 2018 10:45:54 +0200 David Hildenbrand <david@redhat.com> wrote:
> 
>>> Does each user of PG_balloon check for PG_reserved? If this is the case
>>> then yes this would be OK.
>>>
>>
>> I can only spot one user of PageBalloon() at all (fs/proc/page.c) ,
>> which makes me wonder if this bit is actually still relevant. I think
>> the last "real" user was removed with
>>
>> commit b1123ea6d3b3da25af5c8a9d843bd07ab63213f4
>> Author: Minchan Kim <minchan@kernel.org>
>> Date:   Tue Jul 26 15:23:09 2016 -0700
>>
>>     mm: balloon: use general non-lru movable page feature
>>
>>     Now, VM has a feature to migrate non-lru movable pages so balloon
>>     doesn't need custom migration hooks in migrate.c and compaction.c.
>>
>>
>> The only user of PG_balloon in general is
>> "include/linux/balloon_compaction.h", used effectively only by
>> virtio_balloon.
>>
>> All such pages are allocated via balloon_page_alloc() and never set
>> reserved.
>>
>> So to me it looks like PG_balloon could be easily reused, especially to
>> also exclude virtio-balloon pages from dumps.
> 
> Agree.  Maintaining a thingy for page-types.c which hardly anyone uses
> (surely) isn't sufficient justification for consuming a page flag.  We
> should check with the virtio developers first, but this does seem to be
> begging to be reclaimed.

Okay, I'll be looking into reusing this flag to mark pages as
fake/logical offline (e.g. "PG_offline"), so it can be used by

- memory onlining/offlining code ("page is offline" e.g. PG_reserved &&
  PG_offline)
- balloon drivers ("page is logically offline" e.g. !PG_reserved &&
  PG_offline)

In dump tools, we can then skip reading these pages ("page not used by
the system, might contain stale data or might not even be accessible").

Can you drop these two patches for now? I'll try to rework patch nr 1 to
more closely match what PG_reserved actually means. Patch nr 2 might no
longer be necessary if we agree on something like PG_offline.

-- 

Thanks,

David / dhildenb
