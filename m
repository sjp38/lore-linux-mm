Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30E9BC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:48:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1D0A2173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:48:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1D0A2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C7E06B0003; Tue, 21 May 2019 04:48:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5512D6B0005; Tue, 21 May 2019 04:48:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CC646B0006; Tue, 21 May 2019 04:48:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7A976B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:48:35 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id 134so2999013lfk.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 01:48:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KnTJ924Dn9Lr3YGh22gq9VtJDDN4nBsJGSeWXVP+mV0=;
        b=Y93QckMXLy+YAtcHtUH586IMLmrsBcqZdnnnSRc53okTLJJUTcVShaQKnCnV2fqSbw
         yR3z3aYVijwg3ZQsrD3Ya9HrACYq8tHpBzhorVxBoZEVHBEscFN0X/jTPmyHuK4rfZgJ
         CNDGSi/9OrcnrkD2c/ZIsFbO5Mu3v9FqX8NCyKiBSh9TJl+2obFDPgygc9heE1PhVc8j
         SLWC1BCE7R9EFUNNfpgRTfMD0P6Zv/fRpd8ECPTSF3QVK0VfyQt0FlLXEctjKhrYdTcf
         vFXOotDSAyV8NF5ol1AY4V99scndcKztq+FQqf4Q5M2ACBu1LUeSFp3LVxHaYCmJqt9g
         wuPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWp4vp2GeQeZasN4qbTcvoyntIN38WBwWpYr9ePr998eoi0eSPs
	NujC1PhQjrd94a1D4AK+PFh0nv6Yvul2+wme3bt3XznLECTLYRB1bJx+PigPaWfTyCKAUfkmoXo
	VOgOshxwuZMfmymdhbbl/VHwVIAUzlXvD7duTLdaooidOk2u0nCEKL+t1JTU3fOoIDw==
X-Received: by 2002:ac2:482a:: with SMTP id 10mr25457030lft.51.1558428515250;
        Tue, 21 May 2019 01:48:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxGmApsTfcB2J9jS7GSHIX1kJ/GnQ2ne96J3LyXQ4esecQVU9SHydtasvc3HgUFhOzIhd9
X-Received: by 2002:ac2:482a:: with SMTP id 10mr25456988lft.51.1558428514323;
        Tue, 21 May 2019 01:48:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558428514; cv=none;
        d=google.com; s=arc-20160816;
        b=tqYACepF1JPMSe4AeMiyoEfV819mZVPOuQbzM7y/MWTGifRbEm8qVJhbtxNH52JTfJ
         p7brpEKGu3BZU2Byegtn1LgFIAI14ppU6u1YD2kCGfST9fQpRTBo5MDs9sdU/T5GTYy5
         joxMZIQnX+ElUGY5uw3UUYSKrRbPOE+PhqujlUSmEOqOCSK2siZV73o0UZfKiynnpWON
         Dld5Xx5/eh3lkR5MWgXxHx5XvLcEr6TmPL7qCRChzOeXidSbJwZ4RVd+C0tioUs60H3v
         4mTAYfyNNqg0pOt5Jmbk0qlMb3kjPKC3CBaPw9xk+pPvXbCYvMmxDwPA416e4mMWjweb
         bkJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KnTJ924Dn9Lr3YGh22gq9VtJDDN4nBsJGSeWXVP+mV0=;
        b=gdNbzgQGf3p0dyBTRA+7Szq81TXVomn6Cob3XMkYhmzll2YhGc5ZQeifPPsUBsz/s+
         q9n2PAS1d8urQ4ZJGtauqaskWfMtG9MERqv/yQf7nze9g822NRAewuQj+MNAyip92vZO
         jVgSSEDvl9L1gDBfs/GCTjp+wpY/ncThGnLNkeDPOWGFxlrBblLp6XSALHMm6jyQx5af
         wSBt/KxmLPVPznkHbkkvIoPlelwB7AlNKE8jq3YPEuXPFeulgPeaNIquQ7mOjy8gZftW
         s5oVN3yaKZ4iWQE7UGmjwB1Z3OVlXHGIFGKGY6PTB1eFMv6L3xAirBhlrGAuVG34bl7i
         UUFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id x4si12912020ljh.117.2019.05.21.01.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 01:48:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hT0Re-0003xT-KR; Tue, 21 May 2019 11:48:26 +0300
Subject: Re: [PATCH v2 2/7] mm: Extend copy_vma()
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
 andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com,
 riel@surriel.com, keescook@chromium.org, hannes@cmpxchg.org,
 npiggin@gmail.com, mathieu.desnoyers@efficios.com, shakeelb@google.com,
 guro@fb.com, aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <155836081252.2441.9024100415314519956.stgit@localhost.localdomain>
 <20190521081821.fbngbxk7lzwrb7md@box>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <d4664163-35e2-10e0-9c7b-44fa090b7198@virtuozzo.com>
