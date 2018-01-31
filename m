Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7255B6B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 03:43:15 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d17so4001372wrc.9
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 00:43:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7si12038556wrc.554.2018.01.31.00.43.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 00:43:14 -0800 (PST)
Date: Wed, 31 Jan 2018 09:43:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: optimize memory hotplug
Message-ID: <20180131084313.GP21609@dhcp22.suse.cz>
References: <20180131054243.28141-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180131054243.28141-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com

On Wed 31-01-18 00:42:43, Pavel Tatashin wrote:
> This patch was inspired by the discussion of this problem:
> http://lkml.kernel.org/r/20180130083006.GB1245@in.ibm.com
> 
> Currently, during memory hotplugging we traverse struct pages several
> times:
> 
> 1. memset(0) in sparse_add_one_section()
> 2. loop in __add_section() to set do: set_page_node(page, nid); and
>    SetPageReserved(page);
> 3. loop in pages_correctly_reserved() to check that SetPageReserved is set.
> 4. loop in memmap_init_zone() to call __init_single_pfn()
> 
> This patch removes loops 1, 2, and 3 and only leaves the loop 4, where all
> struct page fields are initialized in one go, the same as it is now done
> during boot.

So how do we check that there is no page_to_nid() user before we online
the page? I remember I was fighting strange bugs when reworking this
code. I have forgot all the details of course, I just remember some
nasty and subtle code paths. Maybe we have got rid of those in the past
year but this should be done really carefully. We might have similar
dependences on PageReserved.

That being said, it would be great if we could simplify this. I think
that 3) can be removed right away. It is a pure paranoia. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
