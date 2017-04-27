Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 779A96B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 13:26:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d79so1688031wma.0
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:26:24 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id k203si22230wma.165.2017.04.27.10.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 10:26:21 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id z129so6057257wmb.1
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 10:26:21 -0700 (PDT)
Subject: Re: [PATCH man-pages 1/2] userfaultfd.2: start documenting
 non-cooperative events
References: <1493302474-4701-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493302474-4701-2-git-send-email-rppt@linux.vnet.ibm.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <a95f9ae6-f7db-1ed9-6e25-99ced1fd37a3@gmail.com>
Date: Thu, 27 Apr 2017 19:26:16 +0200
MIME-Version: 1.0
In-Reply-To: <1493302474-4701-2-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: mtk.manpages@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Hi Mike,

I've applied this, but have some questions/points I think 
further clarification.

On 04/27/2017 04:14 PM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  man2/userfaultfd.2 | 135 ++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 128 insertions(+), 7 deletions(-)
> 
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index cfea5cb..44af3e4 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -75,7 +75,7 @@ flag in
>  .PP
>  When the last file descriptor referring to a userfaultfd object is closed,
>  all memory ranges that were registered with the object are unregistered
> -and unread page-fault events are flushed.
> +and unread events are flushed.
>  .\"
>  .SS Usage
>  The userfaultfd mechanism is designed to allow a thread in a multithreaded
> @@ -99,6 +99,20 @@ In such non-cooperative mode,
>  the process that monitors userfaultfd and handles page faults
>  needs to be aware of the changes in the virtual memory layout
>  of the faulting process to avoid memory corruption.
> +
> +Starting from Linux 4.11,
> +userfaultfd may notify the fault-handling threads about changes
> +in the virtual memory layout of the faulting process.
> +In addition, if the faulting process invokes
> +.BR fork (2)
> +system call,
> +the userfaultfd objects associated with the parent may be duplicated
> +into the child process and the userfaultfd monitor will be notified
> +about the file descriptor associated with the userfault objects

What does "notified about the file descriptor" mean?

> +created for the child process,
> +which allows userfaultfd monitor to perform user-space paging
> +for the child process.
> +
>  .\" FIXME elaborate about non-cooperating mode, describe its limitations
>  .\" for kernels before 4.11, features added in 4.11
>  .\" and limitations remaining in 4.11
> @@ -144,6 +158,10 @@ Details of the various
>  operations can be found in
>  .BR ioctl_userfaultfd (2).
>  
> +Since Linux 4.11, events other than page-fault may enabled during
> +.B UFFDIO_API
> +operation.
> +
>  Up to Linux 4.11,
>  userfaultfd can be used only with anonymous private memory mappings.
>  
> @@ -156,7 +174,8 @@ Each
>  .BR read (2)
>  from the userfaultfd file descriptor returns one or more
>  .I uffd_msg
> -structures, each of which describes a page-fault event:
> +structures, each of which describes a page-fault event
> +or an event required for the non-cooperative userfaultfd usage:
>  
>  .nf
>  .in +4n
> @@ -168,6 +187,23 @@ struct uffd_msg {
>              __u64 flags;        /* Flags describing fault */
>              __u64 address;      /* Faulting address */
>          } pagefault;
> +        struct {
> +            __u32 ufd;          /* userfault file descriptor
> +                                   of the child process */
> +        } fork;                 /* since Linux 4.11 */
> +        struct {
> +            __u64 from;         /* old address of the
> +                                   remapped area */
> +            __u64 to;           /* new address of the
> +                                   remapped area */
> +            __u64 len;          /* original mapping length */
> +        } remap;                /* since Linux 4.11 */
> +        struct {
> +            __u64 start;        /* start address of the
> +                                   removed area */
> +            __u64 end;          /* end address of the
> +                                   removed area */
> +        } remove;               /* since Linux 4.11 */
>          ...
>      } arg;
>  
> @@ -194,14 +230,73 @@ structure are as follows:
>  .TP
>  .I event
>  The type of event.
> -Currently, only one value can appear in this field:
> -.BR UFFD_EVENT_PAGEFAULT ,
> -which indicates a page-fault event.
> +Depending of the event type,
> +different fields of the
> +.I arg
> +union represent details required for the event processing.
> +The non-page-fault events are generated only when appropriate feature
> +is enabled during API handshake with
> +.B UFFDIO_API
> +.BR ioctl (2).
> +
> +The following values can appear in the
> +.I event
> +field:
> +.RS
> +.TP
> +.B UFFD_EVENT_PAGEFAULT
> +A page-fault event.
> +The page-fault details are available in the
> +.I pagefault
> +field.
>  .TP
> -.I address
> +.B UFFD_EVENT_FORK
> +Generated when the faulting process invokes
> +.BR fork (2)
> +system call.
> +The event details are available in the
> +.I fork
> +field.
> +.\" FIXME descirbe duplication of userfault file descriptor during fork
> +.TP
> +.B UFFD_EVENT_REMAP
> +Generated when the faulting process invokes
> +.BR mremap (2)
> +system call.
> +The event details are available in the
> +.I remap
> +field.
> +.TP
> +.B UFFD_EVENT_REMOVE
> +Generated when the faulting process invokes
> +.BR madvise (2)
> +system call with
> +.BR MADV_DONTNEED
> +or
> +.BR MADV_REMOVE
> +advice.
> +The event details are available in the
> +.I remove
> +field.
> +.TP
> +.B UFFD_EVENT_UNMAP
> +Generated when the faulting process unmaps a memory range,
> +either explicitly using
> +.BR munmap (2)
> +system call or implicitly during
> +.BR mmap (2)
> +or
> +.BR mremap (2)
> +system calls.
> +The event details are available in the
> +.I remove
> +field.
> +.RE
> +.TP
> +.I pagefault.address
>  The address that triggered the page fault.
>  .TP
> -.I flags
> +.I pagefault.flags
>  A bit mask of flags that describe the event.
>  For
>  .BR UFFD_EVENT_PAGEFAULT ,
> @@ -218,6 +313,32 @@ otherwise it is a read fault.
>  .\"
>  .\" UFFD_PAGEFAULT_FLAG_WP is not yet supported.
>  .RE
> +.TP
> +.I fork.ufd
> +The file descriptor associated with the userfault object
> +created for the child process
> +.TP
> +.I remap.from
> +The original address of the memory range that was remapped using
> +.BR mremap (2).
> +.TP
> +.I remap.to
> +The new address of the memory range that was remapped using
> +.BR mremap (2).
> +.TP
> +.I remap.len
> +The original length of the the memory range that was remapped using
> +.BR mremap (2).
> +.TP
> +.I remove.start
> +The start address of the memory range that was freed using
> +.BR madvise (2)
> +or unmapped
> +.TP
> +.I remove.end
> +The end address of the memory range that was freed using
> +.BR madvise (2)
> +or unmapped
>  .PP
>  A
>  .BR read (2)

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
