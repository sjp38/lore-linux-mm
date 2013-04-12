Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id AD3366B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 01:05:24 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 10:30:48 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9F0DB125804F
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 10:36:45 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C55DN649414150
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 10:35:13 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C55HWC025792
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 15:05:18 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V5 21/25] powerpc: Handle hugepage in perf callchain
In-Reply-To: <20130412013449.GD5065@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1365055083-31956-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130412013449.GD5065@truffula.fritz.box>
Date: Fri, 12 Apr 2013 10:35:16 +0530
Message-ID: <878v4omj8z.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <dwg@au1.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

David Gibson <dwg@au1.ibm.com> writes:

> On Thu, Apr 04, 2013 at 11:27:59AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  arch/powerpc/perf/callchain.c |   32 +++++++++++++++++++++-----------
>>  1 file changed, 21 insertions(+), 11 deletions(-)
>> 
>> diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
>> index 578cac7..99262ce 100644
>> --- a/arch/powerpc/perf/callchain.c
>> +++ b/arch/powerpc/perf/callchain.c
>> @@ -115,7 +115,7 @@ static int read_user_stack_slow(void __user *ptr, void *ret, int nb)
>>  {
>>  	pgd_t *pgdir;
>>  	pte_t *ptep, pte;
>> -	unsigned shift;
>> +	unsigned shift, hugepage;
>>  	unsigned long addr = (unsigned long) ptr;
>>  	unsigned long offset;
>>  	unsigned long pfn;
>> @@ -125,20 +125,30 @@ static int read_user_stack_slow(void __user *ptr, void *ret, int nb)
>>  	if (!pgdir)
>>  		return -EFAULT;
>>  
>> -	ptep = find_linux_pte_or_hugepte(pgdir, addr, &shift, NULL);
>> +	ptep = find_linux_pte_or_hugepte(pgdir, addr, &shift, &hugepage);
>
> So, this patch pretty much demonstrates that your earlier patch adding
> the optional hugepage argument and making the existing callers pass
> NULL was broken.
>
> Any code which calls this function and doesn't use and handle the
> hugepage return value is horribly broken, so permitting the hugepage
> parameter to be optional is itself broken.
>
> I think instead you need to have an early patch that replaces
> find_linux_pte_or_hugepte with a new, more abstracted interface, so
> that code using it will remain correct when hugepage PMDs become
> possible.


The entire thing could have been simple if we supported only one
hugepage size (this is what sparc ended up doing). I guess we don't want
to do that. Also we want to support 16MB and 16GB, which mean we need
hugepd for 16GB at PGD level. My goal was to keep the hugetlb related
code for both 16MB and 16GB similar and consider THP huge page in a
different bucket.

Let me look at again how best I can simplify find_linux_pte_or_hugepte

-aneehs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
