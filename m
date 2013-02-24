Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 2B5D16B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 12:45:36 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 24 Feb 2013 23:12:35 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id ED908125804E
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 23:16:19 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1OHjPYa31457362
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 23:15:25 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1OHjSii020766
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 04:45:29 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH -V2 08/21] powerpc: Decode the pte-lp-encoding bits correctly.
In-Reply-To: <20130222053735.GH6139@drongo>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361465248-10867-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130222053735.GH6139@drongo>
Date: Sun, 24 Feb 2013 23:15:28 +0530
Message-ID: <87ppzpbo7b.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

>
>> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
>> index 71d0c90..d2c9932 100644
>> --- a/arch/powerpc/kvm/book3s_hv.c
>> +++ b/arch/powerpc/kvm/book3s_hv.c
>> @@ -1515,7 +1515,12 @@ static void kvmppc_add_seg_page_size(struct kvm_ppc_one_seg_page_size **sps,
>>  	(*sps)->page_shift = def->shift;
>>  	(*sps)->slb_enc = def->sllp;
>>  	(*sps)->enc[0].page_shift = def->shift;
>> -	(*sps)->enc[0].pte_enc = def->penc;
>> +	/*
>> +	 * FIXME!!
>> +	 * This is returned to user space. Do we need to
>> +	 * return details of MPSS here ?
>
> Yes, we do, probably a separate entry for each valid base/actual page
> size pair.
>

How about

commit fb7bca460d5e3a517dce24c0fe28cc94ffde37fa
Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date:   Sun Feb 24 22:55:38 2013 +0530

    powerpc: Return all the valid pte ecndoing in KVM_PPC_GET_SMMU_INFO ioctl
    
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 48f6d99..e50eb0d 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1508,14 +1508,21 @@ long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
 static void kvmppc_add_seg_page_size(struct kvm_ppc_one_seg_page_size **sps,
 				     int linux_psize)
 {
+	int i, index = 0;
 	struct mmu_psize_def *def = &mmu_psize_defs[linux_psize];
 
 	if (!def->shift)
 		return;
 	(*sps)->page_shift = def->shift;
 	(*sps)->slb_enc = def->sllp;
-	(*sps)->enc[0].page_shift = def->shift;
-	(*sps)->enc[0].pte_enc = def->penc[linux_psize];
+	for (i = 0; i < MMU_PAGE_COUNT; i++) {
+		if ((signed int)def->penc[i] != -1) {
+			BUG_ON(index >= KVM_PPC_PAGE_SIZES_MAX_SZ);
+			(*sps)->enc[index].page_shift = mmu_psize_defs[i].shift;
+			(*sps)->enc[index].pte_enc = def->penc[i];
+			index++;
+		}
+	}
 	(*sps)++;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
