Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E79556B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 06:46:13 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id ey16so1889992wid.1
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 03:46:13 -0800 (PST)
Received: from caramon.arm.linux.org.uk (caramon.arm.linux.org.uk. [78.32.30.218])
        by mx.google.com with ESMTPS id mu3si10474428wic.15.2013.11.27.03.46.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 03:46:11 -0800 (PST)
Date: Wed, 27 Nov 2013 11:39:39 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: netfilter: active obj WARN when cleaning up
Message-ID: <20131127113939.GL16735@n2100.arm.linux.org.uk>
References: <522B25B5.6000808@oracle.com> <5294F27D.4000108@oracle.com> <20131126230709.GA10948@localhost> <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Greg KH <greg@kroah.com>

On Wed, Nov 27, 2013 at 11:45:17AM +0100, Thomas Gleixner wrote:
> On Wed, 27 Nov 2013, Pablo Neira Ayuso wrote:
> 
> > On Tue, Nov 26, 2013 at 02:11:57PM -0500, Sasha Levin wrote:
> > > Ping? I still see this warning.
> > 
> > Did your test include patch 0c3c6c00c6?
> 
> And how is that patch supposed to help?
>  
> > > >[  418.312449] WARNING: CPU: 6 PID: 4178 at lib/debugobjects.c:260 debug_print_object+0x8d/0xb0()
> > > >[  418.313243] ODEBUG: free active (active state 0) object type: timer_list hint:
> > > >delayed_work_timer_fn+0x0/0x20
> 
> > > >[  418.321101]  [<ffffffff812874d7>] kmem_cache_free+0x197/0x340
> > > >[  418.321101]  [<ffffffff81249e76>] kmem_cache_destroy+0x86/0xe0
> > > >[  418.321101]  [<ffffffff83d5d681>] nf_conntrack_cleanup_net_list+0x131/0x170
> 
> The debug code detects an active timer, which itself is part of a
> delayed work struct. The call comes from kmem_cache_destroy().
> 
>          kmem_cache_free(kmem_cache, s);
> 
> So debug object says: s contains an active timer. s is the kmem_cache
> which is destroyed from nf_conntrack_cleanup_net_list.
> 
> Now struct kmem_cache has in case of SLUB:
> 
>     struct kobject kobj;    /* For sysfs */
> 
> and struct kobject has:
> 
> #ifdef CONFIG_DEBUG_KOBJECT_RELEASE
>     struct delayed_work     release;
> #endif
> 
> So this is the thing you want to look at:
> 
> commit c817a67ec (kobject: delayed kobject release: help find buggy
> drivers) added that delayed work thing.
> 
> I fear that does not work for kobjects which are embedded into
> something else.

No, kobjects embedded into something else have their lifetime determined
by the embedded kobject.  That's rule #1 of kobjects - or rather reference
counted objects.

The point at which the kobject gets destructed is when the release function
is called.  If it is destructed before that time, that's a violation of
the reference counted nature of kobjects, and that's what the delay on
releasing is designed to catch.

It's designed to catch code which does this exact path:

	put(obj)
	free(obj)

rather than code which does it the right way:

	put(obj)
		-> refcount becomes 0
			-> release function gets called
				->free(obj)

The former is unsafe because obj may have other references.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
