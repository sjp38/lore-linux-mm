Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD48E6B0031
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 16:04:10 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id t27so386336iob.20
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 13:04:10 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 4si8184265ity.18.2018.03.06.13.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 13:04:09 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w26L1rmL011325
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 21:04:09 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2gj234g5xk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 06 Mar 2018 21:04:08 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w26L47Hi001698
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 21:04:07 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w26L47ng012009
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 21:04:07 GMT
Received: by mail-oi0-f41.google.com with SMTP id g5so16589oiy.8
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 13:04:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180306125604.c394a25a50cae0e36c546855@linux-foundation.org>
References: <20180306192022.28289-1-pasha.tatashin@oracle.com>
 <20180306123655.957e5b6b20b200505544ea7a@linux-foundation.org>
 <CAGM2rea1raxsXDkqZgmmdBiuywp1M3y1p++=J893VJDgGDWLnQ@mail.gmail.com> <20180306125604.c394a25a50cae0e36c546855@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 6 Mar 2018 16:04:06 -0500
Message-ID: <CAGM2rebb9FdceEBO2GfJ7BKf=fEf8p86Yc1vCq4eZyyB0Me+DA@mail.gmail.com>
Subject: Re: [PATCH] mm: might_sleep warning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> > > >       spin_lock(&deferred_zone_grow_lock);
> > > > -     static_branch_disable(&deferred_pages);
> > > > +     deferred_zone_grow = false;
> > > >       spin_unlock(&deferred_zone_grow_lock);
> > > > +     static_branch_disable(&deferred_pages);
> > > >
> > > >       /* There will be num_node_state(N_MEMORY) threads */
> > > >       atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
> > >
> > > Kinda ugly, but I can see the logic behind the decisions.
> > >
> > > Can we instead turn deferred_zone_grow_lock into a mutex?
>
> (top-posting repaired.  Please don't top-post).
>
> > [CCed everyone]
> >
> > Hi Andrew,
> >
> > I afraid we cannot change this spinlock to mutex
> > because deferred_grow_zone() might be called from an interrupt context if
> > interrupt thread needs to allocate memory.
> >
>
> OK.  But if deferred_grow_zone() can be called from interrupt then
> page_alloc_init_late() should be using spin_lock_irq(), shouldn't it?
> I'm surprised that lockdep didn't detect that.

No, page_alloc_init_late()  cannot be called from interrupt, it is
called straight from:
kernel_init_freeable(). But, I believe deferred_grow_zone(): can be called:

get_page_from_freelist()
 _deferred_grow_zone()
   deferred_grow_zone()


>
>
>
> --- a/mm/page_alloc.c~mm-initialize-pages-on-demand-during-boot-fix-4-fix
> +++ a/mm/page_alloc.c
> @@ -1689,9 +1689,9 @@ void __init page_alloc_init_late(void)
>          * context. Since, spin_lock() disables preemption, we must use an
>          * extra boolean deferred_zone_grow.
>          */
> -       spin_lock(&deferred_zone_grow_lock);
> +       spin_lock_irq(&deferred_zone_grow_lock);
>         deferred_zone_grow = false;
> -       spin_unlock(&deferred_zone_grow_lock);
> +       spin_unlock_irq(&deferred_zone_grow_lock);
>         static_branch_disable(&deferred_pages);
>
>         /* There will be num_node_state(N_MEMORY) threads */
> _
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
