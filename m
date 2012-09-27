Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 7D2566B005A
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 07:02:49 -0400 (EDT)
Message-ID: <1348743767.1512.13.camel@x61.thuisdomein>
Subject: [PATCH] mm: frontswap: silence GCC warning
From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 27 Sep 2012 13:02:47 +0200
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Building frontswap.o (which, unsurprisingly, implements frontswap)
triggers this GCC warning:
    mm/frontswap.c: In function 'frontswap_shrink':
    mm/frontswap.c:306:15: warning: 'type' may be used uninitialized in this function [-Wmaybe-uninitialized]

So GCC thinks try_to_unuse() can be called while type is still
uninitialized. That's not correct. That function will actually only be
called if type is set. It seems GCC has trouble in determining that type
must be set if ret is zero and pages_to_unuse is non-zero. But it turns
out that if __frontswap_shrink() returns non-zero in the nothing-to-do
case, GCC can figure that out. So let's do that.

While we're at it, stop setting pages_to_unuse to zero in
__frontswap_shrink(), as that's not needed there.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) I noticed this warning while building v3.6-rc7 on current Fedora
17, using Fedora's default config.

1) Kernel with this patch runs OK. I'm not sure how to actually test for
frontswap specifically. But this patch shouldn't change run time
behavior anyhow. 

2) A nicer patch might be one that stops tracking both 'ret' and
'pages_to_unuse' here and tracks only one of these two values. Eg, I
feel that if 'pages_to_unuse' could be made long we might be able to
clean up the code a little. That is, make some functions return
'pages_to_unuse', where:
    pages_to_unuse <  0: error or nothing to do
                   == 0: unuse all (not actually used here)
                   >  0: unuse that number of pages

 mm/frontswap.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 6b3e71a..739571a 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -273,9 +273,8 @@ static int __frontswap_shrink(unsigned long target_pages,
 
 	total_pages = __frontswap_curr_pages();
 	if (total_pages <= target_pages) {
-		/* Nothing to do */
-		*pages_to_unuse = 0;
-		return 0;
+		/* There's no ENOTHINGTODO, so return something non-zero */
+		return -1;
 	}
 	total_pages_to_unuse = total_pages - target_pages;
 	return __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
