Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E9622900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 03:07:11 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p7U7790Y023905
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:07:09 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by wpaz29.hot.corp.google.com with ESMTP id p7U76Svo003522
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:07:08 -0700
Received: by qwi4 with SMTP id 4so7640075qwi.1
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 00:07:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110829210508.GA1599@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
	<CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
	<20110811210914.GB31229@cmpxchg.org>
	<CALWz4iwJfyWRineMy+W02YBvS0Y=Pv1y8Rb=8i5R=vUCfrO+iQ@mail.gmail.com>
	<CALWz4iwRXBheXFND5zq3ze2PJDkeoxYHD1zOsTyzOe3XqY5apA@mail.gmail.com>
	<20110829190426.GC1434@cmpxchg.org>
	<CALWz4ix1X8=L0HzQpdGd=XVbjZuMCtYngzdG+hLMoeJJCUEjrg@mail.gmail.com>
	<20110829210508.GA1599@cmpxchg.org>
Date: Tue, 30 Aug 2011 00:07:07 -0700
Message-ID: <CALWz4ixH-7c-fEUAHiyf83KyO9SsRzdUm-u+wm2_Ty=xvU_NyA@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, Aug 29, 2011 at 2:05 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, Aug 29, 2011 at 01:36:48PM -0700, Ying Han wrote:
>> On Mon, Aug 29, 2011 at 12:04 PM, Johannes Weiner <hannes@cmpxchg.org>wr=
ote:
>> > On Mon, Aug 29, 2011 at 12:22:02AM -0700, Ying Han wrote:
>> > > > @@ -888,19 +888,21 @@ void mem_cgroup_del_lru_list(struct page *pa=
ge,
>> > > > enum lru_list lru)
>> > > > =A0{
>> > > > =A0>------struct page_cgroup *pc;
>> > > > =A0>------struct mem_cgroup_per_zone *mz;
>> > > > +>------struct mem_cgroup *mem;
>> > > > =B7
>> > > > =A0>------if (mem_cgroup_disabled())
>> > > > =A0>------>-------return;
>> > > > =A0>------pc =3D lookup_page_cgroup(page);
>> > > > ->------/* can happen while we handle swapcache. */
>> > > > ->------if (!TestClearPageCgroupAcctLRU(pc))
>> > > > ->------>-------return;
>> > > > ->------VM_BUG_ON(!pc->mem_cgroup);
>> > > > ->------/*
>> > > > ->------ * We don't check PCG_USED bit. It's cleared when the "pag=
e" is
>> > finally
>> > > > ->------ * removed from global LRU.
>> > > > ->------ */
>> > > > ->------mz =3D page_cgroup_zoneinfo(pc->mem_cgroup, page);
>> > > > +
>> > > > +>------if (TestClearPageCgroupAcctLRU(pc) || PageCgroupUsed(pc)) =
{
>> >
>> > This PageCgroupUsed part confuses me. =A0A page that is being isolated
>> > shortly after being charged while on the LRU may reach here, and then
>> > it is unaccounted from pc->mem_cgroup, which it never was accounted
>> > to.
>> >
>> > Could you explain why you added it?
>>
>> To be honest, i don't have very good reason for that. The PageCgroupUsed
>> check is put there after running some tests and some fixes seems help th=
e
>> test, including this one.
>>
>> The one case I can think of for page !AcctLRU | Used is in the pagevec.
>> However, we shouldn't get to the mem_cgroup_del_lru_list() for a page in
>> pagevec at the first place.
>>
>> I now made it so that PageCgroupAcctLRU on the LRU means accounted
>> to pc->mem_cgroup,
>>
>> this is the same logic currently.
>>
>> > and !PageCgroupAcctLRU on the LRU means accounted to
>> > and babysitted by root_mem_cgroup.
>>
>> this seems to be different from what it is now, especially for swapcache
>> page. So, the page here is linked to root cgroup LRU or not?
>>
>> Anyway, the AcctLRU flags still seems confusing to me:
>>
>> what this flag tells me is that whether or not the page is on a PRIVATE =
lru
>> and being accounted, i used private here to differentiate from the per z=
one
>> lru, where it also has PageLRU flag. =A0The two flags are separate since=
 pages
>> could be on one lru not the other ( I guess ) , but this is changed afte=
r
>> having the root cgroup lru back. For example, AcctLRU is used to keep tr=
ack
>> of the accounted lru pages, especially for root ( we didn't account the
>> !Used pages to root like readahead swapcache). Now we account the full s=
ize
>> of lru list of root including Used and !Used, but only mark the Used pag=
es
>> w/ AcctLRU flag.
>>
>> So in general, i am wondering we should be able to replace that eventual=
ly
>> with existing Used and LRU bit. =A0Sorry this seems to be something we l=
ike to
>> consider later, not necessarily now :)
>
> I have now the following comment in mem_cgroup_lru_del_list():
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * root_mem_cgroup babysits uncharged LRU pages, but
> =A0 =A0 =A0 =A0 * PageCgroupUsed is cleared when the page is about to get
> =A0 =A0 =A0 =A0 * freed. =A0PageCgroupAcctLRU remembers whether the
> =A0 =A0 =A0 =A0 * LRU-accounting happened against pc->mem_cgroup or
> =A0 =A0 =A0 =A0 * root_mem_cgroup.
> =A0 =A0 =A0 =A0 */
>
> Does that answer your question? =A0If not, please tell me, so I can fix
> the comment :-)

