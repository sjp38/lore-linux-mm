Date: Tue, 07 Dec 2004 22:05:39 +0000
From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: Re: PATCH: mark_page_accessed() for read()s on non-page boundaries
References: <20041207213819.GA32537@cistron.nl>
	<20041207135205.783860cf.akpm@osdl.org>
In-Reply-To: <20041207135205.783860cf.akpm@osdl.org> (from akpm@osdl.org on
	Tue Dec  7 22:52:05 2004)
Message-Id: <1102457139l.23999l.3l@stargazer.cistron.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 07 Dec 2004 22:52:05, Andrew Morton wrote:
> 
> You should cc a mailing list.

OK, I've added linux-mm back in. Sorry.

> Miquel van Smoorenburg <miquels@cistron.nl> wrote:
> >
> > When reading a (partial) page from disk using read(), the kernel only
> > marks the page as "accessed" if the read started at a page boundary.
> > This means that files that are accessed randomly at non-page boundaries
> > (usually database style files) will not be cached properly.
> 
> Yeah.  Touching the page on every read can be expensive for small reads, so
> I left that code out very early in 2.5.  Your "is this page different from
> the last one" is a reasonable approach.
> 
> > The patch below uses the readahead state instead. If a page is read(),
> > it is marked as "accessed" if the previous read() was for a different
> > page, whatever the offset in the page.
> 
> Except a smart database programmer will have done
> posix_fadvise(POSIX_FADV_RANDOM) which turns off readahead.  So
> page_cache_readahead() never updates prev_page.

Yes. Blech.

> So you'll need something like this as well:
> 
> 
> --- 25/mm/readahead.c~a	Tue Dec  7 13:50:04 2004
> +++ 25-akpm/mm/readahead.c	Tue Dec  7 13:50:58 2004
> @@ -369,8 +369,10 @@ page_cache_readahead(struct address_spac
>  		goto out;	/* Maximally shrunk */
>  
>  	max = get_max_readahead(ra);
> -	if (max == 0)
> +	if (max == 0) {
> +		ra->prev_page = offset;	/* For do_generic_mapping_read() */
>  		goto out;	/* No readahead */
> +	}
>  
>  	orig_next_size = ra->next_size;

OK, got it. Will go and play with that and posix_fadvise(POSIX_FADV_RANDOM)
some more.

> Have you any testing results to justify the change, btw?

Ok some background info. I'm running the Diablo usenet news server,
which uses a large history database that needs to be fast. Because
of lots of streaming I/O, the history database pages keep getting
thrown out of memory. Many people run the history database on a
laaaarge ramdisk or in /dev/shm to get the system to keep the
database in RAM.

Because of that I developed something called LINUX_FADV_STICKY support
which makes the kernel keep read() pages from a file in core more
aggressively. Like it does when you use mmap() with swappiness
tuned down to 20 or so.

And when developing and testing LINUX_FADV_STICKY I discovered
many pages weren't being marked as accessed in the first place,
hence this patch.

This patch on its own appears to help a bit too, but not enough-
the LINUX_FADV_STICKY patch makes the app scream though, without
using a ramdisk..

So I really need it for the LINUX_FADV_STICKY stuff, but it appeared
to me to be a standalone bug as well, that's why there's this
seperate patch.

If you want me to run some tests, sure - if you have advice on which
ones would be appropriate I'll give it a go.

Thanks,

Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
