Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A94C6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:48:53 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id g67-v6so6500748otb.10
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:48:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 91-v6si5195946oto.257.2018.04.24.09.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 09:48:52 -0700 (PDT)
Date: Tue, 24 Apr 2018 12:48:50 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <850575801.19606468.1524588530119.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180424132057.GE17484@dhcp22.suse.cz>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com> <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com> <20180422125141.GF17484@dhcp22.suse.cz> <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com> <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com> <20180424132057.GE17484@dhcp22.suse.cz>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in
 gfp_kmemleak_mask
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chunyu Hu <chuhu.ncepu@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>



----- Original Message -----
> From: "Michal Hocko" <mhocko@kernel.org>
> To: "Chunyu Hu" <chuhu.ncepu@gmail.com>
> Cc: "Dmitry Vyukov" <dvyukov@google.com>, "Catalin Marinas" <catalin.marinas@arm.com>, "Chunyu Hu"
> <chuhu@redhat.com>, "LKML" <linux-kernel@vger.kernel.org>, "Linux-MM" <linux-mm@kvack.org>
> Sent: Tuesday, April 24, 2018 9:20:57 PM
> Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
> 
> On Mon 23-04-18 12:17:32, Chunyu Hu wrote:
> [...]
> > So if there is a new flag, it would be the 25th bits.
> 
> No new flags please. Can you simply store a simple bool into fail_page_alloc
> and have save/restore api for that?

Hi Michal,

I still don't get your point. The original NOFAIL added in kmemleak was 
for skipping fault injection in page/slab  allocation for kmemleak object, 
since kmemleak will disable itself until next reboot, whenever it hit an 
allocation failure, in that case, it will lose effect to check kmemleak 
in errer path rose by fault injection. But NOFAULT's effect is more than 
skipping fault injection, it's also for hard allocation. So a dedicated flag
for skipping fault injection in specified slab/page allocation was mentioned.
 
d9570ee3bd1d ("kmemleak: allow to coexist with fault injection") 
  
Do you mean something like below, with the save/store api? But looks like
to make it possible to skip a specified allocation, not global disabling,
a bool is not enough, and a gfp_flag is also needed. Maybe I missed something?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d..ca6f609 100644                                                                                                                     
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3053,14 +3053,28 @@ struct page *rmqueue(struct zone *preferred_zone,
 
    bool ignore_gfp_highmem;
    bool ignore_gfp_reclaim;
+   bool ignore_kmemleak_fault;
    u32 min_order;
 } fail_page_alloc = { 
    .attr = FAULT_ATTR_INITIALIZER,
    .ignore_gfp_reclaim = true,
    .ignore_gfp_highmem = true,
+   .ignore_kmemleak_fault = true,
    .min_order = 1,
 };
 
+bool saved_fail_page_alloc_ignore;
+void fail_page_alloc_ignore_save(void)
+{
+   saved_fail_page_alloc_ignore = fail_page_alloc.ignore_kmemleak_fault;
+   fail_page_alloc.ignore_kmemleak_fault = true;
+}
+
+void fail_page_alloc_ignore_restore(void)
+{
+   fail_page_alloc.ignore_kmemleak_fault = saved_fail_page_alloc_ignore;
+}
+
 static int __init setup_fail_page_alloc(char *str)
 {
    return setup_fault_attr(&fail_page_alloc.attr, str);
@@ -3075,6 +3089,9 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
        return false;
    if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
        return false;
+   /* looks like here we still need a new GFP_KMEMLKEAK flag ... */
+   if (fail_page_alloc.ignore_kmemleak_fault && (gfp_mask & __GFP_KMEMLEAK))
+       return false;
    if (fail_page_alloc.ignore_gfp_reclaim &&
            (gfp_mask & __GFP_DIRECT_RECLAIM))
        return false;   

> 
> --
> Michal Hocko
> SUSE Labs
> 

-- 
Regards,
Chunyu Hu
