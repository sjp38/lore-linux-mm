Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D72256B0038
	for <linux-mm@kvack.org>; Tue,  2 May 2017 19:34:32 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z125so21572901itc.4
        for <linux-mm@kvack.org>; Tue, 02 May 2017 16:34:32 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k6si21199990ioo.117.2017.05.02.16.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 16:34:32 -0700 (PDT)
Subject: Re: [PATCH RFC] hugetlbfs 'noautofill' mount option
References: <326e38dd-b4a8-e0ca-6ff7-af60e8045c74@oracle.com>
 <b0efc671-0d7a-0aef-5646-a635478c31b0@oracle.com>
 <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <03127895-3c5a-5182-82de-3baa3116749e@oracle.com>
Date: Tue, 2 May 2017 16:34:18 -0700
MIME-Version: 1.0
In-Reply-To: <7ff6fb32-7d16-af4f-d9d5-698ab7e9e14b@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 5/2/17 2:32 PM, Dave Hansen wrote:
> On 05/01/2017 11:00 AM, Prakash Sangappa wrote:
>> This patch adds a new hugetlbfs mount option 'noautofill', to indicate that
>> pages should not be allocated at page fault time when accessed thru mmapped
>> address.
> I think the main argument against doing something like this is further
> specializing hugetlbfs.  I was really hoping that userfaultfd would be
> usable for your needs here.
>
> Could you elaborate on other options that you considered?  Did you look
> at userfaultfd?  What about an madvise() option that disallows backing
> allocations?


Yes, we did consider userfaultfd and madvise(). The use case in mind is 
the database.

With a database, large number of single threaded processes are involved 
which
will map hugetlbfs file and use it for shared memory. The concern with 
using
userfaultfd is the overhead of setup and having an additional thread per 
process
to monitor the userfaultfd. Even if the additional thread can be 
avoided, by using
an external monitor process and  each process sending the userfaultfd to 
this
monitor process, setup overhead exists.

Similarly, a madvise() option also requires additional system call by every
process mapping the file, this is considered a overhead for the database.

If we do consider a new madvise() option, will it be acceptable since 
this will be
specifically for hugetlbfs file mappings? If so, would a new flag to mmap()
call itself be acceptable, which would define the proposed behavior?. 
That way
no additional system calls need to be made. Again this mmap flag would be
applicable  specifically to hugetlbfs file mappings

With the proposed mount option, it would enforce one consistent behavior
and the application using this filesystem would not have to take additional
steps as with userfaultfd or madvise().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
