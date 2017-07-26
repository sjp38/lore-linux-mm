Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE9BC6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:26:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so30478536wrb.2
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 21:26:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 50si4459290wrx.410.2017.07.25.21.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 21:26:23 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6Q4QFQk145857
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:26:22 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bxc1g3um0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:26:22 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 26 Jul 2017 14:25:18 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6Q4PGIX11468962
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:25:16 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6Q4P748011871
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:25:07 +1000
Subject: Re: [PATCH V2] selftests/vm: Add tests to validate mirror
 functionality with mremap
References: <20170725063657.3915-1-khandual@linux.vnet.ibm.com>
 <20170725133604.GA27322@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 26 Jul 2017 09:54:26 +0530
MIME-Version: 1.0
In-Reply-To: <20170725133604.GA27322@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <32236948-422c-3519-7be3-88527895bf92@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On 07/25/2017 07:06 PM, Michal Hocko wrote:
> On Tue 25-07-17 12:06:57, Anshuman Khandual wrote:
> [...]
>> diff --git a/tools/testing/selftests/vm/mremap_mirror_private_anon.c b/tools/testing/selftests/vm/mremap_mirror_private_anon.c
> [...]
>> +	ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
>> +			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
>> +	if (ptr == MAP_FAILED) {
>> +		perror("map() failed");
>> +		return -1;
>> +	}
>> +	memset(ptr, PATTERN, alloc_size);
>> +
>> +	mirror_ptr =  (char *) mremap(ptr, 0, alloc_size, MREMAP_MAYMOVE);
>> +	if (mirror_ptr == MAP_FAILED) {
>> +		perror("mremap() failed");
>> +		return -1;
>> +	}
> 
> What is the point of this test? It will break with Mike's patch very
> soon. Btw. it never worked.

It works now. The new 'mirrored' buffer does not have same elements
as that of the original one. Yes, once Mike's patch is merged, it
will fail during the mremap() call itself IIUC. I can change this
test to verify that mremap() call failure then but now the mismatch
of elements between the buffers is what is expected and is happening.

But if you would like I can change the test to check for mremap()
failure in this case (which will fail in the current mainline but
will pass eventually when Mike's patch is in). Please do suggest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
