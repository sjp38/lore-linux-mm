Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 72A156B0083
	for <linux-mm@kvack.org>; Wed, 22 May 2013 06:16:39 -0400 (EDT)
Date: Wed, 22 May 2013 12:16:10 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 10/10] kernel: might_fault does not imply might_sleep
Message-ID: <20130522101610.GL18810@twins.programming.kicks-ass.net>
References: <cover.1368702323.git.mst@redhat.com>
 <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
 <20130516184041.GP19669@dyad.programming.kicks-ass.net>
 <20130519093526.GD19883@redhat.com>
 <20130521115734.GA9554@twins.programming.kicks-ass.net>
 <20130522094709.GA26451@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130522094709.GA26451@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, rostedt@goodmis.org

On Wed, May 22, 2013 at 12:47:09PM +0300, Michael S. Tsirkin wrote:
> >  
> > +static inline bool __can_fault(void)
> > +{
> > +	/*
> > +	 * Some code (nfs/sunrpc) uses socket ops on kernel memory while
> > +	 * holding the mmap_sem, this is safe because kernel memory doesn't
> > +	 * get paged out, therefore we'll never actually fault, and the
> > +	 * below annotations will generate false positives.
> > +	 */
> > +	if (segment_eq(get_fs(), KERNEL_DS))
> > +		return false;
> > +
> > +	if (in_atomic() /* || pagefault_disabled() */)
> 
> One question here: I'm guessing you put this comment here
> for illustrative purposes, implying code that will
> be enabled in -rt?
> We don't want it upstream I think, right?

Right, and as a reminder that when we do this we need to add a patch to
-rt. But yeah, we should have a look and see if its worth pulling those
patches from -rt into mainline in some way shape or form. They're big
but trivial IIRC.

I'm fine with you leaving that comment out though.. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
