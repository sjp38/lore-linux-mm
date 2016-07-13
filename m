Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72BF36B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:53:49 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so26860082lfi.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:53:49 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id x8si9548905wme.6.2016.07.13.00.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 00:53:48 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id o80so55391625wme.1
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:53:47 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:53:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: Use bool instead of int for the return
 value of PageMovable
Message-ID: <20160713075346.GC28723@dhcp22.suse.cz>
References: <1468079704-5477-1-git-send-email-chengang@emindsoft.com.cn>
 <20160711002605.GD31817@bbox>
 <5783F7DE.9020203@emindsoft.com.cn>
 <20160712074841.GE14586@dhcp22.suse.cz>
 <57851FC4.4000000@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57851FC4.4000000@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Wed 13-07-16 00:50:12, Chen Gang wrote:
> 
> 
> On 7/12/16 15:48, Michal Hocko wrote:
> > On Tue 12-07-16 03:47:42, Chen Gang wrote:
> > [...]
> >> In our case, the 2 output size are same, but under x86_64, the insns are
> >> different. After uses bool, it uses push/pop instead of branch, for me,
> >> it should be a little better for catching.
> > 
> > The code generated for bool version looks much worse. Look at the fast
> > path. Gcc tries to reuse the retq from the fast path in the bool case
> > and so it has to push rbp and rbx on the stack.
> > 
> > That being said, gcc doesn't seem to generate a better code for bool so
> > I do not think this is really worth it.
> >
> 
> The code below also merge 3 statements into 1 return statement, although
> for me, it is a little more readable, it will generate a little bad code.
> That is the reason why the output looks a little bad.
> 
> In our case, for gcc 6.0, using bool instead of int for bool function
> will get the same output under x86_64.

If the output is same then there is no reason to change it.

> In our case, for gcc 4.8, using bool instead of int for bool function
> will get a little better output under x86_64.

I had a different impression and the fast path code had more
instructions. But anyway, is there really a strong reason to change
those return values in the first place? Isn't that just a pointless code
churn?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
