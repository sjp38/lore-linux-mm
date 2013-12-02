Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 438556B003B
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 12:26:20 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so18513535pdj.4
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 09:26:19 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id j9si3892534pav.310.2013.12.02.09.26.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Dec 2013 09:26:18 -0800 (PST)
Date: Mon, 2 Dec 2013 09:26:15 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: netfilter: active obj WARN when cleaning up
Message-ID: <20131202172615.GA4722@kroah.com>
References: <alpine.DEB.2.02.1311271106090.30673@ionos.tec.linutronix.de>
 <20131127113939.GL16735@n2100.arm.linux.org.uk>
 <alpine.DEB.2.02.1311271409280.30673@ionos.tec.linutronix.de>
 <20131127133231.GO16735@n2100.arm.linux.org.uk>
 <20131127134015.GA6011@n2100.arm.linux.org.uk>
 <alpine.DEB.2.02.1311271443580.30673@ionos.tec.linutronix.de>
 <20131127233415.GB19270@kroah.com>
 <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com>
 <20131202164039.GA19937@kroah.com>
 <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sasha.levin@oracle.com>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Dec 02, 2013 at 05:18:16PM +0000, Christoph Lameter wrote:
> On Mon, 2 Dec 2013, Greg KH wrote:
> 
> > On Mon, Dec 02, 2013 at 04:33:20PM +0000, Christoph Lameter wrote:
> > > On Wed, 27 Nov 2013, Greg KH wrote:
> > >
> > > > Just make the kobject "dynamic" instead of embedded in struct kmem_cache
> > > > and all will be fine.  I can't believe this code has been broken for
> > > > this long.
> > >
> > > The slub code is was designed to use an embedded structure since we
> > > only get the kobj  pointer passed to us from sysfs. If kobj is not
> > > embedded then how can we get from the sysfs object to the kmem_cache
> > > structure from the sysfs callbacks? Sysfs was designed to have embedded
> > > objects as far as I can recall.
> >
> > Yes, it's designed to have embedded objects, so then use it that way and
> > clean up the structure when the kobject goes away.  Don't use a
> > different reference count for your structure than the one in the kobject
> > and think that all will be fine.
> 
> We need our own reference count. So we just have to defer the
> release of the kmem_cache struct until the ->release callback is
> triggered. The put of the embedded kobject must be the last action on the
> kmem_cache  structure which will then trigger release and that will
> trigger the kmem_cache_free().
> 

Ok, that sounds reasonable, or you can just create a "tiny" structure
for the kobject that has a pointer back to your kmem_cache structure
that you can then reference from the show/store functions.  Either is
fine with me.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
