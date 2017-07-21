Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 689E66B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 06:38:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d193so62678016pgc.0
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 03:38:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h2si2921827pgc.498.2017.07.21.03.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 03:38:37 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6LAa3BI139864
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 06:38:36 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bufdyhg8u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 06:38:36 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 21 Jul 2017 20:38:33 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6LAcVBW30343348
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 20:38:31 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6LAcTvJ018751
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 20:38:30 +1000
Subject: Re: [PATCH] selftests/vm: Add test to validate mirror functionality
 with mremap
References: <20170720093651.22106-1-khandual@linux.vnet.ibm.com>
 <965cf169-572c-537b-6784-766edcb4eb19@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 21 Jul 2017 16:08:23 +0530
MIME-Version: 1.0
In-Reply-To: <965cf169-572c-537b-6784-766edcb4eb19@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f1d97d49-df0a-4da9-520e-cc55e3d635c0@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

On 07/21/2017 04:49 AM, Mike Kravetz wrote:
> On 07/20/2017 02:36 AM, Anshuman Khandual wrote:
>> This adds a test to validate mirror functionality with mremap()
>> system call on shared anon mappings.
>>
>> Suggested-by: Mike Kravetz <mike.kravetz@oracle.com>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  tools/testing/selftests/vm/Makefile                |  1 +
>>  .../selftests/vm/mremap_mirror_shared_anon.c       | 54 ++++++++++++++++++++++
> 
> This may be a better fit in LTP where there are already several other
> mremap tests.  I honestly do not know the best place for such a test.

Yeah but these days self tests try to target smaller functional
tests which can run quickly and validate something, hence thought
this may be appropriate as a self test.

> 
>>  2 files changed, 55 insertions(+)
>>  create mode 100644 tools/testing/selftests/vm/mremap_mirror_shared_anon.c
>>
>> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
>> index cbb29e4..11657ff5 100644
>> --- a/tools/testing/selftests/vm/Makefile
>> +++ b/tools/testing/selftests/vm/Makefile
>> @@ -17,6 +17,7 @@ TEST_GEN_FILES += transhuge-stress
>>  TEST_GEN_FILES += userfaultfd
>>  TEST_GEN_FILES += mlock-random-test
>>  TEST_GEN_FILES += virtual_address_range
>> +TEST_GEN_FILES += mremap_mirror_shared_anon
>>  
>>  TEST_PROGS := run_vmtests
>>  
>> diff --git a/tools/testing/selftests/vm/mremap_mirror_shared_anon.c b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
>> new file mode 100644
>> index 0000000..b0adbb2
>> --- /dev/null
>> +++ b/tools/testing/selftests/vm/mremap_mirror_shared_anon.c
>> @@ -0,0 +1,54 @@
>> +/*
>> + * Test to verify mirror functionality with mremap() system
>> + * call for shared anon mappings.
>> + *
>> + * Copyright (C) 2017 Anshuman Khandual, IBM Corporation
>> + *
>> + * Licensed under GPL V2
>> + */
>> +#include <stdio.h>
>> +#include <string.h>
>> +#include <unistd.h>
>> +#include <errno.h>
>> +#include <sys/mman.h>
>> +#include <sys/time.h>
>> +
>> +#define PATTERN		0xbe
>> +#define ALLOC_SIZE	0x10000UL /* Works for 64K and 4K pages */
> 
> Why hardcode?  You could use sysconf to get page size and use some
> multiple of that.

Sure, will do that.

> 
>> +
>> +int test_mirror(char *old, char *new, unsigned long size)
>> +{
>> +	unsigned long i;
>> +
>> +	for (i = 0; i < size; i++) {
>> +		if (new[i] != old[i]) {
>> +			printf("Mismatch at new[%lu] expected "
>> +				"%d received %d\n", i, old[i], new[i]);
>> +			return 1;
>> +		}
>> +	}
>> +	return 0;
>> +}
>> +
>> +int main(int argc, char *argv[])
>> +{
>> +	char *ptr, *mirror_ptr;
>> +
>> +	ptr = mmap(NULL, ALLOC_SIZE, PROT_READ | PROT_WRITE,
>> +			MAP_SHARED | MAP_ANONYMOUS, -1, 0);
>> +	if (ptr == MAP_FAILED) {
>> +		perror("map() failed");
>> +		return -1;
>> +	}
>> +	memset(ptr, PATTERN, ALLOC_SIZE);
>> +
>> +	mirror_ptr =  (char *) mremap(ptr, 0, ALLOC_SIZE, 1);
> 
> Why hardcode 1?  You really want the MREMAP_MAYMOVE flag.  Right?

Right, missed that. My bad.

> 
>> +	if (mirror_ptr == MAP_FAILED) {
>> +		perror("mremap() failed");
>> +		return -1;
>> +	}
>> +
>> +	if (test_mirror(ptr, mirror_ptr, ALLOC_SIZE))
>> +		return 1;
>> +	return 0;
>> +}
> 
> You may want to expand the test to make sure mremap(old_size == 0)
> fails for private mappings.  Of course, this assumes my proposed
> patch gets in.  Until then, it will succeed and create a new unrelated
> mapping.

Even without your patch, the data in the new mapping still does
not match the original one. Anyway, will accommodate private
anon mapping as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
