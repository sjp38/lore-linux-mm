Subject: Re: [patch 2/9] Store max number of objects in the page struct.
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <Pine.LNX.4.64.0803191049450.29173@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>
	 <20080317230528.279983034@sgi.com> <1205917757.10318.1.camel@ymzhang>
	 <Pine.LNX.4.64.0803191049450.29173@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Thu, 20 Mar 2008 11:32:17 +0800
Message-Id: <1205983937.14496.24.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, LKML <linux-kernel@vger.kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-03-19 at 10:49 -0700, Christoph Lameter wrote:
> On Wed, 19 Mar 2008, Zhang, Yanmin wrote:
> 
> > > +	if ((PAGE_SIZE << min_order) / size > 65535)
> > > +		return get_order(size * 65535) - 1;
> > Is it better to define something like USHORT_MAX to replace 65535?
> 
> Yes. Do we have something like that?

I couldn't find such definition in include/linux/kernel.h.


But glibc defines USHRT_MAX file include/limits.h:

/* Minimum and maximum values a `signed short int' can hold.  */
#  define SHRT_MIN      (-32768)
#  define SHRT_MAX      32767

/* Maximum value an `unsigned short int' can hold.  (Minimum is 0.)  */
#  define USHRT_MAX     65535


How about below patch against 2.6.25-rc6?

---

Add definitions of USHRT_MAX and others into kernel. ipc uses it and
slub implementation might also use it.

The patch is against 2.6.25-rc6.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

---

--- linux-2.6.25-rc6/include/linux/kernel.h	2008-03-20 04:25:46.000000000 +0800
+++ linux-2.6.25-rc6_work/include/linux/kernel.h	2008-03-20 04:17:45.000000000 +0800
@@ -20,6 +20,9 @@
 extern const char linux_banner[];
 extern const char linux_proc_banner[];
 
+#define USHRT_MAX	((u16)(~0U))
+#define SHRT_MAX	((s16)(USHRT_MAX>>1))
+#define SHRT_MIN	(-SHRT_MAX - 1)
 #define INT_MAX		((int)(~0U>>1))
 #define INT_MIN		(-INT_MAX - 1)
 #define UINT_MAX	(~0U)
--- linux-2.6.25-rc6/ipc/util.h	2008-03-20 04:25:46.000000000 +0800
+++ linux-2.6.25-rc6_work/ipc/util.h	2008-03-20 04:22:07.000000000 +0800
@@ -12,7 +12,6 @@
 
 #include <linux/err.h>
 
-#define USHRT_MAX 0xffff
 #define SEQ_MULTIPLIER	(IPCMNI)
 
 void sem_init (void);






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
