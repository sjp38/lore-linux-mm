Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56A7E6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 00:26:00 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k31so7479225qta.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 21:26:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e12si125344qte.32.2017.10.09.21.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 21:25:59 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9A4PiEF055621
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 00:25:58 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dgd11kqcw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 00:25:57 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 10 Oct 2017 05:25:55 +0100
Date: Tue, 10 Oct 2017 07:25:49 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] Userfaultfd: Add description for UFFD_FEATURE_SIGBUS
References: <1507589151-27430-1-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507589151-27430-1-git-send-email-prakash.sangappa@oracle.com>
Message-Id: <20171010042549.GA32311@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, mhocko@suse.com

On Mon, Oct 09, 2017 at 03:45:51PM -0700, Prakash Sangappa wrote:
> Userfaultfd feature UFFD_FEATURE_SIGBUS was merged recently and should
> be available in Linux 4.14 release. This patch is for the manpage
> changes documenting this API.
> 
> Documents the following commit:
> 
> commit 2d6d6f5a09a96cc1fec7ed992b825e05f64cb50e
> Author: Prakash Sangappa <prakash.sangappa@oracle.com>
> Date: Wed Sep 6 16:23:39 2017 -0700
> 
>      mm: userfaultfd: add feature to request for a signal delivery
> 
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
> v2: Incorporated review feedback changes.
> ---
>  man2/ioctl_userfaultfd.2 |  9 +++++++++
>  man2/userfaultfd.2       | 23 +++++++++++++++++++++++
>  2 files changed, 32 insertions(+)
> 
> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> index 60fd29b..32f0744 100644
> --- a/man2/ioctl_userfaultfd.2
> +++ b/man2/ioctl_userfaultfd.2
> @@ -196,6 +196,15 @@ with the
>  flag set,
>  .BR memfd_create (2),
>  and so on.
> +.TP
> +.B UFFD_FEATURE_SIGBUS
> +Since Linux 4.14, If this feature bit is set, no page-fault events
> +.B (UFFD_EVENT_PAGEFAULT)
> +will be delivered, instead a
> +.B SIGBUS
> +signal will be sent to the faulting process. Applications using this
> +feature will not require the use of a userfaultfd monitor for processing
> +memory accesses to the regions registered with userfaultfd.
>  .IP
>  The returned
>  .I ioctls
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index 1741ee3..3c5b9c0 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -172,6 +172,29 @@ or
>  .BR ioctl (2)
>  operations to resolve the page fault.
>  .PP
> +Starting from Linux 4.14, if application sets
> +.B UFFD_FEATURE_SIGBUS
> +feature bit using
> +.B UFFDIO_API
> +.BR ioctl (2),
> +no page fault notification will be forwarded to
> +the user-space, instead a
> +.B SIGBUS
> +signal is delivered to the faulting process. With this feature,
> +userfaultfd can be used for robustness purpose to simply catch
> +any access to areas within the registered address range that do not
> +have pages allocated, without having to listen to userfaultfd events.
> +No userfaultfd monitor will be required for dealing with such memory
> +accesses. For example, this feature can be useful for applications that
> +want to prevent the kernel from automatically allocating pages and filling
> +holes in sparse files when the hole is accessed thru mapped address.
> +.PP
> +The
> +.B UFFD_FEATURE_SIGBUS
> +feature is implicitly inherited through fork() if used in combination with
> +.BR UFFD_FEATURE_FORK .
> +
> +.PP
>  Details of the various
>  .BR ioctl (2)
>  operations can be found in
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
