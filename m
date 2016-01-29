Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6056B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:53:40 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id f81so84978159iof.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:53:40 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id p9si25531204ioe.174.2016.01.29.02.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 02:53:38 -0800 (PST)
Date: Fri, 29 Jan 2016 21:53:35 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [linux-next:master 1875/2100] include/linux/jump_label.h:122:2:
 error: implicit declaration of function 'atomic_read'
Message-ID: <20160129215335.1a049964@canb.auug.org.au>
In-Reply-To: <56AB3EEB.8090808@suse.cz>
References: <201601291512.vqk4lpvV%fengguang.wu@intel.com>
	<56AB3EEB.8090808@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kbuild test robot <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kbuild-all@01.org, linux-s390@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

Hi Vlastimil,

On Fri, 29 Jan 2016 11:28:59 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 01/29/2016 08:06 AM, kbuild test robot wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   735cfa51151aeae6df04074165aa36b42481df86
> > commit: e8bd33570a656979c09ce66a11ca8864fda8ad0c [1875/2100] mm, printk: introduce new format string for flags-fix
> > config: s390-allyesconfig (attached as .config)
> > reproduce:
> >         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout e8bd33570a656979c09ce66a11ca8864fda8ad0c
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=s390 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    In file included from include/linux/static_key.h:1:0,
> >                     from include/linux/tracepoint-defs.h:11,
> >                     from include/linux/mmdebug.h:6,
> >                     from arch/s390/include/asm/cmpxchg.h:10,
> >                     from arch/s390/include/asm/atomic.h:19,
> >                     from include/linux/atomic.h:4,
> >                     from include/linux/debug_locks.h:5,
> >                     from include/linux/lockdep.h:23,
> >                     from include/linux/hardirq.h:5,
> >                     from include/linux/kvm_host.h:10,
> >                     from arch/s390/kernel/asm-offsets.c:10:
> >    include/linux/jump_label.h: In function 'static_key_count':  
> >>> include/linux/jump_label.h:122:2: error: implicit declaration of function 'atomic_read' [-Werror=implicit-function-declaration]  
> >      return atomic_read(&key->enabled);  
> 
> Sigh.
> 
> I don't get it, there's "#include <linux/atomic.h>" in jump_label.h right before
> it gets used. So, what implicit declaration?

But we are in the process of reading linux/atomic.h already, and the
#include in jump_label.h will just not read it then (because of the
include guards) so the body of linux/atomic.h has not yet been read
when we process static_key_count().  i.e. we have a circular inclusion.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
