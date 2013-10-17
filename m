Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D1C046B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:58:35 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1810799pdj.15
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 17:58:35 -0700 (PDT)
Message-ID: <525F35F7.4070202@asianux.com>
Date: Thu, 17 Oct 2013 08:57:27 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/readahead.c: need always return 0 when system call
 readahead() succeeds
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com> <525CF787.6050107@asianux.com> <alpine.DEB.2.02.1310161603280.2417@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1310161603280.2417@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On 10/17/2013 07:06 AM, David Rientjes wrote:
> On Tue, 15 Oct 2013, Chen Gang wrote:
> 
>> diff --git a/mm/readahead.c b/mm/readahead.c
>> index 1eee42b..83a202e 100644
>> --- a/mm/readahead.c
>> +++ b/mm/readahead.c
>> @@ -592,5 +592,5 @@ SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
>>  		}
>>  		fdput(f);
>>  	}
>> -	return ret;
>> +	return ret < 0 ? ret : 0;
>>  }
> 
> This was broken by your own "mm/readahead.c: return the value which 
> force_page_cache_readahead() returns" patch in -mm, luckily Linus's tree 
> isn't affected.
> 

Of cause it is.

And every member knows about it: in my comments, already mentioned about
it in a standard way.

Hmm... isn't it enough? (it seems you don't think so)

If possible, you can help me check all my patches again (at least, it is
not a bad idea to me).  ;-)


> Nack to this and nack to the problem patch, which is absolutely pointless 
> and did nothing but introduce this error.  readahead() is supposed to 
> return 0, -EINVAL, or -EBADF and your original patch broke it.  That's 
> because your original patch was completely pointless to begin with.
> 
> 

Do you mean: in do_readahead(), we need not check the return value of
force_page_cache_readahead()?

In my opinion, the system call of readahead() wants to notice whether
force_page_cache_readahead() fails or not (may return -EINVAL), which is
the mainly callee of readahead().

Don't you think so??


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
