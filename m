Date: Fri, 21 Sep 2001 11:27:23 -0400
Subject: Re: broken VM in 2.4.10-pre9
Message-ID: <20010921112722.A3646@cs.cmu.edu>
References: <Pine.LNX.4.33L.0109200903100.19147-100000@imladris.rielhome.conectiva> <20010921080549Z16344-2758+350@humbolt.nl.linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010921080549Z16344-2758+350@humbolt.nl.linux.org>
From: Jan Harkes <jaharkes@cs.cmu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 21, 2001 at 10:13:11AM +0200, Daniel Phillips wrote:
>   - small inactive list really means large active list (and vice versa)
>   - aging increments need to depend on the size of the active list
>   - "exponential" aging may be completely bogus

I don't think so, whenever there is sufficient memory pressure, the scan
of the active list is not only done by kswapd, but also by the page
allocations.

This does have the nice effect that with a large active list on a system
that has a working set that fits in memory, pages basically always age
up, and we get an automatic used-once/drop-behind behaviour for
streaming data because the age of these pages is relatively low.

As soon as the rate of new allocations increases to the point that
kswapd can't keep up, which happens if the number of cached used-once
pages is too small, or the working set expands so that it doesn't fit in
memory. The memory shortage then causes all pages to agressively get
aged down, pushing out the less frequently used pages of the working set.

Exponential down aging simply causes us to loop fewer times in
do_try_to_free_pages is such situations.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
