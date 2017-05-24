Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 06D436B02F4
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:42:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g143so37427678wme.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 03:42:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m24si22866321edc.125.2017.05.24.03.42.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 03:42:55 -0700 (PDT)
Subject: Re: [Question] Mlocked count will not be decreased
References: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
 <85591559-2a99-f46b-7a5a-bc7affb53285@huawei.com>
 <93f1b063-6288-d109-117d-d3c1cf152a8e@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <53778229-34ed-56a2-7f94-c8cd2f519de6@suse.cz>
Date: Wed, 24 May 2017 12:42:21 +0200
MIME-Version: 1.0
In-Reply-To: <93f1b063-6288-d109-117d-d3c1cf152a8e@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>, Qiuxishi <qiuxishi@huawei.com>

On 05/24/2017 12:32 PM, Vlastimil Babka wrote:
> 
> Weird, I can reproduce the issue on my desktop's 4.11 distro kernel, but
> not in qemu and small kernel build, for some reason. So I couldn't test

Ah, Tetsuo's more aggressive testcase worked and I can confirm the fix.
However this would be slightly better, as it doesn't do the increment in
fastpath:

diff --git a/mm/mlock.c b/mm/mlock.c
index 0dd9ca18e19e..721679a2c1aa 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -286,7 +286,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 {
        int i;
        int nr = pagevec_count(pvec);
-       int delta_munlocked;
+       int delta_munlocked = -nr;
        struct pagevec pvec_putback;
        int pgrescued = 0;
 
@@ -306,6 +306,8 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
                                continue;
                        else
                                __munlock_isolation_failed(page);
+               } else {
+                       delta_munlocked++;
                }
 
                /*
@@ -317,7 +319,6 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
                pagevec_add(&pvec_putback, pvec->pages[i]);
                pvec->pages[i] = NULL;
        }
-       delta_munlocked = -nr + pagevec_count(&pvec_putback);
        __mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
        spin_unlock_irq(zone_lru_lock(zone));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
