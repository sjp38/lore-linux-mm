Subject: [PATCH] Mempolicy:  fix mpol_to_str() to handle ignore mode flags
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 17 Apr 2008 14:20:27 -0400
Message-Id: <1208456427.5292.16.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-numa <linux-numa@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Against: 2.6.25-rc8-mm1

Fixes problem introduced by my previous patch:
  mempolicy-use-mpol_f_local-to-indicate-preferred-local-policy.patch

Eliminate display of bogus '=' flag indicator in presence of
internal mode flags.

Without this fix, on 25-rc8-mm1, a display of a process' numa_maps
will show, e.g., default policy as "default=".  Worse, if the maps
include longer policies, such as "interleave:0-3", this problem will
lose the string terminator after the "<mode>=" and display subsequent
default policies as "default=ve:0-3".

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.25-rc8-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc8-mm2.orig/mm/mempolicy.c	2008-04-16 12:27:54.000000000 -0400
+++ linux-2.6.25-rc8-mm2/mm/mempolicy.c	2008-04-17 11:43:10.000000000 -0400
@@ -2149,7 +2149,7 @@ int mpol_to_str(char *buffer, int maxlen
 	strcpy(p, policy_types[mode]);
 	p += l;
 
-	if (flags) {
+	if (flags & MPOL_MODE_FLAGS) {
 		if (buffer + maxlen < p + 2)
 			return -ENOSPC;
 		*p++ = '=';


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
