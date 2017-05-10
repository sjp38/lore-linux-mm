Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 262C7280842
	for <linux-mm@kvack.org>; Wed, 10 May 2017 04:05:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z88so5927523wrc.9
        for <linux-mm@kvack.org>; Wed, 10 May 2017 01:05:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v67si3429634wmv.2.2017.05.10.01.05.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 01:05:44 -0700 (PDT)
Date: Wed, 10 May 2017 10:05:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC v2: post-init-read-only protection for data allocated
 dynamically
Message-ID: <20170510080542.GF31466@dhcp22.suse.cz>
References: <9200d87d-33b6-2c70-0095-e974a30639fd@huawei.com>
 <a445774f-a307-25aa-d44e-c523a7a42da6@redhat.com>
 <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b55343e-4305-a9f1-2b17-51c3c734aea6@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri 05-05-17 13:42:27, Igor Stoppa wrote:
> On 04/05/17 19:49, Laura Abbott wrote:
> > [adding kernel-hardening since I think there would be interest]
> 
> thank you, I overlooked this
> 
> 
> > BPF takes the approach of calling set_memory_ro to mark regions as
> > read only. I'm certainly over simplifying but it sounds like this
> > is mostly a mechanism to have this happen mostly automatically.
> > Can you provide any more details about tradeoffs of the two approaches?
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

This aspect of various sizes makes the SLAB allocator not optimal
because it operates on caches (pools of pages) which manage objects of
the same size. You could use the maximum size of all objects and waste
some memory but you would have to know this max in advance which would
make this approach less practical. You could create more caches of
course but that still requires to know those sizes in advance.

So it smells like a dedicated allocator which operates on a pool of
pages might be a better option in the end. This depends on what you
expect from the allocator. NUMA awareness? Very effective hotpath? Very
good fragmentation avoidance? CPU cache awareness? Special alignment
requirements? Reasonable free()? Etc...

To me it seems that this being an initialization mostly thingy a simple
allocator which manages a pool of pages (one set of sealed and one for
allocations) and which only appends new objects as they fit to unsealed
pages would be sufficient for starter.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
