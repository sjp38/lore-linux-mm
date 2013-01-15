Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7FFF16B006C
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:50:57 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 15:50:56 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 911401FF001C
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 15:50:43 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0FMosSq198666
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 15:50:54 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0FMorMm000799
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 15:50:54 -0700
Message-ID: <50F5DD45.4060603@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 14:50:45 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFCv3][PATCH 1/3] create slow_virt_to_phys()
References: <20130109185904.DD641DCE@kernel.stglabs.ibm.com> <50F5B214.5060604@zytor.com>
In-Reply-To: <50F5B214.5060604@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On 01/15/2013 11:46 AM, H. Peter Anvin wrote:
> I object to this switch statement.  If we are going to create new
> primitives, let's create a primitive that embody this and put it in
> pgtypes_types.h, especially since it is simply an algorithmic operation:

Yeah, that's a good point.  I did at least copy part of the switch from
elsewhere in the file, so there's certainly room for consolidating some
things.

> static inline unsigned long page_level_size(int level)
> {
>     return (PAGE_SIZE/PGDIR_SIZE) << (PGDIR_SHIFT*level);
> }
> static inline unsigned long page_level_shift(int level)
> {
>     return (PAGE_SHIFT-PGDIR_SHIFT) + (PGDIR_SHIFT*level);
> }

(PAGE_SHIFT-PGDIR_SHIFT) == -27, so this can't possibly work, right?

How about something like this?

/*
 * Note: this only holds true for pagetable levels where PTEs can be
 * present.  It would break if you used it on the PGD level where PAE
 * is in use.  It basically assumes that the shift between _all_
 * adjacent levels of the pagetables are the same as the lowest-level
 * shift.
 */
#define PG_SHIFT_PER_LEVEL (PMD_SHIFT-PAGE_SHIFT)

static inline unsigned long page_level_shift(int level)
{
	return PAGE_SHIFT + (level - PG_LEVEL_4K) * PG_SHIFT_PER_LEVEL;
}
static inline unsigned long page_level_size(int level)
{
	return 1 << page_level_shift(level);
}

The generated code for page_level_size() looks pretty good, despite it
depending on page_level_shift(), so we might as well leave it defined
this way for simplicity:

0000000000400610 <plsize>:
  400610:       8d 7c bf fb             lea    -0x5(%rdi,%rdi,4),%edi
  400614:       b8 01 00 00 00          mov    $0x1,%eax
  400619:       8d 4c 3f 0c             lea    0xc(%rdi,%rdi,1),%ecx
  40061d:       d3 e0                   shl    %cl,%eax
  40061f:       c3                      retq

I'll send out another series doing this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
