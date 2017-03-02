Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12FC56B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:49:00 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t184so82231801pgt.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:49:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si6633419pgs.213.2017.03.01.22.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 22:48:59 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v226mafW131197
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 01:48:58 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xcv3unrg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Mar 2017 01:48:58 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 2 Mar 2017 16:48:56 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id AE9A62CE8046
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 17:48:54 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v226mkBY50725042
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 17:48:54 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v226mMFP026008
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 17:48:22 +1100
Subject: Re: mm allocation failure and hang when running xfstests generic/269
 on xfs
References: <20170301044634.rgidgdqqiiwsmfpj@XZHOUW.usersys.redhat.com>
 <20170302003731.GB24593@infradead.org>
 <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 2 Mar 2017 12:17:47 +0530
MIME-Version: 1.0
In-Reply-To: <20170302051900.ct3xbesn2ku7ezll@XZHOUW.usersys.redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d4c2cf89-8d82-ea78-b742-5bf6923a69c1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiong Zhou <xzhou@redhat.com>, Christoph Hellwig <hch@infradead.org>, mhocko@suse.com
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On 03/02/2017 10:49 AM, Xiong Zhou wrote:
> On Wed, Mar 01, 2017 at 04:37:31PM -0800, Christoph Hellwig wrote:
>> On Wed, Mar 01, 2017 at 12:46:34PM +0800, Xiong Zhou wrote:
>>> Hi,
>>>
>>> It's reproduciable, not everytime though. Ext4 works fine.
>> On ext4 fsstress won't run bulkstat because it doesn't exist.  Either
>> way this smells like a MM issue to me as there were not XFS changes
>> in that area recently.
> Yap.
> 
> First bad commit:
> 
> commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Fri Feb 24 14:58:53 2017 -0800
> 
>     vmalloc: back off when the current task is killed
> 
> Reverting this commit on top of
>   e5d56ef Merge tag 'watchdog-for-linus-v4.11'
> survives the tests.

Does fsstress test or the system hang ? I am not familiar with this
code but If it's the test which is getting hung and its hitting this
new check introduced by the above commit that means the requester is
currently being killed by OOM killer for some other memory allocation
request. Then is not this kind if memory alloc failure expected ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
