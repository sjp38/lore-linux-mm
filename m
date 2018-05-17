Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6966B0386
	for <linux-mm@kvack.org>; Thu, 17 May 2018 00:18:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7-v6so1951089pfi.8
        for <linux-mm@kvack.org>; Wed, 16 May 2018 21:18:37 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f6-v6si1399047pgn.348.2018.05.16.21.18.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 21:18:35 -0700 (PDT)
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-2-hch@lst.de>
 <37c16316-aa3a-e3df-79d0-9fca37a5996f@codeaurora.org>
 <20180516180503.GA6627@lst.de>
From: Ritesh Harjani <riteshh@codeaurora.org>
Message-ID: <c8993a13-1084-454c-4d58-17a9e6d96f8e@codeaurora.org>
Date: Thu, 17 May 2018 09:48:30 +0530
MIME-Version: 1.0
In-Reply-To: <20180516180503.GA6627@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org



On 5/16/2018 11:35 PM, Christoph Hellwig wrote:
> On Wed, May 16, 2018 at 10:36:14AM +0530, Ritesh Harjani wrote:
>> 1. if bio_full is true that means no space in bio->bio_io_vec[] no?
>> Than how come we are still proceeding ahead with only warning?
>> While originally in bio_add_page we used to return after checking
>> bio_full. Callers can still call __bio_add_page directly right.
> 
> I you don't know if the bio is full or not don't use __bio_add_page,
> keep using bio_add_page.  The WARN_ON is just a debug tool to catch
> cases where the developer did use it incorrectly.
> 
>> 2. IF above is correct why don't we set the bio->bi_max_vecs to the size
>> of the slab instead of keeeping it to nr_iovecs which user requested?
>> (in bio_alloc_bioset)
> 
> Because we limit the user to the number that the user requested.  Not
> that this patch changes anything about that.
> 
>> 3. Could you please help understand why for cloned bio we still allow
>> __bio_add_page to work? why not WARN and return like in original code?
> 
> It doesn't work, and I have now added the WARN_ON to deal with any
> incorrect usage.
> 
>>> -	if (bio->bi_vcnt >= bio->bi_max_vecs)
>>> -		return 0;
>> Originally here we were supposed to return and not proceed further.
>> Should __bio_add_page not have similar checks to safeguard crossing
>> the bio_io_vec[] boundary?
> 
> No, __bio_add_page is the "I know what I am doing" interface.
> 

Thanks for explaining. I guess I missed reading the comment made on top 
of function __bio_add_page.
"The caller must ensure that @bio has space for another bvec"

This discussion helped me understand a bit about bios & bio_vec.

Thanks!!
Ritesh


-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, 
Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project.
