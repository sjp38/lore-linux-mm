Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC446B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 13:55:22 -0500 (EST)
Received: by pacej9 with SMTP id ej9so53056154pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:55:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id mj10si5912365pab.207.2015.11.18.10.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 10:55:21 -0800 (PST)
Date: Wed, 18 Nov 2015 10:55:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] writeback: initialize m_dirty to avoid compile warning
Message-Id: <20151118105517.2947aaa2.akpm@linux-foundation.org>
In-Reply-To: <564CC5DB.8000104@linaro.org>
References: <1447439201-32009-1-git-send-email-yang.shi@linaro.org>
	<20151117153855.99d2acd0568d146c29defda5@linux-foundation.org>
	<20151118181142.GC11496@mtj.duckdns.org>
	<564CC314.1090904@linaro.org>
	<20151118183344.GD11496@mtj.duckdns.org>
	<564CC5DB.8000104@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Wed, 18 Nov 2015 10:39:23 -0800 "Shi, Yang" <yang.shi@linaro.org> wrote:

> On 11/18/2015 10:33 AM, Tejun Heo wrote:
> > Hello,
> >
> > On Wed, Nov 18, 2015 at 10:27:32AM -0800, Shi, Yang wrote:
> >>> This was the main reason the code was structured the way it is.  If
> >>> cgroup writeback is not enabled, any derefs of mdtc variables should
> >>> trigger warnings.  Ugh... I don't know.  Compiler really should be
> >>> able to tell this much.
> >>
> >> Thanks for the explanation. It sounds like a compiler problem.
> >>
> >> If you think it is still good to cease the compile warning, maybe we could
> >
> > If this is gonna be a problem with new gcc versions, I don't think we
> > have any other options. :(
> >
> >> just assign it to an insane value as what Andrew suggested, maybe
> >> 0xdeadbeef.
> >
> > I'd just keep it at zero.  Whatever we do, the effect is gonna be
> > difficult to track down - it's not gonna blow up in an obvious way.
> > Can you please add a comment tho explaining that this is to work
> > around compiler deficiency?
> 
> Sure.
> 
> Other than this, in v2, I will just initialize m_dirty since compiler 
> just reports it is uninitialized.

gcc-4.4.4 and gcc-4.8.4 warn about all three variables.


--- a/mm/page-writeback.c~writeback-initialize-m_dirty-to-avoid-compile-warning-fix
+++ a/mm/page-writeback.c
@@ -1542,7 +1542,9 @@ static void balance_dirty_pages(struct a
 	for (;;) {
 		unsigned long now = jiffies;
 		unsigned long dirty, thresh, bg_thresh;
-		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh = 0;
+		unsigned long m_dirty = 0;	/* stop bogus uninit warnings */
+		unsigned long m_thresh = 0;
+		unsigned long m_bg_thresh = 0;
 
 		/*
 		 * Unstable writes are a feature of certain networked
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
