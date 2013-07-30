Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 303F46B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 13:27:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2013 03:19:46 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id E2C7B2CE804C
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 03:27:42 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UHRWOS7012726
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 03:27:32 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6UHRfg0021455
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 03:27:42 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/18] mm, hugetlb: unify region structure handling
In-Reply-To: <1375075929-6119-4-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com> <1375075929-6119-4-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 30 Jul 2013 22:57:37 +0530
Message-ID: <87wqo8ot4m.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Currently, to track a reserved and allocated region, we use two different
> ways for MAP_SHARED and MAP_PRIVATE. For MAP_SHARED, we use
> address_mapping's private_list and, for MAP_PRIVATE, we use a resv_map.
> Now, we are preparing to change a coarse grained lock which protect
> a region structure to fine grained lock, and this difference hinder it.
> So, before changing it, unify region structure handling.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index a3f868a..a1ae3ada 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -366,7 +366,12 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
>
>  static void hugetlbfs_evict_inode(struct inode *inode)
>  {
> +	struct resv_map *resv_map;
> +
>  	truncate_hugepages(inode, 0);
> +	resv_map = (struct resv_map *)inode->i_mapping->private_data;
> +	if (resv_map)

can resv_map == NULL ?


> +		kref_put(&resv_map->refs, resv_map_release);

Also the kref_put is confusing. For shared mapping we don't have ref
count incremented right ? So may be you can directly call
resv_map_release or add a comment around explaining this more ?


>  	clear_inode(inode);
>  }
>
> @@ -468,6 +473,11 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
>  					umode_t mode, dev_t dev)
>  {
>  	struct inode *inode;
> +	struct resv_map *resv_map;
> +
> +	resv_map = resv_map_alloc();
> +	if (!resv_map)
> +		return NULL;

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
