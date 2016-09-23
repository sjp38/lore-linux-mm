Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D46A6B0277
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 11:41:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so229951743pfv.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:41:49 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id x8si8353622paa.245.2016.09.23.08.41.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 08:41:48 -0700 (PDT)
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
References: <57E20A69.5010206@zoho.com>
 <20160923144202.GA31387@htj.duckdns.org>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <238b0d3e-2e6b-7f73-8168-d21517e862bb@zoho.com>
Date: Fri, 23 Sep 2016 23:41:33 +0800
MIME-Version: 1.0
In-Reply-To: <20160923144202.GA31387@htj.duckdns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/23 22:42, Tejun Heo wrote:
> Hello,
> 
> On Wed, Sep 21, 2016 at 12:19:53PM +0800, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> endless loop maybe happen if either of parameter addr and end is not
>> page aligned for kernel API function ioremap_page_range()
>>
>> in order to fix this issue and alert improper range parameters to user
>> WARN_ON() checkup and rounding down range lower boundary are performed
>> firstly, loop end condition within ioremap_pte_range() is optimized due
>> to lack of relevant macro pte_addr_end()
>>
>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> 
> Unfortunately, I can't see what the points are in this series of
> patches.  Most seem to be gratuitous changes which don't address real
> issues or improve anything.  "I looked at the code and realized that,
> if the input were wrong, the function would misbehave" isn't good
> enough a reason.  What's next?  Are we gonna harden all pointer taking
> functions too?
> 
> For internal functions, we don't by default do input sanitization /
> sanity check.  There sure are cases where doing so is beneficial but
> reading a random function and thinking "oh this combo of parameters
> can make it go bonkers" isn't the right approach for it.  We end up
> with cruft and code changes which nobody needed in the first place and
> can easily introduce actual real bugs in the process.
> 
> It'd be an a lot more productive use of time and effort for everyone
> involved if the work is around actual issues.
> 
> Thanks.
> 
thanks for your reply firstly
1. ioremap_page_range() is not a kernel internal function
2. sanity check "BUG_ON(addr >= end)" have existed already, but don't check enough
3. are there any obvious hint for rang parameter requirements but BUG_ON(addr >= end)
4. if range which seems right but wrong really is used such as mapping 
   virtual range [0x80000800, 0x80007800) to physical area[0x20000800, 0x20007800)
   what actions should we take? warning message and trying to finish user request
   or panic kernel or hang system in endless loop or return -EINVALi 1/4 ?
   how to help user find their problem?
5. if both boundary of the range are aligned to page, ioremap_page_range() works well
   otherwise endless loop maybe happens


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
