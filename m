Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 99D716B0092
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 15:09:16 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 2/2] memcg: avoid THP split in task migration
Date: Fri,  2 Mar 2012 15:09:06 -0500
Message-Id: <1330718946-19490-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBD46TioS0n7k6nZRG7p8+hiJkUddayr8=0sCxKq8Qct1Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Fri, Mar 02, 2012 at 08:22:29PM +0800, Hillf Danton wrote:
> On Fri, Mar 2, 2012 at 8:31 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
...
> > --- linux-next-20120228.orig/mm/memcontrol.c
> > +++ linux-next-20120228/mm/memcontrol.c
> > @@ -5211,6 +5211,39 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
> >    return ret;
> > }
> >
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +/*
> > + * We don't consider swapping or file mapped pages because THP does not
> > + * support them for now.
> > + * Caller should make sure that pmd_trans_huge(pmd) is true.
> > + */
> > +static int is_target_thp_for_mc(struct vm_area_struct *vma,
> > +        unsigned long addr, pmd_t pmd, union mc_target *target)
> > +{
> > +    struct page *page = NULL;
> > +    struct page_cgroup *pc;
> > +    int ret = 0;
> > +
>
> Need to check move_anon() ?

Right, we need it and page_mapcount check to be consistent with non thp code.

BTH it is maybe a bit off-topic, but I feel strange the following:

  static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
                                            unsigned long addr, pte_t ptent)
  {
          ...
          if (PageAnon(page)) {
                  /* we don't move shared anon */
                  if (!move_anon() || page_mapcount(page) > 2)
                          return NULL;

Here page_mapcount(page) > 2 means that a given page is shared among more
than _three_ users. Documentation/cgroups/memory.txt sec.8.2 says that

  "(for file pages) mapcount of the page is ignored(the page can be
    moved even if page_mapcount(page) > 1)."

It implies that we do not move charge for anonymous page if mapcount > 1.
So I think the above mapcount check should be "> 1."
I'll post fix patch separately if it's correct.

> Other than that,
> Acked-by: Hillf Danton <dhillf@gmail.com>

Thank you!

It's small fix, but I'll resend whole renewed patchset for Andrew to handle
it easier.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
