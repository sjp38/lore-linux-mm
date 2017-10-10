Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C25D86B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:24:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k4so155736wmc.20
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:24:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m131si8809253wmb.103.2017.10.10.14.23.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 14:24:00 -0700 (PDT)
Date: Tue, 10 Oct 2017 14:23:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 19/20] x86/mm: Add speculative pagefault handling
Message-Id: <20171010142356.b33f8a8fee3427fbdf0708e3@linux-foundation.org>
In-Reply-To: <1507543672-25821-20-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507543672-25821-1-git-send-email-ldufour@linux.vnet.ibm.com>
	<1507543672-25821-20-git-send-email-ldufour@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Mon,  9 Oct 2017 12:07:51 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> +/*
> + * Advertise that we call the Speculative Page Fault handler.
> + */
> +#if defined(CONFIG_X86_64) && defined(CONFIG_SMP)
> +#define __HAVE_ARCH_CALL_SPF
> +#endif

Here's where I mess up your life ;)

It would be more idiomatic to define this in arch/XXX/Kconfig:

config SPF
	def_bool y if SMP

then use CONFIG_SPF everywhere.

Also, it would be better if CONFIG_SPF were defined at the start of the
patch series rather than the end, so that as the patches add new code,
that code is actually compilable.  For bisection purposes.  I can
understand if this is too much work and effort - we can live with
things the way they are now.

This patchset is a ton of new code in very sensitive areas and seems to
have received little review and test.  I can do a
merge-and-see-what-happens but it would be quite a risk to send all
this upstream based only on my sketchy review and linux-next runtime
testing.  Can we bribe someone?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
