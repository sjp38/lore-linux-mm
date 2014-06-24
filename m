Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 927086B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 20:33:03 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so6474515pbb.18
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 17:33:03 -0700 (PDT)
Received: from fgwmail.fujitsu.co.jp (fgwmail.fujitsu.co.jp. [164.71.1.133])
        by mx.google.com with ESMTPS id cn6si24039660pad.118.2014.06.23.17.33.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 17:33:02 -0700 (PDT)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail.fujitsu.co.jp (Postfix) with ESMTP id 514373EE0C8
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:33:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 252AAAC0683
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:33:00 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C4DC3E18003
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:32:59 +0900 (JST)
Message-ID: <53A8C6F6.2060906@jp.fujitsu.com>
Date: Tue, 24 Jun 2014 09:31:50 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86,mem-hotplug: modify PGD entry when removing memory
References: <53A132E2.9000605@jp.fujitsu.com>	 <53A133ED.2090005@jp.fujitsu.com> <1403289003.25108.3.camel@misato.fc.hp.com>
In-Reply-To: <1403289003.25108.3.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, tangchen@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, guz.fnst@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com

(2014/06/21 3:30), Toshi Kani wrote:
> On Wed, 2014-06-18 at 15:38 +0900, Yasuaki Ishimatsu wrote:
>   :
>> @@ -186,7 +186,12 @@ void sync_global_pgds(unsigned long start, unsigned long end)
>>   		const pgd_t *pgd_ref = pgd_offset_k(address);
>>   		struct page *page;
>>
>> -		if (pgd_none(*pgd_ref))
>> +		/*
>> +		 * When it is called after memory hot remove, pgd_none()
>> +		 * returns true. In this case (removed == 1), we must clear
>> +		 * the PGD entries in the local PGD level page.
>> +		 */
>> +		if (pgd_none(*pgd_ref) && !removed)
>>   			continue;
>>
>>   		spin_lock(&pgd_lock);
>> @@ -199,12 +204,18 @@ void sync_global_pgds(unsigned long start, unsigned long end)
>>   			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
>>   			spin_lock(pgt_lock);
>>
>> -			if (pgd_none(*pgd))
>> -				set_pgd(pgd, *pgd_ref);
>> -			else

>> +			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
>>   				BUG_ON(pgd_page_vaddr(*pgd)
>>   				       != pgd_page_vaddr(*pgd_ref));
>>
>> +			if (removed) {
>
> Shouldn't this condition be "else if"?

The first if sentence checks whether PGDs hit to BUG_ON. And the second
if sentence checks whether the function was called after hot-removing memory.
I think that the first if sentence and the second if sentence check different
things. So I think the condition should be "if" sentence.

Thanks,
Yasuaki Ishimatsu

>
> Thanks,
> -Toshi
>
>> +				if (pgd_none(*pgd_ref) && !pgd_none(*pgd))
>> +					pgd_clear(pgd);
>> +			} else {
>> +				if (pgd_none(*pgd))
>> +					set_pgd(pgd, *pgd_ref);
>> +			}
>> +
>>   			spin_unlock(pgt_lock);
>>   		}
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
