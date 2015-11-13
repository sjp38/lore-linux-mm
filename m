Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 273AA6B0254
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 06:52:07 -0500 (EST)
Received: by wmww144 with SMTP id w144so27195615wmw.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 03:52:06 -0800 (PST)
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com. [195.75.94.102])
        by mx.google.com with ESMTPS id y4si25330783wjr.114.2015.11.13.03.52.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Nov 2015 03:52:06 -0800 (PST)
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 13 Nov 2015 11:52:05 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 80B232190067
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:51:57 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tADBq2o08192292
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 11:52:02 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tADBq1qL006442
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 04:52:02 -0700
Date: Fri, 13 Nov 2015 12:52:00 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [linux-next:master 12891/13017] mm/slub.c:2396:1: warning:
 '___slab_alloc' uses dynamic stack allocation
Message-ID: <20151113125200.319a3101@mschwide>
In-Reply-To: <20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org>
References: <201511111413.65wysS6A%fengguang.wu@intel.com>
	<20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andreas Krebbel <Andreas.Krebbel@de.ibm.com>

On Wed, 11 Nov 2015 12:41:08 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 11 Nov 2015 14:34:19 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   2bba65ab5f9f1cebd21d95c410b96952851f58b3
> > commit: e191357c4c31d02eb30736a49327ef32407fab47 [12891/13017] slub: create new ___slab_alloc function that can be called with irqs disabled
> > config: s390-allmodconfig (attached as .config)
> > reproduce:
> >         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout e191357c4c31d02eb30736a49327ef32407fab47
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=s390 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    mm/slub.c: In function 'unfreeze_partials.isra.42':
> >    mm/slub.c:2019:1: warning: 'unfreeze_partials.isra.42' uses dynamic stack allocation
> >     }
> >     ^
> >    mm/slub.c: In function 'get_partial_node.isra.43':
> >    mm/slub.c:1654:1: warning: 'get_partial_node.isra.43' uses dynamic stack allocation
> >     }
> >     ^
> >    mm/slub.c: In function 'deactivate_slab':
> >    mm/slub.c:1951:1: warning: 'deactivate_slab' uses dynamic stack allocation
> >     }
> >     ^
> >    mm/slub.c: In function '__slab_free':
> >    mm/slub.c:2696:1: warning: '__slab_free' uses dynamic stack allocation
> >     }
> >     ^
> >    mm/slub.c: In function '___slab_alloc':
> > >> mm/slub.c:2396:1: warning: '___slab_alloc' uses dynamic stack allocation
> >     }
> >     ^
> 
> This patch doesn't add any dynamic stack allocations.  The fact that
> slub.c already had a bunch of these warnings makes me suspect that it's
> happening in one of the s390 headers?
 
That looks like a false positive to me. I can not find any function that does
a dynamic allocation and the generated code creates a stack frame with a
constant size. A bit odd is the fact that the stack frame is create in two
steps, e.g. deactivate_slab:

    a632:       b9 04 00 ef             lgr     %r14,%r15
    a636:       a7 fb ff 50             aghi    %r15,-176	# first 176 bytes
    a63a:       b9 04 00 bf             lgr     %r11,%r15
    a63e:       e3 e0 f0 98 00 24       stg     %r14,152(%r15)
    a644:       e3 10 f0 98 00 04       lg      %r1,152(%r15)
    a64a:       a7 fb ff 30             aghi    %r15,-208	# another 208 bytes
    a64e:       e3 30 b0 e8 00 24       stg     %r3,232(%r11)
    a654:       e3 40 b0 d8 00 24       stg     %r4,216(%r11)

Strange. Andreas can you make something of this?

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
