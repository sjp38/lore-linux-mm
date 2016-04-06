Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8931A828F3
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 20:56:25 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id zm5so21327947pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 17:56:25 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id s6si541228pfi.138.2016.04.05.17.56.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 17:56:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 01/16] mm: use put_page to free page instead of
 putback_lru_page
Date: Wed, 6 Apr 2016 00:54:04 +0000
Message-ID: <20160406005403.GA29576@hori1.linux.bs1.fc.nec.co.jp>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-2-git-send-email-minchan@kernel.org>
 <56FE706D.7080507@suse.cz> <20160404013917.GC6543@bbox>
 <20160404044458.GA20250@hori1.linux.bs1.fc.nec.co.jp>
 <57027E47.7070909@suse.cz>
 <20160405015402.GA30962@hori1.linux.bs1.fc.nec.co.jp>
 <57037562.3040203@suse.cz>
In-Reply-To: <57037562.3040203@suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B63A2058FEB6714FBB784846F111B38A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "bfields@fieldses.org" <bfields@fieldses.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "aquini@redhat.com" <aquini@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, "rknize@motorola.com" <rknize@motorola.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Tue, Apr 05, 2016 at 10:20:50AM +0200, Vlastimil Babka wrote:
> On 04/05/2016 03:54 AM, Naoya Horiguchi wrote:
> > On Mon, Apr 04, 2016 at 04:46:31PM +0200, Vlastimil Babka wrote:
> >> On 04/04/2016 06:45 AM, Naoya Horiguchi wrote:
> >>> On Mon, Apr 04, 2016 at 10:39:17AM +0900, Minchan Kim wrote:
> > ...
> >>>>>
> >>>>> Also (but not your fault) the put_page() preceding
> >>>>> test_set_page_hwpoison(page)) IMHO deserves a comment saying which
> >>>>> pin we are releasing and which one we still have (hopefully? if I
> >>>>> read description of da1b13ccfbebe right) otherwise it looks like
> >>>>> doing something with a page that we just potentially freed.
> >>>>
> >>>> Yes, while I read the code, I had same question. I think the releasi=
ng
> >>>> refcount is for get_any_page.
> >>>
> >>> As the other callers of page migration do, soft_offline_page expects =
the
> >>> migration source page to be freed at this put_page() (no pin remains.=
)
> >>> The refcount released here is from isolate_lru_page() in __soft_offli=
ne_page().
> >>> (the pin by get_any_page is released by put_hwpoison_page just after =
it.)
> >>>
> >>> .. yes, doing something just after freeing page looks weird, but that=
's
> >>> how PageHWPoison flag works. IOW, many other page flags are maintaine=
d
> >>> only during one "allocate-free" life span, but PageHWPoison still doe=
s
> >>> its job beyond it.
> >>
> >> But what prevents the page from being allocated again between put_page=
()
> >> and test_set_page_hwpoison()? In that case we would be marking page
> >> poisoned while still in use, which is the same as marking it while sti=
ll
> >> in use after a failed migration?
> >=20
> > Actually nothing prevents that race. But I think that the result of the=
 race
> > is that the error page can be reused for allocation, which results in k=
illing
> > processes at page fault time. Soft offline is kind of mild/precautious =
thing
> > (for correctable errors that don't require immediate handling), so kill=
ing
> > processes looks to me an overkill. And marking hwpoison means that we c=
an no
> > longer do retry from userspace.
>=20
> So you agree that this race is a bug? It may turn a soft-offline attempt
> into a killed process. In that case we should fix it the same as we are
> fixing the failed migration case.

I agree, it's a bug, although rare and non-critical.

> Maybe it will be just enough to switch
> the test_set_page_hwpoison() and put_page() calls?

Unfortunately that restores the other race with unpoison (described below.)
Sorry for my bad/unclear statements, these races seems exclusive and a comp=
atible
solution is not found, so I prioritized fixing the latter one by comparing
severity (the latter causes kernel crash,) which led to the current code.

> > And another practical thing is the race with unpoison_memory() as descr=
ibed
> > in commit da1b13ccfbebe. unpoison_memory() properly works only for prop=
erly
> > poisoned pages, so doing unpoison for in-use hwpoisoned pages is fragil=
e.
> > That's why I'd like to avoid setting PageHWPoison for in-use pages if p=
ossible.
> >=20
> >> (Also, which part prevents pages with PageHWPoison to be allocated
> >> again, anyway? I can't find it and test_set_page_hwpoison() doesn't
> >> remove from buddy freelists).
> >=20
> > check_new_page() in mm/page_alloc.c should prevent reallocation of Page=
HWPoison.
> > As you pointed out, memory error handler doens't remove it from buddy f=
reelists.
>=20
> Oh, I see. It's using __PG_HWPOISON wrapper, so I didn't notice it when
> searching. In any case that results in a bad_page() warning, right? Is
> it desirable for a soft-offlined page?

That's right, and the bad_page warning might be too strong for soft offlini=
ng.
We can't tell which of memory_failure/soft_offline_page a PageHWPoison came
from, but users can find other lines in dmesg which should tell that.
And memory error events can hit buddy pages directly, in that case we still
need the check in check_new_page().

> If we didn't free poisoned pages
> to buddy system, they wouldn't trigger this warning.

Actually, we didn't free at commit add05cecef80 ("mm: soft-offline: don't f=
ree
target page in successful page migration"), but that's was reverted in
commit f4c18e6f7b5b ("mm: check __PG_HWPOISON separately from PAGE_FLAGS_CH=
ECK_AT_*").
Now I start thinking the revert was a bad decision, so I'll dig this proble=
m again.

> > BTW, it might be a bit off-topic, but recently I felt that check_new_pa=
ge()
> > might be improvable, because when check_new_page() returns 1, the whole=
 buddy
> > block (not only the bad page) seems to be leaked from buddy freelist.
> > For example, if thp (order 9) is requested, and PageHWPoison (or any ot=
her
> > types of bad pages) is found in an order 9 block, all 512 page are disc=
arded.
> > Unpoison can't bring it back to buddy.
> > So, some code to split buddy block including bad page (and recovering c=
ode from
> > unpoison) might be helpful, although that's another story ...
>=20
> Hm sounds like another argument for not freeing the page to buddy lists
> in the first place. Maybe a hook in free_pages_check()?

Sounds a good idea. I'll try it, too.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
