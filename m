Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB78A6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:02:36 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o65so79269058qkl.12
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:02:36 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id z12si9828329qta.120.2017.07.26.12.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:02:36 -0700 (PDT)
Subject: Re: [RESEND PATCH 2/2] userfaultfd: selftest: Add tests for
 UFFD_FREATURE_SIGBUS
References: <1500958062-953846-1-git-send-email-prakash.sangappa@oracle.com>
 <1500958062-953846-3-git-send-email-prakash.sangappa@oracle.com>
 <20170726142723.GW29716@redhat.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <a0cb715f-8652-2526-5580-69aa4ea0e25f@oracle.com>
Date: Wed, 26 Jul 2017 12:02:31 -0700
MIME-Version: 1.0
In-Reply-To: <20170726142723.GW29716@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com



On 7/26/17 7:27 AM, Andrea Arcangeli wrote:
> On Tue, Jul 25, 2017 at 12:47:42AM -0400, Prakash Sangappa wrote:
>> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
>> ---
>>   tools/testing/selftests/vm/userfaultfd.c |  121 +++++++++++++++++++++++++++++-
>>   1 files changed, 118 insertions(+), 3 deletions(-)
> Like Mike said, some comment about the test would be better, commit
> messages are never one liners in the kernel.

Ok

>
>> @@ -408,6 +409,7 @@ static int copy_page(int ufd, unsigned long offset)
>>   				userfaults++;
>>   			break;
>>   		case UFFD_EVENT_FORK:
>> +			close(uffd);
>>   			uffd = msg.arg.fork.ufd;
>>   			pollfd[0].fd = uffd;
>>   			break;
> Isn't this fd leak bugfix independent of the rest of the changes? The
> only side effects should have been that it could run out of fds, but I
> assume this was found by source review as I doubt it could run out of fds.
> This could be splitted off in a separate patch.

Not just the fd leak, it causes problems here with the addition of the
new test userfaultfd_sig_test(). Since the original vma registration
persists in the parent, subsequent registration in userfaultfd_events_test()
fails with 'EBUSY' error, as userfault implementation does not allow
registering same vma with another uffd, while one exists.

Therefore, will need this change. I could just leave this fix here along
with the rest of the changes, will that be ok?

-Prakash

> Overall it looks a good test also exercising UFFD_EVENT_FORK at the
> same time.
>
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
