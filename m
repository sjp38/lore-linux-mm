Date: Mon, 14 Oct 2002 06:52:32 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch, feature] nonlinear mappings, prefaulting support, 2.5.42-F8
Message-ID: <20021014135232.GB4488@holomorphy.com>
References: <Pine.LNX.4.44.0210141334100.17808-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210141334100.17808-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 14, 2002 at 02:38:43PM +0200, Ingo Molnar wrote:
> the patch has got an initial review from Linus, Andrew Morton and Hugh
> Dickins, and most of their suggestions are part of the patch already.

hmm


On Mon, Oct 14, 2002 at 02:38:43PM +0200, Ingo Molnar wrote:
> +int sys_remap_file_pages(unsigned long start, unsigned long size,
> +	unsigned long prot, unsigned long pgoff, unsigned long flags)

ISTR suggesting vectorizing this to reduce syscall traffic.

The semantics of faulting in pages on such a region, while not
incorrect, are at least unusual enough to raise the question of
whether it's appropriate for the kernel to fill the pages as opposed
to returning an error to userspace. The requirement of MAP_LOCKED
or PROT_NONE might as well be in-kernel if the file offset contiguity
assumption is not met, since there's no reliable way for userspace to
use the syscall otherwise. sys_remap_file_pages() also interacts in
an unusual way with the semantics of MAP_POPULATE. MAP_POPULATE seems
to perform a non-blocking make_pages_present() operation not shared
with MAP_LOCKED, and filemap_populate() performs the file offset
contiguous prefaulting which again doesn't mix well with the scatter
gather semantics desired. These are the file offset contiguity
assumptions I mentioned.

Also, a stranger phenomenon appears in filemap_populate(), where
nonblock may be true, and so filemap_getpage() will return NULL,
but -ENOMEM is returned if filemap_getpage() returns NULL.

Also, I see a significant portion of filemap_nopage() duplicated in
filemap_getpage(), including long-stale hashtable-related comments.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
