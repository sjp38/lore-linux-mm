Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-ID: <OF283CD009.20B7561C-ONC1256EA6.003BBE8A-C1256EA6.00424F81@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Tue, 1 Jun 2004 14:04:17 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Ben LaHaise <bcrl@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Architectures Group <linux-arch@vger.kernel.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@osdl.org>, Matthew Wilcox <willy@debian.org>
List-ID: <linux-mm.kvack.org>




> The last issue is ptep_establish, we're flushing the pte in do_wp_page
> inside ptep_establish again for no good reason. Those suprious tlb
> flushes may even trigger IPIs (this time in x86 smp too even with
> processes), so I'd really like to remove the explicit flush in
> do_wp_page, however this will likely break s390 but I don't understand
> s390 so I'll leave it broken for now (at least to show you this
> alternative and to hear comments if it's as broken as the previous one).

No, this shouldn't break s390 in any way, removing superfluous tlb flushes
will benefit s390 just like any other architecture.

> The really scary thing about this patch is the s390 ptep_establish.

The s390 version of ptep_establish isn't scary at all, it's just an
optimization. s390 can use the generic set_pte & flush_tlb_page sequence
for ptep_establish without a problem but there is a better way to do it.
We use the ipte instruction because it only flushes the tlb entries for
a single page and not all of them. Don't worry too much about breaking
s390, if you do I will complain.

blue skies,
   Martin

Linux/390 Design & Development, IBM Deutschland Entwicklung GmbH
Schonaicherstr. 220, D-71032 Boblingen, Telefon: 49 - (0)7031 - 16-2247
E-Mail: schwidefsky@de.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
