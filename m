Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E28126B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 10:40:31 -0400 (EDT)
Date: Fri, 19 Jul 2013 10:39:56 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1374244796-ur27gtic-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBBs7R1e4BaGDORcO+X3trQWcgmEm4UX2EpwXQyDqw2m9w@mail.gmail.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CAJd=RBBs7R1e4BaGDORcO+X3trQWcgmEm4UX2EpwXQyDqw2m9w@mail.gmail.com>
Subject: Re: [PATCH 7/8] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jul 19, 2013 at 01:40:38PM +0800, Hillf Danton wrote:
> On Fri, Jul 19, 2013 at 5:34 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > @@ -518,9 +519,11 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
> >  {
> >         struct page *page;
> >
> > -       if (list_empty(&h->hugepage_freelists[nid]))
> > +       list_for_each_entry(page, &h->hugepage_freelists[nid], lru)
> > +               if (!is_migrate_isolate_page(page))
> > +                       break;
> > +       if (&h->hugepage_freelists[nid] == &page->lru)
> 
> For what is this check?

This check returns true unless a non-isolated free hugepage is found.
In "not found" case page points to h->hugepage_freelists, so without
this check successive code doesn't work fine.

Thanks,
Naoya

> >                 return NULL;
> > -       page = list_entry(h->hugepage_freelists[nid].next, struct page, lru);
> >         list_move(&page->lru, &h->hugepage_activelist);
> >         set_page_refcounted(page);
> >         h->free_huge_pages--;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
