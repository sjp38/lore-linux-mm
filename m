Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F48B6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 07:00:50 -0400 (EDT)
Received: by gxk12 with SMTP id 12so4965367gxk.4
        for <linux-mm@kvack.org>; Tue, 18 Aug 2009 04:00:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090818100031.GC16298@localhost>
References: <20090806210955.GA14201@c2.user-mode-linux.org>
	 <4A87829C.4090908@redhat.com> <20090816051502.GB13740@localhost>
	 <20090816112910.GA3208@localhost>
	 <28c262360908170733q4bc5ddb8ob2fc976b6a468d6e@mail.gmail.com>
	 <20090818023438.GB7958@localhost>
	 <20090818131734.3d5bceb2.minchan.kim@barrios-desktop>
	 <20090818093119.GA12679@localhost>
	 <20090818185247.a4516389.minchan.kim@barrios-desktop>
	 <20090818100031.GC16298@localhost>
Date: Tue, 18 Aug 2009 20:00:48 +0900
Message-ID: <28c262360908180400q361ea322o8959fd5ea5ae3217@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Jeff Dike <jdike@addtoit.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 7:00 PM, Wu Fengguang<fengguang.wu@intel.com> wrote=
:
> On Tue, Aug 18, 2009 at 05:52:47PM +0800, Minchan Kim wrote:
>> On Tue, 18 Aug 2009 17:31:19 +0800
>> Wu Fengguang <fengguang.wu@intel.com> wrote:
>>
>> > On Tue, Aug 18, 2009 at 12:17:34PM +0800, Minchan Kim wrote:
>> > > On Tue, 18 Aug 2009 10:34:38 +0800
>> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
>> > >
>> > > > Minchan,
>> > > >
>> > > > On Mon, Aug 17, 2009 at 10:33:54PM +0800, Minchan Kim wrote:
>> > > > > On Sun, Aug 16, 2009 at 8:29 PM, Wu Fengguang<fengguang.wu@intel=
.com> wrote:
>> > > > > > On Sun, Aug 16, 2009 at 01:15:02PM +0800, Wu Fengguang wrote:
>> > > > > >> On Sun, Aug 16, 2009 at 11:53:00AM +0800, Rik van Riel wrote:
>> > > > > >> > Wu Fengguang wrote:
>> > > > > >> > > On Fri, Aug 07, 2009 at 05:09:55AM +0800, Jeff Dike wrote=
:
>> > > > > >> > >> Side question -
>> > > > > >> > >> =C2=A0Is there a good reason for this to be in shrink_ac=
tive_list()
>> > > > > >> > >> as opposed to __isolate_lru_page?
>> > > > > >> > >>
>> > > > > >> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!page_evi=
ctable(page, NULL))) {
>> > > > > >> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0putback_lru_page(page);
>> > > > > >> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0continue;
>> > > > > >> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > > > > >> > >>
>> > > > > >> > >> Maybe we want to minimize the amount of code under the l=
ru lock or
>> > > > > >> > >> avoid duplicate logic in the isolate_page functions.
>> > > > > >> > >
>> > > > > >> > > I guess the quick test means to avoid the expensive page_=
referenced()
>> > > > > >> > > call that follows it. But that should be mostly one shot =
cost - the
>> > > > > >> > > unevictable pages are unlikely to cycle in active/inactiv=
e list again
>> > > > > >> > > and again.
>> > > > > >> >
>> > > > > >> > Please read what putback_lru_page does.
>> > > > > >> >
>> > > > > >> > It moves the page onto the unevictable list, so that
>> > > > > >> > it will not end up in this scan again.
>> > > > > >>
>> > > > > >> Yes it does. I said 'mostly' because there is a small hole th=
at an
>> > > > > >> unevictable page may be scanned but still not moved to unevic=
table
>> > > > > >> list: when a page is mapped in two places, the first pte has =
the
>> > > > > >> referenced bit set, the _second_ VMA has VM_LOCKED bit set, t=
hen
>> > > > > >> page_referenced() will return 1 and shrink_page_list() will m=
ove it
>> > > > > >> into active list instead of unevictable list. Shall we fix th=
is rare
>> > > > > >> case?
>> > > > >
>> > > > > I think it's not a big deal.
>> > > >
>> > > > Maybe, otherwise I should bring up this issue long time before :)
>> > > >
>> > > > > As you mentioned, it's rare case so there would be few pages in =
active
>> > > > > list instead of unevictable list.
>> > > >
>> > > > Yes.
>> > > >
>> > > > > When next time to scan comes, we can try to move the pages into
>> > > > > unevictable list, again.
>> > > >
>> > > > Will PG_mlocked be set by then? Otherwise the situation is not lik=
ely
>> > > > to change and the VM_LOCKED pages may circulate in active/inactive
>> > > > list for countless times.
>> > >
>> > > PG_mlocked is not important in that case.
>> > > Important thing is VM_LOCKED vma.
>> > > I think below annotaion can help you to understand my point. :)
>> >
>> > Hmm, it looks like pages under VM_LOCKED vma is guaranteed to have
>> > PG_mlocked set, and so will be caught by page_evictable(). Is it?
>>
>> No. I am sorry for making my point not clear.
>> I meant following as.
>> When the next time to scan,
>>
>> shrink_page_list
> =C2=A0->
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0referenced =3D pag=
e_referenced(page, 1,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0sc->mem_cgroup, &vm_flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* In active use o=
r really unfreeable? =C2=A0Activate it. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->order <=3D=
 PAGE_ALLOC_COSTLY_ORDER &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reference=
d && page_mapping_inuse(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto activate_locked;
>
>> -> try_to_unmap
> =C2=A0 =C2=A0 ~~~~~~~~~~~~ this line won't be reached if page is found to=
 be
> =C2=A0 =C2=A0 referenced in the above lines?

Indeed! In fact, I was worry about that.
It looks after live lock problem.
But I think  it's very small race window so  there isn't any report until n=
ow.
Let's Cced Lee.

If we have to fix it, how about this ?
This version  has small overhead than yours since
there is less shrink_page_list call than page_referenced.

diff --git a/mm/rmap.c b/mm/rmap.c
index ed63894..283266c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -358,6 +358,7 @@ static int page_referenced_one(struct page *page,
         */
        if (vma->vm_flags & VM_LOCKED) {
                *mapcount =3D 1;  /* break early from loop */
+               *vm_flags |=3D VM_LOCKED;
                goto out_unmap;
        }

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d224b28..d156e1d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -632,7 +632,8 @@ static unsigned long shrink_page_list(struct
list_head *page_list,
                                                sc->mem_cgroup, &vm_flags);
                /* In active use or really unfreeable?  Activate it. */
                if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER &&
-                                       referenced && page_mapping_inuse(pa=
ge))
+                                       referenced && page_mapping_inuse(pa=
ge)
+                                       && !(vm_flags & VM_LOCKED))
                        goto activate_locked;




>
> Thanks,
> Fengguang
>
>> =C2=A0 =C2=A0 =C2=A0 -> try_to_unmap_xxx
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -> if (vma->vm_flags & =
VM_LOCKED)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -> try_to_mlock_page
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 -> TestSetPageMlocked
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 -> putback_lru_page
>>
>> So at last, the page will be located in unevictable list.
>>
>> > Then I was worrying about a null problem. Sorry for the confusion!
>> >
>> > Thanks,
>> > Fengguang
>> >
>> > > ----
>> > >
>> > > /*
>> > > =C2=A0* called from munlock()/munmap() path with page supposedly on =
the LRU.
>> > > =C2=A0*
>> > > =C2=A0* Note: =C2=A0unlike mlock_vma_page(), we can't just clear the=
 PageMlocked
>> > > =C2=A0* [in try_to_munlock()] and then attempt to isolate the page. =
=C2=A0We must
>> > > =C2=A0* isolate the page to keep others from messing with its unevic=
table
>> > > =C2=A0* and mlocked state while trying to munlock. =C2=A0However, we=
 pre-clear the
>> > > =C2=A0* mlocked state anyway as we might lose the isolation race and=
 we might
>> > > =C2=A0* not get another chance to clear PageMlocked. =C2=A0If we suc=
cessfully
>> > > =C2=A0* isolate the page and try_to_munlock() detects other VM_LOCKE=
D vmas
>> > > =C2=A0* mapping the page, it will restore the PageMlocked state, unl=
ess the page
>> > > =C2=A0* is mapped in a non-linear vma. =C2=A0So, we go ahead and Set=
PageMlocked(),
>> > > =C2=A0* perhaps redundantly.
>> > > =C2=A0* If we lose the isolation race, and the page is mapped by oth=
er VM_LOCKED
>> > > =C2=A0* vmas, we'll detect this in vmscan--via try_to_munlock() or t=
ry_to_unmap()
>> > > =C2=A0* either of which will restore the PageMlocked state by callin=
g
>> > > =C2=A0* mlock_vma_page() above, if it can grab the vma's mmap sem.
>> > > =C2=A0*/
>> > > static void munlock_vma_page(struct page *page)
>> > > {
>> > > ...
>> > >
>> > > --
>> > > Kind regards,
>> > > Minchan Kim
>>
>>
>> --
>> Kind regards,
>> Minchan Kim
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
