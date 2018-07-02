Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6EA46B000A
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 15:54:33 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id f18-v6so5580779ual.5
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 12:54:33 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 95-v6si6403428uad.64.2018.07.02.12.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 12:54:32 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-3-pasha.tatashin@oracle.com>
 <552d5a9b-0ca9-cc30-d8c2-33dc1cde917f@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <b227cf00-a1dd-5371-aafd-9feb332e9d02@oracle.com>
Date: Mon, 2 Jul 2018 15:54:19 -0400
MIME-Version: 1.0
In-Reply-To: <552d5a9b-0ca9-cc30-d8c2-33dc1cde917f@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net



On 07/02/2018 03:47 PM, Dave Hansen wrote:
> On 07/01/2018 07:04 PM, Pavel Tatashin wrote:
>> +	for_each_present_section_nr(pnum_begin + 1, pnum_end) {
>> +		int nid = sparse_early_nid(__nr_to_section(pnum_end));
>>  
>> +		if (nid == nid_begin) {
>> +			map_count++;
>>  			continue;
>>  		}
> 
>> +		sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
>> +		nid_begin = nid;
>> +		pnum_begin = pnum_end;
>> +		map_count = 1;
>>  	}
> 
> Ugh, this is really hard to read.  Especially because the pnum "counter"
> is called "pnum_end".

I called it pnum_end, because that is what is passed to sparse_init_nid(), but I see your point, and I can rename pnum_end to simply pnum if that will make things look better.

> 
> So, this is basically a loop that collects all of the adjacent sections
> in a given single nid and then calls sparse_init_nid().  pnum_end in
> this case is non-inclusive, so the sparse_init_nid() call is actually
> for the *previous* nid that pnum_end is pointing _past_.
> 
> This *really* needs commenting.

There is a comment before sparse_init_nid() about inclusiveness:

434 /*
435  * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
436  * And number of present sections in this node is map_count.
437  */
438 static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
439                                    unsigned long pnum_end,
440                                    unsigned long map_count)


Thank you,
Pavel
