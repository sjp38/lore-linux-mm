Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAFE6B0005
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 07:56:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w42-v6so11969846edd.0
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:56:16 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0115.outbound.protection.outlook.com. [104.47.0.115])
        by mx.google.com with ESMTPS id j26-v6si4888143ejt.47.2018.10.15.04.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 04:56:13 -0700 (PDT)
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [PATCH RFC v2] ksm: Assist buddy allocator to assemble 1-order
 pages
Date: Mon, 15 Oct 2018 11:56:08 +0000
Message-ID: <a566060a-b14e-b495-85bc-992e9b7bbf80@virtuozzo.com>
References: 
 <153959597844.26723.5798112367236156151.stgit@localhost.localdomain>
 <20181015123854.5a22846d@p-imbrenda.boeblingen.de.ibm.com>
In-Reply-To: <20181015123854.5a22846d@p-imbrenda.boeblingen.de.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-ID: <81E0A1E0B2DD3E4084851879FF1A7DC6@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.ibm.com>
Cc: "hughd@google.com" <hughd@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "andriy.shevchenko@linux.intel.com" <andriy.shevchenko@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "imbrenda@linux.vnet.ibm.com" <imbrenda@linux.vnet.ibm.com>, "corbet@lwn.net" <corbet@lwn.net>, "ndesaulniers@google.com" <ndesaulniers@google.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "jia.he@hxt-semitech.com" <jia.he@hxt-semitech.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "colin.king@canonical.com" <colin.king@canonical.com>, "jiang.biao2@zte.com.cn" <jiang.biao2@zte.com.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 15.10.2018 13:38, Claudio Imbrenda wrote:
> I don't have objections to this patch, but I wonder how much impact it
> would have. Have you performed any tests? does it really have such a big
> impact on the availability of order-1 page blocks?=20

I have no synthetic tests on compaction, so this patch is RFC. Maybe you
suggest something? In my test machine I added debug patch on top of this,
which adds a counter of such tree_page preferred pages, and the counter
increments as well. Order-1 page is just a brick of a bigger order pages,
so this patch cares about them.

>=20
> On Mon, 15 Oct 2018 12:33:36 +0300
> Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>=20
>> v2: Style improvements
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
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  mm/ksm.c |   16 ++++++++++++++++
>>  1 file changed, 16 insertions(+)
>>
>> diff --git a/mm/ksm.c b/mm/ksm.c
>> index 5b0894b45ee5..005508c86d0a 100644
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -1321,6 +1321,22 @@ static struct page
>> *try_to_merge_two_pages(struct rmap_item *rmap_item, {
>>  	int err;
>>
>> +	if (IS_ENABLED(CONFIG_COMPACTION)) {
>> +		unsigned long pfn;
>> +
>> +		/*
>> +		 * Find neighbour of @page containing 1-order pair
>> +		 * in buddy-allocator and check whether it is free.
>> +		 * If it is so, try to use @tree_page as ksm page
>> +		 * and to free @page.
>> +		 */
>> +		pfn =3D page_to_pfn(page) ^ 1;
>> +		if (pfn_valid(pfn) && page_count(pfn_to_page(pfn))
>> =3D=3D 0) {
>> +			swap(rmap_item, tree_rmap_item);
>> +			swap(page, tree_page);
>> +		}
>> +	}
>> +
>>  	err =3D try_to_merge_with_ksm_page(rmap_item, page, NULL);
>>  	if (!err) {
>>  		err =3D try_to_merge_with_ksm_page(tree_rmap_item,
>>
>=20
