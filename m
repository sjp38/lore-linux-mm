Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E91DA6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 13:19:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j30so7182176qta.2
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:19:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x38si6718856qtx.134.2017.03.29.10.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 10:19:06 -0700 (PDT)
Date: Wed, 29 Mar 2017 19:19:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] userfaultfd: provide pid in userfault msg
Message-ID: <20170329171903.GG25920@redhat.com>
References: <1490207346-9703-1-git-send-email-a.perevalov@samsung.com>
 <CGME20170322182918eucas1p204ef2f7aadb0ac41d11f15ef434c74c4@eucas1p2.samsung.com>
 <1490207346-9703-2-git-send-email-a.perevalov@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490207346-9703-2-git-send-email-a.perevalov@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Perevalov <a.perevalov@samsung.com>
Cc: "Dr . David Alan Gilbert" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hello,

On Wed, Mar 22, 2017 at 09:29:06PM +0300, Alexey Perevalov wrote:
>  static inline struct uffd_msg userfault_msg(unsigned long address,
>  					    unsigned int flags,
> -					    unsigned long reason)
> +					    unsigned long reason,
> +					    unsigned int features)

userfaultfd_ctx.features is an int so this looks fine to me too. It's
in kernel representation and we do the validation with a __u64 on the
stack in userfaultfd_api() so that we -EINVAL any unknown bit >=32 to
retain backwards compatibility and so we can start using bits over 32
sometime later (by turning the above in a long long).

If the validation passes we then store the "known" (i.e. <32bit)
features in userfaultfd_ctx.features and we keep passing it around as
an int so we can pass it as an int above too.

> @@ -83,6 +84,7 @@ struct uffd_msg {
>  		struct {
>  			__u64	flags;
>  			__u64	address;
> +			pid_t   ptid;
>  		} pagefault;

Now that you made it conditional to a feature flag this could now be
put in an union and I think it'd better be a __u32 (or __u64 if the
pid space is expected to grow beyond 32bit any time in the future,
probably unlikely so __u32 could be enough).

Last thing I wonder is what happens if you pass the uffd from a
container under a PID namespace to some process outside the PID
namespace through unix domains sockets. Then the tpid seen by the
other container will be remapped and it may not be meaningful but
considering this is used for statistical purposes it will still
work. The security is handled through the unix domain sockets in such
case, if the app gives up voluntarily its uffd then it's ok the app
outside the namespace sees the tpid inside (and the same in the other
way around).

The important issue that got fixed in v2 and that I worried about in
v1, is the tpid seen by an uffd inside the namespace is the namespace
tpid and not the one seen outside the namespace that must never be
shown to userland.

Any other comment about merging this new uffd feature?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
