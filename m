Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 467A66B01A7
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 02:28:17 -0400 (EDT)
Received: by pwi4 with SMTP id 4so126193pwi.14
        for <linux-mm@kvack.org>; Sun, 14 Mar 2010 23:28:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	 <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	 <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 15 Mar 2010 15:28:15 +0900
Message-ID: <28c262361003142328w610f0478sbc17880ffa454fe8@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 2:34 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 15 Mar 2010 09:28:08 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi, Mel.
>> On Sat, Mar 13, 2010 at 1:41 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > rmap_walk_anon() was triggering errors in memory compaction that looks=
 like
>> > use-after-free errors in anon_vma. The problem appears to be that betw=
een
>> > the page being isolated from the LRU and rcu_read_lock() being taken, =
the
>> > mapcount of the page dropped to 0 and the anon_vma was freed. This pat=
ch
>> > skips the migration of anon pages that are not mapped by anyone.
>> >
>> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> > Acked-by: Rik van Riel <riel@redhat.com>
>> > ---
>> > =C2=A0mm/migrate.c | =C2=A0 10 ++++++++++
>> > =C2=A01 files changed, 10 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/mm/migrate.c b/mm/migrate.c
>> > index 98eaaf2..3c491e3 100644
>> > --- a/mm/migrate.c
>> > +++ b/mm/migrate.c
>> > @@ -602,6 +602,16 @@ static int unmap_and_move(new_page_t get_new_page=
, unsigned long private,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * just care Anon page here.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageAnon(page)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the page=
 has no mappings any more, just bail. An
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmapped an=
on page is likely to be freed soon but worse,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* it's possib=
le its anon_vma disappeared between when
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the page wa=
s isolated and when we reached here while
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the RCU loc=
k was not held
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapcount(=
page))
>>
>> As looking code about mapcount of page, I got confused.
>> I think mapcount of page is protected by pte lock.
>> But I can't find pte lock in unmap_and_move.
> There is no pte_lock.
>
>> If I am right, what protects race between this condition check and
>> rcu_read_lock?
>> This patch makes race window very small but It can't remove race totally=
.
>>
>> I think I am missing something.
>> Pz, point me out. :)
>>
>
> Hmm. This is my understanding of old story.
>
> At migration.
> =C2=A01. we increase page_count().
> =C2=A02. isolate it from LRU.
> =C2=A03. call try_to_unmap() under rcu_read_lock(). Then,
> =C2=A04. replace pte with swp_entry_t made by PFN. under pte_lock.
> =C2=A05. do migarate
> =C2=A06. remap new pages. under pte_lock()>
> =C2=A07. release rcu_read_lock().
>
> Here, we don't care whether page->mapping holds valid anon_vma or not.
>
> Assume a racy threads which calls zap_pte_range() (or some other)
>
> a) When the thread finds valid pte under pte_lock and successfully call
> =C2=A0 page_remove_rmap().
> =C2=A0 In this case, migration thread finds try_to_unmap doesn't unmap an=
y pte.
> =C2=A0 Then, at 6, remap pte will not work.
> b) When the thread finds migrateion PTE(as swap entry) in zap_page_range(=
).
> =C2=A0 In this case, migration doesn't find migrateion PTE and remap fail=
s.
>
> Why rcu_read_lock() is necessary..
> =C2=A0- When page_mapcount() goes to 0, we shouldn't trust page->mapping =
is valid.
> =C2=A0- Possible cases are
> =C2=A0 =C2=A0 =C2=A0 =C2=A0i) anon_vma (=3D page->mapping) is freed and u=
sed for other object.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ii) anon_vma (=3D page->mapping) is freed
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iii) anon_vma (=3D page->mapping) is freed and=
 used as anon_vma again.
>
> Here, anon_vma_cachep is created =C2=A0by SLAB_DESTROY_BY_RCU. Then, poss=
ible cases
> are only ii) and iii). While anon_vma is anon_vma, try_to_unmap and remap=
_page
> can work well because of the list of vmas and address check. IOW, remap r=
outine
> just do nothing if anon_vma is freed.
>
> I'm not sure by what logic "use-after-free anon_vma" is caught. But yes,
> there will be case, "anon_vma is touched after freed.", I think.
>
> Thanks,
> -Kame
>

Thanks for detail explanation, Kame.
But it can't understand me enough, Sorry.

Mel said he met "use-after-free errors in anon_vma".
So added the check in unmap_and_move.

if (PageAnon(page)) {
 ....
 if (!page_mapcount(page))
   goto uncharge;
 rcu_read_lock();

My concern what protects racy mapcount of the page?
For example,

CPU A                                 CPU B
unmap_and_move
page_mapcount check pass    zap_pte_range
<-- some stall -->                   pte_lock
<-- some stall -->                   page_remove_rmap(map_count is zero!)
<-- some stall -->                   pte_unlock
<-- some stall -->                   anon_vma_unlink
<-- some stall -->                   anon_vma free !!!!
rcu_read_lock
anon_vma has gone!!

I think above scenario make error "use-after-free", again.
What prevent above scenario?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
