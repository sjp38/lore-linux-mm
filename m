Subject: [PATCH] Mempolicy:  fix parsing of tmpfs mpol mount option
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0803071341090.26765@chino.kir.corp.google.com>
References: <alpine.DEB.1.00.0803061135001.18590@chino.kir.corp.google.com>
	 <alpine.DEB.1.00.0803061135560.18590@chino.kir.corp.google.com>
	 <1204922646.5340.73.camel@localhost>
	 <alpine.DEB.1.00.0803071341090.26765@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Wed, 12 Mar 2008 15:33:15 -0400
Message-Id: <1205350396.6000.56.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: DavidRientjes <rientjes@google.com>, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Against:  2.6.25-rc5-mm1 atop:
+ mempolicy-disallow-static-or-relative-flags-for-local-preferred-mode
+ mempolicy-support-optional-mode-flags-fix [Hugh]

Parsing of new mode flags in the tmpfs mpol mount option is
slightly broken:

Setting a valid flag works OK:
	#mount -o remount,mpol=bind=static:1-2 /dev/shm
	#mount
	...
	tmpfs on /dev/shm type tmpfs (rw,mpol=bind=static:1-2)
	...

However, we can't remove them or change them, once we've
set a valid flag:

	#mount -o remount,mpol=bind:1-2 /dev/shm
	#mount
	...
	tmpfs on /dev/shm type tmpfs (rw,mpol=bind:1-2)
	...

It SAYS it removed it, but that's just a copy of the input
string.  If we now try to set it to a different flag, we
get:

	#mount -o remount,mpol=bind=relative:1-2 /dev/shm
	mount: /dev/shm not mounted already, or bad option

And on the console, we see:
	tmpfs: Bad value 'bind' for mount option 'mpol'
	                      ^ lost remainder of string

Furthermore, bogus flags are accepted with out error.
Granted, they are a no-op:

	#mount -o remount,mpol=interleave=foo:0-3 /dev/shm
	#mount
	...
	tmpfs on /dev/shm type tmpfs (rw,mpol=interleave=foo:0-3)

Again, that's just a copy of the input string shown by the
mount command.

This patch fixes the behavior by pre-zeroing the flags so that
only one of the mutually exclusive flags can be set at one time.
It also reports an error when an unrecognized flag is specified.

The check for both flags being set is removed because it can't
happen with this implementation.  If we ever want to support
multiple non-exclusive flags, this area will need rework and we
will need to check that any mutually exclusive flags aren't
specified.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/shmem.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

Index: linux-2.6.25-rc5-mm1/mm/shmem.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/shmem.c	2008-03-12 14:15:27.000000000 -0400
+++ linux-2.6.25-rc5-mm1/mm/shmem.c	2008-03-12 14:18:09.000000000 -0400
@@ -1128,20 +1128,26 @@ static int shmem_parse_mpol(char *value,
 			*policy_nodes = node_states[N_HIGH_MEMORY];
 		err = 0;
 	}
+
+	*mode_flags = 0;
 	if (flags) {
+		/*
+		 * Currently, we only support two mutually exclusive
+		 * mode flags.
+		 */
 		if (!strcmp(flags, "static"))
 			*mode_flags |= MPOL_F_STATIC_NODES;
-		if (!strcmp(flags, "relative"))
+		else if (!strcmp(flags, "relative"))
 			*mode_flags |= MPOL_F_RELATIVE_NODES;
-
-		if ((*mode_flags & MPOL_F_STATIC_NODES) &&
-		    (*mode_flags & MPOL_F_RELATIVE_NODES))
-			err = 1;
+		else
+			err = 1;	/* unrecognized flag */
 	}
 out:
 	/* Restore string for error message */
 	if (nodelist)
 		*--nodelist = ':';
+	if (flags)
+		*--flags = '=';
 	return err;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
