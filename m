Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 84E526B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 15:28:45 -0500 (EST)
Date: Wed, 21 Dec 2011 12:28:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] vfs: __read_cache_page should use gfp argument
 rather than GFP_KERNEL
Message-Id: <20111221122843.18f673c7.akpm@linux-foundation.org>
In-Reply-To: <4EF211EC.7090002@oracle.com>
References: <201112210054.46995.rjw@sisk.pl>
	<CA+55aFzee7ORKzjZ-_PrVy796k2ASyTe_Odz=ji7f1VzToOkKw@mail.gmail.com>
	<4EF15F42.4070104@oracle.com>
	<CA+55aFx=B9adsTR=-uYpmfJnQgdGN+1aL0KUabH5bSY6YcwO7Q@mail.gmail.com>
	<alpine.LSU.2.00.1112202213310.3987@eggly.anvils>
	<4EF211EC.7090002@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, jfs-discussion@lists.sourceforge.net, Kernel Testers List <kernel-testers@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Maciej Rutecki <maciej.rutecki@gmail.com>, Florian Mickler <florian@mickler.org>, davem@davemloft.net, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

On Wed, 21 Dec 2011 11:05:48 -0600
Dave Kleikamp <dave.kleikamp@oracle.com> wrote:

> [ updated to remove now-obsolete comment in read_cache_page_gfp()]
> 
> lockdep reports a deadlock in jfs because a special inode's rw semaphore
> is taken recursively. The mapping's gfp mask is GFP_NOFS, but is not used
> when __read_cache_page() calls add_to_page_cache_lru().

Well hang on, it's not just a lockdep splat.  The kernel actually will
deadlock if we reenter JFS via this GFP_KERNEL allocation attempt, yes?

Was that GFP_NOFS allocation recently added to JFS?  If not then we
should backport this deadlock fix into -stable, no?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
