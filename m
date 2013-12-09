Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id E387C6B0083
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 06:19:16 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so2444757yho.24
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 03:19:16 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id p5si9817452yho.134.2013.12.09.03.19.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 03:19:13 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id y10so5066702pdj.37
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 03:19:12 -0800 (PST)
Message-ID: <52A5A7B5.2040904@gmail.com>
Date: Mon, 09 Dec 2013 19:21:25 +0800
From: Chen Gang <gang.chen.5i5j@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in zswap_writeback_entry()
References: <52A53024.9090701@gmail.com> <52A5935A.4040709@imgtec.com> <52A5973A.7020509@gmail.com> <52A5990E.2080808@imgtec.com>
In-Reply-To: <52A5990E.2080808@imgtec.com>
Content-Type: multipart/mixed;
 boundary="------------090306010206020002090309"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------090306010206020002090309
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 12/09/2013 06:18 PM, James Hogan wrote:
> On 09/12/13 10:11, Chen Gang wrote:
>>> Since the metag compiler is stuck on an old version (gcc 4.2.4), which
>>> is wrong to warn in this case, and newer versions of gcc don't appear to
>>> warn about it anyway (I just checked with gcc 4.7.2 x86_64), I have no
>>> objection to this warning remaining in the metag build.
>>>
>>
>> Do you try "EXTRA_CFLAGS=-W" with gcc 4.7.2? I guess it will report the
>> warning too, I don't feel the compiler is smart enough (except it lets
>> the long function zswap_get_swap_cache_page really inline)  :-)
> 
> EXTRA_CFLAGS=-W on gcc 4.7.2 gives me plenty of pointless unused
> parameter warnings when compiling mm/zswap.o, but not the warning you're
> trying to silence.
> 

Yeah, it will generate plenty of pointless warnings, although we still
can often find valuable bugs in these warnings.

Oh, I tried gcc 4.6.3-2 rhel version, get the same result as yours (do
not report warning), but for me, it is still a compiler's bug, it
*should* report a warning for it, we can try below:

 - modify zswap_get_swap_cache_page() to let it may return another value
   (one sample modification is in attachment)

 - compile again, it doesn't report related warning, either

 - in this case, it *should* report related warning.

Could you help to try it under gcc 4.7.2, thanks?


BTW: gcc really exists some bugs about uninitialized variable, e.g.

  one known bug: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=18501
  kernel related: http://gcc.gnu.org/bugzilla/show_bug.cgi?id=57856


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water and life which God blessed

--------------090306010206020002090309
Content-Type: text/x-patch;
 name="diff.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="diff.patch"

diff --git a/mm/zswap.c b/mm/zswap.c
index 5a63f78..1853ef4 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -469,8 +469,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 		 */
 		err = radix_tree_preload(GFP_KERNEL);
 		if (err)
-			break;
-
+			return -4;
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */

--------------090306010206020002090309--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
