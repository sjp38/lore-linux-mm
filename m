Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EAE9A6B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 01:06:46 -0400 (EDT)
Received: by pwi2 with SMTP id 2so3403098pwi.14
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 22:06:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <l2rcf18f8341004052156n23c77078va3370beb72f33c51@mail.gmail.com>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
	 <k2m28c262361004052133jfc62525bw3cd570765d160876@mail.gmail.com>
	 <l2rcf18f8341004052156n23c77078va3370beb72f33c51@mail.gmail.com>
Date: Tue, 6 Apr 2010 14:06:45 +0900
Message-ID: <p2t28c262361004052206me05462c2saf2e3afc82524123@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 6, 2010 at 1:56 PM, Bob Liu <lliubbo@gmail.com> wrote:
> On 4/6/10, Minchan Kim <minchan.kim@gmail.com> wrote:
>> On Tue, Apr 6, 2010 at 11:59 AM, Bob Liu <lliubbo@gmail.com> wrote:
>>> In funtion migrate_pages(), if the dest node have no
>>> enough free pages,it will fallback to other nodes.
>>> Add GFP_THISNODE to avoid this, the same as what
>>> funtion new_page_node() do in migrate.c.
>>>
>>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>>
>> Yes. It can be fixed. but I have a different concern.
>>
>> I looked at 6484eb3e2a81807722c5f28ef.
>> " =C2=A0 page allocator: do not check NUMA node ID when the caller knows
>> the node is valid
>>
>> =C2=A0 =C2=A0Callers of alloc_pages_node() can optionally specify -1 as =
a node to mean
>> =C2=A0 =C2=A0"allocate from the current node". =C2=A0However, a number o=
f the callers in
>> =C2=A0 =C2=A0fast paths know for a fact their node is valid. =C2=A0To av=
oid a comparison
>> and
>> =C2=A0 =C2=A0branch, this patch adds alloc_pages_exact_node() that only =
checks the nid
>> =C2=A0 =C2=A0with VM_BUG_ON(). =C2=A0Callers that know their node is val=
id are then
>> =C2=A0 =C2=A0converted."
>>
>> alloc_pages_exact_node's naming would be not good.
>> It is not for allocate page from exact node but just for
>> removing check of node's valid.
>> Some people like me who is poor english could misunderstood it.
>>
>> How about changing name with following?
>> /* This function can allocate page to fallback list of node*/
>> alloc_pages_by_nodeid(...)
>>
>> And instead of it, let's change alloc_pages_exact_node with following.
>> static inline struct page *alloc_pages_exact_node(...)
>> {
>> =C2=A0VM_BUG_ON ..
>> =C2=A0return __alloc_pages(gfp_mask|__GFP_THISNODE...);
>> }
>>
>> I think it's more clear than old.
>> What do you think about it?
>>
> Hm.. I agree with you, I was also misunderstanding by the name.
> But let's still waiting for some other reply.
>
> By the way, what about your opinion using GFP_THISNODE or
> __GFP_THISNODE in __alloc_pages().
> I think GFP_THISNODE is ok.
>

Yes. It would be good except alloc_fresh_huge_page_node.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
