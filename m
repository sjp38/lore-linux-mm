Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A46A6B0047
	for <linux-mm@kvack.org>; Sun, 10 May 2009 05:04:59 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1188641yxh.26
        for <linux-mm@kvack.org>; Sun, 10 May 2009 02:05:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	 <20090501123541.7983a8ae.akpm@linux-foundation.org>
	 <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>
	 <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org>
	 <20090507134410.0618b308.akpm@linux-foundation.org>
	 <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
Date: Sun, 10 May 2009 17:59:17 +0900
Message-ID: <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, peterz@infradead.org, riel@redhat.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

2009/5/9 Alan Cox <alan@lxorguk.ukuu.org.uk>:
>> The patch seems reasonable but the changelog and the (non-existent)
>> design documentation could do with a touch-up.
>
> Is it right that I as a user can do things like mmap my database
> PROT_EXEC to get better database numbers by making other
> stuff swap first ?
>
> You seem to be giving everyone a "nice my process up" hack.

How about this?
if priority < DEF_PRIORITY-2, aggressive lumpy reclaim in
shrink_inactive_list() already
reclaim the active page forcely.
then, this patch don't change kernel reclaim policy.

anyway, user process non-changable preventing "nice my process up
hack" seems makes sense to me.

test result:

echo 100 > /proc/sys/vm/dirty_ratio
echo 100 > /proc/sys/vm/dirty_background_ratio
run modified qsbench (use mmap(PROT_EXEC) instead malloc)

           active2active vs active2inactive ratio
before    5:5
after       1:9

please don't ask performance number. I haven't reproduce Wu's patch
improvemnt ;)

Wu, What do you think?

---
 mm/vmscan.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2009-05-10 02:40:01.000000000 +0900
+++ b/mm/vmscan.c	2009-05-10 03:33:30.000000000 +0900
@@ -1275,7 +1275,8 @@ static void shrink_active_list(unsigned
 			struct address_space *mapping = page_mapping(page);

 			pgmoved++;
-			if (mapping && test_bit(AS_EXEC, &mapping->flags)) {
+			if (mapping && (priority >= DEF_PRIORITY - 2) &&
+			    test_bit(AS_EXEC, &mapping->flags)) {
 				pga2a++;
 				list_add(&page->lru, &l_active);
 				continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
