Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26ACB44088B
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 00:02:28 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 63so5720613pgc.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 21:02:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b11si3945133pfd.435.2017.08.24.21.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 21:02:25 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7P40Mvo066947
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 00:02:25 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cj63756gx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 00:02:24 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 25 Aug 2017 14:02:22 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7P42Lef26542298
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:02:21 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7P42LPS006847
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:02:21 +1000
Subject: Re: [PATCH] xfs: Drop setting redundant PF_KSWAPD in kswapd context
References: <20170824104247.8288-1-khandual@linux.vnet.ibm.com>
 <20170824105635.GA5965@dhcp22.suse.cz> <20170825000137.GI21024@dastard>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 25 Aug 2017 09:32:14 +0530
MIME-Version: 1.0
In-Reply-To: <20170825000137.GI21024@dastard>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f60c57f4-c7e2-9ae0-38e8-80c3f77f65e0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, dchinner@redhat.com, bfoster@redhat.com, sandeen@sandeen.net

On 08/25/2017 05:31 AM, Dave Chinner wrote:
> On Thu, Aug 24, 2017 at 12:56:35PM +0200, Michal Hocko wrote:
>> On Thu 24-08-17 16:12:47, Anshuman Khandual wrote:
>>> xfs_btree_split() calls xfs_btree_split_worker() with args.kswapd set
>>> if current->flags alrady has PF_KSWAPD. Hence we should not again add
>>> PF_KSWAPD into the current flags inside kswapd context. So drop this
>>> redundant flag addition.
>>
>> I am not familiar with the code but your change seems incorect. The
>> whole point of args->kswapd is to convey the kswapd context to the
>> worker which is obviously running in a different context. So this patch
>> loses the kswapd context.
> 
> Yup. That's what the code does, and removing the PF_KSWAPD from it
> will break it.

The worker thread need to inherit these flags. Thanks for pointing out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
