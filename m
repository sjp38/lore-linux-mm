Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F24D56B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 05:24:26 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 65so49411268pgi.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 02:24:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m7si4236264pgd.112.2017.03.01.02.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 02:24:26 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v21AMAZD002123
	for <linux-mm@kvack.org>; Wed, 1 Mar 2017 05:24:25 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28wvdg0be9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Mar 2017 05:24:23 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 1 Mar 2017 03:23:59 -0700
Subject: Re: Ext4 stack trace with savedwrite patches
References: <87innzu233.fsf@skywalker.in.ibm.com>
 <20170301094913.GB20512@quack2.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 1 Mar 2017 15:53:52 +0530
MIME-Version: 1.0
In-Reply-To: <20170301094913.GB20512@quack2.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <d6569967-fecd-2708-9e18-cf0964c362bd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, linux-mm@kvack.org



On Wednesday 01 March 2017 03:19 PM, Jan Kara wrote:
> Hi,
>
> On Fri 24-02-17 19:23:52, Aneesh Kumar K.V wrote:
>> I am hitting this while running stress test with the saved write patch
>> series. I guess we are missing a set page dirty some where. I will
>> continue to debug this, but if you have any suggestion let me know.
> <snip>
>
> So this warning can happen when page got dirtied but ->page_mkwrite() was
> not called. I don't know details of how autonuma works but a quick look
> suggests that autonuma can also do numa hinting faults for file pages.
> So the following seems to be possible:
>
> Autonuma decides to check for accesses to a mapped shared file page that is
> dirty. pte_present gets cleared, pte_write stays set (due to logic
> introduced in commit b191f9b106 "mm: numa: preserve PTE write permissions
> across a NUMA hinting fault"). Then page writeback happens, page_mkclean()
> is called to write-protect the page. However page_check_address() returns
> NULL for the PTE (__page_check_address() returns NULL for !pte_present
> PTEs) so we don't clear pte_write bit in page_mkclean_one().


Even though we cleared _PAGE_PRESENT a pte_present() check return true 
for numa fault pte. The problem with savedwrite patch series that i 
quoted in the original mail was that pte_write() was checking on 
_PAGE_WRITE where as numa fault stashed the write bit as savedwrite bit. 
Hence page_mkclean was skipping those ptes.

> Sometime later
> a process looks at the page through mmap, takes NUMA fault and
> do_numa_page() reestablishes a writeable mapping of the page although the
> filesystem does not expect there to be one and funny things happen
> afterwards...
>
> I'll defer to more mm-savvy people to decide how this should be fixed. My
> naive understanding is that page_mkclean_one() should clear the pte_write
> bit even for pages that are undergoing NUMA probation but I'm not sure
> about a preferred way to achieve that...
>
>


Yes found that and finally decided that instead of fixing all those code 
path, we can update pte_write to handle autonuma preserved write bit.

https://lkml.kernel.org/r/1488203787-17849-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
