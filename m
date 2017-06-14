Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E648D6B02F4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:12:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u101so1929743wrc.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:12:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p184si553315wme.20.2017.06.14.10.12.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 10:12:03 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: improve readability of
 transparent_hugepage_enabled()
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
 <e944ba00-3139-8da0-a1f9-642be9300c7c@suse.cz>
 <CAPcyv4h2GfqK3o4WdrKuhKnmjWeXBjeCOCsMv4M-xg9PViLbFw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0dd98f27-59b4-4503-1479-45372c939d6b@suse.cz>
Date: Wed, 14 Jun 2017 19:11:23 +0200
MIME-Version: 1.0
In-Reply-To: <CAPcyv4h2GfqK3o4WdrKuhKnmjWeXBjeCOCsMv4M-xg9PViLbFw@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------22D9FE04E72AEA572EBF13E2"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is a multi-part message in MIME format.
--------------22D9FE04E72AEA572EBF13E2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 06/14/2017 07:02 PM, Dan Williams wrote:
> On Wed, Jun 14, 2017 at 9:53 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> Can you share the test-thp.c so I can add this to my test collection?

Attached.

> I'm assuming cbmc is "Bounded Model Checker for C/C++"?

Yes. This blog from Paul inspired me:
http://paulmck.livejournal.com/38997.html

Works nicely, just if it finds a bug, the counterexamples are a bit of
PITA to decipher :)

Vlastimil

--------------22D9FE04E72AEA572EBF13E2
Content-Type: text/x-csrc;
 name="test-thp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="test-thp.c"

#include <stdbool.h>
#include <stdio.h>

#define VM_GROWSDOWN    0x00000100      /* general info on the segment */
#define VM_HUGEPAGE     0x20000000      /* MADV_HUGEPAGE marked this vma */
#define VM_NOHUGEPAGE   0x40000000      /* MADV_NOHUGEPAGE marked this vma */
#define VM_ARCH_1       0x01000000      /* Architecture-specific flag */
#define VM_GROWSUP VM_ARCH_1
#define VM_SEQ_READ     0x00008000      /* App will access data sequentially */
#define VM_RAND_READ    0x00010000      /* App will not benefit from clustered reads */
#define VM_STACK_INCOMPLETE_SETUP       (VM_RAND_READ | VM_SEQ_READ)

enum transparent_hugepage_flag {
        TRANSPARENT_HUGEPAGE_FLAG,
        TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
        TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
        TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
        TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG,
        TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
        TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
        TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
        TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
};

unsigned long transparent_hugepage_flags;
struct vm_area_struct {
	unsigned long vm_flags;
};

bool is_vma_temporary_stack(struct vm_area_struct *vma)
{
        int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);

        if (!maybe_stack)
                return false;

        if ((vma->vm_flags & VM_STACK_INCOMPLETE_SETUP) ==
                                                VM_STACK_INCOMPLETE_SETUP)
                return true;

        return false;
}

#define transparent_hugepage_enabled1(__vma)				\
	((transparent_hugepage_flags &					\
	  (1<<TRANSPARENT_HUGEPAGE_FLAG) ||				\
	  (transparent_hugepage_flags &					\
	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
	 !is_vma_temporary_stack(__vma))

// v2
static inline bool transparent_hugepage_enabled2(struct vm_area_struct *vma)
{
	if ((vma->vm_flags & VM_NOHUGEPAGE) || is_vma_temporary_stack(vma))
		return false;

	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
		return true;

	if (transparent_hugepage_flags &
				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
		return !!(vma->vm_flags & VM_HUGEPAGE);

	return false;
}

// v1
static inline bool transparent_hugepage_enabled3(struct vm_area_struct *vma)
{
	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
		return true;

	if (transparent_hugepage_flags
			& (1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
		/* check vma flags */;
	else
		return false;

	if ((vma->vm_flags & (VM_HUGEPAGE | VM_NOHUGEPAGE)) == VM_HUGEPAGE
			&& !is_vma_temporary_stack(vma))
		return true;

	return false;
}

int main(int argc, char *argv[])
{
	struct vm_area_struct vma;

	vma.vm_flags = (unsigned long) argv[1];
	transparent_hugepage_flags = (unsigned long) argv[2];

//	assert(transparent_hugepage_enabled1(&vma)
//			== transparent_hugepage_enabled2(&vma));
	assert(transparent_hugepage_enabled1(&vma)
			== transparent_hugepage_enabled3(&vma));
}

--------------22D9FE04E72AEA572EBF13E2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
