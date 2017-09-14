Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 572BF6B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 08:01:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v82so5649593pgb.5
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 05:01:35 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n12si11120464pfb.207.2017.09.14.05.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 05:01:33 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 3/5] mm, swap: VMA based swap readahead
References: <20170807054038.1843-1-ying.huang@intel.com>
	<20170807054038.1843-4-ying.huang@intel.com>
	<20170913014019.GB29422@bbox>
	<20170913140229.8a6cad6f017fa3ea8b53cefc@linux-foundation.org>
	<20170914075345.GA5533@bbox>
Date: Thu, 14 Sep 2017 20:01:30 +0800
In-Reply-To: <20170914075345.GA5533@bbox> (Minchan Kim's message of "Thu, 14
	Sep 2017 16:53:45 +0900")
Message-ID: <87h8w5jxph.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

Minchan Kim <minchan@kernel.org> writes:

> On Wed, Sep 13, 2017 at 02:02:29PM -0700, Andrew Morton wrote:
>> On Wed, 13 Sep 2017 10:40:19 +0900 Minchan Kim <minchan@kernel.org> wrote:
>> 
>> > Every zram users like low-end android device has used 0 page-cluster
>> > to disable swap readahead because it has no seek cost and works as
>> > synchronous IO operation so if we do readahead multiple pages,
>> > swap falut latency would be (4K * readahead window size). IOW,
>> > readahead is meaningful only if it doesn't bother faulted page's
>> > latency.
>> > 
>> > However, this patch introduces additional knob /sys/kernel/mm/swap/
>> > vma_ra_max_order as well as page-cluster. It means existing users
>> > has used disabled swap readahead doesn't work until they should be
>> > aware of new knob and modification of their script/code to disable
>> > vma_ra_max_order as well as page-cluster.
>> > 
>> > I say it's a *regression* and wanted to fix it but Huang's opinion
>> > is that it's not a functional regression so userspace should be fixed
>> > by themselves.
>> > Please look into detail of discussion in
>> > http://lkml.kernel.org/r/%3C1505183833-4739-4-git-send-email-minchan@kernel.org%3E
>> 
>> hm, tricky problem.  I do agree that linking the physical and virtual
>> readahead schemes in the proposed fashion is unfortunate.  I also agree
>> that breaking existing setups (a bit) is also unfortunate.
>> 
>> Would it help if, when page-cluster is written to zero, we do
>> 
>> printk_once("physical readahead disabled, virtual readahead still
>> enabled.  Disable virtual readhead via
>> /sys/kernel/mm/swap/vma_ra_max_order").
>> 
>> Or something like that.  It's pretty lame, but it should help alert the
>> zram-readahead-disabling people to the issue?
>
> It was my last resort. If we cannot find other ways after all, yes, it would
> be a minimum we should do. But it still breaks users don't/can't read/modify
> alert and program.
>
> How about this?
>
> Can't we make vma-based readahead config option?
> With that, users who no interest on readahead don't enable vma-based
> readahead. In this case, page-cluster works as expected "disable readahead
> completely" so it doesn't break anything.

Now.  Users can choose between VMA based readahead and original
readahead via a knob as follow at runtime,

/sys/kernel/mm/swap/vma_ra_enabled

Best Regards,
Huang, Ying


> People who want to use upcoming vma-based readahead can enable the feature
> and we can say such unfortunate things in config/document description
> somewhere so upcoming users will be aware of that unforunate two knobs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
