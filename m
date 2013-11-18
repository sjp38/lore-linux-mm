Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id C6C1D6B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 15:20:32 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so806500pbc.21
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 12:20:32 -0800 (PST)
Received: from psmtp.com ([74.125.245.175])
        by mx.google.com with SMTP id z1si10495448pbn.91.2013.11.18.12.20.29
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 12:20:30 -0800 (PST)
Date: Mon, 18 Nov 2013 15:20:22 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1384806022-4718p9lh-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <528A6448.3080907@sr71.net>
References: <20131115225550.737E5C33@viggo.jf.intel.com>
 <20131115225553.B0E9DFFB@viggo.jf.intel.com>
 <1384800714-y653r3ch-mutt-n-horiguchi@ah.jp.nec.com>
 <1384800841-314l1f3e-mutt-n-horiguchi@ah.jp.nec.com>
 <528A6448.3080907@sr71.net>
Subject: Re: [PATCH] mm: call cond_resched() per MAX_ORDER_NR_PAGES pages copy
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Mel Gorman <mgorman@suse.de>

On Mon, Nov 18, 2013 at 11:02:32AM -0800, Dave Hansen wrote:
> On 11/18/2013 10:54 AM, Naoya Horiguchi wrote:
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index cb5d152b58bc..661ff5f66591 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -454,7 +454,8 @@ static void __copy_gigantic_page(struct page *dst, struct page *src,
> >  	struct page *src_base = src;
> >  
> >  	for (i = 0; i < nr_pages; ) {
> > -		cond_resched();
> > +		if (i % MAX_ORDER_NR_PAGES == 0)
> > +			cond_resched();
> >  		copy_highpage(dst, src);
> 
> This is certainly OK on x86, but remember that MAX_ORDER can be
> overridden by a config variable.  Just picking one at random:
> 
> config FORCE_MAX_ZONEORDER
>         int "Maximum zone order"
>         range 9 64 if PPC64 && PPC_64K_PAGES
> ...
> 
> Would it be OK to only resched once every 2^63 pages? ;)

You're right. We need use more reliable value here.
HPAGE_SIZE/PAGE_SIZE looks better to me.

> Really, though, a lot of things seem to have MAX_ORDER set up so that
> it's at 256MB or 512MB.  That's an awful lot to do between rescheds.

Yes.

BTW, I found that we have the same problem for other functions like
copy_user_gigantic_page, copy_user_huge_page, and maybe clear_gigantic_page.
So we had better handle them too.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
