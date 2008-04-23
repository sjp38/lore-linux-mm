Date: Wed, 23 Apr 2008 15:33:03 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 00 of 12] mmu notifier #v13
Message-ID: <20080423133303.GU24536@duo.random>
References: <patchbomb.1208872276@duo.random> <20080422182213.GS22493@sgi.com> <20080422184335.GN24536@duo.random> <20080422194223.GT22493@sgi.com> <Pine.LNX.4.64.0804221328400.3640@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804221328400.3640@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 22, 2008 at 01:30:53PM -0700, Christoph Lameter wrote:
> One solution would be to separate the invalidate_page() callout into a
> patch at the very end that can be omitted. AFACIT There is no compelling 
> reason to have this callback and it complicates the API for the device 
> driver writers. Not having this callback makes the way that mmu notifiers 
> are called from the VM uniform which is a desirable goal.

I agree that the invalidate_page optimization can be moved to a
separate patch. That will be a patch that will definitely alter the
API in a not backwards compatible way (unlike 2-12 in my #v13, which
are all backwards compatible in terms of mmu notifier API).

invalidate_page is beneficial to both mmu notifier users, and a bit
beneficial to the do_wp_page users too. So there's no point to remove
it from my mmu-notifier-core as long as the mmu-notifier-core is 1/N
in my patchset, and N/N in your patchset, the differences caused by
that ordering difference are a bigger change than invalidate_page
existing or not.

As I expected invalidate_page provided significant benefits (not just
to GRU but to KVM too) without altering the locking scheme at all,
this is because the page fault handler has to notice if begin->end
both runs anyway after follow_page/get_user_pages. So it's a no
brainer to keep and my approach will avoid a not backwards compatible
breakage of the API IMHO. Not a big deal, nobody can care if the API
will change, it will definitely change eventually, it's a kernel
internal one, but given I've already invalidate_page in my patch
there's no reason to remove it as long as mmu-notifier-core remains
N/N on your patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
