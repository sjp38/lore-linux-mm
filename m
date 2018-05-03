Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D33B36B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 17:52:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m18-v6so6134269lfb.9
        for <linux-mm@kvack.org>; Thu, 03 May 2018 14:52:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s29-v6sor3126616lfk.33.2018.05.03.14.52.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 14:52:32 -0700 (PDT)
Subject: Correct way to access the physmap? - Was: Re: [PATCH 7/9] Pmalloc
 Rare Write: modify selected pools
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-8-igor.stoppa@huawei.com>
 <20180424115050.GD26636@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <035f2bba-ebb1-06a0-fb88-3d40f7e484a7@gmail.com>
Date: Fri, 4 May 2018 01:52:29 +0400
MIME-Version: 1.0
In-Reply-To: <20180424115050.GD26636@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, dave.hansen@linux.intel.com
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>



On 24/04/18 15:50, Matthew Wilcox wrote:
> On Mon, Apr 23, 2018 at 04:54:56PM +0400, Igor Stoppa wrote:
>> While the vanilla version of pmalloc provides support for permanently
>> transitioning between writable and read-only of a memory pool, this
>> patch seeks to support a separate class of data, which would still
>> benefit from write protection, most of the time, but it still needs to
>> be modifiable. Maybe very seldom, but still cannot be permanently marked
>> as read-only.
> 
> This seems like a horrible idea that basically makes this feature useless.
> I would say the right way to do this is to have:
> 
> struct modifiable_data {
> 	struct immutable_data *d;
> 	...
> };
> 
> Then allocate a new pool, change d and destroy the old pool.

At the end of the summit, we agreed that I would go through the physmap.

But I'm not sure of what is the correct way to access it :-/

Starting from a vmalloc address, say:

int *i = vmalloc(sizeof(int));

I can get its linear counterpart:

int *j = page_to_virt(vmalloc_to_page(i));

and the physical address:

int *k = virt_to_phys(j);

But how do I get to the physmap?

I did not find much about it, apart from papers that talk about specific 
hardcoded addresses, but I would expect that if there is any hardcoded 
constant, by now, it's hidden behind some macro.

What I have verified, so far, at least on qemu x86_64, is that 
protecting "i" will also make "j" unwritable.

--
igor
