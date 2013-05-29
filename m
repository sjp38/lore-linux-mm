Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 462DA6B0112
	for <linux-mm@kvack.org>; Wed, 29 May 2013 17:09:35 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <754ae8a0-23af-4c87-953f-d608cba84191@default>
Date: Wed, 29 May 2013 14:09:02 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv12 2/4] zbud: add to mm/
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
 <20130529154500.GB428@cerebellum>
 <20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org>
 <20130529204236.GD428@cerebellum>
 <20130529134835.58dd89774f47205da4a06202@linux-foundation.org>
In-Reply-To: <20130529134835.58dd89774f47205da4a06202@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Subject: Re: [PATCHv12 2/4] zbud: add to mm/
>=20
> On Wed, 29 May 2013 15:42:36 -0500 Seth Jennings <sjenning@linux.vnet.ibm=
.com> wrote:
>=20
> > > > > I worry about any code which independently looks at the pageframe
> > > > > tables and expects to find page struts there.  One example is pro=
bably
> > > > > memory_failure() but there are probably others.
> > >
> > > ^^ this, please.  It could be kinda fatal.
> >
> > I'll look into this.
> >
> > The expected behavior is that memory_failure() should handle zbud pages=
 in the
> > same way that it handles in-use slub/slab/slob pages and return -EBUSY.
>=20
> memory_failure() is merely an example of a general problem: code which
> reads from the memmap[] array and expects its elements to be of type
> `struct page'.  Other examples might be memory hotplugging, memory leak
> checkers etc.  I have vague memories of out-of-tree patches
> (bigphysarea?) doing this as well.
>=20
> It's a general problem to which we need a general solution.

<Obi-tmem Kenobe slowly materializes... "use the force, Luke!">

One could reasonably argue that any code that makes incorrect
assumptions about the contents of a struct page structure is buggy
and should be fixed.  Isn't the "general solution" already described
in the following comment, excerpted from include/linux/mm.h, which
implies that "scribbling on existing pageframes" [carefully], is fine?
(And, if not, shouldn't that comment be fixed, or am I misreading
it?)

<start excerpt>
 * For the non-reserved pages, page_count(page) denotes a reference count.
 *   page_count() =3D=3D 0 means the page is free. page->lru is then used f=
or
 *   freelist management in the buddy allocator.
 *   page_count() > 0  means the page has been allocated.
 *
 * Pages are allocated by the slab allocator in order to provide memory
 * to kmalloc and kmem_cache_alloc. In this case, the management of the
 * page, and the fields in 'struct page' are the responsibility of mm/slab.=
c
 * unless a particular usage is carefully commented. (the responsibility of
 * freeing the kmalloc memory is the caller's, of course).
 *
 * A page may be used by anyone else who does a __get_free_page().
 * In this case, page_count still tracks the references, and should only
 * be used through the normal accessor functions. The top bits of page->fla=
gs
 * and page->virtual store page management information, but all other field=
s
 * are unused and could be used privately, carefully. The management of thi=
s
 * page is the responsibility of the one who allocated it, and those who ha=
ve
 * subsequently been given references to it.
 *
 * The other pages (we may call them "pagecache pages") are completely
 * managed by the Linux memory manager: I/O, buffers, swapping etc.
 * The following discussion applies only to them.
<end excerpt>

<Obi-tmem Kenobe slowly dematerializes>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
