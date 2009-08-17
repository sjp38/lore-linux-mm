Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2468B6B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 10:33:55 -0400 (EDT)
Received: by gxk12 with SMTP id 12so4128921gxk.4
        for <linux-mm@kvack.org>; Mon, 17 Aug 2009 07:33:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090816112910.GA3208@localhost>
References: <20090806100824.GO23385@random.random>
	 <20090806102057.GQ23385@random.random>
	 <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com>
	 <20090806130631.GB6162@localhost>
	 <20090806210955.GA14201@c2.user-mode-linux.org>
	 <20090816031827.GA6888@localhost> <4A87829C.4090908@redhat.com>
	 <20090816051502.GB13740@localhost> <20090816112910.GA3208@localhost>
Date: Mon, 17 Aug 2009 23:33:54 +0900
Message-ID: <28c262360908170733q4bc5ddb8ob2fc976b6a468d6e@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Jeff Dike <jdike@addtoit.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Wu.

On Sun, Aug 16, 2009 at 8:29 PM, Wu Fengguang<fengguang.wu@intel.com> wrote=
:
> On Sun, Aug 16, 2009 at 01:15:02PM +0800, Wu Fengguang wrote:
>> On Sun, Aug 16, 2009 at 11:53:00AM +0800, Rik van Riel wrote:
>> > Wu Fengguang wrote:
>> > > On Fri, Aug 07, 2009 at 05:09:55AM +0800, Jeff Dike wrote:
>> > >> Side question -
>> > >> =C2=A0Is there a good reason for this to be in shrink_active_list()
>> > >> as opposed to __isolate_lru_page?
>> > >>
>> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!page_evictable(page=
, NULL))) {
>> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0putba=
ck_lru_page(page);
>> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0conti=
nue;
>> > >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > >>
>> > >> Maybe we want to minimize the amount of code under the lru lock or
>> > >> avoid duplicate logic in the isolate_page functions.
>> > >
>> > > I guess the quick test means to avoid the expensive page_referenced(=
)
>> > > call that follows it. But that should be mostly one shot cost - the
>> > > unevictable pages are unlikely to cycle in active/inactive list agai=
n
>> > > and again.
>> >
>> > Please read what putback_lru_page does.
>> >
>> > It moves the page onto the unevictable list, so that
>> > it will not end up in this scan again.
>>
>> Yes it does. I said 'mostly' because there is a small hole that an
>> unevictable page may be scanned but still not moved to unevictable
>> list: when a page is mapped in two places, the first pte has the
>> referenced bit set, the _second_ VMA has VM_LOCKED bit set, then
>> page_referenced() will return 1 and shrink_page_list() will move it
>> into active list instead of unevictable list. Shall we fix this rare
>> case?

I think it's not a big deal.

As you mentioned, it's rare case so there would be few pages in active
list instead of unevictable list.
When next time to scan comes, we can try to move the pages into
unevictable list, again.

As I know about mlock pages, we already had some races condition.
They will be rescued like above.

>
> How about this fix?
>
> ---
> mm: stop circulating of referenced mlocked pages
>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>
> --- linux.orig/mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A02009-08-16 19:11:13.0=
00000000 +0800
> +++ linux/mm/rmap.c =C2=A0 =C2=A0 2009-08-16 19:22:46.000000000 +0800
> @@ -358,6 +358,7 @@ static int page_referenced_one(struct pa
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vma->vm_flags & VM_LOCKED) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*mapcount =3D 1; =
=C2=A0/* break early from loop */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *vm_flags |=3D VM_LOCK=
ED;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_unmap;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> @@ -482,6 +483,8 @@ static int page_referenced_file(struct p
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&mapping->i_mmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 if (*vm_flags & VM_LOCKED)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 referenced =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return referenced;
> =C2=A0}
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
