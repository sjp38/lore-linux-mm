Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7EC6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 00:30:39 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id k1so1452056pgq.2
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 21:30:39 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b70si767870pfk.47.2017.11.28.21.30.37
        for <linux-mm@kvack.org>;
        Tue, 28 Nov 2017 21:30:38 -0800 (PST)
Date: Wed, 29 Nov 2017 14:36:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 02/18] vchecker: introduce the valid access checker
Message-ID: <20171129053637.GA8125@js1304-P5Q-DELUXE>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1511855333-3570-3-git-send-email-iamjoonsoo.kim@lge.com>
 <87k1yajinf.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k1yajinf.fsf@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>

On Tue, Nov 28, 2017 at 11:41:08AM -0800, Andi Kleen wrote:
> js1304@gmail.com writes:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Looks useful. Essentially unlimited hardware break points, combined
> with slab.

Thanks!!!

> 
> Didn't do a full review, but noticed some things below.
> > +
> > +	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
> > +	if (!buf)
> > +		return -ENOMEM;
> > +
> > +	if (copy_from_user(buf, ubuf, cnt)) {
> > +		kfree(buf);
> > +		return -EFAULT;
> > +	}
> > +
> > +	if (isspace(buf[0]))
> > +		remove = true;
> 
> and that may be uninitialized.

I will add 'cnt == 0' check above.

> and the space changes the operation? That's a strange syntax.

Intention is to clear the all the previous configuration when user
input is '\n'. Will fix it by checking '\n' directly.

> 
> > +	buf[cnt - 1] = '\0';
> 
> That's an underflow of one byte if cnt is 0.

Will add 'cnt == 0' check above.

String parsing part in this patchset will not work properly when the
last input character is not '\n'. I will fix it on the next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