Sorry, not clear to me yet :(

Is this saying that we can not differentiate the page linked to root
but not charged vs
page linked to memcg which is about to be freed.

If that is the case, isn't the page being removed from lru first
before doing uncharge (ClearPageCgroupUsed) ?

>
>> > Always. =A0Which also means that before_commit now ensures an LRU
>> > page is moved to root_mem_cgroup for babysitting during the
>> > charge, so that concurrent isolations/putbacks are always
>> > accounted correctly. =A0Is this what you had in mind? =A0Did I miss
>> > something?
>>
>> In my tree, the before->commit->after protocol is folded into one functi=
on.
>> I didn't post it since I know you also have patch doing that. =A0So gues=
s I
>> don't understand why we need to move the page to root while it is gonna =
be
>> charged to a memcg by commit_charge shortly after.
>
> It is a consequence of your fix that LRU-accounts unused pages to
> root_mem_cgroup upon lru-add, and thus deaccounts !PageCgroupAcctLRU
> from root_mem_cgroup unconditionally upon lru-del.
>
> Consider the following scenario:
>
> =A0 =A0 =A0 =A01. page with multiple mappings swapped out.
>
> =A0 =A0 =A0 =A02. one memcg faults the page, then unmaps it. =A0The page =
is
> =A0 =A0 =A0 =A0uncharged, but swap-freeing fails due to the other ptes, a=
nd
> =A0 =A0 =A0 =A0the page stays lru-accounted on the memcg it's no longer
> =A0 =A0 =A0 =A0charged to.

I agree that a page could be ending up on a memcg-lru (AcctLRU) but
not charged (!Used). But not sure
if the case above is true or not, since we don't uncharge a page which
marked as SwapCache until the
page is removed from the swapcache.

One case which we might change the owner of a page while it is linked
on lru is calling reuse_swap_page() under write fault, so the page is
uncharged after removing from
swapcache while linked in the old memcg lru. It will be adjust by
commit_charge_swapin() later.

>
> =A0 =A0 =A0 =A03. another memcg faults the page. =A0before_commit must
> =A0 =A0 =A0 =A0lru-unaccount from pc->mem_cgroup before pc->mem_cgroup is
> =A0 =A0 =A0 =A0overwritten.
>
> =A0 =A0 =A0 =A04. the page is charged. =A0after_commit does the fixup.
>
> Between 3. and 4., a reclaimer can isolate the page. =A0The old
> lru-accounting is undone and mem_cgroup_lru_del() does this:
>
> =A0 =A0 =A0 =A0if (TestClearPageCgroupAcctLRU(pc)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0VM_BUG_ON(!pc->mem_cgroup);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem =3D pc->mem_cgroup;
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem =3D root_mem_cgroup;
> =A0 =A0 =A0 mz =3D page_cgroup_zoneinfo(mem, page);
> =A0 =A0 =A0 =A0/* huge page split is done under lru_lock. so, we have no =
races. */
> =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, lru) -=3D 1 << compound_order(page);
>
> The rule is that !PageCgroupAcctLRU means that the page is
> lru-accounted to root_mem_cgroup. =A0So when charging, the page has to
> be moved to root_mem_cgroup until a new memcg is responsible for it.

So here we are saying that isolating a page which has be
mem_cgroup_lru_del().  Isn't the later one does lru-unaccount and also
list_del(), so is that possible to isolate a page not on lru. Or is
this caused by not clearing the LRU bit in before_commit?

>
>> My understanding is that in before_commit, we uncharge the page from
>> previous memcg lru if AcctLRU was set, then in the commit_charge we upda=
te
>> the new owner of it. And in after_commit we update the memcg lru for the=
 new
>> owner after linking the page in the lru.
>
> Exactly, just that between unaccounting from the old and accounting to
> the new, someone else may look at the page and has to find it in a
> sensible state.

Wonder if clearing the PageLRU after before_commit is helpful here.

Thanks

--Ying
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
