Subject: Re: Help understanding SPARC32 Sun4c PTE handling
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.61.0708061749230.29956@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0708061749230.29956@mtfhpc.demon.co.uk>
Content-Type: text/plain
Date: Tue, 07 Aug 2007 17:30:48 +1000
Message-Id: <1186471848.938.127.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-mm@kvack.org, "Antonino A. Daplas" <adaplas@hotpop.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-06 at 18:38 +0100, Mark Fortescue wrote:
> Hi David,
> 
> If you have the time ..., if not, hopfully, some one from linux-mm will 
> explain.
> 
> I have been investigating the differences between SunOS PTE and Linux PTE 
> bits. There are some differences that I would like to understand.

I'm no specific of sun4c but I can answer on generalities. Maybe Anton
knows more, I've added him to the CC list :-)

> What is the pte_file() function intended for. The bit in the PTE that
> is used (0x02000000) is set by hardware (definatly on page write and in 
> theory on page read if the SunOS PTE description is to be believed. It 
> is described as the 'refferenced' bit).

_PAGE_FILE in linux is a software-only bit that is set on PTEs that are
not present (_PAGE_PRESENT not set) (and thus normally not used by HW,
that is, not seen as valid). It's used to indicate that the page is part
of a file mapping (rather than an anonymous page).

The linux PTE contains other bits like that, used on non-present PTEs,
mostly encoding where in the swap or where in the file the page for a
non-present PTE is backed.

> The linux-mm documentation only states that it is for swappable non-linear 
> VMAs (exactly what we have in the sun4c unless you assume VMA is signed 
> [like the INMOS Transputer], in which case it is linear from -512MB to 
> +512MB :-). The down size of sigend address mappings is that NULL is 
> nolonger zero and too many people have got lazy and assumed it is.).

In general it's used for file mappings.

> Re-arranging the bits so that _SUN4C_PAGE_ACCESSED and 
> _SUN4C_PAGE_MODIFIED bits match the MMU hardware bits seems to make boots 
> more stable (I have been gettimg non-repeatable boots where the init 
> script goes through the motions but does not actually do what I am 
> expecting or just gets skipped. SLAB is worse than SLUB.) but the changes 
> I have tried sofar, break swapon.

I don't think that _ACCESSED and _DIRTY are ever used on a non-present
PTE so it wouldn't be a problem to have them overlap _PAGE_FILE but I
may be wrong on this one (on ppc, we overlap _PAGE_FILE with some other
bits only relevant to present PTEs). It would make sense, if the HW
provides ACCESSED and DIRTY writeback, to have the PTE bits match what
the HW does, though I've seen cases where we deliberately avoid using
the HW writeback to avoid nasty race conditions. In that later case, we
just make sure the HW "accessed" and "dirty" bits are always set, and
maintain software ones separately. I don't know what the sun4c code
does.

> Linux uses four bits that do not get saved in the MMU PTE 
> (_SUN4C_PAGE_READ, _SUN4C_PAGE_WRITE, _SUN4C_PAGE_MODIFIED and 
> _SUN4C_PAGE_ACCESSED). I have assumed that these are preserved externally 
> in a software copy of the PTE somewhere (I have not found anything that I 
> recognise as specific storage for this in the sparc32 code) as reading the 
> MMU PTE will return zero for these bits.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
