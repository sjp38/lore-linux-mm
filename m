Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 633E46B00B7
	for <linux-mm@kvack.org>; Wed, 22 May 2013 09:42:44 -0400 (EDT)
Date: Wed, 22 May 2013 14:41:24 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2 00/10] uaccess: better might_sleep/might_fault
	behavior
Message-ID: <20130522134124.GD18614@n2100.arm.linux.org.uk>
References: <cover.1368702323.git.mst@redhat.com> <201305221125.36284.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201305221125.36284.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-m32r-ja@ml.linux-m32r.org, kvm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-arch@vger.kernel.org, linux-am33-list@redhat.com, Hirokazu Takata <takata@linux-m32r.org>, x86@kernel.org, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, microblaze-uclinux@itee.uq.edu.au, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-m32r@ml.linux-m32r.org, linux-kernel@vger.kernel.org, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linuxppc-dev@lists.ozlabs.org

On Wed, May 22, 2013 at 11:25:36AM +0200, Arnd Bergmann wrote:
> Given the most commonly used functions and a couple of architectures
> I'm familiar with, these are the ones that currently call might_fault()
> 
> 			x86-32	x86-64	arm	arm64	powerpc	s390	generic
> copy_to_user		-	x	-	-	-	x	x
> copy_from_user		-	x	-	-	-	x	x
> put_user		x	x	x	x	x	x	x
> get_user		x	x	x	x	x	x	x
> __copy_to_user		x	x	-	-	x	-	-
> __copy_from_user	x	x	-	-	x	-	-
> __put_user		-	-	x	-	x	-	-
> __get_user		-	-	x	-	x	-	-
> 
> WTF?

I think your table is rather screwed - especially on ARM.  Tell me -
how can __copy_to_user() use might_fault() but copy_to_user() not when
copy_to_user() is implemented using __copy_to_user() ?  Same for
copy_from_user() but the reverse argument - there's nothing special
in our copy_from_user() which would make it do might_fault() when
__copy_from_user() wouldn't.

The correct position for ARM is: our (__)?(pu|ge)t_user all use
might_fault(), but (__)?copy_(to|from)_user do not.  Neither does
(__)?clear_user.  We might want to fix those to use might_fault().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
