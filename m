Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C21D6B0262
	for <linux-mm@kvack.org>; Wed, 11 May 2016 03:53:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so29490782lfc.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 00:53:16 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id as1si7683975wjc.146.2016.05.11.00.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 00:53:14 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so7767187wmn.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 00:53:14 -0700 (PDT)
Date: Wed, 11 May 2016 09:53:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160511075313.GE16677@dhcp22.suse.cz>
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com>
 <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
 <572CC092.5020702@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <572CC092.5020702@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Fri 06-05-16 09:04:34, Dave Hansen wrote:
> On 05/06/2016 08:10 AM, Odzioba, Lukasz wrote:
> > On Thu 05-05-16 09:21:00, Michal Hocko wrote: 
> >> Or maybe the async nature of flushing turns
> >> out to be just impractical and unreliable and we will end up skipping
> >> THP (or all compound pages) for pcp LRU add cache. Let's see...
> > 
> > What if we simply skip lru_add pvecs for compound pages?
> > That way we still have compound pages on LRU's, but the problem goes
> > away.  It is not quite what this naive patch does, but it works nice for me.
> > 
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 03aacbc..c75d5e1 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -392,7 +392,9 @@ static void __lru_cache_add(struct page *page)
> >         get_page(page);
> >         if (!pagevec_space(pvec))
> >                 __pagevec_lru_add(pvec);
> >         pagevec_add(pvec, page);
> > +       if (PageCompound(page))
> > +               __pagevec_lru_add(pvec);
> >         put_cpu_var(lru_add_pvec);
> >  }
> 
> That's not _quite_ what I had in mind since that drains the entire pvec
> every time a large page is encountered.  But I'm conflicted about what
> the right behavior _is_.
> 
> We'd taking the LRU lock for 'page' anyway, so we might as well drain
> the pvec.

Yes I think this makes sense. The only case where it would be suboptimal
is when the pagevec was already full and then we just created a single
page pvec to drain it. This can be handled better though by:

diff --git a/mm/swap.c b/mm/swap.c
index 95916142fc46..3fe4f180e8bf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
 
 	get_page(page);
-	if (!pagevec_space(pvec))
+	if (!pagevec_add(pvec, page) || PageCompound(page))
 		__pagevec_lru_add(pvec);
-	pagevec_add(pvec, page);
 	put_cpu_var(lru_add_pvec);
 }
 

> Or, does the additional work to put the page on to a pvec and then
> immediately drain it overwhelm that advantage?

pagevec_add is quite trivial so I would be really surprised if it
mattered.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
