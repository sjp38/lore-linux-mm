Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AFE526B01F7
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 03:40:14 -0400 (EDT)
Received: by yxe39 with SMTP id 39so103262yxe.12
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 00:40:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	 <20100412164335.GQ25756@csn.ul.ie>
	 <i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com>
	 <20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com>
	 <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
Date: Tue, 13 Apr 2010 16:40:09 +0900
Message-ID: <l2r28c262361004130040ydff92adfzfba4d678931b3257@mail.gmail.com>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 4:09 PM, Bob Liu <lliubbo@gmail.com> wrote:
> On 4/13/10, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> On Tue, 13 Apr 2010 13:34:52 +0900
>>
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>>
>> > On Tue, Apr 13, 2010 at 1:43 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> =C2=A0> > On Sat, Apr 10, 2010 at 07:49:32PM +0800, Bob Liu wrote:
>> =C2=A0> >> Since alloc_pages_exact_node() is not for allocate page from
>> =C2=A0> >> exact node but just for removing check of node's valid,
>> =C2=A0> >> rename it to alloc_pages_from_valid_node(). Else will make
>> =C2=A0> >> people misunderstanding.
>> =C2=A0> >>
>> =C2=A0> >
>> =C2=A0> > I don't know about this change either but as I introduced the =
original
>> =C2=A0> > function name, I am biased. My reading of it is - allocate me =
pages and
>> =C2=A0> > I know exactly which node I need. I see how it it could be rea=
d as
>> =C2=A0> > "allocate me pages from exactly this node" but I don't feel th=
e new
>> =C2=A0> > naming is that much clearer either.
>> =C2=A0>
>> =C2=A0> Tend to agree.
>> =C2=A0> Then, don't change function name but add some comment?
>> =C2=A0>
>> =C2=A0> /*
>> =C2=A0> =C2=A0* allow pages from fallback if page allocator can't find f=
ree page in your nid.
>> =C2=A0> =C2=A0* If you want to allocate page from exact node, please use
>> =C2=A0> __GFP_THISNODE flags with
>> =C2=A0> =C2=A0* gfp_mask.
>> =C2=A0> =C2=A0*/
>> =C2=A0> static inline struct page *alloc_pages_exact_node(....
>> =C2=A0>
>>
>> I vote for this rather than renaming.
>>
>> =C2=A0There are two functions
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 allo_pages_node()
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_pages_exact_node().
>>
>> =C2=A0Sane progmrammers tend to see implementation details if there are =
2
>> =C2=A0similar functions.
>>
>> =C2=A0If I name the function,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_pages_node_verify_nid() ?
>>
>> =C2=A0I think /* This doesn't support nid=3D-1, automatic behavior. */ i=
s necessary
>> =C2=A0as comment.
>>
>> =C2=A0OFF_TOPIC
>>
>> =C2=A0If you want renaming, =C2=A0I think we should define NID=3D-1 as
>>
>> =C2=A0#define ARBITRARY_NID =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (-1) or
>> =C2=A0#define CURRENT_NID =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (-1)=
 or
>> =C2=A0#define AUTO_NID =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0(-1)
>>
>> =C2=A0or some. Then, we'll have concensus of NID=3D-1 support.
>> =C2=A0(Maybe some amount of programmers don't know what NID=3D-1 means.)
>>
>> =C2=A0The function will be
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_pages_node_no_auto_nid() /* AUTO_NID i=
s not supported by this */
>> =C2=A0or
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 alloc_pages_node_veryfy_nid()
>>
>> =C2=A0Maybe patch will be bigger and may fail after discussion. But it s=
eems
>> =C2=A0worth to try.
>>
>
> Hm..It's a bit bigger.
> Actually, what I want to do was in my original mail several days ago,
> the title is "mempolicy:add GFP_THISNODE when allocing new page"
>
> What I concern is *just* we shouldn't fallback to other nodes if the
> dest node haven't enough free pages during migrate_pages().
>
> The detail is below:
> In funtion migrate_pages(), if the dest node have no
> enough free pages,it will fallback to other nodes.
> Add GFP_THISNODE to avoid this, the same as what
> funtion new_page_node() do in migrate.c.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Long time ago, I already reviewed this patch with Bob. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
