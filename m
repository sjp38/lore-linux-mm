Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 837C56B004D
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:42:25 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id z12so221123wgg.6
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:42:24 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id bo3si6545433wib.43.2014.01.22.03.42.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 03:42:24 -0800 (PST)
Date: Wed, 22 Jan 2014 11:42:15 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 1/3] ARM: Premit ioremap() to map reserved pages
Message-ID: <20140122114215.GZ15937@n2100.arm.linux.org.uk>
References: <1390389916-8711-1-git-send-email-wangnan0@huawei.com> <1390389916-8711-2-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390389916-8711-2-git-send-email-wangnan0@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Nan <wangnan0@huawei.com>
Cc: kexec@lists.infradead.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Geng Hui <hui.geng@huawei.com>, linux-mm@kvack.org, Eric Biederman <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Wed, Jan 22, 2014 at 07:25:14PM +0800, Wang Nan wrote:
> This patch relaxes the restriction set by commit 309caa9cc, which
> prohibit ioremap() on all kernel managed pages.
> 
> Other architectures, such as x86 and (some specific platforms of) powerpc,
> allow such mapping.
> 
> ioremap() pages is an efficient way to avoid arm's mysterious cache control.
> This feature will be used for arm kexec support to ensure copied data goes into
> RAM even without cache flushing, because we found that flush_cache_xxx can't
> reliably flush code to memory.

Yes, let's bypass the check and allow this in violation of the
architecture specification by allowing mapping the same memory with
different types, which leads to unpredictable behaviour.  Yes, that's
a very good idea, because what we want to do is far more important than
following the requirements of the architecture.

So... NAK.

Yes, flush_cache_xxx() doesn't flush back to physical RAM, that's not
what it's defined to do - it's defined that it flushes enough of the
cache to ensure that page table updates are safe (such as when tearing
down a page mapping.)  So it's hardly surprising that doesn't work.

If you want to be able to have DMA access to memory, then you need to
use an API which has been designed for that purpose, and if there isn't
one, then you need to discuss your requirements, rather than trying to
hack around the problem.

The issue here will be that the APIs we currently have for DMA become
extremely expensive when you want to deal with (eg) all system RAM.
Or, there's flush_cache_all() which should flush all levels of cache
in the system, and thus push all data back to RAM.

Now, why are you copying your patches to the stable people?  That makes
no sense - they haven't been reviewed and they haven't been integrated
into an existing kernel.  So, they don't meet the basic requirements
for stable tree submission...

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
