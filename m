Date: Mon, 24 May 2004 21:44:08 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
In-Reply-To: <Pine.LNX.4.58.0405242137210.32189@ppc970.osdl.org>
Message-ID: <Pine.LNX.4.58.0405242141150.32189@ppc970.osdl.org>
References: <1085369393.15315.28.camel@gaston> <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
 <1085371988.15281.38.camel@gaston> <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
 <1085373839.14969.42.camel@gaston> <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
 <20040525034326.GT29378@dualathlon.random> <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
 <20040525042054.GU29378@dualathlon.random> <Pine.LNX.4.58.0405242137210.32189@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Ben LaHaise <bcrl@kvack.org>, linux-mm@kvack.org, Architectures Group <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Mon, 24 May 2004, Linus Torvalds wrote:
>
> We do the accessed bit by clearing the "user readable" thing (or
> something. I forget the exact details, and I'm too lazy to check it out).  

Yup. Lookie here:

	#define __ACCESS_BITS   (_PAGE_ACCESSED | _PAGE_KRE | _PAGE_URE)
	extern inline pte_t pte_mkold(pte_t pte)        { pte_val(pte) &= ~(__ACCESS_BITS); return pte; }

Notice how an "old" pte won't be readable. Then, when we take the page 
fault, we'll do

	extern inline pte_t pte_mkyoung(pte_t pte)      { pte_val(pte) |= __ACCESS_BITS; return pte; }

and now the pte is readable again.

In other words, we absolutely _have_ to do the "pte_mkyoung()" part in the
page fault, or an "old" pte will never become readable again (unless it's
accessed with a write rather than a read, which will then happen to make
it young again).

I'm not quite senile yet.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
