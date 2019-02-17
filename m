Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEC08C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 17:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9720921934
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 17:06:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9720921934
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3793C8E0003; Sun, 17 Feb 2019 12:06:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 303808E0001; Sun, 17 Feb 2019 12:06:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3EA8E0003; Sun, 17 Feb 2019 12:06:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B32EE8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 12:06:36 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id h65so3308481wrh.16
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 09:06:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:references:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=MaNfqnJ2sX4P3SPjigjC3FcIjHvs3ufwxGgJSOZpIyM=;
        b=hAK7bi+1F1mTdGI2ENqdrrSFRo/HJEbHcOO3IRkUrGU1CcYqF0Xlj8x7TrPqgrUmFU
         nGONiShasXxtU3lZLs2VAxn3xmtd0BY/CsXAXCXPaCxbBZhZ81PQ6Dsge0SmKPnDESYp
         XQMAkk7nMd/fEwsI7tMvbo0O4a/CrwQwHmS/0c3co69AM9y/hufI9Awuob87F49stiQg
         Q+KvTki+1/2DWebAFIioKfbtPzURy0J0aMXBVl0IF0RRqgTEPH9+srKRP2W9smcUZtIz
         JMgVkzxsvPXJL3uMPoYfdADh+Jj64ZH0hqeIg4BdeXaKNCWP5WLBvok7cNRNQeG86gtV
         ytYg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: AHQUAuYMVr2W4BouX5UOxvgV4udYpmS9vccNfGpQPTXN2WyaFFCFm5Sp
	GdbFEHABSmeXCweJSjmbazFmOfZijUF6NWFL7y3iyzR/lewhc+pZlYwTUE7Hj26dbS5IiNRNabk
	7aq0R0BVjUozw1uEGBuM9CIy/eiOprxnSBXjcBj7B5PJpIj2Z4G2Slq32EF5zGZc=
X-Received: by 2002:a1c:f319:: with SMTP id q25mr12424669wmq.151.1550423196000;
        Sun, 17 Feb 2019 09:06:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZNRLbWpcrAFRrPsDXYZLw5rdsY79eyzSWw382zE/HTfoEAswdJWbTRV+QnmFKltL1rM3xL
X-Received: by 2002:a1c:f319:: with SMTP id q25mr12424630wmq.151.1550423194831;
        Sun, 17 Feb 2019 09:06:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550423194; cv=none;
        d=google.com; s=arc-20160816;
        b=HB8swA/ppQXa0C0crC6F88L4cWMmbR3KqAr4WEHsqe12Yrz6bJ8H6+iucCN1D3qWBy
         hXae2tqtiPET/OTYum4Kx8Oj1ZRis2AJkFdATkK0+3mZFfWVRc8k1O3LqbQZ8GV2V3DH
         bpBf2A3frcy7GJBVO6o2nM0LOmN2W/XOrCfdmqupqX2YcLDHDdCG1w88lTLSyc4ZTBsU
         UMcPC/mWJBxb9IP7yKD5/RmsMK1dioUbgRfPd//XG3LFjfOXSwCfBkx1saoy5fDVcB5+
         owe/4gqXA9PiCErkGTcEAKWsHIJKCrvI1pZB8ieYHclU9r3Rm1EfH9527EgkpDlpryPL
         3geg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:to:subject:from;
        bh=MaNfqnJ2sX4P3SPjigjC3FcIjHvs3ufwxGgJSOZpIyM=;
        b=KrInZpjxoEPFqXOBLsHAj2uzomRAKuUEOdhaWzBrW5ocTmf/g+edz1ROGM4Tzev9F0
         ofGlm2ejCmiY8BHZ4PbwIV1uQ8XOFPFWT8KBSE/HF5Vqt3uNHivAvGEkNCcqZxcqN+v6
         dAJMg8wsWZS7w7S+1E4d54xGSj8ztJWrqBSkxt7k1P8zYoaqsz4CnHkVz9Tw+iuPjbox
         sMlOU+kW9n6/K0UCgid2FjLVLLyOwl5JUCJEEg90K+3pGK+5Wm1lwSPRyQOGzzoh9l3w
         6p80j9DxiU7GCHowsS1BlMonWajaTFufhN1/nU7LqPuZ3HeGHLo2tgvEjQKYiP7+13mS
         ooHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id o6si4738088wrp.319.2019.02.17.09.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 09:06:34 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id A9E19FF802;
	Sun, 17 Feb 2019 17:06:26 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH v3] hugetlb: allow to free gigantic pages regardless of
 the configuration
