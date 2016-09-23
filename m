Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 253276B0287
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 12:23:10 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id i129so254229637ywb.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 09:23:10 -0700 (PDT)
Received: from mail-yb0-x241.google.com (mail-yb0-x241.google.com. [2607:f8b0:4002:c09::241])
        by mx.google.com with ESMTPS id j191si1494141ybg.173.2016.09.23.09.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 09:23:09 -0700 (PDT)
Received: by mail-yb0-x241.google.com with SMTP id 2so3573044ybv.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 09:23:09 -0700 (PDT)
Date: Fri, 23 Sep 2016 12:23:07 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
Message-ID: <20160923162307.GB31387@htj.duckdns.org>
References: <57E20A69.5010206@zoho.com>
 <20160923144202.GA31387@htj.duckdns.org>
 <238b0d3e-2e6b-7f73-8168-d21517e862bb@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <238b0d3e-2e6b-7f73-8168-d21517e862bb@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

Hello,

On Fri, Sep 23, 2016 at 11:41:33PM +0800, zijun_hu wrote:
> 1. ioremap_page_range() is not a kernel internal function

What matters is whether the input is from userland or easy to get
wrong (IOW the checks serve practical purposes).  Whether a function
is exported via EXPORT_SYMBOL doesn't matter that much in this regard.
EXPORT_SYMBOL doesn't really demark an API layer (we don't put any
effort into keeping it stable or versioned).  Modules are loaded
separately but still part of the same program.

> 2. sanity check "BUG_ON(addr >= end)" have existed already, but don't check enough

That particular check being there doesn't imply that it needs to be
expanded.  If you actually have cases where this mattered and extra
checks would have substantially helped debugging, sure, but that's not
the case here.

> 3. are there any obvious hint for rang parameter requirements but BUG_ON(addr >= end)

You're welcome to add documentation.

> 4. if range which seems right but wrong really is used such as mapping 
>    virtual range [0x80000800, 0x80007800) to physical area[0x20000800, 0x20007800)
>    what actions should we take? warning message and trying to finish user request
>    or panic kernel or hang system in endless loop or return -EINVALi 1/4 ?
>    how to help user find their problem?
> 5. if both boundary of the range are aligned to page, ioremap_page_range() works well
>    otherwise endless loop maybe happens

I don't think it's helpful to imgaine pathological conditions and try
to address all of them.  There's no evidence, not even a tenuous one,
that anyone is suffering from this.  Sometimes it is useful to
implement precautions preemptively but in those cases the rationles
should be along the line of "it's easy to get the inputs wrong for
this function because ABC and those cases are difficult to debug due
to XYZ", not "let's harden all the functions against all input
combinations regardless of likelihood or usefulness".

The thing is that the latter approach not only wastes time of everyone
involved without any real gain but also actually deteriorates the code
base by adding unnecessary complications and introduces bugs through
gratuitous changes.  Please note that I'm not trying to say
re-factoring or cleanups are to be avoided.  We need them for long
term maintainability, even at the cost of introducing some bugs in the
process, but the patches you're submitting are quite off the mark.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