Date: Tue, 21 May 2019 11:48:26 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190521081821.fbngbxk7lzwrb7md@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Kirill,

On 21.05.2019 11:18, Kirill A. Shutemov wrote:
> On Mon, May 20, 2019 at 05:00:12PM +0300, Kirill Tkhai wrote:
>> This prepares the function to copy a vma between
>> two processes. Two new arguments are introduced.
> 
> This kind of changes requires a lot more explanation in commit message,
> describing all possible corner cases> For instance, I would really like to see a story on why logic around
> need_rmap_locks is safe after the change.

Let me fast answer on the below question firstly, and later I'll write
wide explanations, since this requires much more time.
 
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  include/linux/mm.h |    4 ++--
>>  mm/mmap.c          |   33 ++++++++++++++++++++++++---------
>>  mm/mremap.c        |    4 ++--
>>  3 files changed, 28 insertions(+), 13 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 0e8834ac32b7..afe07e4a76f8 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2329,8 +2329,8 @@ extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
>>  	struct rb_node **, struct rb_node *);
>>  extern void unlink_file_vma(struct vm_area_struct *);
>>  extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
>> -	unsigned long addr, unsigned long len, pgoff_t pgoff,
>> -	bool *need_rmap_locks);
>> +	struct mm_struct *, unsigned long addr, unsigned long len,
>> +	pgoff_t pgoff, bool *need_rmap_locks, bool clear_flags_ctx);
>>  extern void exit_mmap(struct mm_struct *);
>>  
>>  static inline int check_data_rlimit(unsigned long rlim,
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 57803a0a3a5c..99778e724ad1 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -3195,19 +3195,21 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
>>  }
>>  
>>  /*
>> - * Copy the vma structure to a new location in the same mm,
>> - * prior to moving page table entries, to effect an mremap move.
>> + * Copy the vma structure to new location in the same vma
>> + * prior to moving page table entries, to effect an mremap move;
>>   */
>>  struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>> -	unsigned long addr, unsigned long len, pgoff_t pgoff,
>> -	bool *need_rmap_locks)
>> +				struct mm_struct *mm, unsigned long addr,
>> +				unsigned long len, pgoff_t pgoff,
>> +				bool *need_rmap_locks, bool clear_flags_ctx)
>>  {
>>  	struct vm_area_struct *vma = *vmap;
>>  	unsigned long vma_start = vma->vm_start;
>> -	struct mm_struct *mm = vma->vm_mm;
>> +	struct vm_userfaultfd_ctx uctx;
>>  	struct vm_area_struct *new_vma, *prev;
>>  	struct rb_node **rb_link, *rb_parent;
>>  	bool faulted_in_anon_vma = true;
>> +	unsigned long flags;
>>  
>>  	/*
>>  	 * If anonymous vma has not yet been faulted, update new pgoff
>> @@ -3220,15 +3222,25 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>>  
>>  	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
>>  		return NULL;	/* should never get here */
>> -	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
>> -			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
>> -			    vma->vm_userfaultfd_ctx);
>> +
>> +	uctx = vma->vm_userfaultfd_ctx;
>> +	flags = vma->vm_flags;
>> +	if (clear_flags_ctx) {
>> +		uctx = NULL_VM_UFFD_CTX;
>> +		flags &= ~(VM_UFFD_MISSING | VM_UFFD_WP | VM_MERGEABLE |
>> +			   VM_LOCKED | VM_LOCKONFAULT | VM_WIPEONFORK |
>> +			   VM_DONTCOPY);
>> +	}
> 
> Why is the new logic required? No justification given.

Ditto.

>> +
>> +	new_vma = vma_merge(mm, prev, addr, addr + len, flags, vma->anon_vma,
>> +			    vma->vm_file, pgoff, vma_policy(vma), uctx);
>>  	if (new_vma) {
>>  		/*
>>  		 * Source vma may have been merged into new_vma
>>  		 */
>>  		if (unlikely(vma_start >= new_vma->vm_start &&
>> -			     vma_start < new_vma->vm_end)) {
>> +			     vma_start < new_vma->vm_end) &&
>> +			     vma->vm_mm == mm) {
> 
> How can vma_merge() succeed if vma->vm_mm != mm?

We don't use vma as an argument of vma_merge(). We use vma as a source of
vma->anon_vma, vma->vm_file and vma_policy().

We search some new_vma in mm with the same characteristics as vma has in vma->vm_mm.
In case of success vma_merge() returns it for us. For example, it may success, when
vma->vm_mm is mm_struct of forked process, while mm is mm_struct of its parent.

[...]

Kirill

