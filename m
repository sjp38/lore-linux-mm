Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 319666B0038
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 11:34:05 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id k14so1853721wgh.1
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 08:34:04 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id gi2si9648539wjd.112.2014.04.30.08.34.03
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 08:34:03 -0700 (PDT)
Date: Wed, 30 Apr 2014 16:33:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH V4 6/7] arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
Message-ID: <20140430153317.GG31220@arm.com>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
 <1396018892-6773-7-git-send-email-steve.capper@linaro.org>
 <20140430152047.GF31220@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140430152047.GF31220@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Apr 30, 2014 at 04:20:47PM +0100, Catalin Marinas wrote:
> On Fri, Mar 28, 2014 at 03:01:31PM +0000, Steve Capper wrote:
> > In order to implement fast_get_user_pages we need to ensure that the
> > page table walker is protected from page table pages being freed from
> > under it.
> > 
> > This patch enables HAVE_RCU_TABLE_FREE, any page table pages belonging
> > to address spaces with multiple users will be call_rcu_sched freed.
> > Meaning that disabling interrupts will block the free and protect the
> > fast gup page walker.
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> 
> While this patch is simple, I'd like to better understand the reason for
> it. Currently HAVE_RCU_TABLE_FREE is enabled for powerpc and sparc while
> __get_user_pages_fast() is supported by a few other architectures that
> don't select HAVE_RCU_TABLE_FREE. So why do we need it for fast gup on
> arm/arm64 while not all the other archs need it?

OK, replying to myself. I assume the other architectures that don't need
HAVE_RCU_TABLE_FREE use IPI for TLB shootdown, hence they gup_fast
synchronisation for free.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
