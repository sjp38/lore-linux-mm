Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1676B0033
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:44:46 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so6323550pdj.8
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:44:45 -0700 (PDT)
Received: by mail-bk0-f44.google.com with SMTP id mz10so13bkb.3
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:44:42 -0700 (PDT)
Date: Wed, 25 Sep 2013 19:44:36 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: mm: insure topdown mmap chooses addresses above security minimum
Message-ID: <20130925174436.GA14037@gmail.com>
References: <1380057811-5352-1-git-send-email-timothy.c.pepper@linux.intel.com>
 <20130925073048.GB27960@gmail.com>
 <20130925171243.GA7428@tcpepper-desk.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925171243.GA7428@tcpepper-desk.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timothy Pepper <timothy.c.pepper@linux.intel.com>
Cc: linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, James Morris <james.l.morris@oracle.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>


* Timothy Pepper <timothy.c.pepper@linux.intel.com> wrote:

> On Wed 25 Sep at 09:30:49 +0200 mingo@kernel.org said:
> > >  	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
> > >  	info.length = len;
> > > -	info.low_limit = PAGE_SIZE;
> > > +	info.low_limit = max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));
> > >  	info.high_limit = mm->mmap_base;
> > >  	info.align_mask = filp ? get_align_mask() : 0;
> > >  	info.align_offset = pgoff << PAGE_SHIFT;
> > 
> > There appears to be a lot of repetition in these methods - instead of 
> > changing 6 places it would be more future-proof to first factor out the 
> > common bits and then to apply the fix to the shared implementation.
> 
> Besides that existing redundancy in the multiple somewhat similar
> arch_get_unmapped_area_topdown() functions, I was expecting people might
> question the added redundancy of the six instances of:
> 
> 	max(PAGE_SIZE, PAGE_ALIGN(mmap_min_addr));

That redundancy would be automatically addressed by my suggestion.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
