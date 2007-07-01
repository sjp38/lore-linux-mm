In-reply-to: <20070629141528.511942868@de.ibm.com> (message from Martin
	Schwidefsky on Fri, 29 Jun 2007 15:55:35 +0200)
Subject: Re: [patch 5/5] Optimize page_mkclean_one
References: <20070629135530.912094590@de.ibm.com> <20070629141528.511942868@de.ibm.com>
Message-Id: <E1I4wgB-00071r-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 01 Jul 2007 12:29:19 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> page_mkclean_one is used to clear the dirty bit and to set the write
> protect bit of a pte. In additions it returns true if the pte either
> has been dirty or if it has been writable. As far as I can see the
> function should return true only if the pte has been dirty, or page
> writeback will needlessly write a clean page.

There are some weird cases, like for example get_user_pages(), when
the pte takes a write fault and the page is modified, but the pte
doesn't become dirty, because the page is written through the kernel
mapping.

In the get_user_pages() case the page itself is dirtied, so your patch
probably doesn't break that.  But I'm not sure if there aren't similar
cases like that that the pte_write() check is taking care of.

And anyway if the dirty page tracking works correctly, your patch
won't optimize anything, since the pte will _only_ become writable if
the page was dirtied.

So in fact normally pte_dirty() and pte_write() should be equivalent,
except for some weird cases.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
