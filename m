Date: Tue, 9 May 2006 12:05:05 +0100
Subject: [PATCH 0/3] Zone boundry alignment fixes
Message-ID: <exportbomb.1147172704@pinky>
References: <445DF3AB.9000009@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Bob Picco <bob.picco@hp.com>, Ingo Molnar <mingo@elte.hu>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ok.  Finally got my test bed working and got this lot tested.

To summarise the problem , the buddy allocator currently requires
that the boundries between zones occur at MAX_ORDER boundries.
The specific case where we were tripping up on this was in x86 with
NUMA enabled.  There we try to ensure that each node's stuct pages
are in node local memory, in order to allow them to be virtually
mapped we have to reduce the size of ZONE_NORMAL.  Here we are
rounding the remap space up to a large page size to allow large
page TLB entries to be used.  However, these are smaller than
MAX_ORDER.  This can lead to bad buddy merges.  With VM_DEBUG enabled
we detect the attempts to merge across this boundry and panic.

We have two basic options we can either apply the appropriate
alignment when we make make the NUMA remap space, or we can 'fix'
the assumption in the buddy allocator.  The fix for the buddy
allocator involves adding conditionals to the free fast path and
so it seems reasonable to at least favor realigning the remap space.

Following this email are 3 patches:

zone-init-check-and-report-unaligned-zone-boundries -- introduces
  a zone alignement helper, and uses it to add a check to zone
  initialisation for unaligned zone boundries,

x86-align-highmem-zone-boundries-with-NUMA -- uses the zone alignment
  helper to align the end of ZONE_NORMAL after the remap space has
  been reserved, and

zone-allow-unaligned-zone-boundries -- modifies the buddy allocator
  so that we can allow unaligned zone boundries.  A new configuration
  option is added to enable this functionality.

The first two are the fixes for alignement in x86, these fix the
panics thrown when VM_DEBUG is enabled.

The last is a patch to support unaligned zone boundries.  As this
(re)introduces a zone check into the free hot path it seems
reasonable to only enable this should it be needed; for example
we never need this if we have a single zone.  I have tested the
failing system with this patch enabled and it also fixes the panic.
I am inclined to suggest that it be included as it very clearly
documents the alignment requirements for the buddy allocator.

Comments.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
