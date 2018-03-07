Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5D9F6B0006
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 09:49:05 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v64so1195024wma.4
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 06:49:05 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id l26si1315054edf.443.2018.03.07.06.49.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 06:49:04 -0800 (PST)
Subject: Re: [PATCH 1/7] genalloc: track beginning of allocations
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
 <20180228200620.30026-2-igor.stoppa@huawei.com>
 <20180306131856.GD19349@rapoport-lnx>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <54e95716-9d61-51a3-9ae8-196e60625b76@huawei.com>
Date: Wed, 7 Mar 2018 16:48:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180306131856.GD19349@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 06/03/18 15:19, Mike Rapoport wrote:
> On Wed, Feb 28, 2018 at 10:06:14PM +0200, Igor Stoppa wrote:

[...]

> If I'm not mistaken, several kernel-doc descriptions are duplicated now.
> Can you please keep a single copy? ;-)

What's the preferred approach?
Document the functions that are API in the .h file and leave in the .c
those which are not API?

[...]

>> + * The alignment at which to perform the research for sequence of empty
> 
>                                            ^ search?

yes

>> + * get_boundary() - verifies address, then measure length.
> 
> There's some lack of consistency between the name and implementation and
> the description.
> It seems that it would be simpler to actually make it get_length() and
> return the length of the allocation or nentries if the latter is smaller.
> Then in gen_pool_free() there will be no need to recalculate nentries
> again.

There is an error in the documentation. I'll explain below.

> 
>>   * @map: pointer to a bitmap
>> - * @start: a bit position in @map
>> - * @nr: number of bits to set
>> + * @start_entry: the index of the first entry in the bitmap
>> + * @nentries: number of entries to alter
> 
> Maybe: "maximal number of entries to check"?

No, it's actually the total number of entries in the chunk.

[...]

>> +	return nentries - start_entry;
> 
> Shouldn't it be "nentries + start_entry"?

And in the light of the correct comment, also what I am doing should be
now more clear:

* start_entry is the index of the initial entry
* nentries is the number of entries in the chunk

If I iterate over the rest of the chunk:

(i = start_entry + 1; i < nentries; i++)

without finding either another HEAD or an empty slot, then it means I
was measuring the length of the last allocation in the chunk, which was
taking up all the space, to the end.

Simple example:

- chunk with 7 entries -> nentries is 7
- start_entry is 2, meaning that the last allocation starts from the 3rd
element, iow it occupies indexes from 2 to 6, for a total of 5 entries
- so the length is (nentries - start_entry) = (7 - 2) = 5


But yeah, the kerneldoc was wrong.

[...]

>> - * gen_pool_alloc_algo - allocate special memory from the pool
>> + * gen_pool_alloc_algo() - allocate special memory from the pool
> 
> + using specified algorithm

ok

> 
>>   * @pool: pool to allocate from
>>   * @size: number of bytes to allocate from the pool
>>   * @algo: algorithm passed from caller
>> @@ -285,14 +502,18 @@ EXPORT_SYMBOL(gen_pool_alloc);
>>   * Uses the pool allocation function (with first-fit algorithm by default).
> 
> "uses the provided @algo function to find room for the allocation"

ok

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
