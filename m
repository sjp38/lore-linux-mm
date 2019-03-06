Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8CB9C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 20:08:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D975205F4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 20:08:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D975205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B4A08E0003; Wed,  6 Mar 2019 15:08:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1646D8E0002; Wed,  6 Mar 2019 15:08:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07A258E0003; Wed,  6 Mar 2019 15:08:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6BE88E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 15:08:54 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o9so6877138edh.10
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 12:08:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=KzrXqJ9dWlFcqjSEWj9nrNesYCPQkjv/4JeaeHLXinM=;
        b=US+5I87IVgqNepi8FNMXbznjf+ERnV6U7g195s1tKscujZosD9hzilvH1iWzp4YSkz
         Lr3olfDUrHH+8y/ERrqrWeNLj6HrrN4JRVfymP21xXwzBVrJPBMQHyNU+8K8V1lBJX88
         k+SxegzuUzZgwtsCEET4z6PD9LVe2hLC9qeAIXFKgk5uEUBezTPQCIDCrQRK38s3Q6FP
         Lzb7Y/Ks3+7faHI9p2jHOyv0stVWe5r0BqNgHOMXH4wAiBXICNmm2w7hUbUwspwfHmJi
         ACkhXu3E0ptQXwDH6h3C7TtN/j0taWG3rinUvIBaJDcVS58wwTb24Jr56rKRsShq9sY3
         xVhQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW51yHNpIDbk/pC+0eBoEfQHTtyTh5IJdH5jRr61hmtDYxa0jaW
	cAWJNzcbvNItWZpYZqkU5z5N+BRZyb8w3aBK9bGMj3AqerDO1NtqbH1T5AzdZBOSNNR36TNRb2v
	68jrPcD4Hcj5O8/hGoyfFvhJOBXStDfTT9WpmAirbLKVjQ1PrxmQU3/s3kGHj7YM=
X-Received: by 2002:a50:ea87:: with SMTP id d7mr25657342edo.21.1551902934162;
        Wed, 06 Mar 2019 12:08:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqxySa9iDdguBRLgTopy1mj/c3TwxlQ5w4Bxq3BDmaMHR9az8PWLWMCBk+gRoDWxbMvRrqzS
X-Received: by 2002:a50:ea87:: with SMTP id d7mr25657278edo.21.1551902932838;
        Wed, 06 Mar 2019 12:08:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551902932; cv=none;
        d=google.com; s=arc-20160816;
        b=uokGJK91uVU3cZU4YRvHAXsVTDBAWy82/48mWBY0yCkdisZA44r6/ejmmR56mP6nnu
         oONq3w/Garw5jGJ/tpFFdQDysXdmqyCtq6FGcfR/RzyjvwX8lYCpodHiKqrGQt1O3DsK
         DSStOX3lhHQgrih3tuee7dRzaL41zyBS2t89nQFwdiQbwxwn0P4AKTSyIkOmVaSk78yu
         B+Xj/eWn26E4SZbnQDIzUFxnTbPL11NYcsMCyYu4j3me0/nViBpgLvi4tJkLeTaX5UNP
         ZxH6jKmlXJk/whFF9a55qK+hZwSShaW+vBSKkiAkgm2j9HncN1Zjp4FNV+zC3Xv4g8eb
         gyGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=KzrXqJ9dWlFcqjSEWj9nrNesYCPQkjv/4JeaeHLXinM=;
        b=NLRglKWTTcGUpD4eaom/fEVzDRtEjsFaNFmmjYbz4glve46wQd2q3xAdqt+BnSq6sA
         ptP61SPOCCp8Yr+0J9SRmcxzJNcpWs/n2u6UgFKQBLCzdkkI0MGD6tLEKX+KWPVEam6n
         H9dIK4k4LqDburNhSTfNy3M/wDsry9Aw64kfAELHfSXqz8rpiKHa4CDMEpbin5jar2h1
         Z3j6kldOqY+GY2lBnMFvzOfhCDte+7/Qe2luEzsCcx3L3ni2zTFIWtRvNgqSvHzwl4Wq
         NJ1Mz9MHMaq/FiHJPhaopcbbzs1kFq1lfZmQMoiuYAIYDRF58VExGYG1UxFERSbJuDys
         23TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id 39si530965edq.222.2019.03.06.12.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 12:08:52 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 9B140FF806;
	Wed,  6 Mar 2019 20:08:07 +0000 (UTC)
Subject: Re: [PATCH v5 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190306190005.7036-1-alex@ghiti.fr>
 <20190306190005.7036-5-alex@ghiti.fr>
 <7c81abe0-5f9d-32f9-1e9a-70ab06d48f8e@intel.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <82a3f572-e9c1-0151-3d7d-a646f5e5302c@ghiti.fr>
Date: Wed, 6 Mar 2019 15:08:06 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <7c81abe0-5f9d-32f9-1e9a-70ab06d48f8e@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/6/19 2:16 PM, Dave Hansen wrote:
> On 3/6/19 11:00 AM, Alexandre Ghiti wrote:
>> +static int set_max_huge_pages(struct hstate *h, unsigned long count,
>> +			      nodemask_t *nodes_allowed)
>>   {
>>   	unsigned long min_count, ret;
>>   
>> -	if (hstate_is_gigantic(h) && !gigantic_page_supported())
>> -		return h->max_huge_pages;
>> +	/*
>> +	 * Gigantic pages allocation depends on the capability for large page
>> +	 * range allocation. If the system cannot provide alloc_contig_range,
>> +	 * allow users to free gigantic pages.
>> +	 */
>> +	if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
>> +		spin_lock(&hugetlb_lock);
>> +		if (count > persistent_huge_pages(h)) {
>> +			spin_unlock(&hugetlb_lock);
>> +			return -EINVAL;
>> +		}
>> +		goto decrease_pool;
>> +	}
> We talked about it during the last round and I don't seen any mention of
> it here in comments or the changelog: Why is this a goto?  Why don't we
> just let the code fall through to the "decrease_pool" label?  Why is
> this new block needed at all?  Can't we just remove the old check and
> let it be?

I'll get rid of the goto, I don't know how to justify it properly in a 
comment,
maybe because it is not necessary.
This is not a new block, this means exactly the same as before (remember
gigantic_page_supported() actually meant CONTIG_ALLOC before this series),
except that now we allow a user to free boottime allocated gigantic pages.
And no we cannot just remove the check and let it be since it would modify
the current behaviour, which is to return an error when trying to allocate
gigantic pages whereas alloc_contig_range is not defined. I thought it was
clearly commented above, I can try to make it more explicit.

