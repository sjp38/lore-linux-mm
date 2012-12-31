Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id BD9EA6B006C
	for <linux-mm@kvack.org>; Mon, 31 Dec 2012 18:06:12 -0500 (EST)
MIME-Version: 1.0
Message-ID: <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
Date: Mon, 31 Dec 2012 15:06:09 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCH 7/8] zswap: add to mm/
>=20
> zswap is a thin compression backend for frontswap. It receives
> pages from frontswap and attempts to store them in a compressed
> memory pool, resulting in an effective partial memory reclaim and
> dramatically reduced swap device I/O.

Hi Seth --

Happy (almost) New Year!

I am eagerly studying one of the details of your zswap "flush"
code in this patch to see how you solved a problem or two that
I was struggling with for the similar mechanism RFC'ed for zcache
(see https://lkml.org/lkml/2012/10/3/558).  I like the way
that you force the newly-uncompressed to-be-flushed page immediately
into a swap bio in zswap_flush_entry via the call to swap_writepage,
though I'm not entirely convinced that there aren't some race
conditions there.  However, won't swap_writepage simply call
frontswap_store instead and re-compress the page back into zswap?
The (very ugly) solution I used for this was to flag the page in a
frontswap_denial_map (see https://lkml.org/lkml/2012/10/3/560).
Don't you require something like that also, or am I missing some
magic in your code?

I'm also a bit concerned about the consequent recursion:

frontswap_store->
  zswap_fs_store->
    zswap_flush_entries->
      zswap_flush_entry->
        __swap_writepage->
          swap_writepage->
            frontswap_store->
              zswap_fs_store-> etc

It's not obvious to me how deeply this might recurse and/or
how the recursion is terminated.  The RFC'ed zcache code
calls its equivalence of your "flush" code only from the
shrinker thread to avoid this, though there may be a third,
better, way.

A second related issue that concerns me is that, although you
are now, like zcache2, using an LRU queue for compressed pages
(aka "zpages"), there is no relationship between that queue and
physical pageframes.  In other words, you may free up 100 zpages
out of zswap via zswap_flush_entries, but not free up a single
pageframe.  This seems like a significant design issue.  Or am
I misunderstanding the code?

A third concern is about scalability... the locking seems very
coarse-grained.  In zcache, you personally observed and fixed
hashbucket contention (see https://lkml.org/lkml/2011/9/29/215).
Doesn't zswap's tree_lock essentially use a single tree (per
swaptype), i.e. no scalability?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
