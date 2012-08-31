Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 052226B006C
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 04:12:07 -0400 (EDT)
Date: Fri, 31 Aug 2012 01:15:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 07/12] rbtree: adjust root color in rb_insert_color()
 only when necessary
Message-Id: <20120831011541.ddf8ed78.akpm@linux-foundation.org>
In-Reply-To: <CANN689EBA6yPk3pS-yXZ1-ticG7eU3mY1mWMWp2S3xhJ73ODFA@mail.gmail.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
	<1342139517-3451-8-git-send-email-walken@google.com>
	<50406F60.5040707@intel.com>
	<CANN689EBA6yPk3pS-yXZ1-ticG7eU3mY1mWMWp2S3xhJ73ODFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Adrian Hunter <adrian.hunter@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, acme@redhat.com

On Fri, 31 Aug 2012 01:07:24 -0700 Michel Lespinasse <walken@google.com> wrote:

> On Fri, Aug 31, 2012 at 1:01 AM, Adrian Hunter <adrian.hunter@intel.com> wrote:
> > This breaks tools/perf build in linux-next:
> >
> > ../../lib/rbtree.c: In function 'rb_insert_color':
> > ../../lib/rbtree.c:95:9: error: 'true' undeclared (first use in this function)
> > ../../lib/rbtree.c:95:9: note: each undeclared identifier is reported only once for each function it appears in
> > ../../lib/rbtree.c: In function '__rb_erase_color':
> > ../../lib/rbtree.c:216:9: error: 'true' undeclared (first use in this function)
> > ../../lib/rbtree.c: In function 'rb_erase':
> > ../../lib/rbtree.c:368:2: error: unknown type name 'bool'
> > make: *** [util/rbtree.o] Error 1
> 
> I thought Andrew had a patch
> rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix-perf-compilation
> that fixed this though a Makefile change ?

Yup.  But it's unclear why we should include the header via the cc
command line?


From: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Subject: rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix-perf-compilation

Commit 2cfaf9cc68190c24fdd05e4d104099b3f27c7a44 (rbtree: adjust root color
in rb_insert_color() only when necessary) introduces bool type and constants
to the rbtree.c, and breaks compilation of tools/perf:

../../lib/rbtree.c: In function `rb_insert_color':
../../lib/rbtree.c:95:9: error: `true' undeclared (first use in this function)
../../lib/rbtree.c:95:9: note: each undeclared identifier is reported only once
or each function it appears in
../../lib/rbtree.c: In function `__rb_erase_color':
../../lib/rbtree.c:216:9: error: `true' undeclared (first use in this function)
../../lib/rbtree.c: In function `rb_erase':
../../lib/rbtree.c:368:2: error: unknown type name `bool'
make: *** [util/rbtree.o] Error 1

This patch is the easiest solution I can think of.

Signed-off-by: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Acked-by: Michel Lespinasse <walken@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 tools/perf/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN tools/perf/Makefile~rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix-perf-compilation tools/perf/Makefile
--- a/tools/perf/Makefile~rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix-perf-compilation
+++ a/tools/perf/Makefile
@@ -806,7 +806,7 @@ $(OUTPUT)ui/browsers/map.o: ui/browsers/
 	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) -DENABLE_SLFUTURE_CONST $<
 
 $(OUTPUT)util/rbtree.o: ../../lib/rbtree.c $(OUTPUT)PERF-CFLAGS
-	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) -DETC_PERFCONFIG='"$(ETC_PERFCONFIG_SQ)"' $<
+	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) -DETC_PERFCONFIG='"$(ETC_PERFCONFIG_SQ)"' -include stdbool.h $<
 
 $(OUTPUT)util/parse-events.o: util/parse-events.c $(OUTPUT)PERF-CFLAGS
 	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) -Wno-redundant-decls $<
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
