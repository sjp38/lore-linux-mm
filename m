Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7928C6B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 13:32:06 -0400 (EDT)
Date: Tue, 17 Apr 2012 19:32:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Weirdness in __alloc_bootmem_node_high
Message-ID: <20120417173203.GA32482@tiehlicka.suse.cz>
References: <20120417155502.GE22687@tiehlicka.suse.cz>
 <CAE9FiQXWKzv7Wo4iWGrKapmxQYtAGezghwup1UKoW2ghqUSr+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAE9FiQXWKzv7Wo4iWGrKapmxQYtAGezghwup1UKoW2ghqUSr+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 17-04-12 10:12:30, Yinghai Lu wrote:
> On Tue, Apr 17, 2012 at 8:55 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > Hi,
> > I just come across the following condition in __alloc_bootmem_node_high
> > which I have hard times to understand. I guess it is a bug and we need
> > something like the following. But, to be honest, I have no idea why we
> > care about those 128MB above MAX_DMA32_PFN.
> > ---
> >  mm/bootmem.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/bootmem.c b/mm/bootmem.c
> > index 0131170..5adb072 100644
> > --- a/mm/bootmem.c
> > +++ b/mm/bootmem.c
> > @@ -737,7 +737,7 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
> >        /* update goal according ...MAX_DMA32_PFN */
> >        end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
> >
> > -       if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
> > +       if (end_pfn > MAX_DMA32_PFN + (128 << (20 - PAGE_SHIFT)) &&
> >            (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
> >                void *ptr;
> >                unsigned long new_goal;
> > --
> 
> We are not using bootmem with x86 now, so could remove those workaround now.

Could you be more specific about what the workaround is used for?

Thanks

> 
> Thanks
> 
> Yinghai
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
