MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16843.12842.127923.387226@cargo.ozlabs.ibm.com>
Date: Fri, 24 Dec 2004 08:01:30 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: Prezeroing V2 [0/3]: Why and When it works
In-Reply-To: <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	<41C20E3E.3070209@yahoo.com.au>
	<Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter writes:

> The most expensive operation in the page fault handler is (apart of SMP
> locking overhead) the zeroing of the page. This zeroing means that all
> cachelines of the faulted page (on Altix that means all 128 cachelines of
> 128 byte each) must be loaded and later written back. This patch allows to
> avoid having to load all cachelines if only a part of the cachelines of
> that page is needed immediately after the fault.

On ppc64 we avoid having to zero newly-allocated page table pages by
using a slab cache for them, with a constructor function that zeroes
them.  Page table pages naturally end up being full of zeroes when
they are freed, since ptep_get_and_clear, pmd_clear or pgd_clear has
been used on every non-zero entry by that stage.  Thus there is no
extra work required either when allocating them or freeing them.

I don't see any point in your patches for systems which don't have
some magic hardware for zeroing pages.  Your patch seems like a lot of
extra code that only benefits a very small number of machines.

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
