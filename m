Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B73C46B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:09:32 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x2-v6so530452plv.0
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:09:32 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r10-v6si3395620pfe.121.2018.06.20.15.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 15:09:31 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 0/3] KASLR feature to randomize each loadable module
Date: Wed, 20 Jun 2018 15:09:27 -0700
Message-Id: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kristen.c.accardi@intel.com, dave.hansen@intel.com, arjan.van.de.ven@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Hi,
This is to add a KASLR feature for stronger randomization for the location of
the text sections of dynamically loaded kernel modules.

Today the RANDOMIZE_BASE feature randomizes the base address where the module
allocations begin with 10 bits of entropy. From here, a highly deterministic
algorithm allocates space for the modules as they are loaded and un-loaded. If
an attacker can predict the order and identities for modules that will be
loaded, then a single text address leak can give the attacker access to the
locations of all the modules.

This patch changes the module loading KASLR algorithm to randomize the position
of each module text section allocation with at least 18 bits of entropy in the
typical case. It used on x86_64 only for now.

Allocation Algorithm
====================
The algorithm evenly breaks the module space in two, a random area and a backup
area. For module text allocations, it first tries to allocate up to 10 randomly
located starting pages inside the random section. If this fails, it will
allocate in the backup area. The backup area base will be offset in the same
way as current algorithm does for the base area, which has 10 bits of entropy.

Randomness and Fragmentation
============================
The advantages of this algorithm over the existing one are higher entropy and
that each module text section is randomized in relation to the other sections,
so that if one location is leaked the location of other sections cannot be
inferred.

However, unlike the existing algorithm, the amount of randomness provided has a
dependency on the number of modules allocated and the sizes of the modules text
sections.

The following estimates are based on simulations done with core section
allocation sizes recorded from all in-tree x86_64 modules, and with a module
space size of 1GB (the size when KASLR is enabled). The entropy provided for the
Nth allocation will come from three sources of randomness, the address picked
for the random area, the probability the section will be allocated in the backup
area and randomness from the number of modules already allocated in the backup
area. For computing a lower bound entropy in the following calculations, the
randomness of the modules already in the backup area, or overlapping from the
random area, is ignored since it is usually small for small numbers of modules
and will only increase the entropy.

For probability of the Nth module being in the backup area, p, a lower bound
entropy estimate is calculated here as:
Entropy = -((1-p)*log2((1-p)/(1073741824/4096)) + p*log2(p/1024))

Nth Modules	Probability Nth in Backup (p<0.01)	Entropy (bits)
200		0.00015658918				18.0009525805
300		0.00061754750				18.0025340517
400		0.00092257674				18.0032512276
500		0.00143354729				18.0041398771
600		0.00199926260				18.0048133611
700		0.00303342527				18.0054763676
800		0.00375362443				18.0056209924
900		0.00449013182				18.0055609282
1000		0.00506372420				18.0053909502
2000		0.01655518527				17.9891937614

For the subclass of control flow attacks, a wrong guess can often crash the
process or even the system if is wrong, so the probability of the first guess
being right can be more important than the Nth guess. KASLR schemes usually have
equal probability for each possible position, but in this scheme that is not the
case. So a more conservative comparison to existing schemes is the amount of
information that would have to be guessed correctly for the position that has
the highest probability for having the Nth module allocated (as that would be
the attackers best guess).

This next table shows the bits that would have to be guessed for a most likely
position for the Nth module, assuming no other address has leaked:

Min Info = MIN(-log2(p/1024), -log2((1-p)/(1073741824/4096)))

Nth Modules	Min Info		Random Area 		Backup Area
200		18.00022592813		18.00022592813		22.64072780584
300		18.00089120792		18.00089120792		20.66116227856
400		18.00133161125		18.00133161125		20.08204345143
500		18.00206965540		18.00206965540		19.44619478537
600		18.00288721335		18.00288721335		18.96631630463
700		18.00438295865		18.00438295865		18.36483651470
800		18.00542552443		18.00542552443		18.05749997547
900		17.79902648177		18.00649247790		17.79902648177
1000		17.62558545623		18.00732396876		17.62558545623
2000		15.91657303366		18.02408399587		15.91657303366

So the defensive strength of this algorithm in typical usage (<800 modules) for
x86_64 should be at least 18 bits, even if an address from the random area
leaks.

If an address from a section in the backup area leaks however, the remaining
information that would have to be guessed is reduced. To get at a lower bound,
the following assumes the address of the leak is the first module in the backup
area and ignores the probability of guessing the identity.

Nth Modules	P of At Least 2 in Backup (p<0.01)	Info (bits)
200		0.00005298177				14.20414443057
300		0.00005298177				14.20414443057
400		0.00034665456				11.49421363374
500		0.00310895422				8.32935491164
600		0.01299838019				6.26552433915
700		0.04042051772				4.62876838940
800		0.09812051823				3.34930133623
900		0.19325547277				2.37141882470
1000		0.32712329132				1.61209361130

So the in typical usage, the entropy will still be decent if an address in the
backup leaks as well.

As for fragmentation, this algorithm reduces the average number of modules that
can be loaded without an allocation failure by about 6% (~17000 to ~16000)
(p<0.05). It can also reduce the largest module executable section that can be
loaded by half to ~500MB in the worst case.

Implementation
==============
This patch adds a new function in vmalloc (__vmalloc_node_try_addr) that tries
to allocate at a specific address. In the x86 module loader, this new vmalloc
function is used to implement the algorithm described above.

The new __vmalloc_node_try_addr function uses the existing function 
__vmalloc_node_range, in order to introduce this algorithm with the least
invasive change. The side effect is that each time there is a collision when
trying to allocate in the random area a TLB flush will be triggered. There is 
a more complex, more efficient implementation that can be used instead if 
there is interest in improving performance.


Rick Edgecombe (3):
  vmalloc: Add __vmalloc_node_try_addr function
  x86/modules: Increase randomization for modules
  vmalloc: Add debugfs modfraginfo

 arch/x86/include/asm/pgtable_64_types.h |   1 +
 arch/x86/kernel/module.c                |  80 +++++++++++++++--
 include/linux/vmalloc.h                 |   3 +
 mm/vmalloc.c                            | 151 +++++++++++++++++++++++++++++++-
 4 files changed, 227 insertions(+), 8 deletions(-)

-- 
2.7.4
