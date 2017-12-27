Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAB466B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 09:28:59 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s5so19014442wra.3
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 06:28:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor17546387edc.45.2017.12.27.06.28.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 06:28:58 -0800 (PST)
Date: Wed, 27 Dec 2017 15:28:54 +0100
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171227142853.b5agfi2kzo25g5ot@ltop.local>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
 <20171221214810.GC9087@linux.intel.com>
 <20171222011000.GB23624@bombadil.infradead.org>
 <20171222042120.GA18036@localhost>
 <20171222123112.GA6401@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222123112.GA6401@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Josh Triplett <josh@joshtriplett.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Dec 22, 2017 at 04:31:12AM -0800, Matthew Wilcox wrote:
> On Thu, Dec 21, 2017 at 08:21:20PM -0800, Josh Triplett wrote:
> 
> While I've got you, I've been looking at some other sparse warnings from
> this file.  There are several caused by sparse being unable to handle
> the following construct:
> 
> 	if (foo)
> 		x = NULL;
> 	else {
> 		x = bar;
> 		__acquire(bar);
> 	}
> 	if (!x)
> 		return -ENOMEM;
> 
> Writing it as:
> 
> 	if (foo)
> 		return -ENOMEM;
> 	else {
> 		x = bar;
> 		__acquire(bar);
> 	}
> 
> works just fine.  ie this removes the warning:

It must be noted that these two versions are not equivalent
(in the first version, it also returns with -ENOMEM if bar
is NULL/zero).
 
It must be noted that sparse's goal regarding the context imbalance
is to give the warning if some point in the code can be reached via
two paths (or more) and the lock state (the context) is not identical
in each of these paths.

> 
> Is there any chance sparse's dataflow analysis will be improved in the
> near future?

A lot of functions in the kernel have this context imbalance,
really a lot. For example, any function doing conditional locking
is a problem here. Happily when these functions are inlined,
sparse, thanks to its optimizations, can remove some paths and
merge some others. 
So yes, by adding some smartness to sparse, some of the false
warnings will be removed, however:
1) some __must_hold()/__acquires()/__releases() annotations are
   missing, making sparse's job impossible.
2) a lot of the 'false warnings' are not so false because there is
   indeed two possible paths with different lock state
3) it has its limits (at the end, giving the correct warning is
   equivalent to the halting problem).

Now, to answer to your question, I'm not aware of any effort that would
make a significant differences (it would need, IMO, code hoisting & 
value range propagation).

-- Luc Van Oostenryck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
