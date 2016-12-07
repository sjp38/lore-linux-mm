Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEADB6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:58:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so34688787wme.5
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:58:12 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id k11si7432630wmb.125.2016.12.07.00.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 00:58:11 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id kp2so48563001wjc.0
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:58:11 -0800 (PST)
Date: Wed, 7 Dec 2016 09:58:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
Message-ID: <20161207085809.GD17136@dhcp22.suse.cz>
References: <584523E4.9030600@huawei.com>
 <58461A0A.3070504@huawei.com>
 <20161207084305.GA20350@dhcp22.suse.cz>
 <7b74a021-e472-a21e-7936-6741e07906b5@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7b74a021-e472-a21e-7936-6741e07906b5@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Wed 07-12-16 09:48:52, Vlastimil Babka wrote:
> On 12/07/2016 09:43 AM, Michal Hocko wrote:
> > On Tue 06-12-16 09:53:14, Xishi Qiu wrote:
> >> A compiler could re-read "old_flags" from the memory location after reading
> >> and calculation "flags" and passes a newer value into the cmpxchg making 
> >> the comparison succeed while it should actually fail.
> >>
> >> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> >> Suggested-by: Christian Borntraeger <borntraeger@de.ibm.com>
> >> ---
> >>  mm/mmzone.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/mmzone.c b/mm/mmzone.c
> >> index 5652be8..e0b698e 100644
> >> --- a/mm/mmzone.c
> >> +++ b/mm/mmzone.c
> >> @@ -102,7 +102,7 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
> >>  	int last_cpupid;
> >>  
> >>  	do {
> >> -		old_flags = flags = page->flags;
> >> +		old_flags = flags = READ_ONCE(page->flags);
> >>  		last_cpupid = page_cpupid_last(page);
> > 
> > what prevents compiler from doing?
> > 		old_flags = READ_ONCE(page->flags);
> > 		flags = READ_ONCE(page->flags);
> 
> AFAIK, READ_ONCE tells the compiler that page->flags is volatile. It
> can't read from volatile location more times than being told?

But those are two different variables which we assign to so what
prevents the compiler from applying READ_ONCE on each of them
separately? Anyway, this could be addressed easily by 
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 5652be858e5e..b4e093dd24c1 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -102,10 +102,10 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
 	int last_cpupid;
 
 	do {
-		old_flags = flags = page->flags;
+		old_flags = READ_ONCE(page->flags);
 		last_cpupid = page_cpupid_last(page);
 
-		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
+		flags = old_flags & ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
 		flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
 	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
 

> > Or this doesn't matter?
> 
> I think it would matter.
> 
> >>  
> >>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
> >> -- 
> >> 1.8.3.1
> >>
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
