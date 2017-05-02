Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 911A76B02F4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 05:16:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g67so13056285wrd.0
        for <linux-mm@kvack.org>; Tue, 02 May 2017 02:16:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a33si19844776wra.282.2017.05.02.02.16.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 02:16:33 -0700 (PDT)
Date: Tue, 2 May 2017 11:16:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] dev/mem: "memtester -p 0x6c80000000000 10G" cause crash
Message-ID: <20170502091630.GH14593@dhcp22.suse.cz>
References: <59083C5B.5080204@huawei.com>
 <20170502084323.GG14593@dhcp22.suse.cz>
 <590848B0.2000801@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <590848B0.2000801@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shakeel Butt <shakeelb@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On Tue 02-05-17 16:52:00, Xishi Qiu wrote:
> On 2017/5/2 16:43, Michal Hocko wrote:
> 
> > On Tue 02-05-17 15:59:23, Xishi Qiu wrote:
> >> Hi, I use "memtester -p 0x6c80000000000 10G" to test physical address 0x6c80000000000
> >> Because this physical address is invalid, and valid_mmap_phys_addr_range()
> >> always return 1, so it causes crash.
> >>
> >> My question is that should the user assure the physical address is valid?
> > 
> > We already seem to be checking range_is_allowed(). What is your
> > CONFIG_STRICT_DEVMEM setting? The code seems to be rather confusing but
> > my assumption is that you better know what you are doing when mapping
> > this file.
> > 
> 
> HI Michal,
> 
> CONFIG_STRICT_DEVMEM=y, and range_is_allowed() will skip memory, but
> 0x6c80000000000 is not memory, it is just a invalid address, so it cause
> crash. 

OK, I only now looked at the value. It is beyond addressable limit
(for 47b address space). None of the checks seems to stop this because
range_is_allowed() resp. its devmem_is_allowed() will allow it as a
non RAM (!page_is_ram check). I am not really sure how to fix this or
whether even we should try to fix this particular problem. As I've said
/dev/mem is dangerous and you should better know what you are doing when
accessing it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
