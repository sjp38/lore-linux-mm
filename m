Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A617B6B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:28:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so1351365edr.4
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 14:28:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i6-v6si1014704edf.73.2018.07.26.14.28.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 14:28:55 -0700 (PDT)
Subject: Re: freepage accounting bug with CMA/migrate isolation
References: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
 <efc17c04-8498-29c8-56bb-9cbad897f0d8@suse.cz>
 <fb90a412-ead7-0ada-c443-2bd1c41f2614@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <78329b64-0101-e1bd-1f7a-5194c56053b1@suse.cz>
Date: Thu, 26 Jul 2018 23:26:33 +0200
MIME-Version: 1.0
In-Reply-To: <fb90a412-ead7-0ada-c443-2bd1c41f2614@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>

On 07/26/2018 06:50 PM, Mike Kravetz wrote:
> On 07/26/2018 05:28 AM, Vlastimil Babka wrote:
>>> Just looking for suggesting in where/how to debug.  I've been hacking on
>>> this without much success.
> 
> As mentioned in my reply to Laura, I noticed that move_freepages_block()
> can move more than a pageblock of pages.  This is the case where page_order
> of the (first) free page is > pageblock_order.  Should only happen in the
> set_migratetype_isolate case as unset has that check you added.  Thi

Hmm not sure which "check I added" you mean, in
unset_migratetype_isolate() ?

> generally 'works' as alloc_contig_range rounds up to MAX_ORDER(-1).  So,
> set and unset migrate isolate tend to balance out.  But, I am wondering
> if there might be some kind of race where someone could mess with those
> pageblocks (and freepage counts) while we drop the zone lock.  Trying to

Yeah see my other mail for such race when we drop the zone lock in
unset_migratetype_isolate(). set_migratetype_isolate() would also have
this problem (which would result in *less* freepages counted), but if we
move MAX_ORDER-1 pages to MIGRATE_ISOLATE freelist, then nobody can mess
with them while the zone is locked, as they are isolated.
unset_migratetype_isolate() has no such luck.

> put together a quick hack to test this theory, but it is more complicated
> that first thought. :)
> 
