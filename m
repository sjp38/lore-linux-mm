Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 437CC6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 12:20:01 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2095556pad.0
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 09:20:00 -0700 (PDT)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id qj1si3300261pbb.342.2014.04.03.09.19.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 09:20:00 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 4 Apr 2014 02:19:55 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id AA734357803F
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 03:19:51 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s33FxDA211469138
	for <linux-mm@kvack.org>; Fri, 4 Apr 2014 02:59:13 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s33GJohY015733
	for <linux-mm@kvack.org>; Fri, 4 Apr 2014 03:19:50 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] hugetlb: ensure hugepage access is denied if hugepages are not supported
In-Reply-To: <20140326155815.GB15234@linux.vnet.ibm.com>
References: <20140324230256.GA18778@linux.vnet.ibm.com> <20140326155815.GB15234@linux.vnet.ibm.com>
Date: Thu, 03 Apr 2014 21:49:46 +0530
Message-ID: <87ioqqo065.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: paulus@samba.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, nyc@holomorphy.com

Nishanth Aravamudan <nacc@linux.vnet.ibm.com> writes:

> On 24.03.2014 [16:02:56 -0700], Nishanth Aravamudan wrote:
>> In KVM guests on Power, if the guest is not backed by hugepages, we see
>> the following in the guest:
>> 
>> AnonHugePages:         0 kB
>> HugePages_Total:       0
>> HugePages_Free:        0
>> HugePages_Rsvd:        0
>> HugePages_Surp:        0
>> Hugepagesize:         64 kB
>> 
>> This seems like a configuration issue -- why is a hstate of 64k being
>> registered?
>> 
>> I did some debugging and found that the following does trigger,
>> mm/hugetlb.c::hugetlb_init():
>> 
>>         /* Some platform decide whether they support huge pages at boot
>>          * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
>>          * there is no such support
>>          */
>>         if (HPAGE_SHIFT == 0)
>>                 return 0;
>> 
>> That check is only during init-time. So we don't support hugepages, but
>> none of the hugetlb APIs actually check this condition (HPAGE_SHIFT ==
>> 0), so /proc/meminfo above falsely indicates there is a valid hstate (at
>> least one). But note that there is no /sys/kernel/mm/hugepages meaning
>> no hstate was actually registered.
>> 
>> Further, it turns out that huge_page_order(default_hstate) is 0, so
>> hugetlb_report_meminfo is doing:
>> 
>> 1UL << (huge_page_order(h) + PAGE_SHIFT - 10)
>> 
>> which ends up just doing 1 << (PAGE_SHIFT - 10) and since the base page
>> size is 64k, we report a hugepage size of 64k... And allow the user to
>> allocate hugepages via the sysctl, etc.
>> 
>> What's the right thing to do here?
>> 
>> 1) Should we add checks for HPAGE_SHIFT == 0 to all the hugetlb APIs? It
>> seems like HPAGE_SHIFT == 0 should be the equivalent, functionally, of
>> the config options being off. This seems like a lot of overhead, though,
>> to put everywhere, so maybe I can do it in an arch-specific macro, that
>> in asm-generic defaults to 0 (and so will hopefully be compiled out?).
>> 
>> 2) What should hugetlbfs do when HPAGE_SHIFT == 0? Should it be
>> mountable? Obviously if it's mountable, we can't great files there
>> (since the fs will report insufficient space). [1]
>
> Here is my solution to this. Comments appreciated!
>
> In KVM guests on Power, in a guest not backed by hugepages, we see the
> following:
>
> AnonHugePages:         0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:         64 kB
>
> HPAGE_SHIFT == 0 in this configuration, which indicates that hugepages
> are not supported at boot-time, but this is only checked in
> hugetlb_init(). Extract the check to a helper function, and use it in a
> few relevant places.
>
> This does make hugetlbfs not supported in this environment. I believe
> this is fine, as there are no valid hugepages and that won't change at
> runtime.
>
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>


Looks good. Can you resubmit it as a proper patch ? You may also want to
capture in commit message saying hugetlbfs file system also will not be
registered. 

>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index d19b30a..c7aa477 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -1017,6 +1017,11 @@ static int __init init_hugetlbfs_fs(void)
>  	int error;
>  	int i;
>  
> +	if (!hugepages_supported()) {
> +		printk(KERN_ERR "hugetlbfs: Disabling because there are no supported page sizes\n");
> +		return -ENOTSUPP;
> +	}
> +
>  	error = bdi_init(&hugetlbfs_backing_dev_info);
>  	if (error)
>  		return error;
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 8c43cc4..0aea8de 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -450,4 +450,14 @@ static inline spinlock_t *huge_pte_lock(struct hstate *h,
>  	return ptl;
>  }
>  
> +static inline bool hugepages_supported(void)
> +{
> +	/*
> +	 * Some platform decide whether they support huge pages at boot
> +	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
> +	 * there is no such support
> +	 */
> +	return HPAGE_SHIFT != 0;
> +}
> +
>  #endif /* _LINUX_HUGETLB_H */
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c01cb9f..1c99585 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1949,11 +1949,7 @@ module_exit(hugetlb_exit);
>  
>  static int __init hugetlb_init(void)
>  {
> -	/* Some platform decide whether they support huge pages at boot
> -	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
> -	 * there is no such support
> -	 */
> -	if (HPAGE_SHIFT == 0)
> +	if (!hugepages_supported())
>  		return 0;
>  
>  	if (!size_to_hstate(default_hstate_size)) {
> @@ -2069,6 +2065,9 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
>  	unsigned long tmp;
>  	int ret;
>  
> +	if (!hugepages_supported())
> +		return -ENOTSUPP;
> +
>  	tmp = h->max_huge_pages;
>  
>  	if (write && h->order >= MAX_ORDER)
> @@ -2122,6 +2121,9 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
>  	unsigned long tmp;
>  	int ret;
>  
> +	if (!hugepages_supported())
> +		return -ENOTSUPP;
> +
>  	tmp = h->nr_overcommit_huge_pages;
>  
>  	if (write && h->order >= MAX_ORDER)
> @@ -2147,6 +2149,8 @@ out:
>  void hugetlb_report_meminfo(struct seq_file *m)
>  {
>  	struct hstate *h = &default_hstate;
> +	if (!hugepages_supported())
> +		return;
>  	seq_printf(m,
>  			"HugePages_Total:   %5lu\n"
>  			"HugePages_Free:    %5lu\n"
> @@ -2163,6 +2167,8 @@ void hugetlb_report_meminfo(struct seq_file *m)
>  int hugetlb_report_node_meminfo(int nid, char *buf)
>  {
>  	struct hstate *h = &default_hstate;
> +	if (!hugepages_supported())
> +		return 0;
>  	return sprintf(buf,
>  		"Node %d HugePages_Total: %5u\n"
>  		"Node %d HugePages_Free:  %5u\n"
> @@ -2177,6 +2183,9 @@ void hugetlb_show_meminfo(void)
>  	struct hstate *h;
>  	int nid;
>  
> +	if (!hugepages_supported())
> +		return;
> +
>  	for_each_node_state(nid, N_MEMORY)
>  		for_each_hstate(h)
>  			pr_info("Node %d hugepages_total=%u hugepages_free=%u hugepages_surp=%u hugepages_size=%lukB\n",
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
