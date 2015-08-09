Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id A3E746B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 08:17:48 -0400 (EDT)
Received: by oiev193 with SMTP id v193so45314032oie.3
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 05:17:48 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id wx3si12077161oeb.11.2015.08.09.05.17.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Aug 2015 05:17:47 -0700 (PDT)
From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFC PATCH] percpu: Prevent endless loop if there is no unallocated region
Date: Sun,  9 Aug 2015 05:17:39 -0700
Message-Id: <1439122659-31442-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>

Qemu tests with unicore32 show memory management code entering an endless
loop in pcpu_alloc(). Bisect points to commit a93ace487a33 ("percpu: move
region iterations out of pcpu_[de]populate_chunk()"). Code analysis
identifies the following relevant changes.

-       rs = page_start;
-       pcpu_next_pop(chunk, &rs, &re, page_end);
-
-       if (rs != page_start || re != page_end) {
+       pcpu_for_each_unpop_region(chunk, rs, re, page_start, page_end) {

For unicore32, values were page_start==0, page_end==1, rs==0, re==1.
This worked fine with the old code. With the new code, however, the loop
is always entered. Debugging information added into the loop shows
an endless repetition of

in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1

To make matters worse, the identified memory chunk is immutable,
resulting in endless "WARNING: CPU: 0 PID: 0 at mm/percpu.c:1004
pcpu_alloc+0x56c/0x5d4()" messages.

It appears that pcpu_for_each_unpop_region() always loops at least
once even if there is no unpopulated region, since the result of
find_next_zero_bit() points to the end of the range if there is no zero
bit available.

One could think that something is wrong with the unicore32 code, but a
comment above pcpu_for_each_unpop_region() states "populate if not all
pages are already there", suggesting that the situation is valid.

An additional range check in pcpu_for_each_unpop_region() fixes the
observed problem.

Fixes: a93ace487a33 ("percpu: move region iterations out of pcpu_[de]populate_chunk()")
Cc: Tejun Heo <tj@kernel.org>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Tested potential impact on other architectures with more than 60 qemu
configurations. All work fine. Still, not sure if this is the correct
fix, and/or if there is something wrong with the calling code, so
marking it as RFC.

 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 2dd74487a0af..18b239c33c12 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -269,7 +269,7 @@ static void __maybe_unused pcpu_next_pop(struct pcpu_chunk *chunk,
  */
 #define pcpu_for_each_unpop_region(chunk, rs, re, start, end)		    \
 	for ((rs) = (start), pcpu_next_unpop((chunk), &(rs), &(re), (end)); \
-	     (rs) < (re);						    \
+	     (rs) < (re) && (rs) < (end);				    \
 	     (rs) = (re) + 1, pcpu_next_unpop((chunk), &(rs), &(re), (end)))
 
 #define pcpu_for_each_pop_region(chunk, rs, re, start, end)		    \
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
