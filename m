Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4E7E6B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 07:42:34 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id q28so12262420uaa.6
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 04:42:34 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id d7si6631535uad.352.2018.02.01.04.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 04:42:33 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-4-igor.stoppa@huawei.com>
 <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <48fde114-d063-cfbf-e1b6-262411fcd963@huawei.com>
Date: Thu, 1 Feb 2018 14:42:24 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 01/02/18 02:00, Christopher Lameter wrote:
> On Tue, 30 Jan 2018, Igor Stoppa wrote:
> 
>> @@ -1769,6 +1774,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>>
>>  	kmemleak_vmalloc(area, size, gfp_mask);
>>
>> +	for (page_counter = 0; page_counter < area->nr_pages; page_counter++)
>> +		area->pages[page_counter]->area = area;
>> +
>>  	return addr;
> 
> Well this introduces significant overhead for large sized allocation. Does
> this not matter because the areas are small?

Relatively significant?
I do not object to your comment, but in practice i see that:

- vmalloc is used relatively little
- allocations do not seem to be huge
- there seem to be way larger overheads in the handling of virtual pages
  (see my proposal for the LFS/m summit, about collapsing struct
   vm_struct and struct vmap_area)


> Would it not be better to use compound page allocations here?
> page_head(whatever) gets you the head page where you can store all sorts
> of information about the chunk of memory.

Can you please point me to this function/macro? I don't seem to be able
to find it, at least not in 4.15

During hardened user copy permission check, I need to confirm if the
memory range that would be exposed to userspace is a legitimate
sub-range of a pmalloc allocation.


So, I start with the pair (address, size) and I must end up to something
I can compare it against.
The idea here is to pass through struct_page and then the related
vm_struct/vmap_area, which already has the information about the
specific chunk of virtual memory.

I cannot comment on your proposal because I do not know where to find
the reference you made, or maybe I do not understand what you mean :-(

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
