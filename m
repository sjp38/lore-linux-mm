Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1486E6B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 12:03:00 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id o188-v6so2222266ith.1
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 09:03:00 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id p12-v6si1685649iti.64.2018.06.15.09.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 09:02:56 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5FFxv23073883
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:02:55 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2jk0xr1kqm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:02:55 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5FG2tSf010229
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:02:55 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5FG2sAw014532
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 16:02:54 GMT
Received: by mail-ot0-f178.google.com with SMTP id i19-v6so11518180otk.10
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 09:02:54 -0700 (PDT)
MIME-Version: 1.0
References: <20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp>
 <20180613090700.GG13364@dhcp22.suse.cz> <20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp>
 <20180614053859.GA9863@techadventures.net> <20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp>
 <20180614213033.GA19374@techadventures.net> <20180615010927.GC1196@hori1.linux.bs1.fc.nec.co.jp>
 <20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp> <20180615084142.GE24039@dhcp22.suse.cz>
 <20180615140000.44tht4f3ek3lh2u2@xakep.localdomain> <20180615143308.GA26321@techadventures.net>
In-Reply-To: <20180615143308.GA26321@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 15 Jun 2018 12:02:17 -0400
Message-ID: <CAGM2reYA=jqL7KO6j9Tcjxyeb_=7aCfyekdO_aaRSZYv7_WeVg@mail.gmail.com>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, Linux Memory Management List <linux-mm@kvack.org>, osalvador@suse.de, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, willy@infradead.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

> Hi Pavel,
>
> I think this makes a lot of sense.
> Since Naoya is out until Wednesday, maybe I give it a shot next week and see if I can gather some numbers.

Hi Oscar,

Thank you for the offer to do this. Since, sched_clock() is not yet
initialized at the time zero_resv_unavail() is called, it is difficult
to measure it during boot. But, I had x86 early boot timestamps
patches handy, so I could measure, thus decided to submit the patch.
http://lkml.kernel.org/r/20180615155733.1175-1-pasha.tatashin@oracle.com

Thank you,
Pavel

>
> >
> > Thank you,
> > Pasha
> >
> > >
> > > > ---
> > > >  arch/x86/kernel/e820.c | 15 ++++++++++++---
> > > >  1 file changed, 12 insertions(+), 3 deletions(-)
> > > >
> > > > diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
> > > > index d1f25c831447..c88c23c658c1 100644
> > > > --- a/arch/x86/kernel/e820.c
> > > > +++ b/arch/x86/kernel/e820.c
> > > > @@ -1248,6 +1248,7 @@ void __init e820__memblock_setup(void)
> > > >  {
> > > >   int i;
> > > >   u64 end;
> > > > + u64 addr = 0;
> > > >
> > > >   /*
> > > >    * The bootstrap memblock region count maximum is 128 entries
> > > > @@ -1264,13 +1265,21 @@ void __init e820__memblock_setup(void)
> > > >           struct e820_entry *entry = &e820_table->entries[i];
> > > >
> > > >           end = entry->addr + entry->size;
> > > > +         if (addr < entry->addr)
> > > > +                 memblock_reserve(addr, entry->addr - addr);
> > > > +         addr = end;
> > > >           if (end != (resource_size_t)end)
> > > >                   continue;
> > > >
> > > > +         /*
> > > > +          * all !E820_TYPE_RAM ranges (including gap ranges) are put
> > > > +          * into memblock.reserved to make sure that struct pages in
> > > > +          * such regions are not left uninitialized after bootup.
> > > > +          */
> > > >           if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
> > > > -                 continue;
> > > > -
> > > > -         memblock_add(entry->addr, entry->size);
> > > > +                 memblock_reserve(entry->addr, entry->size);
> > > > +         else
> > > > +                 memblock_add(entry->addr, entry->size);
> > > >   }
> > > >
> > > >   /* Throw away partial pages: */
> > > > --
> > > > 2.7.4
> > >
> > > --
> > > Michal Hocko
> > > SUSE Labs
> > >
> >
>
> Best Regards
> Oscar Salvador
>
