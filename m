Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 144766B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 05:50:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i202-v6so1750594wmf.9
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 02:50:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18-v6sor1944970wrp.48.2018.07.12.02.50.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 02:50:04 -0700 (PDT)
Date: Thu, 12 Jul 2018 11:50:02 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: Boot failures with "mm/sparse: Remove
 CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER" on powerpc (was Re: mmotm
 2018-07-10-16-50 uploaded)
Message-ID: <20180712095002.GA5342@techadventures.net>
References: <20180710235044.vjlRV%akpm@linux-foundation.org>
 <87lgai9bt5.fsf@concordia.ellerman.id.au>
 <20180711133737.GA29573@techadventures.net>
 <CAGM2reYsSi5kDGtnTQASnp1v49T8Y+9o_pNxmSq-+m68QhF2Tg@mail.gmail.com>
 <CAOXBz7ixEK85S-029XrM4+g4fxtSY6_tke0gcQ-hOXFCb7wcZg@mail.gmail.com>
 <87efg981rd.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87efg981rd.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Oscar Salvador <osalvador.vilardaga@gmail.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, mhocko@suse.cz, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, mm-commits@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, bhe@redhat.com, aneesh.kumar@linux.ibm.com, khandual@linux.vnet.ibm.com

> > I just roughly check, but if I checked the right place,
> > vmemmap_populated() checks for the section to contain the flags we are
> > setting in sparse_init_one_section().
> 
> Yes.
> 
> > But with this patch, we populate first everything, and then we call
> > sparse_init_one_section() in sparse_init().
> > As I said I could be mistaken because I just checked the surface.
> 
> Yeah I think that's correct.
> 
> This might just be a bug in our code, let me look at it a bit.

I wonder if something like this could make the trick:

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 51ce091914f9..e281651f50cd 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -177,6 +177,8 @@ static __meminit void vmemmap_list_populate(unsigned long phys,
        vmemmap_list = vmem_back;
 }
 
+static unsigned long last_addr_populated = 0;
+
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
                struct vmem_altmap *altmap)
 {
@@ -191,7 +193,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
                void *p;
                int rc;
 
-               if (vmemmap_populated(start, page_size))
+               if (start + page_size <= last_addr_populated)
                        continue;
 
                if (altmap)
@@ -212,6 +214,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
                                __func__, rc);
                        return -EFAULT;
                }
+               last_addr_populated = start + page_size;
        }

I know it looks hacky, and chances are that are wrong, but could you give it a try?
I will try to grab a ppc server and try it out too.
 
Thanks
-- 
Oscar Salvador
SUSE L3
