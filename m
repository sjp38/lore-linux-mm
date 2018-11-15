Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0CDE96B05B6
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 15:57:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f9so13812780pgs.13
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 12:57:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bc7si3546524plb.120.2018.11.15.12.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 12:57:56 -0800 (PST)
Date: Thu, 15 Nov 2018 12:57:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/1] vmalloc: add test driver to analyse vmalloc
 allocator
Message-Id: <20181115125753.278720db11306755265c42ae@linux-foundation.org>
In-Reply-To: <20181115134706.GC19286@bombadil.infradead.org>
References: <20181113151629.14826-1-urezki@gmail.com>
	<20181113151629.14826-2-urezki@gmail.com>
	<20181113141046.f62f5bd88d4ebc663b0ac100@linux-foundation.org>
	<20181114151737.GA23419@dhcp22.suse.cz>
	<20181114150053.c3fe42507923322a0a10ae1c@linux-foundation.org>
	<20181115083957.GE23831@dhcp22.suse.cz>
	<20181115084642.GB19286@bombadil.infradead.org>
	<20181115125750.GS23831@dhcp22.suse.cz>
	<20181115134706.GC19286@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, 15 Nov 2018 05:47:06 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> On Thu, Nov 15, 2018 at 01:57:50PM +0100, Michal Hocko wrote:
> > On Thu 15-11-18 00:46:42, Matthew Wilcox wrote:
> > > How about adding
> > > 
> > > #ifdef CONFIG_VMALLOC_TEST
> > > int run_internal_vmalloc_tests(void)
> > > {
> > > ...
> > > }
> > > EXPORT_SYMBOL_GPL(run_internal_vmalloc_tests);
> > > #endif
> > > 
> > > to vmalloc.c?  That would also allow calling functions which are marked
> > > as static, not just functions which aren't exported to modules.
> > 
> > Yes that would be easier but do we want to pollute the normal code with
> > testing? This looks messy to me.
> 
> I don't think it's necessarily the worst thing in the world if random
> people browsing the file are forced to read test-cases ;-)
> 
> There's certainly a spectrum of possibilities here, one end being to
> basically just re-export static functions,

Yes, if we're to it this way then a basic

#ifdef CONFIG_VMALLOC_TEST
EXPORT_SYMBOL_GPL(__vmalloc_node_range);
#endif

should suffice.  If the desired symbol was a static one, a little
non-static wrapper would be needed as well.

> and the other end putting
> every vmalloc test into vmalloc.c.  vmalloc.c is pretty big at 70kB, but
> on the other hand, it's the 18th largest file in mm/ (can you believe
> page_alloc.c is 230kB?!)
