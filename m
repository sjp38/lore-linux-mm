Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1363C6B006C
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 16:39:46 -0400 (EDT)
Received: by pdbfl12 with SMTP id fl12so66265432pdb.9
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 13:39:45 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id wh1si32401764pac.221.2015.03.09.13.39.44
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 13:39:45 -0700 (PDT)
Message-ID: <54FE0510.5020209@akamai.com>
Date: Mon, 09 Mar 2015 16:39:44 -0400
From: Eric B Munson <emunson@akamai.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] Allow compaction of unevictable pages
References: <1425921156-16923-1-git-send-email-emunson@akamai.com> <alpine.DEB.2.10.1503091254380.26686@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503091254380.26686@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 03/09/2015 03:57 PM, David Rientjes wrote:
> On Mon, 9 Mar 2015, Eric B Munson wrote:
> 
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h 
>> index f279d9c..599fb01 100644 --- a/include/linux/mmzone.h +++
>> b/include/linux/mmzone.h @@ -232,8 +232,6 @@ struct lruvec { 
>> #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x2) /* Isolate
>> for asynchronous migration */ #define ISOLATE_ASYNC_MIGRATE
>> ((__force isolate_mode_t)0x4) -/* Isolate unevictable pages */ 
>> -#define ISOLATE_UNEVICTABLE	((__force isolate_mode_t)0x8)
>> 
>> /* LRU Isolation modes. */ typedef unsigned __bitwise__
>> isolate_mode_t; diff --git a/mm/compaction.c b/mm/compaction.c 
>> index 8c0d945..4a8ea87 100644 --- a/mm/compaction.c +++
>> b/mm/compaction.c @@ -872,8 +872,7 @@
>> isolate_migratepages_range(struct compact_control *cc, unsigned
>> long start_pfn, if (!pageblock_pfn_to_page(pfn, block_end_pfn,
>> cc->zone)) continue;
>> 
>> -		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn, -
>> ISOLATE_UNEVICTABLE); +		pfn = isolate_migratepages_block(cc,
>> pfn, block_end_pfn, 0);
>> 
>> /* * In case of fatal failure, release everything that might diff
>> --git a/mm/vmscan.c b/mm/vmscan.c index 5e8eadd..3b2a444 100644 
>> --- a/mm/vmscan.c +++ b/mm/vmscan.c @@ -1234,10 +1234,6 @@ int
>> __isolate_lru_page(struct page *page, isolate_mode_t mode) if
>> (!PageLRU(page)) return ret;
>> 
>> -	/* Compaction should not handle unevictable pages but CMA can
>> do so */ -	if (PageUnevictable(page) && !(mode &
>> ISOLATE_UNEVICTABLE)) -		return ret; - ret = -EBUSY;
>> 
>> /*
> 
> Looks better!
> 
> I think there's one more cleanup we can do now thanks to your
> patch: dropping the isolate_mode_t formal from
> isolate_migratepages_block() entirely since that function can now
> just do
> 
> const isolate_mode_t isolate_mode = (cc->mode == MIGRATE_ASYNC ?
> ISOLATE_ASYNC_MIGRATE : 0);
> 
> since we already pass in the struct compact_control and
> isolate_mode only depends on MIGRATE_ASYNC or not.
> 
> If you'd like to fold that change into this patch because it's
> logically allowed by it, feel free to add my enthusiastic
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Otherwise, I'll just send a change on top of it if you don't have
> time.

I'll V3 out shortly with that change.

Thanks for the review.

Eric
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJU/gUNAAoJELbVsDOpoOa9088P/1/HpbuC/CqmFq4FLTdPpXrt
AfDzzGL2e55dVE18Iqmcw6/LUJNb6gr49KmvlnPpMXVmUGTUhtgCySJqQTWtTcHq
NiXC6TuKYsknD7eYIeaR2M9zTN5Cq9swP01d8nIXCilfNNnK31QzlGrxVS5Vk8+X
OzlBUbdcfsOPaRItqadae0cQ19eNTtq33v9msRAwiovuyIL5LkNN1savq1sJVz7B
W9LFwhmUOrKYtxf8AlrSQ0Kg/X5YOskpaTQoPif0BoRkvNsAtE9sWDlzg4a24pn5
HGrlWcjJLsw4ZhEwfUnX1w5m2C2NhEbwKJ08eqyPF5kNavdzDqx+TsZ79ZYYMEVL
bYJcRZ0+Oef/u5ICpJrvlS2FdDqweAKuvT1bUcXoUZQfxxHi5gujp+4vfBZk3ct0
mnpbEcUAq5btck99p9PcAE6C3+T+NKjX+R7mVkOwbhFRpzrV1YMqreb7bcGutzhB
00QhNciI5izfJZIdasq783T7XFyd7oO1gl0MNf/lI1v0dklSr92j4WF7d6rbGX4h
Nnnbt4If1qP/F0n/NjRprHJg1muUZW2J8GBCq11cWnWXkl4y7S208MbyIewf1iVy
yl+ko2nFTbyDMYG46wsCoxqxmuWtUap+oanvF4NXbQ47wQO8hI8vjN9ph1MACxJP
l1pRsS0/XBUIBhnVYQMG
=suBI
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