To: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190214193100.3529-1-alex@ghiti.fr>
 <c6d9be5f-3b3a-c95b-0045-9f98ea52a5c4@intel.com>
Message-ID: <37046a52-a0eb-cb1a-0a72-601cdee45917@ghiti.fr>
Date: Sun, 17 Feb 2019 12:06:26 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <c6d9be5f-3b3a-c95b-0045-9f98ea52a5c4@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/15/19 12:34 PM, Dave Hansen wrote:
>> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
>> +#ifdef CONFIG_CONTIG_ALLOC
>>   /* The below functions must be run on a range from a single zone. */
>>   extern int alloc_contig_range(unsigned long start, unsigned long end,
>>   			      unsigned migratetype, gfp_t gfp_mask);
>> -extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>>   #endif
>> +extern void free_contig_range(unsigned long pfn, unsigned int nr_pages);
> There's a lot of stuff going on in this patch.  Adding/removing config
> options.  Please get rid of these superfluous changes or at least break
> them out.


I agree that this patch does a lot of things. I am going at least to 
split it
into 2 separate patches, one suggested-by Vlastimil regarding the renaming
of MEMORY_ISOLATION && COMPACTION || CMA, and another that indeed
does what was primarily intended.


>>   #ifdef CONFIG_CMA
>>   /* CMA stuff */
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 25c71eb8a7db..138a8df9b813 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -252,12 +252,17 @@ config MIGRATION
>>   	  pages as migration can relocate pages to satisfy a huge page
>>   	  allocation instead of reclaiming.
>>   
>> +
>>   config ARCH_ENABLE_HUGEPAGE_MIGRATION
>>   	bool
> Like this. :)


My apologies for that.


>>   config ARCH_ENABLE_THP_MIGRATION
>>   	bool
>>   
>> +config CONTIG_ALLOC
>> +	def_bool y
>> +	depends on (MEMORY_ISOLATION && COMPACTION) || CMA
>> +
>>   config PHYS_ADDR_T_64BIT
>>   	def_bool 64BIT
> Please think carefully though the Kconfig dependencies.  'select' is
> *not* the same as 'depends on'.
>
> This replaces a bunch of arch-specific "select ARCH_HAS_GIGANTIC_PAGE"
> with a 'depends on'.  I *think* that ends up being OK, but it absolutely
> needs to be addressed in the changelog about why *you* think it is OK
> and why it doesn't change the functionality of any of the patched
> architetures.


Ok.


>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index afef61656c1e..e686c92212e9 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1035,7 +1035,6 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
>>   		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
>>   		nr_nodes--)
>>   
>> -#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>>   static void destroy_compound_gigantic_page(struct page *page,
>>   					unsigned int order)
>>   {
> Whats the result of this #ifdef removal?  A universally larger kernel
> even for architectures that do not support runtime gigantic page
> alloc/free?  That doesn't seem like a good thing.


Ok, I agree, now that we removed the "wrong" definition of 
ARCH_HAS_GIGANTIC_PAGE,
we can actually use this define for architectures to show they support 
gigantic pages
and avoid the problem you mention. Thanks.


>> @@ -1058,6 +1057,12 @@ static void free_gigantic_page(struct page *page, unsigned int order)
>>   	free_contig_range(page_to_pfn(page), 1 << order);
>>   }
>>   
>> +static inline bool gigantic_page_runtime_allocation_supported(void)
>> +{
>> +	return IS_ENABLED(CONFIG_CONTIG_ALLOC);
>> +}
> Why bother having this function?  Why don't the callers just check the
> config option directly?


