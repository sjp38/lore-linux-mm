Date: Tue, 10 Apr 2007 17:00:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101659250.2751@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> It would be nice to get all this stuff user-documented, so there's one place to
> go to work out how to drive slub.

Index: linux-2.6.21-rc6/Documentation/vm/slub.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc6/Documentation/vm/slub.txt	2007-04-10 16:59:03.000000000 -0700
@@ -0,0 +1,114 @@
+Short users guide for SLUB
+--------------------------
+
+First of all slub should transparently replace SLAB. If you enable
+SLUB then everything should work the same (Note the word "should".
+There is likely not much value in that word at this point).
+
+The basic philosophy of SLUB is very different from SLAB. SLAB
+requires rebuilding the kernel to activate debug options for all
+SLABS. SLUB always includes full debugging but its off by default.
+SLUB can enable debugging only for selected slabs in order to avoid
+an impact on overall system performance which may make a bug more
+difficult to find.
+
+In order to switch debugging on one can add a option "slub_debug"
+to the kernel command line. That will enable full debugging for
+all slabs.
+
+Typically one would then use the "slabinfo" command to get statistical
+data and perform operation on the slabs. By default slabinfo only lists
+slabs that have data in them. See "slabinfo -h" for more options when
+running the command. slabinfo is included in this directory and can
+be compiled with
+
+gcc -o slabinfo slabinfo.c
+
+Some of the modes of operation of slabinfo require that slub debugging
+be enabled on the command line. F.e. no tracking information will be
+available without debugging on and validation can only partially
+be performed if debugging was not switched on.
+
+Some more sophisticated uses of slub_debug:
+-------------------------------------------
+
+Parameters may be given to slub_debug. If none is specified then full
+debugging is enabled. Format:
+
+slub_debug=<Debug-Options>       Enable options for all slabs
+slub_debug=<Debug-Options>,<slab name>
+				Enable options only for select slabs
+
+Possible debug options are
+	F		Sanity checks on (enables SLAB_DEBUG_FREE. Sorry
+			SLAB legacy issues)
+	Z		Red zoning
+	P		Poisoning (object and padding)
+	U		User tracking (free and alloc)
+	T		Trace (please only use on single slabs)
+
+F.e. in order to boot just with sanity checks and red zoning one would specify:
+
+	slub_debug=FZ
+
+Trying to find an issue in the dentry cache? Try
+
+	slub_debug=,dentry_cache
+
+to only enable debugging on the dentry cache.
+
+Red zoning and tracking may realign the slab. We can just apply sanity checks to
+the dentry cache with
+
+	slub_debug=F,dentry_cache
+
+In case you forgot to enable debugging on the kernel command line: It is
+possible to enable debugging manually when the kernel is up. Look at the
+contents of:
+
+/sys/slab/<slab name>/
+
+Look at the writable files. Writing 1 to them will enable the
+corresponding debug option. All options can be set on a slab that does
+not contain objects. If the slab already contains objects then sanity checks
+and tracing may only be enabled. The other options may cause the realignment
+of objects.
+
+Careful with tracing: It may spew out lots of information and never stop if
+used on the wrong slab.
+
+SLAB Merging
+------------
+
+If no debugging is specified then SLUB may merge similar slabs together
+in order to reduce overhead and increase cache hotness of objects.
+slabinfo -a displays which slabs were merged together.
+
+Getting more performance
+------------------------
+
+To some degree SLUBs performance is limited by the need to take the
+list_lock once in a while to deal with partial slabs. That overhead is
+governed by the order of the allocation for each slab. The allocations
+can be influenced by kernel parameters:
+
+slub_min_objects=x		(default 8)
+slub_min_order=x		(default 0)
+slub_max_order=x		(default 4)
+
+slub_min_objects allows to specify how many objects must at least fit
+into one slab in order for the allocation order to be acceptable.
+In general slub will be able to perform this number of allocations
+on a slab without consulting centralized resources (list_lock) where
+contention may occur.
+
+slub_min_order specifies a minim order of slabs. A similar effect like
+slub_min_objects.
+
+slub_max_order specified the order at which slub_min_objects should no
+longer be checked. This is useful to avoid SLUB trying to generate
+super large order pages to fit slub_min_objects of a slab cache with
+large object sizes into one high order page.
+
+
+Christoph Lameter, <clameter@sgi.com>, April 10, 2007

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
