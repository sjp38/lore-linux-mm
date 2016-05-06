Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id EADD86B0005
	for <linux-mm@kvack.org>; Fri,  6 May 2016 12:04:38 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t140so217953444oie.0
        for <linux-mm@kvack.org>; Fri, 06 May 2016 09:04:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rz10si8084441oec.5.2016.05.06.09.04.37
        for <linux-mm@kvack.org>;
        Fri, 06 May 2016 09:04:37 -0700 (PDT)
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
References: <D6EDEBF1F91015459DB866AC4EE162CC023AEF26@IRSMSX103.ger.corp.intel.com>
 <5720F2A8.6070406@intel.com> <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <572CC092.5020702@intel.com>
Date: Fri, 6 May 2016 09:04:34 -0700
MIME-Version: 1.0
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>"Shutemov, Kirill" <kirill.shutemov@intel.com>

On 05/06/2016 08:10 AM, Odzioba, Lukasz wrote:
> On Thu 05-05-16 09:21:00, Michal Hocko wrote: 
>> Or maybe the async nature of flushing turns
>> out to be just impractical and unreliable and we will end up skipping
>> THP (or all compound pages) for pcp LRU add cache. Let's see...
> 
> What if we simply skip lru_add pvecs for compound pages?
> That way we still have compound pages on LRU's, but the problem goes
> away.  It is not quite what this naive patch does, but it works nice for me.
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 03aacbc..c75d5e1 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -392,7 +392,9 @@ static void __lru_cache_add(struct page *page)
>         get_page(page);
>         if (!pagevec_space(pvec))
>                 __pagevec_lru_add(pvec);
>         pagevec_add(pvec, page);
> +       if (PageCompound(page))
> +               __pagevec_lru_add(pvec);
>         put_cpu_var(lru_add_pvec);
>  }

That's not _quite_ what I had in mind since that drains the entire pvec
every time a large page is encountered.  But I'm conflicted about what
the right behavior _is_.

We'd taking the LRU lock for 'page' anyway, so we might as well drain
the pvec.

Or, does the additional work to put the page on to a pvec and then
immediately drain it overwhelm that advantage?

Or does it just not matter?

Kirill, do you have a suggestion for how we should be checking for THP
pages in code like this?  PageCompound() will surely _work_ for anon-THP
and your file-THP, but is it the best way to check?

> Do we have any tests that I could use to measure performance impact
> of such changes before I start to tweak it up? Or maybe it doesn't make
> sense at all ?

You probably want to very carefully calculate the time to fault a page,
then separately to free a page.  If we can't manage to detect a delta on
a little microbenchmark like that then we'll probably never see one in
practice.

You'll want to measure the fault time for a 4k pages, 2M pages, and then
possibly a mix.

You'll want to do this in a highly parallel test to make sure any
additional LRU lock overhead shows up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
