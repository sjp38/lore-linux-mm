From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [RFC v1 0/2] Per-arch page checksumming and comparison
Date: Mon, 25 Sep 2017 10:46:12 +0200
Message-ID: <1506329174-19265-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: borntraeger@de.ibm.com, kvm@vger.kernel.org, linux-mm@kvack.org, nefelim4ag@gmail.com, akpm@linux-foundation.org, aarcange@redhat.com, mingo@kernel.org, zhongjiang@huawei.com, kirill.shutemov@linux.intel.com, arvind.yadav.cs@gmail.com, solee@os.korea.ac.kr, ak@linux.intel.com
List-Id: linux-mm.kvack.org

Since we now have two different proposals on how to speed up KSM, I
thought I'd share what I had done too, so we can now have three :)

I have analysed the performance of KSM, and I have found out that both
the checksum and the memcmp take up a significant amount of time.
Depending on the content of the pages, either function can be the
"bottleneck".

I did some synthetic benchmarks, using different checksum functions and
with different page content scenarios. Only in the best case (e.g.
pages differing at the very beginning) was the checksum consuming more
CPU time than the memcmps.
Using a simpler function (like CRC32 or even just a simple sum)
significantly reduced the CPU load. 
In other scenarios, like when the pages differ in the middle or at the
end, the biggest offender is the memcmp. Still, using simpler checksums
lowers the overall CPU load.

The idea I had in this patchseries was to provide arch-overridable
functions to checksum and compare whole pages.

Depending on the arch, the best memcmp/checksum to use in the
specialized case of comparing/checksumming one whole page might not
necessarily be the one that is the best in the general case. So what I
did here was to factor out the old code and make it generic, and then
provide an s390-specific implementation for the checksum using the CKSM
instruction, which is also used to calculate the checksum of IP
headers, the idea being that other architectures can then follow and
use their preferred checksum.


I like Sioh Lee's proposal of using the crypto API to choose a fast but
good checksum, since this can be made arch-dependant too, and CRC32 is
also almost as fast as the simple checksum. Also, I had underestimated
how many more collisions the simple checksum could potentially cause
(although I did not see any performance regressions in my tests).

While there is a crypto API to choose between different hash functions,
there is nothing like that for page comparison.


I think at this point we need to coordinate a little, to avoid
reinventing the wheel three times and in different ways.




Claudio Imbrenda (2):
  VS1544 KSM generic memory comparison functions
  VS1544 KSM s390-specific memory comparison functions

 arch/alpha/include/asm/Kbuild       |  1 +
 arch/arc/include/asm/Kbuild         |  1 +
 arch/arm/include/asm/Kbuild         |  1 +
 arch/arm64/include/asm/Kbuild       |  1 +
 arch/blackfin/include/asm/Kbuild    |  1 +
 arch/c6x/include/asm/Kbuild         |  1 +
 arch/cris/include/asm/Kbuild        |  1 +
 arch/frv/include/asm/Kbuild         |  1 +
 arch/h8300/include/asm/Kbuild       |  1 +
 arch/hexagon/include/asm/Kbuild     |  1 +
 arch/ia64/include/asm/Kbuild        |  1 +
 arch/m32r/include/asm/Kbuild        |  1 +
 arch/m68k/include/asm/Kbuild        |  1 +
 arch/metag/include/asm/Kbuild       |  1 +
 arch/microblaze/include/asm/Kbuild  |  1 +
 arch/mips/include/asm/Kbuild        |  1 +
 arch/mn10300/include/asm/Kbuild     |  1 +
 arch/nios2/include/asm/Kbuild       |  1 +
 arch/openrisc/include/asm/Kbuild    |  1 +
 arch/parisc/include/asm/Kbuild      |  1 +
 arch/powerpc/include/asm/Kbuild     |  1 +
 arch/s390/include/asm/page_memops.h | 18 ++++++++++++++++++
 arch/score/include/asm/Kbuild       |  1 +
 arch/sh/include/asm/Kbuild          |  1 +
 arch/sparc/include/asm/Kbuild       |  1 +
 arch/tile/include/asm/Kbuild        |  1 +
 arch/um/include/asm/Kbuild          |  1 +
 arch/unicore32/include/asm/Kbuild   |  1 +
 arch/x86/include/asm/Kbuild         |  1 +
 arch/xtensa/include/asm/Kbuild      |  1 +
 include/asm-generic/page_memops.h   | 31 +++++++++++++++++++++++++++++++
 mm/ksm.c                            | 27 +++------------------------
 32 files changed, 81 insertions(+), 24 deletions(-)
 create mode 100644 arch/s390/include/asm/page_memops.h
 create mode 100644 include/asm-generic/page_memops.h

-- 
2.7.4
