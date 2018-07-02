Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECA1A6B000E
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:00:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m1-v6so6858164pgr.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:00:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q14-v6si16246740pll.324.2018.07.02.13.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:00:46 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-3-pasha.tatashin@oracle.com>
 <552d5a9b-0ca9-cc30-d8c2-33dc1cde917f@intel.com>
 <b227cf00-a1dd-5371-aafd-9feb332e9d02@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <38a2629d-689c-4592-9bd7-a77ab1b2045c@intel.com>
Date: Mon, 2 Jul 2018 13:00:43 -0700
MIME-Version: 1.0
In-Reply-To: <b227cf00-a1dd-5371-aafd-9feb332e9d02@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 07/02/2018 12:54 PM, Pavel Tatashin wrote:
> 
> 
> On 07/02/2018 03:47 PM, Dave Hansen wrote:
>> On 07/01/2018 07:04 PM, Pavel Tatashin wrote:
>>> +	for_each_present_section_nr(pnum_begin + 1, pnum_end) {
>>> +		int nid = sparse_early_nid(__nr_to_section(pnum_end));
>>>  
>>> +		if (nid == nid_begin) {
>>> +			map_count++;
>>>  			continue;
>>>  		}
>>
>>> +		sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
>>> +		nid_begin = nid;
>>> +		pnum_begin = pnum_end;
>>> +		map_count = 1;
>>>  	}
>>
>> Ugh, this is really hard to read.  Especially because the pnum "counter"
>> is called "pnum_end".
> 
> I called it pnum_end, because that is what is passed to
> sparse_init_nid(), but I see your point, and I can rename pnum_end to
> simply pnum if that will make things look better.

Could you just make it a helper that takes a beginning pnum and returns
the number of consecutive sections?

>> So, this is basically a loop that collects all of the adjacent sections
>> in a given single nid and then calls sparse_init_nid().  pnum_end in
>> this case is non-inclusive, so the sparse_init_nid() call is actually
>> for the *previous* nid that pnum_end is pointing _past_.
>>
>> This *really* needs commenting.
> 
> There is a comment before sparse_init_nid() about inclusiveness:
> 
> 434 /*
> 435  * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
> 436  * And number of present sections in this node is map_count.
> 437  */
> 438 static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
> 439                                    unsigned long pnum_end,
> 440                                    unsigned long map_count)

Which I totally missed.  Could you comment the code, please?
