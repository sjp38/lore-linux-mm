Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 269446B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 05:59:38 -0500 (EST)
Received: by pbcup15 with SMTP id up15so17909pbc.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 02:59:37 -0800 (PST)
Date: Mon, 5 Mar 2012 19:59:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -next] slub: set PG_slab on all of slab pages
Message-ID: <20120305105918.GA13252@barrios>
References: <1330505674-31610-1-git-send-email-namhyung.kim@lge.com>
 <20120304103446.GA9267@barrios>
 <4F547C90.4040007@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F547C90.4040007@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 05, 2012 at 05:42:56PM +0900, Namhyung Kim wrote:
> 2012-03-04 7:34 PM, Minchan Kim wrote:
> >Hi Namhyung,
> >
> 
> Hi Minchan,
> glad to see you here again :)

Thanks!

> 
> 
> >On Wed, Feb 29, 2012 at 05:54:34PM +0900, Namhyung Kim wrote:
> >>Unlike SLAB, SLUB doesn't set PG_slab on tail pages, so if a user would
> >>call free_pages() incorrectly on a object in a tail page, she will get
> >>i confused with the undefined result. Setting the flag would help her by
> >>emitting a warning on bad_page() in such a case.
> >>
> >>Reported-by: Sangseok Lee <sangseok.lee@lge.com>
> >>Signed-off-by: Namhyung Kim <namhyung.kim@lge.com>
> >
> >I read this thread and I feel the we don't reach right point.
> >I think it's not a compound page problem.
> >We can face above problem where we allocates big order page without __GFP_COMP
> >and free middle page of it.
> >
> >Fortunately, We can catch such a problem by put_page_testzero in __free_pages
> >if you enable CONFIG_DEBUG_VM.
> >
> >Did you tried that with CONFIG_DEBUG_VM?
> >
> 
> To be honest, I don't have a real test environment which brings this
> issue in the first place. On my simple test environment, enabling
> CONFIG_DEBUG_VM emits a bug when I tried to free middle of the slab
> pages. Thanks for pointing it out.
> 
> However I guess there was a chance to bypass that test anyhow since
> it did reach to __free_pages_ok(). If the page count was 0 already,
> free_pages() will prevent it from getting to the function even
> though CONFIG_DEBUG_VM was disabled. But I don't think it's a kernel
> bug - it seems entirely our fault :( I'll recheck and talk about it
> with my colleagues.

Let me ask a question.
Could you see bad page message by PG_slab with SLUB after you apply your patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
