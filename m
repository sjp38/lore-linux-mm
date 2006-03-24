From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] swswsup: return correct load_image error
Date: Fri, 24 Mar 2006 16:17:23 +1100
References: <200603200234.01472.kernel@kolivas.org> <200603210022.32985.rjw@sisk.pl> <200603241600.56144.kernel@kolivas.org>
In-Reply-To: <200603241600.56144.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603241617.24434.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tuesday 21 March 2006 10:22, Rafael J. Wysocki wrote:
> > Basically, yes.  swsusp.c and snapshot.c contain common functions,
> > disk.c and swap.c contain the code used by the built-in swsusp only,
> > and user.c contains the userland interface.  If you want something to
> > be run by the built-in swsusp only, place it in disk.c.

Would this patch suffice?

Cheers,
Con
---
Swsusp reclaims a lot of memory during the suspend cycle and can benefit
from the aggressive_swap_prefetch mode immediately upon resuming.

Signed-off-by: Con Kolivas <kernel@kolivas.org>
---
 kernel/power/disk.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6.16-mm1/kernel/power/disk.c
===================================================================
--- linux-2.6.16-mm1.orig/kernel/power/disk.c	2006-03-24 15:48:14.000000000 +1100
+++ linux-2.6.16-mm1/kernel/power/disk.c	2006-03-24 16:15:05.000000000 +1100
@@ -19,6 +19,7 @@
 #include <linux/fs.h>
 #include <linux/mount.h>
 #include <linux/pm.h>
+#include <linux/swap-prefetch.h>
 
 #include "power.h"
 
@@ -138,8 +139,10 @@ int pm_suspend_disk(void)
 			unprepare_processes();
 			return error;
 		}
-	} else
+	} else {
 		pr_debug("PM: Image restored successfully.\n");
+		aggressive_swap_prefetch();
+	}
 
 	swsusp_free();
  Done:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
