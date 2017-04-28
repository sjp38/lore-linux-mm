Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF046B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:45:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b17so42233881pfd.1
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:45:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q3si5583042pfd.238.2017.04.28.02.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Apr 2017 02:45:29 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3S9iGiY121801
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:45:28 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a3j0md8e0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:45:28 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 28 Apr 2017 10:45:25 +0100
Date: Fri, 28 Apr 2017 12:45:16 +0300
In-Reply-To: <a95f9ae6-f7db-1ed9-6e25-99ced1fd37a3@gmail.com>
References: <1493302474-4701-1-git-send-email-rppt@linux.vnet.ibm.com> <1493302474-4701-2-git-send-email-rppt@linux.vnet.ibm.com> <a95f9ae6-f7db-1ed9-6e25-99ced1fd37a3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH man-pages 1/2] userfaultfd.2: start documenting non-cooperative events
From: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Message-Id: <190E3CFC-492F-4672-9385-9C3D8F57F26C@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org



On April 27, 2017 8:26:16 PM GMT+03:00, "Michael Kerrisk (man-pages)" <mtk=
=2Emanpages@gmail=2Ecom> wrote:
>Hi Mike,
>
>I've applied this, but have some questions/points I think=20
>further clarification=2E
>
>On 04/27/2017 04:14 PM, Mike Rapoport wrote:
>> Signed-off-by: Mike Rapoport <rppt@linux=2Evnet=2Eibm=2Ecom>
>> ---
>>  man2/userfaultfd=2E2 | 135
>++++++++++++++++++++++++++++++++++++++++++++++++++---
>>  1 file changed, 128 insertions(+), 7 deletions(-)
>>=20
>> diff --git a/man2/userfaultfd=2E2 b/man2/userfaultfd=2E2
>> index cfea5cb=2E=2E44af3e4 100644
>> --- a/man2/userfaultfd=2E2
>> +++ b/man2/userfaultfd=2E2
>> @@ -75,7 +75,7 @@ flag in
>>  =2EPP
>>  When the last file descriptor referring to a userfaultfd object is
>closed,
>>  all memory ranges that were registered with the object are
>unregistered
>> -and unread page-fault events are flushed=2E
>> +and unread events are flushed=2E
>>  =2E\"
>>  =2ESS Usage
>>  The userfaultfd mechanism is designed to allow a thread in a
>multithreaded
>> @@ -99,6 +99,20 @@ In such non-cooperative mode,
>>  the process that monitors userfaultfd and handles page faults
>>  needs to be aware of the changes in the virtual memory layout
>>  of the faulting process to avoid memory corruption=2E
>> +
>> +Starting from Linux 4=2E11,
>> +userfaultfd may notify the fault-handling threads about changes
>> +in the virtual memory layout of the faulting process=2E
>> +In addition, if the faulting process invokes
>> +=2EBR fork (2)
>> +system call,
>> +the userfaultfd objects associated with the parent may be duplicated
>> +into the child process and the userfaultfd monitor will be notified
>> +about the file descriptor associated with the userfault objects
>
>What does "notified about the file descriptor" mean?

Well, seems that I've made this one really awkward :)
When the monitored process forks, all the userfault objects associated=E2=
=80=8B with it are duplicated into the child process=2E For each duplicated=
 object, userfault generates event of type UFFD_EVENT_FORK and the uffdio_m=
sg for this event contains the file descriptor that should be used to manip=
ulate the duplicated userfault object=2E
Hope this clarifies=2E

