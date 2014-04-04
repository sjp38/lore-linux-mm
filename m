Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EC4256B006C
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 20:43:07 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so2536537pdb.14
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 17:43:07 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id xk5si2005362pbc.271.2014.04.03.17.43.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 17:43:06 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 4 Apr 2014 06:13:03 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 521911258048
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 06:15:30 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s340h4nX66453720
	for <linux-mm@kvack.org>; Fri, 4 Apr 2014 06:13:05 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s340gw4F015793
	for <linux-mm@kvack.org>; Fri, 4 Apr 2014 06:12:59 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: hugetlb: ensure hugepage access is denied if hugepages are not supported
In-Reply-To: <20140403231413.GB17412@linux.vnet.ibm.com>
References: <20140403231413.GB17412@linux.vnet.ibm.com>
Date: Fri, 04 Apr 2014 06:12:56 +0530
Message-ID: <87d2gxorfz.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, nyc@holomorphy.com, benh@kernel.crashing.org, paulus@samba.org, anton@samba.org, akpm@linux-foundation.org

Nishanth Aravamudan <nacc@linux.vnet.ibm.com> writes:

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
> This does make hugetlbfs not supported (not registered at all) in this
> environment. I believe this is fine, as there are no valid hugepages and
> that won't change at runtime.
>
> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index d19b30a..cc8fcc7 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -1017,6 +1017,11 @@ static int __init init_hugetlbfs_fs(void)
>  	int error;
>  	int i;
>
> +	if (!hugepages_supported()) {
> +		printk(KERN_ERR "hugetlbfs: Disabling because there are no supported hugepage sizes\n");
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
