Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 4C8426B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 08:39:01 -0400 (EDT)
Date: Tue, 21 May 2013 13:21:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 10/10] kernel: might_fault does not imply might_sleep
Message-ID: <20130521112126.GJ26912@twins.programming.kicks-ass.net>
References: <cover.1368702323.git.mst@redhat.com>
 <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
 <20130516184041.GP19669@dyad.programming.kicks-ass.net>
 <20130519093526.GD19883@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130519093526.GD19883@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, rostedt@goodmis.org

On Sun, May 19, 2013 at 12:35:26PM +0300, Michael S. Tsirkin wrote:
> On Thu, May 16, 2013 at 08:40:41PM +0200, Peter Zijlstra wrote:
> > On Thu, May 16, 2013 at 02:16:10PM +0300, Michael S. Tsirkin wrote:
> > > There are several ways to make sure might_fault
> > > calling function does not sleep.
> > > One is to use it on kernel or otherwise locked memory - apparently
> > > nfs/sunrpc does this. As noted by Ingo, this is handled by the
> > > migh_fault() implementation in mm/memory.c but not the one in
> > > linux/kernel.h so in the current code might_fault() schedules
> > > differently depending on CONFIG_PROVE_LOCKING, which is an undesired
> > > semantical side effect.
> > > 
> > > Another is to call pagefault_disable: in this case the page fault
> > > handler will go to fixups processing and we get an error instead of
> > > sleeping, so the might_sleep annotation is a false positive.
> > > vhost driver wants to do this now in order to reuse socket ops
> > > under a spinlock (and fall back on slower thread handler
> > > on error).
> > 
> > Are you using the assumption that spin_lock() implies preempt_disable() implies
> > pagefault_disable()? Note that this assumption isn't valid for -rt where the
> > spinlock becomes preemptible but we'll not disable pagefaults.
> 
> No, I was not assuming that. What I'm trying to say is that a caller
> that does something like this under a spinlock:
> 	preempt_disable
> 	pagefault_disable
> 	error = copy_to_user
> 	pagefault_enable
> 	preempt_enable_no_resched
> 
> is not doing anything wrong and should not get a warning,
> as long as error is handled correctly later.
> Right?

Aside from the no_resched() thing which Steven already explained and my
previous email asking why you need the preempt_disable() at all, that
should indeed work.

The reason I was asking was that I wasn't sure you weren't doing:

  spin_lock(&my_lock);
  error = copy_to_user();
  spin_unlock(&my_lock);

and expecting the copy_to_user() to always take the exception table
route. This works on mainline (since spin_lock implies a preempt disable
and preempt_disable is the same as pagefault_disable). However as should
be clear by now, it doesn't quite work that way for -rt.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
