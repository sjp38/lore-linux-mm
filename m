Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D08936B04FD
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 17:54:43 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id o16so1493417wmf.4
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 14:54:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1si2755161wmj.68.2018.01.04.14.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 14:54:42 -0800 (PST)
Date: Thu, 4 Jan 2018 14:54:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also
 eof
Message-Id: <20180104145439.ab5cca8adbccee4ef54348fa@linux-foundation.org>
In-Reply-To: <be7778b9-58de-3717-0da5-e88fc5ec5542@alibaba-inc.com>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
	<8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
	<20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
	<20180103161753.8b22d32d640f6e0be4119081@linux-foundation.org>
	<be7778b9-58de-3717-0da5-e88fc5ec5542@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?IuWkt+WImShDYXNwYXIpIg==?= <jinli.zjl@alibaba-inc.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?IuadqA==?= =?UTF-8?B?5YuHKOaZuuW9uyki?= <zhiche.yy@alibaba-inc.com>, =?UTF-8?B?Ig==?= =?UTF-8?B?5Y2B5YiAIg==?= <shidao.ytt@alibaba-inc.com>

On Thu, 04 Jan 2018 16:17:50 +0800 "a?.a??(Caspar)" <jinli.zjl@alibaba-inc.com> wrote:

> > So, thinking caps on: why not just discard them?  After all, that's
> > what userspace asked us to do.
> 
> Hi Andrew, I doubt if "just discard them" is a proper action to match 
> the userspace's expectation. Maybe we will never meet the userspace's 
> expectation since we are doing pages in kernel while userspace is 
> passing bytes offset/length to the kernel. Note that Mel Gorman has 
> already documented page-unaligned behaviors in posix_fadvise() man 
> page[1] but obviously not all people (including /me) are able to read 
> the _latest_ version, so someone might still uses the syscall with page 
> unaligned offset/length. The userspace might only ask for discarding 
> certain *bytes*, instead of *pages*.
> 
> And I think we need to look back first why we thought "preserved is 
> better than discard". If we throw the whole page, the rest part of the 
> page might still be required (consider the offset and length is in the 
> middle of a file) because it's untagged:
> 
>    ...|------------ PAGE --------------|...
>    ...| DONTNEED |------ UNTAGGED -----|...
> 
> but the page has gone, page fault occurs and we need to reload it from 
> the disk -- performance degradation happens.
> 
> Maybe that's why we would rather preserv the whole page before.
> 
> But if we don't throw the partial page at all, and if the tail partial 
> page is _exactly the end of the file_, a page that advised to be NONEED 
> would be left in memory. And we all know that it is safe to throw it.
> 
> So we come up with this patch -- to keep the partial page not been 
> throwing away, and add a special case when the partial page is the end 
> of the file, we can throw it safely. I guess it might be a better solution.

OK, that makes sense.

As Mel (sort of) said, "delete part of page" can mean "I want to retain
the other part of the page".  So we should retain the page.  But for
end-of-file, there is no "other part of the page".

> One thing I'm worrying about is that, this patch might lead to a new 
> undocumented behavior, so maybe we need to document this special case in 
> posix_fadvise() man page too? hmmm...

That wouldn't hurt.

Could you please resend the patch with the changelog updated to reflect
this discussion?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
