Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E74D56B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 16:37:25 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so56953321pab.6
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 13:37:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wq4si15145945pab.92.2015.01.30.13.37.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jan 2015 13:37:25 -0800 (PST)
Date: Fri, 30 Jan 2015 13:37:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 02/17] x86_64: add KASan support
Message-Id: <20150130133723.26e6e7f2b8e489a8640abd05@linux-foundation.org>
In-Reply-To: <54CBAE2E.2030106@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-3-git-send-email-a.ryabinin@samsung.com>
	<20150129151224.4e7947af78605c199763102c@linux-foundation.org>
	<54CBAE2E.2030106@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andy Lutomirski <luto@amacapital.net>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>

On Fri, 30 Jan 2015 19:15:42 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> >> --- a/lib/Kconfig.kasan
> >> +++ b/lib/Kconfig.kasan
> >> @@ -5,6 +5,7 @@ if HAVE_ARCH_KASAN
> >>  
> >>  config KASAN
> >>  	bool "AddressSanitizer: runtime memory debugger"
> >> +	depends on !MEMORY_HOTPLUG
> >>  	help
> >>  	  Enables address sanitizer - runtime memory debugger,
> >>  	  designed to find out-of-bounds accesses and use-after-free bugs.
> > 
> > That's a significant restriction.  It has obvious runtime implications.
> > It also means that `make allmodconfig' and `make allyesconfig' don't
> > enable kasan, so compile coverage will be impacted.
> > 
> > This wasn't changelogged.  What's the reasoning and what has to be done
> > to fix it?
> > 
> 
> Yes, this is runtime dependency. Hot adding memory won't work.
> Since we don't have shadow for hotplugged memory, kernel will crash on the first access to it.
> To fix this we need to allocate shadow for new memory.
> 
> Perhaps it would be better to have a runtime warning instead of Kconfig dependecy?

Is there a plan to get mem-hotplug working with kasan, btw?  It doesn't
strike me as very important/urgent.  Please add a sentence about this
to the changelog as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
