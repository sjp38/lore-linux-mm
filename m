Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98A9F6B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:21:49 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i2so1812906pgq.8
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:21:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n14si9201297pfh.229.2018.01.19.05.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Jan 2018 05:21:48 -0800 (PST)
Date: Fri, 19 Jan 2018 05:21:45 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180119132145.GB2897@bombadil.infradead.org>
References: <bug-198497-27@https.bugzilla.kernel.org/>
 <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
 <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xen@randomwebstuff.com
Cc: Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Fri, Jan 19, 2018 at 04:14:42PM +1300, xen@randomwebstuff.com wrote:
> 
> On 19/01/18 4:04 PM, Matthew Wilcox wrote:
> > On Thu, Jan 18, 2018 at 02:18:20PM -0800, Laura Abbott wrote:
> > > On 01/18/2018 01:55 PM, Andrew Morton wrote:
> > > > > [   24.647744] BUG: unable to handle kernel NULL pointer dereference at
> > > > > 00000008
> > > > > [   24.647801] IP: __radix_tree_lookup+0x14/0xa0
> > > > > [   24.647811] *pdpt = 00000000253d6027 *pde = 0000000000000000
> > > > > [   24.647828] Oops: 0000 [#1] SMP
> > > > > [   24.647842] CPU: 5 PID: 3600 Comm: java Not tainted
> > > > > 4.14.13-rh10-20180115190010.xenU.i386 #1
> > > > > [   24.647855] task: e52518c0 task.stack: e4e7a000
> > > > > [   24.647866] EIP: __radix_tree_lookup+0x14/0xa0
> > > > > [   24.647876] EFLAGS: 00010286 CPU: 5
> > > > > [   24.647884] EAX: 00000004 EBX: 00000007 ECX: 00000000 EDX: 00000000

If my understanding is right, EDX contains the index we're looking up.
Which is zero.  So the swp_entry we got is one bit away from being NULL.
Hmm.  Have you run memtest86 or some other memory tester on the system
recently?

> PS: cannot recall seeing this issue on x86_64, just 32 bit.

Laura has 64-bit instances of this.

PPS: reminder
> this is on a Xen VM which per https://xenbits.xen.org/docs/unstable/man/xl.cfg.5.html#PVH-Guest-Specific-Options
> has "out of sync pagetables" if that is relevant (we do not set that option,
> I am unsure what default is used).

Laura also has non-Xen instances of this.  They may not all be the same
bug, of course.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
