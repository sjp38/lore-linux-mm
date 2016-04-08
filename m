Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id E2C056B025E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 11:32:34 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id u8so71629250lbk.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 08:32:34 -0700 (PDT)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id r128si7227136lfe.62.2016.04.08.08.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 08:32:33 -0700 (PDT)
Received: by mail-lb0-x242.google.com with SMTP id ot1so3249018lbb.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 08:32:33 -0700 (PDT)
Date: Fri, 8 Apr 2016 17:32:29 +0200
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: Re: [PATCH 0/3] mm/mmap.c: don't unmap the overlapping VMA(s)
Message-ID: <20160408153228.GA1397@home.local>
References: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
 <20160404073100.GA10272@dhcp22.suse.cz>
 <570287B3.6050903@suse.cz>
 <20160407161128.GA2713@home.local>
 <20160407163108.GF32755@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160407163108.GF32755@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mtk.manpages@gmail.com, cmetcalf@mellanox.com, arnd@arndb.de, viro@zeniv.linux.org.uk, mszeredi@suse.cz, dave@stgolabs.net, kirill.shutemov@linux.intel.com, mingo@kernel.org, dan.j.williams@intel.com, dave.hansen@linux.intel.com, koct9i@gmail.com, hannes@cmpxchg.org, jack@suse.cz, xiexiuqi@huawei.com, iamjoonsoo.kim@lge.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, rientjes@google.com, denc716@gmail.com, toshi.kani@hpe.com, ldufour@linux.vnet.ibm.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Thu, Apr 07, 2016 at 06:31:09PM +0200, Michal Hocko wrote:
> On Thu 07-04-16 18:11:29, Piotr Kwapulinski wrote:
> > On Mon, Apr 04, 2016 at 05:26:43PM +0200, Vlastimil Babka wrote:
> > > On 04/04/2016 09:31 AM, Michal Hocko wrote:
> > > >On Sat 02-04-16 21:17:31, Piotr Kwapulinski wrote:
> > > >>Currently the mmap(MAP_FIXED) discards the overlapping part of the
> > > >>existing VMA(s).
> > > >>Introduce the new MAP_DONTUNMAP flag which forces the mmap to fail
> > > >>with ENOMEM whenever the overlapping occurs and MAP_FIXED is set.
> > > >>No existing mapping(s) is discarded.
> > > >
> > > >You forgot to tell us what is the use case for this new flag.
> > > 
> > > Exactly. Also, returning ENOMEM is strange, EINVAL might be a better match,
> > > otherwise how would you distinguish a "geunine" ENOMEM from passing a wrong
> > > address?
> > > 
> > > 
> > 
> > Thanks to all for suggestions. I'll fix them.
> > 
> > The example use case:
> > #include <stdio.h>
> > #include <string.h>
> > #include <sys/mman.h>
> > 
> > void main(void)
> > {
> >   void* addr = (void*)0x1000000;
> >   size_t size = 0x600000;
> >   void* start = 0;
> >   start = mmap(addr,
> >                size,
> >                PROT_WRITE,
> >                MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
> >                -1, 0);
> > 
> >   strcpy(start, "PPPP");
> >   printf("%s\n", start);        // == PPPP
> > 
> >   addr = (void*)0x1000000;
> >   size = 0x9000;
> >   start = mmap(addr,
> >                size,
> >                PROT_READ | PROT_WRITE,
> >                MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
> >                -1, 0);
> >   
> >   printf("%s\n", start);        // != PPPP
> > }
> > 
> > Another use case, this time with huge pages in action.
> > The limit configured in proc's nr_hugepages is exceeded.
> > mmap unmaps the area and fails. No new mapping is created.
> > The program segfaults.
> 
> Yes and this is the standard behavior for ages. So _why_ somebody wants
> non-default behavior. When I've asked for the use case I meant a real
> life code (not just an example snippet) which cannot cope with the
> standard semantic. In other words why this cannot be handled in the
> userspace and we have to add a new API which we have to maintain for
> ever?

Ok, I got it. Thanks for feedback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
