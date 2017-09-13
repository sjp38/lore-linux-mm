Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96D2E6B0069
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 17:02:33 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h16so1341381wrf.0
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 14:02:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t205si1764033wmg.21.2017.09.13.14.02.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 14:02:32 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:02:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v4 3/5] mm, swap: VMA based swap readahead
Message-Id: <20170913140229.8a6cad6f017fa3ea8b53cefc@linux-foundation.org>
In-Reply-To: <20170913014019.GB29422@bbox>
References: <20170807054038.1843-1-ying.huang@intel.com>
	<20170807054038.1843-4-ying.huang@intel.com>
	<20170913014019.GB29422@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Wed, 13 Sep 2017 10:40:19 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Every zram users like low-end android device has used 0 page-cluster
> to disable swap readahead because it has no seek cost and works as
> synchronous IO operation so if we do readahead multiple pages,
> swap falut latency would be (4K * readahead window size). IOW,
> readahead is meaningful only if it doesn't bother faulted page's
> latency.
> 
> However, this patch introduces additional knob /sys/kernel/mm/swap/
> vma_ra_max_order as well as page-cluster. It means existing users
> has used disabled swap readahead doesn't work until they should be
> aware of new knob and modification of their script/code to disable
> vma_ra_max_order as well as page-cluster.
> 
> I say it's a *regression* and wanted to fix it but Huang's opinion
> is that it's not a functional regression so userspace should be fixed
> by themselves.
> Please look into detail of discussion in
> http://lkml.kernel.org/r/%3C1505183833-4739-4-git-send-email-minchan@kernel.org%3E

hm, tricky problem.  I do agree that linking the physical and virtual
readahead schemes in the proposed fashion is unfortunate.  I also agree
that breaking existing setups (a bit) is also unfortunate.

Would it help if, when page-cluster is written to zero, we do

printk_once("physical readahead disabled, virtual readahead still
enabled.  Disable virtual readhead via
/sys/kernel/mm/swap/vma_ra_max_order").

Or something like that.  It's pretty lame, but it should help alert the
zram-readahead-disabling people to the issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
