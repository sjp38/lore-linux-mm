Received: by uproxy.gmail.com with SMTP id k40so44069ugc
        for <linux-mm@kvack.org>; Thu, 26 Jan 2006 23:35:49 -0800 (PST)
Message-ID: <84144f020601262335g49c21b62qaa729732e9275c0@mail.gmail.com>
Date: Fri, 27 Jan 2006 09:35:49 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 0/9] Critical Mempools
In-Reply-To: <43D968E4.5020300@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1138217992.2092.0.camel@localhost.localdomain>
	 <Pine.LNX.4.62.0601260954540.15128@schroedinger.engr.sgi.com>
	 <43D954D8.2050305@us.ibm.com>
	 <Pine.LNX.4.62.0601261516160.18716@schroedinger.engr.sgi.com>
	 <43D95BFE.4010705@us.ibm.com> <20060127000304.GG10409@kvack.org>
	 <43D968E4.5020300@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>, linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Benjamin LaHaise wrote:
> > Personally, I'm more in favour of a proper reservation system.  mempools
> > are pretty inefficient.  Reservations have useful properties, too -- one
> > could reserve memory for a critical process to use, but allow the system
> > to use that memory for easy to reclaim caches or to help with memory
> > defragmentation (more free pages really helps the buddy allocator).

On 1/27/06, Matthew Dobson <colpatch@us.ibm.com> wrote:
> That's an interesting idea...  Keep track of the number of pages "reserved"
> but allow them to be used something like read-only pagecache...  Something
> along those lines would most certainly be easier on the page allocator,
> since it wouldn't have chunks of pages "missing" for long periods of time.

Any thoughts on what kind of allocation patterns do we have for those
critical callers? The worst case is of course that for just one 32
byte critical allocation we steal away a complete page from the
reserves which doesn't sound like a good idea under extreme VM
pressure. For a general solution, I don't think it's enough that you
simply flag an allocation GFP_CRITICAL and let the page allocator do
the allocation.

As as side note, we already have __GFP_NOFAIL. How is it different
from GFP_CRITICAL and why aren't we improving that?

                                  Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
