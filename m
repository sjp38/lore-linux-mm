Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA16897
	for <linux-mm@kvack.org>; Wed, 13 Nov 2002 11:46:15 -0800 (PST)
Message-ID: <3DD2AC06.DD4CC8D1@digeo.com>
Date: Wed, 13 Nov 2002 11:46:14 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 7/4  -ac to newer rmap
References: <20021113145002Z80262-18062+21@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> I guess that after a truncate() and maybe some special ext3 transactions
> anonymous pages can have page->buffers set. Not quite sure about delete
> from swap cache, though ... maybe the reverse of this patch should be
> applied into the -rmap tree and mainline instead ?

There is special code in mainline 2.4's try_to_swap_out() to
handle these damn pages:

        /*
         * Anonymous buffercache pages can be left behind by
         * concurrent truncate and pagefault.
         */
        if (page->buffers)
                goto preserve;

These pages are very rare.  And we rather have to do this because
the buffers may be of the wrong blocksize.

And look, you've already fixed it, in page_launder_zone():

                if (page->pte_chain && !page->mapping && !page->buffers) {

So block_flushpage() "has to succeed" in there.  The only path to those
buffers is via the page, and the page is locked and there is no IO
under way and swapcache is not coherent with the blockdev mapping.

(If one of those buffers _is_ locked, block_flushpage() does lock_buffer()
inside spinlock).

It's not the most glorious part of the kernel.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
