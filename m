Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id CB1BC6B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 23:49:04 -0400 (EDT)
Message-ID: <50120FA8.20409@redhat.com>
Date: Thu, 26 Jul 2012 23:48:56 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <50118E7F.8000609@redhat.com>
In-Reply-To: <50118E7F.8000609@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/26/2012 02:37 PM, Rik van Riel wrote:
> On 07/23/2012 12:04 AM, Hugh Dickins wrote:
>
>> I spent hours trying to dream up a better patch, trying various
>> approaches.  I think I have a nice one now, what do you think?  And
>> more importantly, does it work?  I have not tried to test it at all,
>> that I'm hoping to leave to you, I'm sure you'll attack it with gusto!
>>
>> If you like it, please take it over and add your comments and signoff
>> and send it in.  The second part won't come up in your testing, and 
>> could
>> be made a separate patch if you prefer: it's a related point that struck
>> me while I was playing with a different approach.
>>
>> I'm sorely tempted to leave a dangerous pair of eyes off the Cc,
>> but that too would be unfair.
>>
>> Subject-to-your-testing-
>> Signed-off-by: Hugh Dickins <hughd@google.com>
>
> This patch looks good to me.
>
> Larry, does Hugh's patch survive your testing?
>
>
Like I said earlier, no.  However, I finally set up a reproducer that 
only takes a few seconds
on a large system and this totally fixes the problem:

-------------------------------------------------------------------------------------------------------------------------
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c36febb..cc023b8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2151,7 +2151,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, 
struct mm_struct *src,
                         goto nomem;

                 /* If the pagetables are shared don't copy or take 
references */
-               if (dst_pte == src_pte)
+               if (*(unsigned long *)dst_pte == *(unsigned long *)src_pte)
                         continue;

                 spin_lock(&dst->page_table_lock);
---------------------------------------------------------------------------------------------------------------------------

When we compare what the src_pte & dst_pte point to instead of their 
addresses everything works,
I suspect there is a missing memory barrier somewhere ???

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
