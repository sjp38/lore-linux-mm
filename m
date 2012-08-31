Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6F2F56B0069
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 04:00:24 -0400 (EDT)
Message-ID: <50406F60.5040707@intel.com>
Date: Fri, 31 Aug 2012 11:01:36 +0300
From: Adrian Hunter <adrian.hunter@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 07/12] rbtree: adjust root color in rb_insert_color()
 only when necessary
References: <1342139517-3451-1-git-send-email-walken@google.com> <1342139517-3451-8-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-8-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, acme@redhat.com

On 13/07/12 03:31, Michel Lespinasse wrote:
> The root node of an rbtree must always be black. However, rb_insert_color()
> only needs to maintain this invariant when it has been broken - that is,
> when it exits the loop due to the current (red) node being the root.
> In all other cases (exiting after tree rotations, or exiting due to
> an existing black parent) the invariant is already satisfied, so there
> is no need to adjust the root node color.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  lib/rbtree.c |   19 +++++++++++++++----
>  1 files changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/lib/rbtree.c b/lib/rbtree.c
> index 12abb8a..d0be5fc 100644
> --- a/lib/rbtree.c
> +++ b/lib/rbtree.c
> @@ -91,8 +91,21 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
>  {
>  	struct rb_node *parent, *gparent;
>  
> -	while ((parent = rb_parent(node)) && rb_is_red(parent))
> -	{
> +	while (true) {

This breaks tools/perf build in linux-next:

../../lib/rbtree.c: In function 'rb_insert_color':
../../lib/rbtree.c:95:9: error: 'true' undeclared (first use in this function)
../../lib/rbtree.c:95:9: note: each undeclared identifier is reported only once for each function it appears in
../../lib/rbtree.c: In function '__rb_erase_color':
../../lib/rbtree.c:216:9: error: 'true' undeclared (first use in this function)
../../lib/rbtree.c: In function 'rb_erase':
../../lib/rbtree.c:368:2: error: unknown type name 'bool'
make: *** [util/rbtree.o] Error 1

How about:

From: Adrian Hunter <adrian.hunter@intel.com>
Date: Fri, 31 Aug 2012 10:49:27 +0300
Subject: [PATCH] perf tools: fix build for another rbtree.c change

Fixes:

../../lib/rbtree.c: In function 'rb_insert_color':
../../lib/rbtree.c:95:9: error: 'true' undeclared (first use in this function)
../../lib/rbtree.c:95:9: note: each undeclared identifier is reported only once for each function it appears in
../../lib/rbtree.c: In function '__rb_erase_color':
../../lib/rbtree.c:216:9: error: 'true' undeclared (first use in this function)
../../lib/rbtree.c: In function 'rb_erase':
../../lib/rbtree.c:368:2: error: unknown type name 'bool'
make: *** [util/rbtree.o] Error 1

Signed-off-by: Adrian Hunter <adrian.hunter@intel.com>
---
 tools/perf/util/include/linux/rbtree.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/perf/util/include/linux/rbtree.h b/tools/perf/util/include/linux/rbtree.h
index 7a243a1..2a030c5 100644
--- a/tools/perf/util/include/linux/rbtree.h
+++ b/tools/perf/util/include/linux/rbtree.h
@@ -1 +1,2 @@
+#include <stdbool.h>
 #include "../../../../include/linux/rbtree.h"
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
