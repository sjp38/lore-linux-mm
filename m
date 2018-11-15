Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B38A76B0341
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 09:12:38 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id g6-v6so885444iom.7
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 06:12:38 -0800 (PST)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80137.outbound.protection.outlook.com. [40.107.8.137])
        by mx.google.com with ESMTPS id p5-v6si19894027jaa.58.2018.11.15.06.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Nov 2018 06:12:37 -0800 (PST)
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [PATCH v3] ksm: Assist buddy allocator to assemble 1-order pages
Date: Thu, 15 Nov 2018 14:12:34 +0000
Message-ID: <0ac6ace8-1e0a-7013-7b1f-2dbe0f35f34f@virtuozzo.com>
References: 
 <153995241537.4096.15189862239521235797.stgit@localhost.localdomain>
 <20181109130857.54a1f383629e771b4f3888c4@linux-foundation.org>
In-Reply-To: <20181109130857.54a1f383629e771b4f3888c4@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-ID: <F07B702676D4814DBE08A2199BD6708C@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "hughd@google.com" <hughd@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "andriy.shevchenko@linux.intel.com" <andriy.shevchenko@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "imbrenda@linux.vnet.ibm.com" <imbrenda@linux.vnet.ibm.com>, "corbet@lwn.net" <corbet@lwn.net>, "ndesaulniers@google.com" <ndesaulniers@google.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "jia.he@hxt-semitech.com" <jia.he@hxt-semitech.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "colin.king@canonical.com" <colin.king@canonical.com>, "jiang.biao2@zte.com.cn" <jiang.biao2@zte.com.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 10.11.2018 0:08, Andrew Morton wrote:
> On Fri, 19 Oct 2018 15:33:39 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wr=
ote:
>=20
>> v3: Comment improvements.
>> v2: Style improvements.
>>
>> try_to_merge_two_pages() merges two pages, one of them
>> is a page of currently scanned mm, the second is a page
>> with identical hash from unstable tree. Currently, we
>> merge the page from unstable tree into the first one,
>> and then free it.
>>
>> The idea of this patch is to prefer freeing that page
>> of them, which has a free neighbour (i.e., neighbour
>> with zero page_count()). This allows buddy allocator
>> to assemble at least 1-order set from the freed page
>> and its neighbour; this is a kind of cheep passive
>> compaction.
>>
>> AFAIK, 1-order pages set consists of pages with PFNs
>> [2n, 2n+1] (odd, even), so the neighbour's pfn is
>> calculated via XOR with 1. We check the result pfn
>> is valid and its page_count(), and prefer merging
>> into @tree_page if neighbour's usage count is zero.
>>
>> There a is small difference with current behavior
>> in case of error path. In case of the second
>> try_to_merge_with_ksm_page() is failed, we return
>> from try_to_merge_two_pages() with @tree_page
>> removed from unstable tree. It does not seem to matter,
>> but if we do not want a change at all, it's not
>> a problem to move remove_rmap_item_from_tree() from
>> try_to_merge_with_ksm_page() to its callers.
>>
>=20
> Seems sensible.
>=20
>>
>> ...
>>
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -1321,6 +1321,23 @@ static struct page *try_to_merge_two_pages(struct=
 rmap_item *rmap_item,
>>  {
>>  	int err;
>> =20
>> +	if (IS_ENABLED(CONFIG_COMPACTION)) {
>> +		unsigned long pfn;
>> +
>> +		/*
>> +		 * Find neighbour of @page containing 1-order pair in buddy
>> +		 * allocator and check whether its count is 0. If so, we
>> +		 * consider the neighbour as a free page (this is more
>> +		 * probable than it's freezed via page_ref_freeze()), and
>> +		 * we try to use @tree_page as ksm page and to free @page.
>> +		 */
>> +		pfn =3D page_to_pfn(page) ^ 1;
>> +		if (pfn_valid(pfn) && page_count(pfn_to_page(pfn)) =3D=3D 0) {
>> +			swap(rmap_item, tree_rmap_item);
>> +			swap(page, tree_page);
>> +		}
>> +	}
>> +
>=20
> A few thoughts
>=20
> - if tree_page's neighbor is unused, there was no point in doing this
>   swapping?

You are sure, and this is the thing I analyzed from several ways before
the submitting. There is no point for doing this swapping, but there is
no point for not doing it too. Both of this approach are almost equal
each other, while the "doing swapping" approach just adds less code.
This is the only reason I prefered it.

> - if both *page and *tree_page have unused neighbors we could go
>   further and look for an opportunity to create an order-2 page.=20
>   etcetera.  This may b excessive ;)

We may do that, there are just less probability to meet a page with
3 free neighbors, than with 1 free neighbor. But we can.

> - are we really sure that this optimization causes desirable results?
>   If we always merge from one tree into the other, we maximise the
>   opportunities for page coalescing in the long term.  But if we
>   sometimes merge one way and sometimes merge the other way, we might
>   end up with less higher-order page coalescing?  Or am I confusing
>   myself?

Just the previous version was RFC, so I'm not 100% sure :) I asked for
compaction tests in reply to v2, but it looks like we don't have them.
I tested this by adding a counter of swapped pages on top of this patch.
The counter grows (though, not so fast as I expected this before).

It's difficult to rate the long term coalescing, since there are many
players, which may introduce external influence, or make page disappear
from process (shrinker, parallel compaction, COW on ksm-ed page, thp).
This all is not completely deterministic, there are too many input
parameters. There is a question whether short term compaction or long
term compaction is more important. I have no answer on this...

Kirill
