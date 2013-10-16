Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9C06B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 19:06:33 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1796844pad.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 16:06:33 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1796803pad.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 16:06:31 -0700 (PDT)
Date: Wed, 16 Oct 2013 16:06:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/readahead.c: need always return 0 when system call
 readahead() succeeds
In-Reply-To: <525CF787.6050107@asianux.com>
Message-ID: <alpine.DEB.2.02.1310161603280.2417@chino.kir.corp.google.com>
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com>
 <525CF787.6050107@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On Tue, 15 Oct 2013, Chen Gang wrote:

> diff --git a/mm/readahead.c b/mm/readahead.c
> index 1eee42b..83a202e 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -592,5 +592,5 @@ SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
>  		}
>  		fdput(f);
>  	}
> -	return ret;
> +	return ret < 0 ? ret : 0;
>  }

This was broken by your own "mm/readahead.c: return the value which 
force_page_cache_readahead() returns" patch in -mm, luckily Linus's tree 
isn't affected.

Nack to this and nack to the problem patch, which is absolutely pointless 
and did nothing but introduce this error.  readahead() is supposed to 
return 0, -EINVAL, or -EBADF and your original patch broke it.  That's 
because your original patch was completely pointless to begin with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
