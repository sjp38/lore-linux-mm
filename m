Date: Thu, 03 Apr 2003 10:00:19 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-ID: <8750000.1049385619@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0304031615190.1951-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0304031615190.1951-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Thursday, April 03, 2003 16:38:12 +0100 Hugh Dickins
<hugh@veritas.com> wrote:

> I don't see that as a big hole at all.  While we're in page_convert_anon,
> yes, page_referenced won't find all the ptes and try_to_unmap won't be
> able to unmap them all; but there are plenty of other reasons why a page
> may be briefly unfreeable even though try_to_unmap succeeded, it'll just
> try again later.

No, try_to_unmap will claim success when in fact there are still mappings.
It'd be all right if it failed, but there's no way to tell it to fail.  The
page will be freed by kswapd based on try_to_unmap's claim of success.

> (Hmm, is the current page_convert_anon maintaining nr_reverse_maps
> correctly?  I would think not, since it's doing nothing about it, and
> page_remove_rmap would decrement seeing an Anon.  But perhaps I'm
> confused again, a quick test doesn't show the drop I'd expect.)

You're right, it is a hole.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