>> +created for the child process,
>> +which allows userfaultfd monitor to perform user-space paging
>> +for the child process=2E
>> +
>>  =2E\" FIXME elaborate about non-cooperating mode, describe its
>limitations
>>  =2E\" for kernels before 4=2E11, features added in 4=2E11
>>  =2E\" and limitations remaining in 4=2E11
>> @@ -144,6 +158,10 @@ Details of the various
>>  operations can be found in
>>  =2EBR ioctl_userfaultfd (2)=2E
>> =20
>> +Since Linux 4=2E11, events other than page-fault may enabled during
>> +=2EB UFFDIO_API
>> +operation=2E
>> +
>>  Up to Linux 4=2E11,
>>  userfaultfd can be used only with anonymous private memory mappings=2E
>> =20
>> @@ -156,7 +174,8 @@ Each
>>  =2EBR read (2)
>>  from the userfaultfd file descriptor returns one or more
>>  =2EI uffd_msg
>> -structures, each of which describes a page-fault event:
>> +structures, each of which describes a page-fault event
>> +or an event required for the non-cooperative userfaultfd usage:
>> =20
>>  =2Enf
>>  =2Ein +4n
>> @@ -168,6 +187,23 @@ struct uffd_msg {
>>              __u64 flags;        /* Flags describing fault */
>>              __u64 address;      /* Faulting address */
>>          } pagefault;
>> +        struct {
>> +            __u32 ufd;          /* userfault file descriptor
>> +                                   of the child process */
>> +        } fork;                 /* since Linux 4=2E11 */
>> +        struct {
>> +            __u64 from;         /* old address of the
>> +                                   remapped area */
>> +            __u64 to;           /* new address of the
>> +                                   remapped area */
>> +            __u64 len;          /* original mapping length */
>> +        } remap;                /* since Linux 4=2E11 */
>> +        struct {
>> +            __u64 start;        /* start address of the
>> +                                   removed area */
>> +            __u64 end;          /* end address of the
>> +                                   removed area */
>> +        } remove;               /* since Linux 4=2E11 */
>>          =2E=2E=2E
>>      } arg;
>> =20
>> @@ -194,14 +230,73 @@ structure are as follows:
>>  =2ETP
>>  =2EI event
>>  The type of event=2E
>> -Currently, only one value can appear in this field:
>> -=2EBR UFFD_EVENT_PAGEFAULT ,
>> -which indicates a page-fault event=2E
>> +Depending of the event type,
>> +different fields of the
>> +=2EI arg
>> +union represent details required for the event processing=2E
>> +The non-page-fault events are generated only when appropriate
>feature
>> +is enabled during API handshake with
>> +=2EB UFFDIO_API
>> +=2EBR ioctl (2)=2E
>> +
>> +The following values can appear in the
>> +=2EI event
>> +field:
>> +=2ERS
>> +=2ETP
>> +=2EB UFFD_EVENT_PAGEFAULT
>> +A page-fault event=2E
>> +The page-fault details are available in the
>> +=2EI pagefault
>> +field=2E
>>  =2ETP
>> -=2EI address
>> +=2EB UFFD_EVENT_FORK
>> +Generated when the faulting process invokes
>> +=2EBR fork (2)
>> +system call=2E
>> +The event details are available in the
>> +=2EI fork
>> +field=2E
>> +=2E\" FIXME descirbe duplication of userfault file descriptor during
>fork
>> +=2ETP
>> +=2EB UFFD_EVENT_REMAP
>> +Generated when the faulting process invokes
>> +=2EBR mremap (2)
>> +system call=2E
>> +The event details are available in the
>> +=2EI remap
>> +field=2E
>> +=2ETP
>> +=2EB UFFD_EVENT_REMOVE
>> +Generated when the faulting process invokes
>> +=2EBR madvise (2)
>> +system call with
>> +=2EBR MADV_DONTNEED
>> +or
>> +=2EBR MADV_REMOVE
>> +advice=2E
>> +The event details are available in the
>> +=2EI remove
>> +field=2E
>> +=2ETP
>> +=2EB UFFD_EVENT_UNMAP
>> +Generated when the faulting process unmaps a memory range,
>> +either explicitly using
>> +=2EBR munmap (2)
>> +system call or implicitly during
>> +=2EBR mmap (2)
>> +or
>> +=2EBR mremap (2)
>> +system calls=2E
>> +The event details are available in the
>> +=2EI remove
>> +field=2E
>> +=2ERE
>> +=2ETP
>> +=2EI pagefault=2Eaddress
>>  The address that triggered the page fault=2E
>>  =2ETP
>> -=2EI flags
>> +=2EI pagefault=2Eflags
>>  A bit mask of flags that describe the event=2E
>>  For
>>  =2EBR UFFD_EVENT_PAGEFAULT ,
>> @@ -218,6 +313,32 @@ otherwise it is a read fault=2E
>>  =2E\"
>>  =2E\" UFFD_PAGEFAULT_FLAG_WP is not yet supported=2E
>>  =2ERE
>> +=2ETP
>> +=2EI fork=2Eufd
>> +The file descriptor associated with the userfault object
>> +created for the child process
>> +=2ETP
>> +=2EI remap=2Efrom
>> +The original address of the memory range that was remapped using
>> +=2EBR mremap (2)=2E
>> +=2ETP
>> +=2EI remap=2Eto
>> +The new address of the memory range that was remapped using
>> +=2EBR mremap (2)=2E
>> +=2ETP
>> +=2EI remap=2Elen
>> +The original length of the the memory range that was remapped using
>> +=2EBR mremap (2)=2E
>> +=2ETP
>> +=2EI remove=2Estart
>> +The start address of the memory range that was freed using
>> +=2EBR madvise (2)
>> +or unmapped
>> +=2ETP
>> +=2EI remove=2Eend
>> +The end address of the memory range that was freed using
>> +=2EBR madvise (2)
>> +or unmapped
>>  =2EPP
>>  A
>>  =2EBR read (2)
>
>Cheers,
>
>Michael

--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
