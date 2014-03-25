Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A01DF6B003C
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 14:01:57 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so562442wgh.3
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:01:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qb5si1647743wic.35.2014.03.25.11.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 11:01:56 -0700 (PDT)
Date: Tue, 25 Mar 2014 11:01:50 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mm: slub: gpf in deactivate_slab
Message-ID: <20140325180149.GD7519@dhcp22.suse.cz>
References: <53208A87.2040907@oracle.com>
 <5331A6C3.2000303@oracle.com>
 <20140325165247.GA7519@dhcp22.suse.cz>
 <alpine.DEB.2.10.1403251205140.24534@nuc>
 <20140325175634.GC7519@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140325175634.GC7519@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 25-03-14 10:56:34, Michal Hocko wrote:
> On Tue 25-03-14 12:06:36, Christoph Lameter wrote:
> > On Tue, 25 Mar 2014, Michal Hocko wrote:
> > 
> > > You are right. The function even does VM_BUG_ON(!irqs_disabled())...
> > > Unfortunatelly we do not seem to have an _irq alternative of the bit
> > > spinlock.
> > > Not sure what to do about it. Christoph?
> > >
> > > Btw. it seems to go way back to 3.1 (1d07171c5e58e).
> > 
> > Well there is a preempt_enable() (bit_spin_lock) and a preempt_disable()
> > bit_spin_unlock() within a piece of code where irqs are disabled.
> > 
> > Is that a problem? Has been there for a long time.
> 
> It is because preempt_enable calls __preempt_schedule when the preempt
> count drops down to 0. You would need to call preempt_disable before you
> disable interrupts or use an irq safe bit spin unlock which doesn't
> enabled preemption unconditionally.

Hmm, now that I am looking into the code more closely it seems that
preempt_schedule bails out when interrupts are disabled.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
