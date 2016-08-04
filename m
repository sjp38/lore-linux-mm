Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1785B6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:01:14 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s207so23753459oie.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:01:14 -0700 (PDT)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id i125si2949090itb.72.2016.08.04.06.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 06:01:12 -0700 (PDT)
Received: by mail-io0-x244.google.com with SMTP id g86so21670970ioj.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:01:12 -0700 (PDT)
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
 <df8dd6cd-245d-0673-0246-e514b2a67fc2@I-love.SAKURA.ne.jp>
From: nick <xerofoify@gmail.com>
Message-ID: <43b955c4-8592-1d8b-2624-419dd5501d6e@gmail.com>
Date: Thu, 4 Aug 2016 09:01:09 -0400
MIME-Version: 1.0
In-Reply-To: <df8dd6cd-245d-0673-0246-e514b2a67fc2@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, viro@zeniv.linux.org.uk
Cc: akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, vbabka@suse.cz, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2016-08-04 08:18 AM, Tetsuo Handa wrote:
> On 2016/08/04 6:48, Nicholas Krause wrote:
>> This fixes a kmemleak leak warning complaining about working on
>> unitializied memory as found in the function, getname_flages. Seems
>> that we are indeed working on unitialized memory, as the filename
>> char pointer is never made to point to the filname structure's result
>> member for holding it's name, fix this by using memcpy to copy the
>> filname structure pointer's, name to the char pointer passed to this
>> function.
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  fs/namei.c         | 1 +
>>  mm/early_ioremap.c | 1 +
>>  2 files changed, 2 insertions(+)
>>
>> diff --git a/fs/namei.c b/fs/namei.c
>> index c386a32..6b18d57 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -196,6 +196,7 @@ getname_flags(const char __user *filename, int flags, int *empty)
>>  		}
>>  	}
>>  
>> +	memcpy((char *)result->name, filename, len);
> 
> This filename is a __user pointer. Reading with memcpy() is not safe.
Indeed that is dangerous, I will test a v2 seeing if it is also fixed using
copy_to_user with the same pointers to kernel memory space into user space 
like this with memcpy.
Good Catch,
Nick
> 
>>  	result->uptr = filename;
>>  	result->aname = NULL;
>>  	audit_getname(result);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
