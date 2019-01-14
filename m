Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC238E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 14:26:45 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d35so132763qtd.20
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:26:45 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f47si21043193qte.179.2019.01.14.11.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 11:26:44 -0800 (PST)
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
 <ad3a53ba-82e2-2dc7-1cd2-feef7def0bc3@oracle.com>
 <50c6abdc-b906-d16a-2f8f-8647b3d129aa@oracle.com>
From: Steven Sistare <steven.sistare@oracle.com>
Message-ID: <7d1ccbc3-7dad-99de-1b15-77bb1196f9a3@oracle.com>
Date: Mon, 14 Jan 2019 14:26:26 -0500
MIME-Version: 1.0
In-Reply-To: <50c6abdc-b906-d16a-2f8f-8647b3d129aa@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux_lkml_grp@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>

On 1/14/2019 1:54 PM, Mike Kravetz wrote:
> On 1/14/19 7:35 AM, Steven Sistare wrote:
>> On 1/11/2019 6:28 PM, Mike Kravetz wrote:
>>> On 1/11/19 1:55 PM, Kirill A. Shutemov wrote:
>>>> On Fri, Jan 11, 2019 at 08:10:03PM +0000, Mike Kravetz wrote:
>>>>> At LPC last year, Boaz Harrosh asked why he had to 'jump through hoops'
>>>>> to get an address returned by mmap() suitably aligned for THP.  It seems
>>>>> that if mmap is asking for a mapping length greater than huge page
>>>>> size, it should align the returned address to huge page size.
>>
>> A better heuristic would be to return an aligned address if the length
>> is a multiple of the huge page size.  The gap (if any) between the end of
>> the previous VMA and the start of this VMA would be filled by subsequent
>> smaller mmap requests.  The new behavior would need to become part of the
>> mmap interface definition so apps can rely on it and omit their hoop-jumping
>> code.
> 
> Yes, the heuristic really should be 'length is a multiple of the huge page
> size'.  As you mention, this would still leave gaps.  I need to look closer
> but this may not be any worse than the trick of mapping an area with rounded
> up length and then unmapping pages at the beginning.
> 
> When I sent this out, the thought in the back of my mind was that this doesn't
> really matter unless there is some type of alignment guarantee.  Otherwise,
> user space code needs continue employing their code to check/force alignment.
> Making matters somewhat worse is that I do not believe there is C interface to
> query huge page size.  I thought there was discussion about adding one, but I
> can not find it.

Right. Solaris provides getpagesizes().

>> Personally I would like to see a new MAP_ALIGN flag and treat the addr
>> argument as the alignment (like Solaris), but I am told that adding flags
>> is problematic because old kernels accept undefined flag bits from userland
>> without complaint, so their behavior would change.
> 
> Well, a flag would clearly define desired behavior.
> 
> As others have been mentioned, there are mechanisms in place that allow user
> space code to get the alignment it wants.  However, it is at the expense of
> an additional system call or two.  Perhaps the question is, "Is it worth
> defining new behavior to eliminate this overhead?".
> 
> One other thing to consider is that at mmap time, we likely do not know if
> the vma will/can use THP.  We would know if system wide THP configuration
> is set to never or always.  However, I 'think' the default for most distros
> is madvize.  Therefore, it is not until a subsequent madvise call that we
> know THP will be employed.  If the application code will need to make this
> separate madvise call, then perhaps it is not too much to expect that it
> take explicit action to optimally align the mapping.

True.  It is annoying to write the extra code, but the power user will do it.

The heuristic alignment would primarily benefit applications that are not as
carefully optimized.

- Steve
