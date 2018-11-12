Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D29C6B026C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 01:27:19 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b4-v6so3724276plb.3
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 22:27:19 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 63-v6si17001584pfe.182.2018.11.11.22.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 22:27:18 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 12 Nov 2018 11:57:17 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v4 1/4] mm: reference totalram_pages and managed_pages
 once per function
In-Reply-To: <20181112061337.GG21824@bombadil.infradead.org>
References: <1542002869-16704-1-git-send-email-arunks@codeaurora.org>
 <1542002869-16704-2-git-send-email-arunks@codeaurora.org>
 <20181112061337.GG21824@bombadil.infradead.org>
Message-ID: <a40d8c9e5c0c3c412d347a24a7c66010@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org

Hello Matthew,

Thanks for reviewing.
On 2018-11-12 11:43, Matthew Wilcox wrote:
> On Mon, Nov 12, 2018 at 11:37:46AM +0530, Arun KS wrote:
>> +++ b/arch/um/kernel/mem.c
>> @@ -51,8 +51,7 @@ void __init mem_init(void)
>> 
>>  	/* this will put all low memory onto the freelists */
>>  	memblock_free_all();
>> -	max_low_pfn = totalram_pages;
>> -	max_pfn = totalram_pages;
>> +	max_pfn = max_low_pfn = totalram_pages;
> 
> We don't normally do "a = b = c".  How about:
> 
>  	max_low_pfn = totalram_pages;
> -	max_pfn = totalram_pages;
> +	max_pfn = max_low_pfn;

Point taken. Will fix it.

> 
>> +++ b/arch/x86/kernel/cpu/microcode/core.c
>> @@ -434,9 +434,10 @@ static ssize_t microcode_write(struct file *file, 
>> const char __user *buf,
>>  			       size_t len, loff_t *ppos)
>>  {
>>  	ssize_t ret = -EINVAL;
>> +	unsigned long totalram_pgs = totalram_pages;
> 
> Can't we use a better variable name here?  Even nr_pages would look
> better to me.

Looks better.

Regards,
Arun

> 
>> +++ b/drivers/hv/hv_balloon.c
>> +	unsigned long totalram_pgs = totalram_pages;
> 
> Ditto
> 
>> +++ b/fs/file_table.c
>> +	unsigned long totalram_pgs = totalram_pages;
> 
> ... throughout, I guess.
