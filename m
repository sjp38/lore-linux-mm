Date: Mon, 5 May 2008 10:28:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080505042751.GB26920@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805051026040.8885@schroedinger.engr.sgi.com>
References: <20080430001249.c07ff5c8.akpm@linux-foundation.org>
 <20080430072620.GI27652@wotan.suse.de> <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com>
 <20080501014418.GB15179@wotan.suse.de> <Pine.LNX.4.64.0805011224150.8738@schroedinger.engr.sgi.com>
 <20080502004445.GB30768@wotan.suse.de> <Pine.LNX.4.64.0805011805150.13527@schroedinger.engr.sgi.com>
 <20080502012350.GF30768@wotan.suse.de> <Pine.LNX.4.64.0805011833480.13697@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0805021411260.21677@schroedinger.engr.sgi.com>
 <20080505042751.GB26920@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 5 May 2008, Nick Piggin wrote:

> AFAIK, any filesystem which may not lock the page under read IO should
> have PG_private set. In which case, if they don't have buffers they
> should have a releasepage method. Otherwise, how would we ever reclaim
> !uptodate && !buffers pages?

Hmmm.. Ok mpage.c does:

static void mpage_end_io_write(struct bio *bio, int err)
{
        const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
        struct bio_vec *bvec = bio->bi_io_vec + bio->bi_vcnt - 1;

        do {
                struct page *page = bvec->bv_page;

                if (--bvec >= bio->bi_io_vec)
                        prefetchw(&bvec->bv_page->flags);

                if (!uptodate){
                        SetPageError(page);
                        if (page->mapping)
                                set_bit(AS_EIO, &page->mapping->flags);
                }
                end_page_writeback(page);
        } while (bvec >= bio->bi_io_vec);
        bio_put(bio);
}

So it seems the page is always locked if !Uptodate.
 
> So I don't think we need this patch.

Ok.

Is there any easy way to check if any of the buffers are locked? It would 
be good if we could skip the pages with pending I/O on the first migration 
passes and only get to them after most of the others have been migrated. 
The taking of the buffer locks instead of the page lock defeats the scheme 
to defer the difficult migrations till later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
