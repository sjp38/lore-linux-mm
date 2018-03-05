Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A04F6B0007
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:30:28 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id w9so6346646uaa.17
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:30:28 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 7si3445870uap.203.2018.03.05.11.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 11:30:27 -0800 (PST)
Subject: Re: [PATCH v12 02/11] mm, swap: Add infrastructure for saving page
 metadata on swap
References: <cover.1519227112.git.khalid.aziz@oracle.com>
 <f5316c71e645d99ffdd52963f1e9675de3fc6386.1519227112.git.khalid.aziz@oracle.com>
 <0d77dc3c-1454-a689-a0fb-f07e8973c29e@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <4a766f6d-ba96-7963-b367-7214eab7e307@oracle.com>
Date: Mon, 5 Mar 2018 12:29:51 -0700
MIME-Version: 1.0
In-Reply-To: <0d77dc3c-1454-a689-a0fb-f07e8973c29e@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, mgorman@techsingularity.net, willy@infradead.org, hughd@google.com, minchan@kernel.org, hannes@cmpxchg.org, shli@fb.com, mingo@kernel.org, jglisse@redhat.com, me@tobin.cc, anthony.yznaga@oracle.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 03/05/2018 12:20 PM, Dave Hansen wrote:
> On 02/21/2018 09:15 AM, Khalid Aziz wrote:
>> If a processor supports special metadata for a page, for example ADI
>> version tags on SPARC M7, this metadata must be saved when the page is
>> swapped out. The same metadata must be restored when the page is swapped
>> back in. This patch adds two new architecture specific functions -
>> arch_do_swap_page() to be called when a page is swapped in, and
>> arch_unmap_one() to be called when a page is being unmapped for swap
>> out. These architecture hooks allow page metadata to be saved if the
>> architecture supports it.
> 
> I still think silently squishing cacheline-level hardware data into
> page-level software data structures is dangerous.
> 
> But, you seem rather determined to do it this way.  I don't think this
> will _hurt_ anyone else, though other than needlessly cluttering up the
> code.

Hello Dave,

Thanks for taking the time to look at this patch and providing feedback.

ADI data is per page data and is held in the spare bits in the RAM. It 
is loaded into the cache when data is loaded from RAM and flushed out to 
spare bits in the RAM when data is flushed from cache. Sparc allows one 
tag for each ADI block size of data and ADI block size is same as 
cacheline size. When a page is loaded into RAM from swap space, all of 
the associated ADI data for the page must also be loaded into the RAM, 
so it looks like page level data and storing it in page level software 
data structure makes sense. I am open to other suggestions though.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
