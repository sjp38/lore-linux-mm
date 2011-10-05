Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 32EB7900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 21:03:16 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <77608af6-a747-47f6-81ac-e1379f75fd65@default>
Date: Tue, 4 Oct 2011 18:03:00 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>
 <4E72284B.2040907@linux.vnet.ibm.com>
 <075c4e4c-a22d-47d1-ae98-31839df6e722@default>
 <4E725109.3010609@linux.vnet.ibm.com>
 <863f8de5-a8e5-427d-a329-e69a5402f88a@default>
 <1317657556.16137.696.camel@nimitz> <4E89F6D1.6000502@vflare.org
 1317666154.16137.727.camel@nimitz>
In-Reply-To: <1317666154.16137.727.camel@nimitz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Sent: Monday, October 03, 2011 12:23 PM
> To: Nitin Gupta
> Cc: Dan Magenheimer; Seth Jennings; Greg KH; gregkh@suse.de; devel@driver=
dev.osuosl.org;
> cascardo@holoscopio.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org=
; brking@linux.vnet.ibm.com;
> rcj@linux.vnet.ibm.com
> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
>=20
> On Mon, 2011-10-03 at 13:54 -0400, Nitin Gupta wrote:
> > I think disabling preemption on the local CPU is the cheapest we can ge=
t
> > to protect PCPU buffers. We may experiment with, say, multiple buffers
> > per CPU, so we end up disabling preemption only in highly improbable
> > case of getting preempted just too many times exactly within critical
> > section.
>=20
> I guess the problem is two-fold: preempt_disable() and
> local_irq_save().
>=20
> > static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oi=
dp,
> >                                 uint32_t index, struct page *page)
> > {
> >         struct tmem_pool *pool;
> >         int ret =3D -1;
> >
> >         BUG_ON(!irqs_disabled());
>=20
> That tells me "zcache" doesn't work with interrupts on.  It seems like
> awfully high-level code to have interrupts disabled.  The core page
> allocator has some irq-disabling spinlock calls, but that's only really
> because it has to be able to service page allocations from interrupts.
> What's the high-level reason for zcache?
>=20
> I'll save the discussion about preempt for when Seth posts his patch.

I completely agree that the irq/softirq/preempt states should be
re-examined and, where possible, improved before zcache moves
out of staging.

Actually, I think cleancache_put is called from a point in the kernel
where irqs are disabled.  I believe it is unsafe to call a routine
sometimes with irqs disabled and sometimes with irqs enabled?
I think some points of call to cleancache_flush may also have
irqs disabled.

IIRC, much of the zcache code has preemption disabled because
it is unsafe for a page fault to occur when zcache is running,
since the page fault may cause a (recursive) call into zcache
and possibly recursively take a lock.

Anyway, some of the atomicity constraints in the code are
definitely required, but there are very likely some constraints
that are overzealous and can be removed.  For now, I'd rather
have the longer interrupt latency with code that works than
have developers experimenting with zcache and see lockups. :-}

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
