Date: Sat, 14 Oct 2000 14:33:09 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: [RFC] atomic pte updates and pae changes, take 2
Message-ID: <20001014143309.D5813@redhat.com>
References: <Pine.LNX.4.21.0010132002440.25522-100000@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010132002440.25522-100000@devserv.devel.redhat.com>; from bcrl@redhat.com on Fri, Oct 13, 2000 at 08:17:42PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Oct 13, 2000 at 08:17:42PM -0400, Ben LaHaise wrote:
> 
> Below is take two of the patch making pte_clear use atomic xchg in an
> effort to avoid the loss of dirty bits.  PAE no longer uses cmpxchg8 for
> updates; set_pte is two ordered long writes with a barrier.

Looks good.  The only trouble I can see left is that pte_clear() is
still using set_pte(), which doesn't work right for PAE36.  set_pte()
is setting the high word first, which is fine for installing a new pte,
but if you do that to clear a pte then you have left the old
page-present bit intact while you've removed have of the pte.
pte_clear() needs to clear the words in the other order (just as
pte_get_and_clear correctly does).

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
