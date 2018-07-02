Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4B66B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 05:27:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g16-v6so5434591edq.10
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 02:27:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j10-v6si301799edn.439.2018.07.02.02.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 02:27:15 -0700 (PDT)
Date: Mon, 2 Jul 2018 11:27:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Issue fixed by commit 53a59fc67f97 is surfacing again..
Message-ID: <20180702092713.GA19043@dhcp22.suse.cz>
References: <11416e51-08b5-11ec-a2c8-9078c386d895@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <11416e51-08b5-11ec-a2c8-9078c386d895@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri 29-06-18 17:32:00, Laurent Dufour wrote:
[...]
> As Power is 64K page size based, MAX_GATHER_BATCH = 8189, so
> MAX_GATHER_BATCH_COUNT will not exceed 1.
> 
> So there is no way to loop in zap_pte_range() due to the batch's limit.
> I guess we are never hitting the workaround introduced in the commit
> 53a59fc67f97. By the way should cond_resched being called in zap_pte_range()
> when the flush is due to the batch's limit ?

Well, I guess you are missing 2 things here. zap path does cond_resched
once per pmd regardless of the batching. MAX_GATHER_BATCH_COUNT is there
to not accumulate too many pages to free at once after we are done with
the address space tear down (tlb_finish_mmu). So whatever is the
batching it should not have a big effect on the zap part.
[...]
> Anyway, this should not fix the soft lockup I'm facing because
> MAX_GATHER_BATCH_COUNT=1 on ppc64.
> 
> Indeed, I'm wondering if the 10K pages is too large in some cases, especially
> when the node is loaded, and contention on the pte lock is likely to happen.
> Here with less than 8k pages processed soft lockup are surfacing.
> 
> Should the MAX_GATHER_BATCH limit be forced to lower value on ppc64 or more
> code introduced to work around that ?

Have you tried to profile what is taking so long? Exit path is not
parallel to hit on pte locks and having many processes shouldn't add to
any lock contention I can see. Why is per-pmd cond_resched not enough?
-- 
Michal Hocko
SUSE Labs
