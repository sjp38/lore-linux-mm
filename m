Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A074EC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:52:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5837920679
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:52:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5837920679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D093D8E0002; Mon, 17 Jun 2019 16:52:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBA2B8E0001; Mon, 17 Jun 2019 16:52:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA97E8E0002; Mon, 17 Jun 2019 16:52:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85C398E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:52:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y9so6531446plp.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:52:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xiANO5ACxkrsUZZlJDdR9TA3COaxevUzdEnrg5cbi/U=;
        b=BVpTpyq9ESt9d6gi1AhhaPfL2PFiICrLY5Mqu+Z1W7jAusF5RWumYnq7siU9g2JmYv
         BfGFejRVBZ3Wucs9rvKDWrCmDCFhqdKlHrsbJj7hdyWeJ4flD8vZYVzeKmNbEuboMsWv
         W9pZJaP+LZlK3NScKRree+L+CO2QN8tbghBLeUKTv44xWSqhAMc0fzWVEPY3Sk6B2s1L
         H0RZpkEQDJ/hZKKN9B8MlxSkpKsTX+6ulOob0whBkG1X8b81kxTA4L0ufDLWT9vIWuhF
         7P3Elvec+B+w8PLv6FUai+R48yGikpSWg6/8qYA+763k44pEDlucHKCacALlAJeTEkpX
         8Fxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWBSmZlcfioJcuAVISAGecFhDH1ohZ/GnU8yEoTECi2mHi8/q7K
	x0VYlNbtn4Wn60Hdaor4Tm5m4Eyj6jkELkItWYr8aAiFvp0gqZVI1lnUsG7FzFs5RlnZjDFIDhx
	i+LSeS//Lpuhvev9qxolB4VXAXfnBhNq5tGjMGje3jagvz+ZpJSnOpFDa2c7RikIdVA==
X-Received: by 2002:aa7:92d2:: with SMTP id k18mr16781127pfa.153.1560804770185;
        Mon, 17 Jun 2019 13:52:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8kWAf28NsZsEwVasdBrVi9tKwkjGtcyE/s17Z01nimFB42IIyxkZG41vz+DqwH4X+DxB5
X-Received: by 2002:aa7:92d2:: with SMTP id k18mr16781018pfa.153.1560804768769;
        Mon, 17 Jun 2019 13:52:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560804768; cv=none;
        d=google.com; s=arc-20160816;
        b=zOdk4ssWLjpo735XHH84J6/jqVoZzmX5zqUH6EQmUN4LCoAGZ0WJaV6TcmXjcCAUOE
         lR1c/hVp3XdYeuCTYG1Oajf4VF3oxonLlk8nS1okepNc5OPwKFuqrWW9SE4CyOO5N8wh
         /NZzHDfPaMiDNNyojvN31rX+3ZkC7TGdE0pB45aM2cmh2h4o55UmD4z42951InAAhCU1
         uNReYEU9VUBPRdwTztKkZ6zGT3MdqfF0FkRWE4nDCdqLm5+4FgJ37y9K10qpiVH2MtOy
         NtT7zizG2s6buIyV2+ZvTkiif8IDtT8WbPepxYd6hicO735LsDd9Oy8oLp56tBMuCR4N
         BqZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xiANO5ACxkrsUZZlJDdR9TA3COaxevUzdEnrg5cbi/U=;
        b=snT9wmTQbFqBAMv1zmYOujiquVgcQ5UdClHlOs3CSDPTJdw1v1MH7vs76nsF7k3pJu
         8aJpYkRBvkBsg0k7bIQVS9ya95UQ6jsBQbMxDxiSA8AgtP8h12o9Otg/3Dv+YCtsjqT1
         6sYSm/W3KadGrM1qzcN8KwFalHN2+cAw4EqnGLlHl7mMwmCDBljL861Xr473ArdJSHnA
         etT12xotrSgsKcfkAw7zrxwq5CGygrbJLaG0UYWhgO2q5HC72rUSj/2vHQcgalkEyLo4
         +OOCjBTFxERmWx1SmchhRnhWomDms+bS4fMwrUw8sEw0SEFqDsMV64D4J7sZCdt4npOH
         WK/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id t7si11512292pgu.3.2019.06.17.13.52.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 13:52:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TURrDIY_1560804746;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TURrDIY_1560804746)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 18 Jun 2019 04:52:32 +0800
Subject: Re: [5.1-stable PATCH] mm: mmu_gather: remove __tlb_reset_range() for
 force flush
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org,
 aneesh.kumar@linux.ibm.com, jstancek@redhat.com, mgorman@suse.de,
 minchan@kernel.org, namit@vmware.com, npiggin@gmail.com,
 peterz@infradead.org, will.deacon@arm.com
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1560804390-28494-1-git-send-email-yang.shi@linux.alibaba.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ec95c6bc-fcf8-e83b-b260-0d9e13ebb870@linux.alibaba.com>
Date: Mon, 17 Jun 2019 13:52:17 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1560804390-28494-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is wrong, please disregard this one. The corrected one will 
be posted soon. Sorry for the inconvenience.


Yang



