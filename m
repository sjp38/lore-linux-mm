Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 349846B0029
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 14:54:00 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w10so8915283wrg.2
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:54:00 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 5si15204231wmn.169.2018.02.20.11.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 11:53:58 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
From: Igor Stoppa <igor.stoppa@huawei.com>
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-4-igor.stoppa@huawei.com>
 <20180211211646.GC4680@bombadil.infradead.org>
 <cef01110-dc23-4442-f277-88d1d3662e00@huawei.com>
Message-ID: <b59546a4-5a5b-ca48-3b51-09440b6a5493@huawei.com>
Date: Tue, 20 Feb 2018 21:53:30 +0200
MIME-Version: 1.0
In-Reply-To: <cef01110-dc23-4442-f277-88d1d3662e00@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 12/02/18 18:24, Igor Stoppa wrote:
> 
> 
> On 11/02/18 23:16, Matthew Wilcox wrote:
>> On Sun, Feb 11, 2018 at 05:19:17AM +0200, Igor Stoppa wrote:
>>> The struct page has a "mapping" field, which can be re-used, to store a
>>> pointer to the parent area. This will avoid more expensive searches.
>>>
>>> As example, the function find_vm_area is reimplemented, to take advantage
>>> of the newly introduced field.
>>
>> Umm.  Is it more efficient?  You're replacing an rb-tree search with a
>> page-table walk.  You eliminate a spinlock, which is great, but is the
>> page-table walk more efficient?  I suppose it'll depend on the depth of
>> the rb-tree, and (at least on x86), the page tables should already be
>> in cache.
> 
> I thought the tradeoff favorable.

It turns out that it's probably not so favorable.
The patch relies on the function vmalloc_to_page ... which will return
NULL when applied to huge mappings, while the original implementation
will still work.

It was found while testing on a configuration with framebuffer.

So it seems unlikely that there is any gain to be had, from this
perspective.

The use of the field still makes sense from the perspective of adding
pmalloc support to hardened usercopy, but there is no more need for the
field to exist as separate patch.

This patch can be simplified and merged with the pmalloc patch.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
