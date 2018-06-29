Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6185B6B0010
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:01:22 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id l17-v6so3070714uak.9
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:01:22 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u127-v6si76641vkg.285.2018.06.29.11.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 11:01:21 -0700 (PDT)
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180627013116.12411-1-bhe@redhat.com>
 <20180627013116.12411-5-bhe@redhat.com>
 <cb67381c-078c-62e6-e4c0-9ecf3de9e84d@intel.com>
 <CAGM2rebsL_fS8XKRvN34NWiFN3Hh63ZOD8jDj8qeSOUPXcZ2fA@mail.gmail.com>
 <88f16247-aea2-f429-600e-4b54555eb736@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <b8d5b9cb-ca09-4bcc-0a31-3db1232fe787@oracle.com>
Date: Fri, 29 Jun 2018 14:01:14 -0400
MIME-Version: 1.0
In-Reply-To: <88f16247-aea2-f429-600e-4b54555eb736@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On 06/29/2018 01:52 PM, Dave Hansen wrote:
> On 06/29/2018 10:48 AM, Pavel Tatashin wrote:
>> Here is example:
>> Node1:
>> map_map[0] -> Struct pages ...
>> map_map[1] -> NULL
>> Node2:
>> map_map[2] -> Struct pages ...
>>
>> We always want to configure section from Node2 with struct pages from
>> Node2. Even, if there are holes in-between. The same with usemap.
> 
> Right...  But your example consumes two mem_map[]s.
> 
> But, from scanning the code, we increment nr_consumed_maps three times.
> Correct?

Correct: it should be incremented on every iteration of the loop. No matter if the entries contained valid data or NULLs. So we increment in three places:

if map_map[] has invalid entry, increment, continue
if usemap_map[] has invalid entry, increment, continue
at the end of the loop, everything was valid we increment it

This is done so nr_consumed_maps does not get out of sync with the current pnum. pnum does not equal to nr_consumed_maps, as there are may be holes in pnums, but there is one-to-one correlation.

Pavel
