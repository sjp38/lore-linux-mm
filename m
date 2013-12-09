Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 406AC6B0096
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 05:08:53 -0500 (EST)
Received: by mail-yh0-f45.google.com with SMTP id v1so2446470yhn.32
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 02:08:53 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id v1si9614892yhg.201.2013.12.09.02.08.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 02:08:52 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id y13so4909161pdi.5
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 02:08:51 -0800 (PST)
Message-ID: <52A5973A.7020509@gmail.com>
Date: Mon, 09 Dec 2013 18:11:06 +0800
From: Chen Gang <gang.chen.5i5j@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com> <52A5935A.4040709@imgtec.com>
In-Reply-To: <52A5935A.4040709@imgtec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/09/2013 05:54 PM, James Hogan wrote:
> On 09/12/13 02:51, Chen Gang wrote:
>> Recommend to add default case to avoid compiler's warning, although at
>> present, the original implementation is still correct.
>>
>> The related warning (with allmodconfig for metag):
>>
>>     CC      mm/zswap.o
>>   mm/zswap.c: In function 'zswap_writeback_entry':
>>   mm/zswap.c:537: warning: 'ret' may be used uninitialized in this function
>>
>>
>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
>> ---
>>  mm/zswap.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/zswap.c b/mm/zswap.c
>> index 5a63f78..bfd1807 100644
>> --- a/mm/zswap.c
>> +++ b/mm/zswap.c
>> @@ -585,6 +585,8 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>>  
>>  		/* page is up to date */
>>  		SetPageUptodate(page);
>> +	default:
>> +		BUG();
> 
> This doesn't hide the warning when CONFIG_BUG=n since BUG() optimises
> out completely.
> 

When "CONFIG_BUG=n", it will report many related warnings (for me,
CONFIG_BUG need be as architecture specific config feature, not a
generic config feature -- most architectures always enable it).

So for common generic users, we can assume it will always have effect.


> Since the metag compiler is stuck on an old version (gcc 4.2.4), which
> is wrong to warn in this case, and newer versions of gcc don't appear to
> warn about it anyway (I just checked with gcc 4.7.2 x86_64), I have no
> objection to this warning remaining in the metag build.
> 

Do you try "EXTRA_CFLAGS=-W" with gcc 4.7.2? I guess it will report the
warning too, I don't feel the compiler is smart enough (except it lets
the long function zswap_get_swap_cache_page really inline)  :-)


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water and life which God blessed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
