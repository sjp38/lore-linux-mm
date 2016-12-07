Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 482BC6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 04:59:47 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so81832869wjc.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 01:59:47 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id y130si7651190wmc.29.2016.12.07.01.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 01:59:45 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g23so26770828wme.1
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 01:59:45 -0800 (PST)
Date: Wed, 7 Dec 2016 10:59:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
Message-ID: <20161207095943.GF17136@dhcp22.suse.cz>
References: <584523E4.9030600@huawei.com>
 <58461A0A.3070504@huawei.com>
 <20161207084305.GA20350@dhcp22.suse.cz>
 <7b74a021-e472-a21e-7936-6741e07906b5@suse.cz>
 <20161207085809.GD17136@dhcp22.suse.cz>
 <b3c3cff5-5d47-7a32-9def-9f42640c9211@suse.cz>
 <ceb6c990-6d88-dc79-b494-432ed838f3c9@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ceb6c990-6d88-dc79-b494-432ed838f3c9@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On Wed 07-12-16 10:40:47, Christian Borntraeger wrote:
> On 12/07/2016 10:29 AM, Vlastimil Babka wrote:
> > On 12/07/2016 09:58 AM, Michal Hocko wrote:
> >> On Wed 07-12-16 09:48:52, Vlastimil Babka wrote:
> >>> On 12/07/2016 09:43 AM, Michal Hocko wrote:
> >>>> On Tue 06-12-16 09:53:14, Xishi Qiu wrote:
> >>>>> A compiler could re-read "old_flags" from the memory location after reading
> >>>>> and calculation "flags" and passes a newer value into the cmpxchg making 
> >>>>> the comparison succeed while it should actually fail.
> >>>>>
> >>>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> >>>>> Suggested-by: Christian Borntraeger <borntraeger@de.ibm.com>
> >>>>> ---
> >>>>>  mm/mmzone.c | 2 +-
> >>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>>>>
> >>>>> diff --git a/mm/mmzone.c b/mm/mmzone.c
> >>>>> index 5652be8..e0b698e 100644
> >>>>> --- a/mm/mmzone.c
> >>>>> +++ b/mm/mmzone.c
> >>>>> @@ -102,7 +102,7 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
> >>>>>  	int last_cpupid;
> >>>>>  
> >>>>>  	do {
> >>>>> -		old_flags = flags = page->flags;
> >>>>> +		old_flags = flags = READ_ONCE(page->flags);
> >>>>>  		last_cpupid = page_cpupid_last(page);
> >>>>
> >>>> what prevents compiler from doing?
> >>>> 		old_flags = READ_ONCE(page->flags);
> >>>> 		flags = READ_ONCE(page->flags);
> >>>
> >>> AFAIK, READ_ONCE tells the compiler that page->flags is volatile. It
> >>> can't read from volatile location more times than being told?
> >>
> >> But those are two different variables which we assign to so what
> >> prevents the compiler from applying READ_ONCE on each of them
> >> separately?
> > 
> > I would naively expect that it's assigned to flags first, and then from
> > flags to old_flags. But I don't know exactly the C standard evaluation
> > rules that apply here.
> > 
> >> Anyway, this could be addressed easily by
> > 
> > Yes, that way there should be no doubt.
> 
> That change would make it clearer, but the code is correct anyway,
> as assignments in C are done from right to left, so 
> old_flags = flags = READ_ONCE(page->flags);
> 
> is equivalent to 
> 
> flags = READ_ONCE(page->flags);
> old_flags = flags;

OK, I guess you are right. For some reason I thought that the compiler
is free to bypass flags and split an assignment
a = b = c; into b = c; a = c
which would still follow from right to left rule. I guess I am over
speculating here though, so sorry for the noise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
