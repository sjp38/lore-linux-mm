Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A80F16B0714
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 12:59:35 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f69-v6so2004075pfa.15
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 09:59:35 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id v14-v6si7330675pgi.5.2018.11.09.09.59.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 09:59:34 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 09 Nov 2018 09:59:33 -0800
From: isaacm@codeaurora.org
Subject: Potentially Incorrect Wraparound Check in mm/usercopy.c
Message-ID: <1ec2adea9665ea1a7e2fcbad029bc678@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org
Cc: linux-mm@kvack.org, psodagud@codeaurora.org, tsoni@codeaurora.org

Hi Kees,

We are seeing the following message and kernel BUG on the 4.14.76 
kernel:
[   16.094139] usercopy: kernel memory overwrite attempt detected to 
fffffffffffff000 (<wrapped address>) (4096 bytes)
[   16.140498] kernel BUG at 
/local/mnt/workspace/isaacm/hana_workspace/kdev/kernel/mm/usercopy.c:72!

This occurs when a thread tries to write 4 KB to one page, and the 
virtual address for that page--which was acquired via a call to 
kmap_atomic()--is 0xfffffffffffff000. Before doing the write, we call 
check_copy_size(0xfffffffffffff000, SZ_4K, false). It seems like we are 
seeing this issue because of the first check in check_bogus_address(), 
which checks to see if reading the 4 KB will cause wraparound. With the 
following change, we no longer see this issue:

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 852eb4e..0293645 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -151,7 +151,7 @@ static inline void check_bogus_address(const 
unsigned long ptr, unsigned long n,
                                        bool to_user)
  {
         /* Reject if object wraps past end of memory. */
-       if (ptr + n < ptr)
+       if (ptr + (n - 1) < ptr)
                 usercopy_abort("wrapped address", NULL, to_user, 0, ptr 
+ n);

         /* Reject if NULL or ZERO-allocation. */

Is there a reason why this change to that check would not be valid? If 
we are checking to see if reading n bytes, starting at ptr, will cause a 
wraparound, then shouldn't we be checking to ensure that the range of 
memory that will actually be read from won't cause a wraparound, since 
we would only be accessing [ptr, ptr + (n - 1)], and not ptr + n?

Thanks,
Isaac Manjarres
