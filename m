Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5E076B0062
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:33:36 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id n18-v6so5760804ybg.13
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:33:36 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x14si13523054qtc.128.2018.03.05.12.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 12:33:35 -0800 (PST)
Subject: Re: [PATCH v12 02/11] mm, swap: Add infrastructure for saving page
 metadata on swap
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <f5316c71e645d99ffdd52963f1e9675de3fc6386.1519227112.git.khalid.aziz@oracle.com>
 <0d77dc3c-1454-a689-a0fb-f07e8973c29e@linux.intel.com>
 <4a766f6d-ba96-7963-b367-7214eab7e307@oracle.com>
 <d807ba68-decd-e195-f607-ef6962e40c96@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <66c8ab93-f491-ad2e-5313-d03e23f73006@oracle.com>
Date: Mon, 5 Mar 2018 13:28:16 -0700
MIME-Version: 1.0
In-Reply-To: <d807ba68-decd-e195-f607-ef6962e40c96@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, mgorman@techsingularity.net, willy@infradead.org, hughd@google.com, minchan@kernel.org, hannes@cmpxchg.org, shli@fb.com, mingo@kernel.org, jglisse@redhat.com, me@tobin.cc, anthony.yznaga@oracle.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 12:35 PM, Dave Hansen wrote:
> On 03/05/2018 11:29 AM, Khalid Aziz wrote:
>> ADI data is per page data and is held in the spare bits in the RAM. It
>> is loaded into the cache when data is loaded from RAM and flushed out to
>> spare bits in the RAM when data is flushed from cache. Sparc allows one
>> tag for each ADI block size of data and ADI block size is same as
>> cacheline size.
> 
> Which does not square with your earlier assertion "ADI data is per page
> data".  It's per-cacheline data.  Right?

That is one way to look at it. Current sparc processors do implement 
same ADI block size as cacheline size but architecture does not require 
ADI block size to be same as cacheline size. If those two sizes were 
different, we wouldn't call it cacheline data.

> 
>> When a page is loaded into RAM from swap space, all of
>> the associated ADI data for the page must also be loaded into the RAM,
>> so it looks like page level data and storing it in page level software
>> data structure makes sense. I am open to other suggestions though.
> 
> Do you have a way to tell that data is not being thrown away?  Like if
> the ADI metadata is different for two different cachelines within a
> single page?

Yes, since access to tagged data is made using pointers with ADI tag 
embedded in the top bits, any mismatch between what app thinks the ADI 
tags should be and what is stored in the RAM for corresponding page will 
result in exception. If ADI data gets thrown away, we will get an ADI 
tag mismatch exception. If ADI tags for two different ADI blocks on a 
page are different when app expected them to be the same, we will see an 
exception on access to the block with wrong ADI data.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
