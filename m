Date: Tue, 7 Jan 2003 15:37:13 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] allow bigger PAGE_OFFSET with PAE
Message-ID: <20030107233713.GB23814@holomorphy.com>
References: <3E1B334E.8030807@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E1B334E.8030807@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 07, 2003 at 12:06:38PM -0800, Dave Hansen wrote:
> Also, this gets the kernel's pagetables right, but neglects 
> userspace's for now.  pgd_alloc() needs to be fixed to allocate 
> another PMD, if the split isn't PMD-alighed.

Um, that should be automatic when USER_PTRS_PER_PGD is increased.

I see the following:

$ grep -n TASK_SIZE include/asm-i386/*.h                 
include/asm-i386/a.out.h:22:#define STACK_TOP   TASK_SIZE
include/asm-i386/elf.h:60:#define ELF_ET_DYN_BASE         (TASK_SIZE / 3 * 2)
include/asm-i386/pgtable.h:68:#define USER_PTRS_PER_PGD (TASK_SIZE/PGDIR_SIZE)
include/asm-i386/processor.h:277:#define TASK_SIZE      (PAGE_OFFSET)
include/asm-i386/processor.h:282:#define TASK_UNMAPPED_BASE     (PAGE_ALIGN(TASK_SIZE / 3))


... which sounds like you need to round up in an overflow-safe fashion
in the macro.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
