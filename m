Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 333526B03BE
	for <linux-mm@kvack.org>; Mon,  8 May 2017 11:25:37 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l39so30426634qtb.9
        for <linux-mm@kvack.org>; Mon, 08 May 2017 08:25:37 -0700 (PDT)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id m131si12686525qke.65.2017.05.08.08.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 08:25:34 -0700 (PDT)
Received: by mail-qk0-f179.google.com with SMTP id k74so54975496qke.1
        for <linux-mm@kvack.org>; Mon, 08 May 2017 08:25:34 -0700 (PDT)
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <b3fab9c3-fa35-eb7b-204c-f85a0d392e12@redhat.com>
Date: Mon, 8 May 2017 08:25:31 -0700
MIME-Version: 1.0
In-Reply-To: <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 05/05/2017 03:42 AM, Igor Stoppa wrote:
> On 04/05/17 19:49, Laura Abbott wrote:
>> [adding kernel-hardening since I think there would be interest]
> 
> thank you, I overlooked this
> 
> 
>> BPF takes the approach of calling set_memory_ro to mark regions as
>> read only. I'm certainly over simplifying but it sounds like this
>> is mostly a mechanism to have this happen mostly automatically.
>> Can you provide any more details about tradeoffs of the two approaches?
> 
> I am not sure I understand the question ...
> For what I can understand, the bpf is marking as read only something
> that spans across various pages, which is fine.
> The payload to be protected is already organized in such pages.
> 
> But in the case I have in mind, I have various, heterogeneous chunks of
> data, coming from various subsystems, not necessarily page aligned.
> And, even if they were page aligned, most likely they would be far
> smaller than a page, even a 4k page.
> 
> The first problem I see, is how to compact them into pages, ensuring
> that no rwdata manages to infiltrate the range.
> 
> The actual mechanism for marking pages as read only is not relevant at
> this point, if I understand your question correctly, since set_memory_ro
> is walking the pages it receives as parameter.
> 

Thanks for clarifying, this makes sense. I also saw some replies up
thread that also answered some my questions.

>> arm and arm64 have the added complexity of using larger
>> page sizes on the linear map so dynamic mapping/unmapping generally
>> doesn't work. 
> 
> Do you mean that a page could be 16MB and therefore it would not be
> possible to get a smaller chunk?
> 

Roughly yes.

PAGE_SIZE is still 4K/16K/64K but the underlying page table mappings
may use larger mappings (2MB, 32M, 512M, etc.). The ARM architecture
has a break-before-make requirement which requires old mappings be
fully torn down and invalidated to avoid TLB conflicts. This is nearly
impossible to do correctly on live page tables so the current policy
is to not break down larger mappings.

>> arm64 supports DEBUG_PAGEALLOC by mapping with only
>> pages but this is generally only wanted as a debug mechanism.
>> I don't know if you've given this any thought at all.
> 
> Since the beginning I have thought about this feature as an opt-in
> feature. I am aware that it can have drawbacks, but I think it would be
> valuable as debugging tool even where it's not feasible to keep it
> always-on.
> 
> OTOH on certain systems it can be sufficiently appealing to be kept on,
> even if it eats up some more memory.

I'd rather see this designed as being mandatory from the start and then
provide a mechanism to turn it off if necessary. The uptake and
coverage from opt-in features tends to be very low based on past experience.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