On 6/17/19 1:46 PM, Yang Shi wrote:
> A few new fields were added to mmu_gather to make TLB flush smarter for
> huge page by telling what level of page table is changed.
>
> __tlb_reset_range() is used to reset all these page table state to
> unchanged, which is called by TLB flush for parallel mapping changes for
> the same range under non-exclusive lock (i.e. read mmap_sem).  Before
> commit dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in
> munmap"), the syscalls (e.g. MADV_DONTNEED, MADV_FREE) which may update
> PTEs in parallel don't remove page tables.  But, the forementioned
> commit may do munmap() under read mmap_sem and free page tables.  This
> may result in program hang on aarch64 reported by Jan Stancek.  The
> problem could be reproduced by his test program with slightly modified
> below.
>
> ---8<---
>
> static int map_size = 4096;
> static int num_iter = 500;
> static long threads_total;
>
> static void *distant_area;
>
> void *map_write_unmap(void *ptr)
> {
> 	int *fd = ptr;
> 	unsigned char *map_address;
> 	int i, j = 0;
>
> 	for (i = 0; i < num_iter; i++) {
> 		map_address = mmap(distant_area, (size_t) map_size, PROT_WRITE | PROT_READ,
> 			MAP_SHARED | MAP_ANONYMOUS, -1, 0);
> 		if (map_address == MAP_FAILED) {
> 			perror("mmap");
> 			exit(1);
> 		}
>
> 		for (j = 0; j < map_size; j++)
> 			map_address[j] = 'b';
>
> 		if (munmap(map_address, map_size) == -1) {
> 			perror("munmap");
> 			exit(1);
> 		}
> 	}
>
> 	return NULL;
> }
>
> void *dummy(void *ptr)
> {
> 	return NULL;
> }
>
> int main(void)
> {
> 	pthread_t thid[2];
>
> 	/* hint for mmap in map_write_unmap() */
> 	distant_area = mmap(0, DISTANT_MMAP_SIZE, PROT_WRITE | PROT_READ,
> 			MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
> 	munmap(distant_area, (size_t)DISTANT_MMAP_SIZE);
> 	distant_area += DISTANT_MMAP_SIZE / 2;
>
> 	while (1) {
> 		pthread_create(&thid[0], NULL, map_write_unmap, NULL);
> 		pthread_create(&thid[1], NULL, dummy, NULL);
>
> 		pthread_join(thid[0], NULL);
> 		pthread_join(thid[1], NULL);
> 	}
> }
> ---8<---
>
> The program may bring in parallel execution like below:
>
>          t1                                        t2
> munmap(map_address)
>    downgrade_write(&mm->mmap_sem);
>    unmap_region()
>    tlb_gather_mmu()
>      inc_tlb_flush_pending(tlb->mm);
>    free_pgtables()
>      tlb->freed_tables = 1
>      tlb->cleared_pmds = 1
>
>                                          pthread_exit()
>                                          madvise(thread_stack, 8M, MADV_DONTNEED)
>                                            zap_page_range()
>                                              tlb_gather_mmu()
>                                                inc_tlb_flush_pending(tlb->mm);
>
>    tlb_finish_mmu()
>      if (mm_tlb_flush_nested(tlb->mm))
>        __tlb_reset_range()
>
> __tlb_reset_range() would reset freed_tables and cleared_* bits, but
> this may cause inconsistency for munmap() which do free page tables.
> Then it may result in some architectures, e.g. aarch64, may not flush
> TLB completely as expected to have stale TLB entries remained.
>
> Use fullmm flush since it yields much better performance on aarch64 and
> non-fullmm doesn't yields significant difference on x86.
>
> The original proposed fix came from Jan Stancek who mainly debugged this
> issue, I just wrapped up everything together.
>
> Fixes: dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Tested-by: Jan Stancek <jstancek@redhat.com>
> Suggested-by: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: stable@vger.kernel.org  4.20+
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> ---
>   mm/mmu_gather.c | 23 ++++++++++++++++++++++-
>   1 file changed, 22 insertions(+), 1 deletion(-)
>
> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
> index f2f03c6..3543b82 100644
> --- a/mm/mmu_gather.c
> +++ b/mm/mmu_gather.c
> @@ -92,9 +92,30 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
>   {
>   	struct mmu_gather_batch *batch, *next;
>   
> +	/*
> +	 * If there are parallel threads are doing PTE changes on same range
> +	 * under non-exclusive lock (e.g., mmap_sem read-side) but defer TLB
> +	 * flush by batching, one thread may end up seeing inconsistent PTEs
> +	 * and result in having stale TLB entries.  So flush TLB forcefully
> +	 * if we detect parallel PTE batching threads.
> +	 *
> +	 * However, some syscalls, e.g. munmap(), may free page tables, this
> +	 * needs force flush everything in the given range. Otherwise this
> +	 * may result in having stale TLB entries for some architectures,
> +	 * e.g. aarch64, that could specify flush what level TLB.
> +	 */
>   	if (force) {
> +		/*
> +		 * The aarch64 yields better performance with fullmm by
> +		 * avoiding multiple CPUs spamming TLBI messages at the
> +		 * same time.
> +		 *
> +		 * On x86 non-fullmm doesn't yield significant difference
> +		 * against fullmm.
> +		 */
> +		tlb->fullmm = 1;
>   		__tlb_reset_range(tlb);
> -		__tlb_adjust_range(tlb, start, end - start);
> +		tlb->freed_tables = 1;
>   	}
>   
>   	tlb_flush_mmu(tlb);

