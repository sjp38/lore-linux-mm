Date: Sun, 22 Jun 2003 23:32:35 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] Fix vmtruncate race and distributed filesystem race
Message-Id: <20030622233235.0924364d.akpm@digeo.com>
In-Reply-To: <20030623032842.GA1167@us.ibm.com>
References: <133430000.1055448961@baldur.austin.ibm.com>
	<20030612134946.450e0f77.akpm@digeo.com>
	<20030612140014.32b7244d.akpm@digeo.com>
	<150040000.1055452098@baldur.austin.ibm.com>
	<20030612144418.49f75066.akpm@digeo.com>
	<184910000.1055458610@baldur.austin.ibm.com>
	<20030620001743.GI18317@dualathlon.random>
	<20030623032842.GA1167@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: andrea@suse.de, dmccr@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Paul E. McKenney" <paulmck@us.ibm.com> wrote:
>
> > but you can't trap this with a single counter increment in do_truncate:
>  > 
>  > 	CPU 0			CPU 1
>  > 	----------		-----------
>  > 				do_no_page
>  > 	truncate

        i_size = new_i_size;

>  > 	increment counter
>  > 				read counter
>  > 				->nopage

                                check i_size

>  > 	vmtruncate
>  > 				read counter again -> different so retry
>  > 
>  > thanks to the second counter increment after vmtruncate in my fix, the
>  > above race couldn't happen.
> 
>  The trick is that CPU 0 is expected to have updated the filesystem's
>  idea of what pages are available before calling vmtruncate,
>  invalidate_mmap_range() or whichever.

i_size has been updated, and filemap_nopage() will return NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
