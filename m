Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B147D6B0035
	for <linux-mm@kvack.org>; Sat, 23 Nov 2013 15:29:37 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hm6so2879078wib.2
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:29:37 -0800 (PST)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id fy4si1417676wjc.33.2013.11.23.12.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Nov 2013 12:29:36 -0800 (PST)
Received: by mail-wg0-f53.google.com with SMTP id b13so2441790wgh.20
        for <linux-mm@kvack.org>; Sat, 23 Nov 2013 12:29:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfPExH3igteHko_iVxpG59wM+Xh0F-U1LWwZo0An0eMcGw@mail.gmail.com>
References: <1385158254-6304-1-git-send-email-ddstreet@ieee.org> <CAL1ERfPExH3igteHko_iVxpG59wM+Xh0F-U1LWwZo0An0eMcGw@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Sat, 23 Nov 2013 15:29:16 -0500
Message-ID: <CALZtONDZdjsnYNGA2gC4pw5BfS+r2zm+bJzv8G9bBTOuquLHWw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: reverse zswap_entry tree/refcount relationship
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Fri, Nov 22, 2013 at 9:23 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> Hello Dan,
>
> On Sat, Nov 23, 2013 at 6:10 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>> Currently, zswap_entry_put removes the entry from its tree if
>> the resulting refcount is 0.  Several places in code put an
>> entry's initial reference, but they also must remove the entry
>> from its tree first, which makes the tree removal in zswap_entry_put
>> redundant.
>>
>> I believe this has the refcount model backwards - the initial
>> refcount reference shouldn't be managed by multiple different places
>> in code, and the put function shouldn't be removing the entry
>> from the tree.  I think the correct model is for the tree to be
>> the owner of the initial entry reference.  This way, the only time
>> any code needs to put the entry is if it's also done a get previously.
>> The various places in code that remove the entry from the tree simply
>> do that, and the zswap_rb_erase function does the put of the initial
>> reference.
>>
>> This patch moves the initial referencing completely into the tree
>> functions - zswap_rb_insert gets the entry, while zswap_rb_erase
>> puts the entry.  The zswap_entry_get/put functions are still available
>> for any code that needs to use an entry outside of the tree lock.
>> Also, the zswap_entry_find_get function is renamed to zswap_rb_search_get
>> since the function behavior and return value is closer to zswap_rb_search
>> than zswap_entry_get.  All code that previously removed the entry from
>> the tree and put it now only remove the entry from the tree.
>>
>> The comment headers for most of the tree insert/search/erase functions
>> and the get/put functions are updated to clarify if the tree lock
>> needs to be held as well as when the caller needs to get/put an
>> entry (i.e. iff the caller is using the entry outside the tree lock).
>
> I do not like this patch idea, It breaks the zswap_rb_xxx() purity.
> I think zswap_rb_xxx() should only focus on rbtree operations.
>
> The current code might be redundant, but its logic is clear.
> So it is not essential need to be changed.

It makes absolutely no sense to include zswap_rb_erase() inside
zswap_entry_put() when it's clear that the entry will *never* (with
the writethrough patch) be on the rb tree when the final refcount is
put.

It does make sense, IMHO, for the tree to manage the initial refcount.

Alternately, if everyone agrees with you that the tree insert/remove
shouldn't manage the initial entry refcount, then it seems to me that
the zswap_rb_erase() call should be removed from zswap_entry_put() and
all places in the code that call zswap_rb_erase() need to also call
zswap_entry_put() for the initial refcount (which they already do).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
