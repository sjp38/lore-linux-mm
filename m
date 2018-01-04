Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE6EE6B04D2
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 02:44:36 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id j6so689111pll.4
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 23:44:36 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id 20si1952378pft.356.2018.01.03.23.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 23:44:35 -0800 (PST)
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
From: "=?UTF-8?B?5aS35YiZKENhc3Bhcik=?=" <jinli.zjl@alibaba-inc.com>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
 <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
 <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
 <7dd95219-f0be-b30a-0a43-2aadcc61899c@alibaba-inc.com>
Message-ID: <63eeeda3-6e94-69e5-9cfc-75d34a4c4e4a@alibaba-inc.com>
Date: Thu, 04 Jan 2018 15:44:20 +0800
MIME-Version: 1.0
In-Reply-To: <7dd95219-f0be-b30a-0a43-2aadcc61899c@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?5p2o5YuHKOaZuuW9uyk=?= <zhiche.yy@alibaba-inc.com>, =?UTF-8?B?5Y2B5YiA?= <shidao.ytt@alibaba-inc.com>



On 2018/1/4 14:13, a?.a??(Caspar) wrote:
> 
> This patch is trying to help to solve a real issue. Sometimes we need to 
> evict the whole file from page cache because we are sure it will not be 
> used in the near future. We try to use posix_fadvise() to finish our 
> work but we often see a "small tail" at the end of some files could not 
> be evicted, after digging a little bit, we find those file sizes are not 
> page-aligned and the "tail" turns out to be partial pages.
> 
> We fail to find a standard from posix_fadvise() manual page to subscribe 
> the function behaviors if the `offset' and `len' params are not 

Oops, I find a 'standard' documented in latest man-pages.git[1], blame 
my centos7, it runs with an old man-pages.rpm :-(

Thanks,
Caspar

[1] 
https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git/commit/?h=ceb1c326b9f3e863dfd9bf33bc7118bb1fa29bfc

> page-aligned, then we go to kernel tree and see this:
> 
>  A A A A A A A  /*
>  A A A A A A A A  * First and last FULL page! Partial pages are deliberately
>  A A A A A A A A  * preserved on the expectation that it is better to preserve
>  A A A A A A A A  * needed memory than to discard unneeded memory.
>  A A A A A A A A  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
