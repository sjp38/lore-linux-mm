Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2AA126B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:54:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p135so7605058qke.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 11:54:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x11si5209578qtf.45.2017.07.26.11.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 11:54:30 -0700 (PDT)
Subject: Re: [RESEND PATCH 2/2] userfaultfd: selftest: Add tests for
 UFFD_FREATURE_SIGBUS
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-3-git-send-email-prakash.sangappa@oracle.com>
 <20170726075347.GA32369@rapoport-lnx>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <bd97fafe-adce-50a5-0ce3-c3fe67b03ff7@oracle.com>
Date: Wed, 26 Jul 2017 11:54:23 -0700
MIME-Version: 1.0
In-Reply-To: <20170726075347.GA32369@rapoport-lnx>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, mike.kravetz@oracle.com



On 7/26/17 12:53 AM, Mike Rapoport wrote:
>> +
>>   /*
>>    * For non-cooperative userfaultfd test we fork() a process that will
>>    * generate pagefaults, will mremap the area monitored by the
>> @@ -585,19 +598,54 @@ static int userfaultfd_open(int features)
>>    * The release of the pages currently generates event for shmem and
>>    * anonymous memory (UFFD_EVENT_REMOVE), hence it is not checked
>>    * for hugetlb.
>> + * For signal test(UFFD_FEATURE_SIGBUS), primarily test signal
>> + * delivery and ensure no userfault events are generated.
> Can you add some details about the tests? E.g. what is the meaning if
> signal_test=1 and signal_test=2 and what is the difference between them?

Ok, I will.

>
>>    */
>> -static int faulting_process(void)
>> +static int faulting_process(int signal_test)
>>   {
>>   	unsigned long nr;
>>   	unsigned long long count;
>>   	unsigned long split_nr_pages;
>> +	unsigned long lastnr;
>> +	struct sigaction act;
>> +	unsigned long signalled=0, sig_repeats = 0;
> Spaces around that '='         ^

Will fix it.
>
>>   	if (test_type != TEST_HUGETLB)
>>   		split_nr_pages = (nr_pages + 1) / 2;
>>   	else
>>   		split_nr_pages = nr_pages;
>>
>> +	if (signal_test) {
>> +		sigbuf = &jbuf;
>> +		memset (&act, 0, sizeof(act));
> There should be no space between function name and open parenthesis.

ok
>
>> +		act.sa_sigaction = sighndl;
>> +		act.sa_flags = SA_SIGINFO;
>> +		if (sigaction(SIGBUS, &act, 0)) {
>> +			perror("sigaction");
>> +			return 1;
>> +		}
>> +		lastnr = (unsigned long)-1;
>> +	}
>> +
>>   	for (nr = 0; nr < split_nr_pages; nr++) {
>> +		if (signal_test) {
>> +			if (sigsetjmp(*sigbuf, 1) != 0) {
>> +				if (nr == lastnr) {
>> +					sig_repeats++;
>> +					continue;
> If I understand correctly, when nr == lastnr we get a repeated signal for
> the same page and this is an error, right?

Yes,

> Why would we continue the test and won't return error immediately?

Yes, it could just return error. I will fix it.
>
>> +				}
>> +
>> +				lastnr = nr;
>> +				if (signal_test == 1) {
>> +					if (copy_page(uffd, nr * page_size))
>> +						signalled++;
>> +				} else {
>> +					signalled++;
>> +					continue;
>> +				}
>> +			}
>> +		}
>> +
>>   		count = *area_count(area_dst, nr);
>>   		if (count != count_verify[nr]) {
>>   			fprintf(stderr,
>> @@ -607,6 +655,8 @@ static int faulting_process(void)
>>   		}
>>   	}
>>
>> +	if (signal_test)
>> +		return signalled != split_nr_pages || sig_repeats != 0;
> I believe return !(signalled == split_nr_pages && sig_repeats == 0) is
> clearer.
> And I blank line after the return statement would be nice :)

Ok.
Will send out v2 patch with the changes.

Thanks,
-Prakash


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
