Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 341706B2A79
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:30:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a26-v6so2978007pgw.7
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:30:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f5-v6si4475143plf.411.2018.08.23.07.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 07:30:47 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: Always call tlb_finish_mmu().
References: <1535023848-5554-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180823115957.GF29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <6bf40c7f-3e68-8702-b087-9e37abb2d547@i-love.sakura.ne.jp>
Date: Thu, 23 Aug 2018 22:48:22 +0900
MIME-Version: 1.0
In-Reply-To: <20180823115957.GF29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 2018/08/23 20:59, Michal Hocko wrote:
> On Thu 23-08-18 20:30:48, Tetsuo Handa wrote:
>> Commit 93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
>> notifiers") added "continue;" without calling tlb_finish_mmu(). I don't
>> know whether tlb_flush_pending imbalance causes problems other than
>> extra cost, but at least it looks strange.
> 
> tlb_flush_pending has mm scope and it would confuse
> mm_tlb_flush_pending. At least ptep_clear_flush could get confused and
> flush unnecessarily for prot_none entries AFAICS. Other paths shouldn't
> trigger for oom victims. Even ptep_clear_flush is unlikely to happen.
> So nothing really earth shattering but I do agree that it looks weird
> and should be fixed.

OK. But what is the reason we call tlb_gather_mmu() before
mmu_notifier_invalidate_range_start_nonblock() ?
I want that the fix explains why we can't do

-			tlb_gather_mmu(&tlb, mm, start, end);
 			if (mmu_notifier_invalidate_range_start_nonblock(mm, start, end)) {
 				ret = false;
 				continue;
 			}
+			tlb_gather_mmu(&tlb, mm, start, end);

instead.
