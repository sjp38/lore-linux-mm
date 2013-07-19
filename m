Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 118A56B0033
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:04:56 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id dn14so4736052obc.16
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 21:04:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374203899-w7jwqowi-mutt-n-horiguchi@ah.jp.nec.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1374183272-10153-2-git-send-email-n-horiguchi@ah.jp.nec.com>
	<CAJd=RBD-uCuqyD0OTJ119woikBSyd8=A7uhHp5kUJeweS+2okQ@mail.gmail.com>
	<1374203899-w7jwqowi-mutt-n-horiguchi@ah.jp.nec.com>
Date: Fri, 19 Jul 2013 12:04:56 +0800
Message-ID: <CAJd=RBDxVdkAhuozG04kDVwr71c9Yy+nQNjqHPeVbq-KbKb4MA@mail.gmail.com>
Subject: Re: [PATCH 1/8] migrate: make core migration code aware of hugepage
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jul 19, 2013 at 11:18 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
>> > +bool isolate_huge_page(struct page *page, struct list_head *l)
>>
>> Can we replace the page parameter with p?
>
> Yes. Maybe it's strange to use the full name "page" for one parameter
> and an extremely shortened one "l" for another one.
>
Actually i mean the l arg could be replaced with something else ;)

>> > +
>> > +void putback_active_hugepage(struct page *page)
>> > +{
>> > +       VM_BUG_ON(!PageHead(page));
>> > +       spin_lock(&hugetlb_lock);
>> > +       list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
>> > +       spin_unlock(&hugetlb_lock);
>> > +       put_page(page);
>> > +}
>> > +
>> > +void putback_active_hugepages(struct list_head *l)
>> > +{
>> > +       struct page *page;
>> > +       struct page *page2;
>> > +
>> > +       list_for_each_entry_safe(page, page2, l, lru)
>> > +               putback_active_hugepage(page);
>>
>> Can we acquire hugetlb_lock only once?
>
> I'm not sure which is the best. In general, fine-grained locking is
> preferred because other lock contenders wait less.
> Could you tell some specific reason to hold lock outside the loop?
>
No anything special, looks we can do list splice after taking lock,
then we no longer contend it.

>> > @@ -1025,7 +1029,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>> >                 list_for_each_entry_safe(page, page2, from, lru) {
>> >                         cond_resched();
>> >
>> > -                       rc = unmap_and_move(get_new_page, private,
>> > +                       if (PageHuge(page))
>> > +                               rc = unmap_and_move_huge_page(get_new_page,
>> > +                                               private, page, pass > 2, mode);
>> > +                       else
>> > +                               rc = unmap_and_move(get_new_page, private,
>> >                                                 page, pass > 2, mode);
>> >
>> Is this hunk unclean merge?
>
> Sorry, I don't catch the point. This patch is based on v3.11-rc1 and
> the present HEAD has no changes from that release.
> Or do you mean that other trees have some conflicts? (my brief checking
> on -mm/-next didn't find that...)
>
Looks this hunk should appear in 2/8 or later, as 1/8 is focusing
on hugepage->lru?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
