Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 115A96B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 05:45:30 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id e11so3057249bkh.23
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 02:45:30 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id rl9si12089414bkb.67.2013.11.27.02.45.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 02:45:30 -0800 (PST)
Date: Wed, 27 Nov 2013 11:45:17 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: netfilter: active obj WARN when cleaning up
In-Reply-To: <20131126230709.GA10948@localhost>
Message-ID: <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de>
References: <522B25B5.6000808@oracle.com> <5294F27D.4000108@oracle.com> <20131126230709.GA10948@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Greg KH <greg@kroah.com>, Russell King <linux@arm.linux.org.uk>

On Wed, 27 Nov 2013, Pablo Neira Ayuso wrote:

> On Tue, Nov 26, 2013 at 02:11:57PM -0500, Sasha Levin wrote:
> > Ping? I still see this warning.
> 
> Did your test include patch 0c3c6c00c6?

And how is that patch supposed to help?
 
> > >[  418.312449] WARNING: CPU: 6 PID: 4178 at lib/debugobjects.c:260 debug_print_object+0x8d/0xb0()
> > >[  418.313243] ODEBUG: free active (active state 0) object type: timer_list hint:
> > >delayed_work_timer_fn+0x0/0x20

> > >[  418.321101]  [<ffffffff812874d7>] kmem_cache_free+0x197/0x340
> > >[  418.321101]  [<ffffffff81249e76>] kmem_cache_destroy+0x86/0xe0
> > >[  418.321101]  [<ffffffff83d5d681>] nf_conntrack_cleanup_net_list+0x131/0x170

The debug code detects an active timer, which itself is part of a
delayed work struct. The call comes from kmem_cache_destroy().

         kmem_cache_free(kmem_cache, s);

So debug object says: s contains an active timer. s is the kmem_cache
which is destroyed from nf_conntrack_cleanup_net_list.

Now struct kmem_cache has in case of SLUB:

    struct kobject kobj;    /* For sysfs */

and struct kobject has:

#ifdef CONFIG_DEBUG_KOBJECT_RELEASE
    struct delayed_work     release;
#endif

So this is the thing you want to look at:

commit c817a67ec (kobject: delayed kobject release: help find buggy
drivers) added that delayed work thing.

I fear that does not work for kobjects which are embedded into
something else.

Handing off to rmk, mm and kobject folks.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