Ok, this function is only used once in set_max_huge_pages where you
mention the need for a comment, so I can get rid of it. Thanks.


>> +#ifdef CONFIG_CONTIG_ALLOC
>>   static int __alloc_gigantic_page(unsigned long start_pfn,
>>   				unsigned long nr_pages, gfp_t gfp_mask)
>>   {
>> @@ -1143,22 +1148,15 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>>   static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
>>   static void prep_compound_gigantic_page(struct page *page, unsigned int order);
>>   
>> -#else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
>> -static inline bool gigantic_page_supported(void) { return false; }
>> +#else /* !CONFIG_CONTIG_ALLOC */
>>   static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
>>   		int nid, nodemask_t *nodemask) { return NULL; }
>> -static inline void free_gigantic_page(struct page *page, unsigned int order) { }
>> -static inline void destroy_compound_gigantic_page(struct page *page,
>> -						unsigned int order) { }
>>   #endif
>>   
>>   static void update_and_free_page(struct hstate *h, struct page *page)
>>   {
>>   	int i;
>>   
>> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
>> -		return;
> I don't get the point of removing this check.  Logically, this reads as
> checking if the architecture supports gigantic hstates and has nothing
> to do with allocation.

I think this check was wrong from the beginning: gigantic_page_supported()
was only checking (MEMORY_ISOLATION && COMPACTION) || CMA, which has
nothing to do with the capability to free gigantic pages.

But then I went through all the architectures to see if removing this 
test could
affect any of them. And I noticed that if an architecture supports gigantic
page without advertising it with ARCH_HAS_GIGANTIC_PAGE, then it would
decrement the number of free huge page but would not actually free the 
pages.

I found at least 2 archs that have gigantic pages, but do not allow
runtime allocation nor freeing of those pages because they do not define
the (wrong) ARCH_HAS_GIGANTIC_PAGE:

- ia64 has HPAGE_SHIFT_DEFAULT = 28, with PAGE_SHIFT = 14
- sh has max HPAGE_SHIFT = 29 and max PAGE_SHIFT = 16

with default MAX_ORDER = 11, both architectures support gigantic pages.

So I'm going to propose a patch that selects the (right) 
ARCH_HAS_GIGANTIC_PAGE
for those archs, because I think they should be able to free their boottime
gigantic pages.

Regarding this check, we can either remove it if we are sure that
every architecture that has gigantic pages selects ARCH_HAS_GIGANTIC_PAGE,
or leaving it in case some future archs forget to select it.

I'd rather patch all archs so that they can at least free gigantic pages and
then remove the test since hstate_is_gigantic would imply 
gigantic_page_supported.
I will propose something like that if you agree.


>>   	h->nr_huge_pages--;
>>   	h->nr_huge_pages_node[page_to_nid(page)]--;
>>   	for (i = 0; i < pages_per_huge_page(h); i++) {
>> @@ -2276,13 +2274,20 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
>>   }
>>   
>>   #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
>> -static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
>> +static int set_max_huge_pages(struct hstate *h, unsigned long count,
>>   						nodemask_t *nodes_allowed)
>>   {
>>   	unsigned long min_count, ret;
>>   
>> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
>> -		return h->max_huge_pages;
>> +	if (hstate_is_gigantic(h) &&
>> +		!gigantic_page_runtime_allocation_supported()) {
> The indentation here is wrong and reduces readability.  Needs to be like
> this:
>
> 	if (hstate_is_gigantic(h) &&
> 	    !gigantic_page_runtime_allocation_supported()) {


This will disappear with your previous remark, thanks.


>> +		spin_lock(&hugetlb_lock);
>> +		if (count > persistent_huge_pages(h)) {
>> +			spin_unlock(&hugetlb_lock);
>> +			return -EINVAL;
>> +		}
>> +		goto decrease_pool;
>> +	}
> Needs comments.
>
> 	/* Gigantic pages can be freed but not allocated */
>
> or something.
>

Ok, I agree, I'll add that and another sentence regarding the removal
of gigantic_page_runtime_allocation_supported.

Thank you Dave for your comments !

Alex

