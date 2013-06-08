Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 0CED36B0031
	for <linux-mm@kvack.org>; Sat,  8 Jun 2013 12:57:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 9 Jun 2013 02:48:56 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 9FBCE2BB0051
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 02:57:52 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r58GhMm661538368
	for <linux-mm@kvack.org>; Sun, 9 Jun 2013 02:43:23 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r58GvoOx012953
	for <linux-mm@kvack.org>; Sun, 9 Jun 2013 02:57:51 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V7 09/18] powerpc: Switch 16GB and 16MB explicit hugepages to a different page table format
In-Reply-To: <1370632664.6813.10@snotra>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1367177859-7893-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1370558559.32518.4@snotra> <87zjv2wp5h.fsf@linux.vnet.ibm.com> <1370632664.6813.10@snotra>
Date: Sat, 08 Jun 2013 22:27:48 +0530
Message-ID: <87obbgpmk3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Scott Wood <scottwood@freescale.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Scott Wood <scottwood@freescale.com> writes:

> On 06/06/2013 10:55:22 PM, Aneesh Kumar K.V wrote:
>> Scott Wood <scottwood@freescale.com> writes:
>> 
>> > On 04/28/2013 02:37:30 PM, Aneesh Kumar K.V wrote:
>> >> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> >>
>> >> We will be switching PMD_SHIFT to 24 bits to facilitate THP

.....

>> >>
>> >> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> >> ---
>> >>  arch/powerpc/include/asm/page.h    |   2 +
>> >>  arch/powerpc/include/asm/pgtable.h |   2 +
>> >>  arch/powerpc/mm/gup.c              |  18 +++-
>> >>  arch/powerpc/mm/hugetlbpage.c      | 176
>> >> +++++++++++++++++++++++++++++++------
>> >>  4 files changed, 168 insertions(+), 30 deletions(-)
>> >
>> > After this patch, on 64-bit book3e (e5500, and thus 4K pages), I see
>> > messages like this after exiting a program that uses hugepages
>> > (specifically, qemu):
>> >
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221516.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221516.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc2214d6.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc2214d6.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221916.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221916.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc2218d6.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc2218d6.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221496.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221496.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221856.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221856.
>> > /home/scott/fsl/git/linux/upstream/mm/memory.c:407: bad pmd
>> > 40000001fc221816.
>> 
>> hmm that implies some of the code paths are not properly #ifdef.
>> The goal was to limit the new format CONFIG_PPC_BOOK3S_64 as seen in  
>> the
>> definition of huge_pte_alloc. Can you send me the .config ?
>
> Attached.
>
>

That didn't give much hint on why we are finding bad pmd. One of the
reason for finding bad pmd is we are finding hugepd with the new format,
ie, bottom two bits == 00, next 4 bits indicate size of table, but use
the old functions to check whether it is hugepd

static inline int hugepd_ok(hugepd_t hpd)
{
	return (hpd.pd > 0);
}

Can you check the intermediate file generated and verify that the
huge_pte_alloc is doing the right thing. All the new changes should be
limitted to book3s 64. Hence boo3e should all work as before.

With the config shared I am not finding anything wrong, but I can't test
these configs. Also can you confirm what you bisect this to 

e2b3d202d1dba8f3546ed28224ce485bc50010be 
powerpc: Switch 16GB and 16MB explicit hugepages to a different page table format

or 

cf9427b85e90bb1ff90e2397ff419691d983c68b "powerpc: New hugepage directory format"

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
