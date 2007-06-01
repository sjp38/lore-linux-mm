Date: Fri, 1 Jun 2007 14:08:07 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
Message-ID: <20070601180807.GB7968@redhat.com>
References: <20070531002047.702473071@sgi.com> <20070531003012.302019683@sgi.com> <a8e1da0705301735r5619f79axcb3ea6c7dd344efc@mail.gmail.com> <Pine.LNX.4.64.0705301747370.4809@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705301747370.4809@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: young dave <hidave.darkstar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, May 30, 2007 at 05:49:56PM -0700, Christoph Lameter wrote:
 > On Thu, 31 May 2007, young dave wrote:
 > 
 > > Hi Christoph,
 > > 
 > > > Introduce CONFIG_STABLE to control checks only useful for development.
 > > 
 > > What about control checks only as SLUB_DEBUG is set?
 > 
 > Debug code is always included in all builds unless it is an embedded 
 > system. Debug code is kept out of the hot path.
 > 
 > Disabling SLUB_DEBUG should only be done for embedded systems. That is why 
 > the option is in CONFIG_EMBEDDED.

Something I'd really love to have is a CONFIG option to decide if
slub_debug is set or not by default.  The reasoning behind this is that during
development of each Fedora release, I used to leave SLAB_DEBUG=y for
months on end and catch all kinds of nasties.

Now that I've switched it over to using slub, I ended up adding the
ugly patch below, because otherwise, no-one would ever run with
slub_debug and we'd miss out on all those lovely bugs.
(I have 'make release' and 'make debug' targets which enable/disable
 this [and other] patches in the Fedora kernel).

(Patch for illustration only, obviously not for applying).

Unless someone beats me to it, I'll hack up a CONFIG option around
this. Having that turned on if !CONFIG_STABLE would also be a win I think.

	Dave


--- linux-2.6/mm/slub.c~	2007-05-27 21:48:42.000000000 -0400
+++ linux-2.6/mm/slub.c	2007-05-27 21:51:22.000000000 -0400
@@ -323,7 +323,7 @@ static inline int slab_index(void *p, st
 /*
  * Debug settings:
  */
-static int slub_debug;
+static int slub_debug = DEBUG_DEFAULT_FLAGS;
 
 static char *slub_debug_slabs;
 


-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
