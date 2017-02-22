Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0095B6B0038
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 12:50:28 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id h10so3177599ith.2
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 09:50:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x127si2240737itd.17.2017.02.22.09.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 09:50:27 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1MHmjE4110878
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 12:50:26 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28ruy1049g-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 12:50:26 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 22 Feb 2017 17:50:23 -0000
Subject: Re: [PATCH 2/2] mm/cgroup: delay soft limit data allocation
References: <1487779091-31381-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487779091-31381-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170222171132.GB26472@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 22 Feb 2017 18:50:19 +0100
MIME-Version: 1.0
In-Reply-To: <20170222171132.GB26472@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <3b8d0a31-d869-4564-0e03-ac621af43ce7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 22/02/2017 18:11, Michal Hocko wrote:
> On Wed 22-02-17 16:58:11, Laurent Dufour wrote:
> [...]
>>  static struct mem_cgroup_tree_per_node *
>>  soft_limit_tree_node(int nid)
>>  {
>> @@ -465,6 +497,8 @@ static void mem_cgroup_update_tree(struct mem_cgroup *memcg, struct page *page)
>>  	struct mem_cgroup_tree_per_node *mctz;
>>  
>>  	mctz = soft_limit_tree_from_page(page);
>> +	if (!mctz)
>> +		return;
>>  	/*
>>  	 * Necessary to update all ancestors when hierarchy is used.
>>  	 * because their event counter is not touched.
>> @@ -502,7 +536,8 @@ static void mem_cgroup_remove_from_trees(struct mem_cgroup *memcg)
>>  	for_each_node(nid) {
>>  		mz = mem_cgroup_nodeinfo(memcg, nid);
>>  		mctz = soft_limit_tree_node(nid);
>> -		mem_cgroup_remove_exceeded(mz, mctz);
>> +		if (mctz)
>> +			mem_cgroup_remove_exceeded(mz, mctz);
>>  	}
>>  }
>>  
> 
> this belongs to the previous patch, right?

It may. I made the first patch fixing the panic I saw but if you prefer
this to be part of the first one, fair enough.
Tell me what you like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
