Date: Wed, 23 May 2007 05:03:38 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
In-Reply-To: <1179874748.32247.868.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705230438490.14106@blonde.wat.veritas.com>
References: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
 <20070509231937.ea254c26.akpm@linux-foundation.org>
 <1178778583.14928.210.camel@localhost.localdomain>
 <20070510.001234.126579706.davem@davemloft.net>
 <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
 <1179176845.32247.107.camel@localhost.localdomain>
 <1179212184.32247.163.camel@localhost.localdomain>
 <1179757647.6254.235.camel@localhost.localdomain>
 <1179815339.32247.799.camel@localhost.localdomain>
 <Pine.LNX.4.64.0705221738020.22822@blonde.wat.veritas.com>
 <1179874748.32247.868.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Tom \"spot\" Callaway" <tcallawa@redhat.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, mark@mtfhpc.demon.co.uk, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Benjamin Herrenschmidt wrote:
> 
> > Would the "__changed && __dirty" architectures (x86, x86_64, ia64)
> > be better off saying __changed = __dirty && pte_same?  I doubt it's
> > worth bothering about.
> 
> I'd say let gcc figure it out :-)

No, I wasn't meaning the optimization, but the significance of the
boolean __changed that's returned.  If ptep_set_access_flags does
not change the pte (because !dirty or !safely_writable or whatever
that arch calls it), then ideally it ought to return false.

But it doesn't affect correctness if it sometimes says true not
false, and these arches happen to have an empty update_mmu_cache
(with lazy_mmu_prot_update currently under separate review), and
what you have follows what was already being done, and sun4c
already has to "lie": so it's rather theoretical.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
