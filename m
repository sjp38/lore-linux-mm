From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080417000624.18399.35041.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 0/4] Verification and debugging of memory initialisation V2
Date: Thu, 17 Apr 2008 01:06:24 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Many changes are based on feedback from Ingo. Others are from off-list mails
that were not group-replied for some reason. A number of issues were rattled
out while testing on machines other than x86-32. V1 was pretty flaky and
barely a proof-of-concept but this version has successfully boot-tested on
x86-32, x86-64 and ppc64. It has been successfully cross-compiled on ARM
which does not support arch-independent zone-sizing.

Changelog since V1
  o Make memory initialisation verification a DEBUG option depending on
    DEBUG_KERNEL option. By default it will then to verify structures but
    tracing can be enabled via the command-line. Without the CONFIG option,
    checks will still be made on PFN ranges passed by the architecture-specific
    code and a warning printed once if a problem is encountered
  o Reshuffle the patches so that the zonelist printing is at the end of the
    patchset. This is because -mm requires a different patch to print zonelists
    and this allows the end patch to be temporarily dropped when testing against
    -mm
  o Rebase on top of Ingo's sparsemem fix for easier testing
  o WARN_ON_ONCE when PFNs from the architecture violate SPARSEMEM limitations.
    The warning should be "harmless" as the system will boot regardless but
    it acts as a reminder that bad input is being used.
  o Convert mminit_debug_printk() to a macro
  o Spelling mistake corrections
  o Proper use of KERN_CONT
  o Document mminit_debug_level=
  o Fix check on pageflags where the masks were not being shifted
  o The zone ID should should have used page_zonenum not page_zone_id
  o Iterate all zonelists correctly
  o Correct typo of SECTIONS_SHIFT

Boot initialisation has always been a bit of a mess with a number
of ugly points. While significant amounts of the initialisation
is architecture-independent, it trusts of the data received from the
architecture layer. This was a mistake in retrospect as it has resulted in
a number of difficult-to-diagnose bugs.

This patchset optionally adds some validation and tracing to memory
initialisation. It also introduces a few basic defencive measures and
depending on a boot parameter, will perform additional tests for errors
"that should never occur". I think this would have reduced debugging time
for some boot-related problems. 

One question. These patches generally print at KERN_INFO level on the
assumption if the user has compiled in the option, they are not expecting to
also have to set loglevel. However, it has been pointed out privately that this
may be confusing. Which level for printk would people find less surprising?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
