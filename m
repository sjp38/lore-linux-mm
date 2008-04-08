Date: Wed, 9 Apr 2008 00:06:27 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080408220627.GP10133@duo.random>
References: <patchbomb.1207669443@duo.random> <47FBE7C9.9000701@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47FBE7C9.9000701@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 09, 2008 at 12:46:49AM +0300, Avi Kivity wrote:
> That's unusual.  What happens to the notifier?  Suppose I destroy a vm 

Yes it's quite unusual.

> without exiting the process, what happens if it fires?

The mmu notifier ops should stop doing stuff (if there will be no
memslots they will be noops), or the ops can be replaced atomically
with null pointers. The important thing is that the module can't go
away until ->release is invoked or until mmu_notifier_unregister
returned 0.

Previously there was no mmu_notifier_unregister, so adding it can't be
a regression compared to #v11, even if it can fail and you may have to
retry later after returning to userland. Retrying from userland is
always safe in oom kill terms, only looping inside the kernel isn't
safe as do_exit has no chance to run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
