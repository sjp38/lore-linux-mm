Date: Thu, 27 Sep 2007 15:59:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kswapd should only wait on IO if there is IO
Message-Id: <20070927155907.a4dce0d8.akpm@linux-foundation.org>
In-Reply-To: <20070927185027.1a1b4c13@bree.surriel.com>
References: <20070927170816.055548fd@bree.surriel.com>
	<20070927144702.a9124c7a.akpm@linux-foundation.org>
	<20070927181325.21aae460@bree.surriel.com>
	<20070927152121.3f5b6830.akpm@linux-foundation.org>
	<20070927185027.1a1b4c13@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Sep 2007 18:50:27 -0400
Rik van Riel <riel@redhat.com> wrote:

> On Thu, 27 Sep 2007 15:21:21 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > Nope, sc.nr_io_pages will also be incremented when the code runs into
> > > pages that are already PageWriteback.
> > 
> > yup, I didn't think of that.  Hopefully someone else will be in there
> > working on that zone too.  If this caller yields and defers to kswapd
> > then that's very likely.  Except we just took away the ability to do that..
> 
>                 if (PageDirty(page)) {
>                         if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
>                                 goto keep_locked;
>                         if (!may_enter_fs)
>                                 goto keep_locked;
> 
> I think we can fix that problem by adding a sc->nr_io_pages++
> between the last if and the goto keep_locked in shrink_page_list.
> 
> That way !GFP_IO or !GFP_FS tasks will cause themselves to sleep
> if there are pages that need to be written out, even if those
> pages are not in flight to disk yet.

yeah, that's prudent I guess.

> I have also added the comment you wanted.

And lost the changelog ;)

> -		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
> +		if (sc.nr_scanned && priority < DEF_PRIORITY - 2 &&
> +				sc.nr_io_pages > sc.swap_cluster_max)

I do think this design decision needs a bit of explanation too.

>  			congestion_wait(WRITE, HZ/10);
>  	}
>  	/* top priority shrink_caches still had more to do? don't OOM, then */
> @@ -1315,6 +1330,7 @@ loop_again:
>  		if (!priority)
>  			disable_swap_token();
>  
> +		sc.nr_io_pages = 0;
>  		all_zones_ok = 1;
>  
>  		/*
> @@ -1398,7 +1414,8 @@ loop_again:
>  		 * OK, kswapd is getting into trouble.  Take a nap, then take
>  		 * another pass across the zones.
>  		 */
> -		if (total_scanned && priority < DEF_PRIORITY - 2)
> +		if (total_scanned && priority < DEF_PRIORITY - 2 &&

As did that one.  Ho hum :(  Maybe it's in the git history somewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
