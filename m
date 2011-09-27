Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D534C9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:06:03 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8RD2aQ2020757
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:02:36 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8RD5fS8103956
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:05:44 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8RD5cUv021156
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 07:05:41 -0600
Date: Tue, 27 Sep 2011 18:20:20 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
Message-ID: <20110927125020.GB3685@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
 <1317127079.15383.52.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1317127079.15383.52.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-09-27 14:37:59]:

> On Tue, 2011-09-20 at 17:33 +0530, Srikar Dronamraju wrote:
> > +static unsigned long xol_take_insn_slot(struct uprobes_xol_area *area)
> > +{
> > +       unsigned long slot_addr, flags;
> > +       int slot_nr;
> > +
> > +       do {
> > +               spin_lock_irqsave(&area->slot_lock, flags);
> > +               slot_nr = find_first_zero_bit(area->bitmap, UINSNS_PER_PAGE);
> > +               if (slot_nr < UINSNS_PER_PAGE) {
> > +                       __set_bit(slot_nr, area->bitmap);
> > +                       slot_addr = area->vaddr +
> > +                                       (slot_nr * UPROBES_XOL_SLOT_BYTES);
> > +                       atomic_inc(&area->slot_count);
> > +               }
> > +               spin_unlock_irqrestore(&area->slot_lock, flags);
> > +               if (slot_nr >= UINSNS_PER_PAGE)
> > +                       xol_wait_event(area);
> > +
> > +       } while (slot_nr >= UINSNS_PER_PAGE);
> > +
> > +       return slot_addr;
> > +} 
> 
> Why isn't a find_first_bit() + set_and_test_bit() not sufficient? That
> is, what do you need that lock for?

yes, we could do without the lock to.
Will do this in the next patchset.

-- 
Thanks and Regards 
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
