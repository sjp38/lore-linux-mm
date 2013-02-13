Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id CDB1A6B0008
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 11:49:46 -0500 (EST)
MIME-Version: 1.0
Message-ID: <4943cb48-5725-49a3-a095-edfde72ca822@default>
Date: Wed, 13 Feb 2013 08:47:50 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [LSF/MM TOPIC] In-kernel compression in the MM subsystem
References: <601542b0-4c92-4d90-aed8-826235c06eab@default>
 <1360117134.2403.4.camel@kernel.cn.ibm.com>
 <73fe6782-21f4-47c5-886f-367374a3e600@default>
 <1360742910.1473.10.camel@kernel.cn.ibm.com>
In-Reply-To: <1360742910.1473.10.camel@kernel.cn.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

> From: Simon Jeons [mailto:simon.jeons@gmail.com]
> Subject: Re: [LSF/MM TOPIC] In-kernel compression in the MM subsystem
>=20
> On Wed, 2013-02-06 at 10:40 -0800, Dan Magenheimer wrote:
> > > From: Simon Jeons [mailto:simon.jeons@gmail.com]
> > > Subject: Re: [LSF/MM TOPIC] In-kernel compression in the MM subsystem
> > >
> > > Hi Dan,
> > > On Sat, 2013-01-26 at 12:16 -0800, Dan Magenheimer wrote:
> > > > There's lots of interesting things going on in kernel memory
> > > > management, but one only(?) increases the effective amount
> > > > of data that can be stored in a fixed amount of RAM: in-kernel
> > > > compression.
> > > >
> > > > Since ramzswap/compcache (now zram) was first proposed in 2009
> > > > as an in-memory compressed swap device, there have been a number
> > > > of in-kernel compression solutions proposed, including
> > > > zcache, kztmem, and now zswap.  Each shows promise to improve
> > > > performance by using compression under memory pressure to
> > > > reduce I/O due to swapping and/or paging.  Each is still
> > > > in staging (though zram may be promoted by LSFMM 2013)
> > > > because each also brings a number of perplexing challenges.
> > > >
> > > > I think it's time to start converging on which one or more
> > > > of these solutions, if any, should be properly promoted and
> > > > more fully integrated into the kernel memory management
> > > > subsystem.  Before this can occur, it's important to build a
> > > > broader understanding and, hopefully, also a broader consensus
> > > > among the MM community on a number of key challenges and questions
> > > > in order to guide and drive further development and merging.
> > > >
> > > > I would like to collect a list of issues/questions, and
> > > > start a discussion at LSF/MM by presenting this list, select
> > > > the most important, then lead a discussion on how ever many
> > > > there is time for.  Most likely this is an MM-only discussion
> > > > though a subset might be suitable for a cross-talk presentataion.
> > > >
> > >
> > > Is there benchmark to test each component in tmem?
> >
> > Hi Simon --
> >
> > I'm not sure what you mean.  Could you add a few words
> > to clarify?
> >
>=20
> Hi Dan,
>=20
> Some questions about zsmalloc:
>=20
> 1) What's the meaning of comment above USE_PGTABLE_MAPPING macro "This
> cause zsmalloc to use page table mapping rather than copying for object
> mapping"?
> 2) How zsmalloc handle object span two pages? It seems that in function
> init_zspage, link->next =3D obj_location_to_handle(next_page, 0); you
> encode next_page and 0 to object, then how can zs_malloc find this free
> object? IIUC, this encode skip the object span two pages.
> 3) Why must map after malloc if want to use a object?
> 4) What's the number of ZS_MAX_ALLOC_SIZE and ZS_MIN_ALLOC_SIZE? There
> are too many macros to figure it out.

Hi Simon --

Those are good questions, but you are asking the wrong person.
I stopped using zsmalloc in zcache (and ramster) because it
has certain issues and it didn't appear to me those issues
would/could be resolved.  I wrote a custom allocator (see zbud.c)
to avoid those issues.  This is explained in:
http://lkml.indiana.edu/hypermail/linux/kernel/1208.1/03763.html=20

I'd be interested in hearing your ideas/requirements for
in-kernel compression!

Thanks,
Dan

P.S. Note that "old" zcache (which uses zsmalloc) will be gone in
3.8 and "new" zcache (which uses zbud and merges in ramster)
will be in drivers/staging/zcache in 3.8.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
