Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 805CC6B0260
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:45:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q203so574648wmb.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:45:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k10si8760821wrd.344.2017.10.10.14.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 14:45:55 -0700 (PDT)
Date: Tue, 10 Oct 2017 14:45:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/page_alloc.c: inline __rmqueue()
Message-Id: <20171010144545.c87a28b0f3c4e475305254ab@linux-foundation.org>
In-Reply-To: <20171010054342.GF1798@intel.com>
References: <20171009054434.GA1798@intel.com>
	<3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
	<20171010025151.GD1798@intel.com>
	<20171010025601.GE1798@intel.com>
	<8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
	<20171010054342.GF1798@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Tue, 10 Oct 2017 13:43:43 +0800 Aaron Lu <aaron.lu@intel.com> wrote:

> On Mon, Oct 09, 2017 at 10:19:52PM -0700, Dave Hansen wrote:
> > On 10/09/2017 07:56 PM, Aaron Lu wrote:
> > > This patch adds inline to __rmqueue() and vmlinux' size doesn't have any
> > > change after this patch according to size(1).
> > > 
> > > without this patch:
> > >    text    data     bss     dec     hex     filename
> > > 9968576 5793372 17715200  33477148  1fed21c vmlinux
> > > 
> > > with this patch:
> > >    text    data     bss     dec     hex     filename
> > > 9968576 5793372 17715200  33477148  1fed21c vmlinux
> > 
> > This is unexpected.  Could you double-check this, please?
> 
> mm/page_alloc.o has size changes:
> 
> Without this patch:
> $ size mm/page_alloc.o
>   text    data     bss     dec     hex filename
>  36695    9792    8396   54883    d663 mm/page_alloc.o
> 
> With this patch:
> $ size mm/page_alloc.o
>   text    data     bss     dec     hex filename
>  37511    9792    8396   55699    d993 mm/page_alloc.o
> 
> But vmlinux doesn't.
> 
> It's not clear to me what happened, do you want to me dig this out?

There's weird stuff going on.

With x86_64 gcc-4.8.4

Patch not applied:

akpm3:/usr/local/google/home/akpm/k/25> nm mm/page_alloc.o|grep __rmqueue
0000000000002a00 t __rmqueue

Patch applied:

akpm3:/usr/local/google/home/akpm/k/25> nm mm/page_alloc.o|grep __rmqueue
000000000000039f t __rmqueue_fallback
0000000000001220 t __rmqueue_smallest

So inlining __rmqueue has caused the compiler to decide to uninline
__rmqueue_fallback and __rmqueue_smallest, which largely undoes the
effect of your patch.

`inline' is basically advisory (or ignored) in modern gcc's.  So gcc
has felt free to ignore it in __rmqueue_fallback and __rmqueue_smallest
because gcc thinks it knows best.  That's why we created
__always_inline, to grab gcc by the scruff of its neck.

So...  I think this patch could do with quite a bit more care, tuning
and testing with various gcc versions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
