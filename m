Date: Sun, 13 Oct 2002 12:56:56 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: 2.5.42-mm2
Message-ID: <20021013125656.J7028@nightmaster.csn.tu-chemnitz.de>
References: <3DA7C3A5.98FCC13E@digeo.com> <20021012182202.A27215@nightmaster.csn.tu-chemnitz.de> <3DA85B54.3E0A122F@digeo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yEPQxsgoJgBvi8ip"
Content-Disposition: inline
In-Reply-To: <3DA85B54.3E0A122F@digeo.com>; from akpm@digeo.com on Sat, Oct 12, 2002 at 10:26:44AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Kai Makisara <Kai.Makisara@kolumbus.fi>, Douglas Gilbert <dougg@torque.net>, linux-scsi@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--yEPQxsgoJgBvi8ip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Andrew,

[I cc'ed the people relevant to this issue]

On Sat, Oct 12, 2002 at 10:26:44AM -0700, Andrew Morton wrote:
> Ingo Oeser wrote:
> > Stupid question: Would you accept a patch that extends
> > get_user_pages() to accept an additional "struct scatterlist vector[]"?
> 
> It's not really my area Ingo.  But I can wave such a patch about
> on the mailing lists, generally get it some review and attention
> I guess.
 
I had waved an example on what is really needed instead of kiobuf
crap some time ago[1]. This raised a discussion on linux-scsi[2]
(but I'm not subscribed there) and someone[2] actually successfully
tested this.

> Such nfrastructure would need something which used it, as a proof-of-concept,
> testbed, etc...

I would love to test my ideas out, but the special purpose device
where I need it for has bit-errors on its big SDRAM chips and I can
only use a small 32K area of storage for testing, which is not
expected to reveal any noticable performance from that method,
due to the high setup overhead. I think you know the numbers from
direct-io.

The video hardware, where you (or Geert?) basically implemented
the things, we proposed[3] would be a perfect testbed for this.

Thanks & Regards

Ingo Oeser

[1] <20020720003918.G758@nightmaster.csn.tu-chemnitz.de> on lkml
[2] <Pine.LNX.4.44.0207292045040.770-100000@kai.makisara.local> on linux-scsi
[3] Attached here.
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth

--yEPQxsgoJgBvi8ip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sgmap.c"

/* Proposal for User space <-> scatterlist mapping
 * by  Ingo Oeser <ioe@informatik.tu-chemnitz.de>
 * and Kai Makisara <Kai.Makisara@kolumbus.fi> */

#define SGMAP_MAX_UDMA_PAGES		(1 << (19 - PAGE_SHIFT))
#define SGMAP_MAX_UDMA_PAGES_INLINE	16

/* An experiment ... */
/* Pin down user pages and put them into a scatter gather list */
int sg_map_user_pages(struct scatterlist *sgl, const unsigned int max_pages,
		      unsigned long uaddr, size_t count, int rw)
{
	int res, i;
	unsigned int nr_pages = ((uaddr & ~PAGE_MASK) + count - 1 + ~PAGE_MASK) >> PAGE_SHIFT;
	struct page *inline_pages[SGMAP_MAX_UDMA_PAGES_INLINE];
	struct page **pages = inline_pages;

	/* User attempted Overflow! 
	 * NOTE: This kind of request must be split by the caller. 
	 */
	if ((uaddr + count) < uaddr)
		return -EINVAL;

	/* To big for provided scatterlist array */
	if (nr_pages > max_pages)
		return -ENOMEM;

	/* Hmm? */
	if (count == 0)
		return 0;

	if (unlikely(nr_pages > SGMAP_MAX_UDMA_PAGES_INLINE)) {
		pages = kmalloc(nr_pages * sizeof(pages[0]), GFP_USER);
		if (!pages)
			return -ENOMEM;
	}
	down_read(&current->mm->mmap_sem);
	res = get_user_pages(
		    current,
		    current->mm,
		    uaddr,
		    nr_pages,
		    rw == READ,	/* logic is perversed^Wreversed here :-( */
		    0,	/* don't force */
		    &pages[0],
		    NULL);
	up_read(&current->mm->mmap_sem);

	/* Errors and no page mapped should return here */
	if (res <= 0)
		goto out_free;

	memset(sgl, 0, sizeof(*sgl) * nr_pages);

	sgl[0].page = pages[0];
	sgl[0].offset = uaddr & ~PAGE_MASK;

	/* FIXME: flush superflous for rw==READ, 
	 *  probably wrong function for rw==WRITE
	 */
	flush_dcache_page(pages[0]);

	/* Page crossing transfers need these adjustments */
	if (res > 1) {
		for (i = 1; i < res; i++) {
			sgl[i].offset = 0;
			sgl[i].page = pages[i];
			sgl[i].length = PAGE_SIZE;

			flush_dcache_page(pages[i]);
		}
		sgl[0].length = PAGE_SIZE - sgl[0].offset;
		count -= sgl[0].length;
		count -= (res - 2) * PAGE_SIZE;
	}
	sgl[res - 1].length = count;

out_free:
	if (pages != inline_pages)
		kfree(pages);
	return res;
}

/* And unmap them... */
int sg_unmap_user_pages(struct scatterlist *sgl, const unsigned int nr_pages)
{
	int i;

	for (i = 0; i < nr_pages; i++)
		page_cache_release(sgl[i].page);

	return 0;
}



--yEPQxsgoJgBvi8ip--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
