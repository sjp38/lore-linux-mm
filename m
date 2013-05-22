Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4B9066B00CB
	for <linux-mm@kvack.org>; Wed, 22 May 2013 10:30:52 -0400 (EDT)
Date: Wed, 22 May 2013 17:30:00 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 07/10] powerpc: uaccess s/might_sleep/might_fault/
Message-ID: <20130522143000.GA21886@redhat.com>
References: <cover.1368702323.git.mst@redhat.com>
 <2aa6c3da21a28120126732b5e0b4ecd6cba8ca3b.1368702323.git.mst@redhat.com>
 <201305221559.01806.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201305221559.01806.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

On Wed, May 22, 2013 at 03:59:01PM +0200, Arnd Bergmann wrote:
> On Thursday 16 May 2013, Michael S. Tsirkin wrote:
> > @@ -178,7 +178,7 @@ do {                                                                \
> >         long __pu_err;                                          \
> >         __typeof__(*(ptr)) __user *__pu_addr = (ptr);           \
> >         if (!is_kernel_addr((unsigned long)__pu_addr))          \
> > -               might_sleep();                                  \
> > +               might_fault();                                  \
> >         __chk_user_ptr(ptr);                                    \
> >         __put_user_size((x), __pu_addr, (size), __pu_err);      \
> >         __pu_err;                                               \
> > 
> 
> Another observation:
> 
> 	if (!is_kernel_addr((unsigned long)__pu_addr))
> 		might_sleep();
> 
> is almost the same as
> 
> 	might_fault();
> 
> except that it does not call might_lock_read().
> 
> The version above may have been put there intentionally and correctly, but
> if you want to replace it with might_fault(), you should remove the
> "if ()" condition.
> 
> 	Arnd

Good point, thanks.
I think I'll do it in a separate patch on top,
just to make sure bisect does not result in a revision that
produces false positive warnings.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
