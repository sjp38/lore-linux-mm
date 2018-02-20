Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBDCB6B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:37:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i11so6899233pgq.10
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 05:37:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u2-v6si5896591plr.50.2018.02.20.05.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 05:37:28 -0800 (PST)
Date: Tue, 20 Feb 2018 05:37:25 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: zsmalloc: Replace return type int with bool
Message-ID: <20180220133725.GC21243@bombadil.infradead.org>
References: <20180219194216.GA26165@jordon-HP-15-Notebook-PC>
 <201802201156.4Z60eDwx%fengguang.wu@intel.com>
 <CAFqt6zagwbvs06yK6KPp1TE5Z-mXzv6Bh2rhFFAyjz3Nh0BXmA@mail.gmail.com>
 <20180220090820.GA153760@rodete-desktop-imager.corp.google.com>
 <CAFqt6zZeiU9uMq0kNJRBs_aBTmHvZZkaotJ6GnVOjT6Y3nyS9g@mail.gmail.com>
 <20180220125246.GB21243@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180220125246.GB21243@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com, Linux-MM <linux-mm@kvack.org>

On Tue, Feb 20, 2018 at 04:52:46AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 20, 2018 at 04:25:15PM +0530, Souptick Joarder wrote:
> > On Tue, Feb 20, 2018 at 2:38 PM, Minchan Kim <minchan@kernel.org> wrote:
> > > Yub, bool could be more appropriate. However, there are lots of other places
> > > in kernel where use int instead of bool.
> > > If we fix every such places with each patch, it would be very painful.
> > > If you believe it's really worth, it would be better to find/fix every
> > > such places in one patch. But I'm not sure it's worth.
> > >
> > 
> > Sure, I will create patch series and send it.
> 
> Please don't.  If you're touching a function for another reason, it's
> fine to convert it to return bool.  A series of patches converting every
> function in the kernel that could be converted will not make friends.

... but if you're looking for something to do, here's something from my
TODO list that's in the same category.

The vm_ops fault, huge_fault, page_mkwrite and pfn_mkwrite handlers are
currently defined to return an int (see linux/mm.h).  Unlike the majority
of functions which return int, these functions are supposed to return
one or more of the VM_FAULT flags.  There's general agreement that this
should become a new typedef, vm_fault_t.  We can do a gradual conversion;
start off by adding

typedef int vm_fault_t;

to linux/mm.h.  Then the individual drivers can be converted (one patch
per driver) to return vm_fault_t from those handlers (probably about
180 patches, so take it slowly).  Once all drivers are converted, we
can change that typedef to:

typedef enum {
	VM_FAULT_OOM	= 1,
	VM_FAULT_SIGBUS	= 2,
	VM_FAULT_MAJOR	= 4,
...
} vm_fault_t;

and then the compiler will warn if anyone tries to introduce a new handler
that returns int.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
