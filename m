Date: Tue, 12 Dec 2006 01:52:32 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]  incorrect error handling inside
 generic_file_direct_write
Message-Id: <20061212015232.eacfbb46.akpm@osdl.org>
In-Reply-To: <87bqm9tie3.fsf@sw.ru>
References: <87k60y1rq4.fsf@sw.ru>
	<20061211124052.144e69a0.akpm@osdl.org>
	<87bqm9tie3.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitriy Monakhov <dmonakhov@sw.ru>
Cc: Dmitriy Monakhov <dmonakhov@openvz.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Dec 2006 15:20:52 +0300
Dmitriy Monakhov <dmonakhov@sw.ru> wrote:

> > XFS (at least) can call generic_file_direct_write() with i_mutex not held. 
> > And vmtruncate() expects i_mutex to be held.
> >
> > I guess a suitable solution would be to push this problem back up to the
> > callers: let them decide whether to run vmtruncate() and if so, to ensure
> > that i_mutex is held.
> >
> > The existence of generic_file_aio_write_nolock() makes that rather messy
> > though.
> This means we may call generic_file_aio_write_nolock() without i_mutex, right?
> but call trace is :
>   generic_file_aio_write_nolock() 
>   ->generic_file_buffered_write() /* i_mutex not held here */ 
> but according to filemaps locking rules: mm/filemap.c:77
>  ..
>  *  ->i_mutex			(generic_file_buffered_write)
>  *    ->mmap_sem		(fault_in_pages_readable->do_page_fault)
>  ..
> I'm confused a litle bit, where is the truth? 

xfs_write() calls generic_file_direct_write() without taking i_mutex for
O_DIRECT writes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
