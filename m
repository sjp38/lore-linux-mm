From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080428192839.23649.82172.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/4] Verification and debugging of memory initialisation V4
Date: Mon, 28 Apr 2008 20:28:39 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, mingo@elte.hu, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Boot initialisation is very complex, with significant numbers of
architecture-specific routines, hooks and code ordering. While significant
amounts of the initialisation is architecture-independent, it trusts
the data received from the architecture layer. This is a mistake, and has
resulted in a number of difficult-to-diagnose bugs. This patchset adds some
validation and tracing to memory initialisation. It also introduces a few
basic defensive measures.  The validation code can be explicitly disabled
for embedded systems.

I believe it's ready for a round of testing in -mm. The patches are based
against 2.6.25-mm1.

Changelog since V3
  o (Andrew) Only allow disabling of verification checks on CONFIG_EMBEDDED
  o (Andy Whitcroft) Documentation and leader fixups
  o (Andy) Rename mminit_debug_printk to mminit_dprintk for consistency
  o (Andy) Rename mminit_verify_pageflags to mminit_verify_pageflags_layout
  o (Andy) Rename mminit_validate_physlimits to mminit_validate_memmodel_limits
  o (Andy) Fix page->flags bitmap overlap checks
  o (Andy) Fix argument type for level in mminit_dprintk()
  o (Mel) Add WARNING error level that is the default logging level for
  	  mminit_loglevel=. Messages printed at this or lower levels will use
	  KERN_WARNING for the printk loglevel. Otherwise KERN_DEBUG is used.

Changelog since V2
  o (Mel) Rebase to 2.6.25-mm1 and rewrite zonelist dump
  o (Mel) Depend on DEBUG_VM instead of DEBUG_KERNEL
  o (Mel) Use __meminitdata instead of __initdata for logging level
  o (Christoph) Get rid of FLAGS_RESERVED references
  o (Christoph) Print out flag usage information
  o (Ingo) Default do the verifications on DEBUG_VM and instead control the
           level of verbose logging with mminit_loglevel= instead of
	   mminit_debug_level=
  o (Anon) Log at KERN_DEBUG level
  o (Anon) Optimisation to the mminit_debug_printk macro

Changelog since V1
  o (Ingo) Make memory initialisation verification a DEBUG option depending on
    DEBUG_KERNEL option. By default it will then to verify structures but
    tracing can be enabled via the command-line. Without the CONFIG option,
    checks will still be made on PFN ranges passed by the architecture-specific
    code and a warning printed once if a problem is encountered
  o (Ingo) WARN_ON_ONCE when PFNs from the architecture violate SPARSEMEM
    limitations. The warning should be "harmless" as the system will boot
    regardless but it acts as a reminder that bad input is being used.
  o (Anon) Convert mminit_debug_printk() to a macro
  o (Anon) Spelling mistake corrections
  o (Anon) Use of KERN_CONT properly for multiple printks
  o (Mel) Reshuffle the patches so that the zonelist printing is at the
    end of the patchset. This is because -mm requires a different patch to
    print zonelists and this allows the end patch to be temporarily dropped
    when testing against -mm
  o (Mel) Rebase on top of Ingo's sparsemem fix for easier testing
  o (Mel) Document mminit_debug_level=
  o (Mel) Fix check on pageflags where the masks were not being shifted
  o (Mel) The zone ID should should have used page_zonenum not page_zone_id
  o (Mel) Iterate all zonelists correctly
  o (Mel) Correct typo of SECTIONS_SHIFT

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
