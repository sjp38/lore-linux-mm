Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36A5C6B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 02:05:10 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id w45so14063778uac.13
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 23:05:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k30si4158959qtd.419.2017.10.07.23.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Oct 2017 23:05:09 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9864i2N000714
	for <linux-mm@kvack.org>; Sun, 8 Oct 2017 02:05:08 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2det831mm2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 08 Oct 2017 02:05:07 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 8 Oct 2017 07:05:05 +0100
Date: Sun, 8 Oct 2017 09:04:59 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] Userfaultfd: Add description for UFFD_FEATURE_SIGBUS
References: <1507344740-21993-1-git-send-email-prakash.sangappa@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507344740-21993-1-git-send-email-prakash.sangappa@oracle.com>
Message-Id: <20171008060459.GA3370@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, arcange@redhat.com, mhocko@suse.com

Hello Prakash,

On Fri, Oct 06, 2017 at 07:52:20PM -0700, Prakash Sangappa wrote:
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
>     mm: userfaultfd: add feature to request for a signal delivery
> 
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> ---
>  man2/ioctl_userfaultfd.2 |  9 +++++++++
>  man2/userfaultfd.2       | 17 +++++++++++++++++
>  2 files changed, 26 insertions(+)
> 
> diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> index 60fd29b..cfc65ae 100644
> --- a/man2/ioctl_userfaultfd.2
> +++ b/man2/ioctl_userfaultfd.2
> @@ -196,6 +196,15 @@ with the
>  flag set,
>  .BR memfd_create (2),
>  and so on.
> +.TP
> +.B UFFD_FEATURE_SIGBUS
> +Since Linux 4.14, If this feature bit is set, no page-fault events(
> +.B UFFD_EVENT_PAGEFAULT
> +) will be delivered, instead a
> +.B SIGBUS
> +signal will be sent to the faulting process. Applications using this
> +feature will not require the use of a userfaultfd monitor for handling
> +page-fault events.

This sounds to me a bit misleading: "no page-fault events" and "handling
page-fault events"
Maybe "processing memory accesses to the regions registered with
userfaultfd"?

>  .IP
>  The returned
>  .I ioctls
> diff --git a/man2/userfaultfd.2 b/man2/userfaultfd.2
> index 1741ee3..a033742 100644
> --- a/man2/userfaultfd.2
> +++ b/man2/userfaultfd.2
> @@ -172,6 +172,23 @@ or
>  .BR ioctl (2)
>  operations to resolve the page fault.
>  .PP
> +Starting from Linux 4.14, if application sets
> +.B UFFD_FEATURE_SIGBUS
> +feature bit using
> +.B UFFDIO_API
> +.BR ioctl (2)
> +, no page fault notification will be forwarded to
> +the user-space, instead a
> +.B SIGBUS
> +signal is delivered to the faulting process. With this feature,
> +userfaultfd can be used for robustness purpose to simply catch
> +any access to areas within the registered address range that do not
> +have pages allocated, without having to deal with page-fault events.
> +No userfaultd monitor will be required for handling page faults. For

Since we do not get page fault events, maybe better would be to say
"dealing with such memory accesses" or something like that.

> +example, this feature can be useful for applications that want to
> +prevent the kernel from automatically allocating pages and filling
> +holes in sparse files when the hole is accessed thru mapped address.
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
