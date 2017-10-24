Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0036B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 04:12:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so7762592wmu.10
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 01:12:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si6896922wrz.329.2017.10.24.01.12.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 01:12:33 -0700 (PDT)
Date: Tue, 24 Oct 2017 10:12:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
Message-ID: <20171024081232.6to62flr7h3qgxvv@dhcp22.suse.cz>
References: <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
 <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
 <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
 <20171023180232.luayzqacnkepnm57@dhcp22.suse.cz>
 <0c934e18-5436-792f-2b2c-ebca3ae2d786@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c934e18-5436-792f-2b2c-ebca3ae2d786@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue 24-10-17 09:41:46, C.Wehrmeyer wrote:
[...]
> 1. Provide mmap with some sort of flag (which would be redundant IMHO) in
> order to churn out properly aligned pages (not transparent, but the current
> MAP_HUGETLB flag isn't either).

You can easily implement such a thing in userspace. In fact glibc has
already done that for you.

> 2. Based on THP enabling status always churn out properly aligned pages, and
> just failsafe to smaller pages if hugepages couldn't be allocated (truly
> transparent).
> 3. Map in memory, then tell madvise to make as many hugepages out of it as
> possible while still keeping the initial mapping (not transparent, and not
> sure Linux can actually do that).

I think there is still some confusion here. Kernel will try to fault in
THP pages on properly aligned addresses. So if you create a larger
mapping than the THP size then you will get a THP (assuming the memory
is not fragmented). It is just the unaligned addresses will get regular
pages.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
