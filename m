Date: Thu, 24 Aug 2006 17:17:30 -0700
From: Paul Jackson <pj@sgi.com>
Subject: pxx_page macro patch breaks arm build in 2.6.18-rc4-mm2
Message-Id: <20060824171730.162c245a.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, Diego Calleja <diegocg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

The defconfig arch=arm build is broken in 2.6.18-rc4-mm2.

The patch "standardize-pxx_page-macros.patch" removed various macros,
including pmd_page_kernel.

It seems to have missed one place, which breaks the defconfig 'arm'
build in 2.6.18-rc4-mm2:


=======================================================
  LD      .tmp_vmlinux1
arch/arm/mm/built-in.o(.text+0x1698): In function `$a':
: undefined reference to `pmd_page_kernel'
make: *** [.tmp_vmlinux1] Error 1
=======================================================


The offending line and a little context, in arch/arm/mm/ioremap.c:


=======================================================
                        * Free the page table, if there was one.
                         */
                        if ((pmd_val(pmd) & PMD_TYPE_MASK) == PMD_TYPE_TABLE)
                                pte_free_kernel(pmd_page_kernel(pmd));
                }

                addr += PGDIR_SIZE;
=======================================================

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
