Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0057CC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:39:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B186B20685
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:39:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B186B20685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53E188E00AB; Thu, 21 Feb 2019 13:39:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EDCD8E00A9; Thu, 21 Feb 2019 13:39:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DE178E00AB; Thu, 21 Feb 2019 13:39:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 180968E00A9
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:39:02 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id v67so5879014qkl.22
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:39:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=z5WDqReEwlGQt8J9k92HeC/9A5s8C70b5fder7AqGTs=;
        b=WRvQ6ijaCsu+fC8FMHv2HV7Nz4Hv3k8ksY1VPGWAyOch34yFa2Rt88Yavu5xHlm7h4
         phHMF3JnNipK/iNPiU3O4nnY+k4XAxYjc0OeiRC2D7zeZNBqITvOow3LNFPMSDTStRrU
         3aVSRt419KseFT71MMJgilc4Q71BpMlDxJshqulnwtV8/enS0QAtXzeEzPuR1E4zvdwr
         qzFsnksotnb5aegIMAuGsfTT75LIvf0FmubaADpCMrVCQKmsTQsRd+BoCWprCPjLveig
         NjDGMEyNTIQ6aC6X8/Ok4dLI3BXoFL3V5x56Gk2+YfYFQmBRW1pvIT25ZqMijDm0FEdF
         YjpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaIkpgcpD5F6mqfAl+UH+5AXb9+ZdVU28VOZmNdV90XXwp4+g0l
	Vvr1bfqHxLCHJ4PNxnJ+4/RxF/71Dq9ECs2GMwRJYu6n+iIjF2E+tNqOSYl5X30u84fSiNFf/8m
	j4MWZDJhM0DZ9zVig6MTGm/TTnCAwQLJ2Q3fzni35fi2UuUGlmPfFKKbXoCefp9MBSQ==
X-Received: by 2002:ac8:18fa:: with SMTP id o55mr32895892qtk.272.1550774341860;
        Thu, 21 Feb 2019 10:39:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ+sYzaHHcr0Ykj2EyHv3Va9G3dMRxwHrY0X/+rN+IPelZJov0Ls25pkR1sg9HNiTEDTRgX
X-Received: by 2002:ac8:18fa:: with SMTP id o55mr32895864qtk.272.1550774341324;
        Thu, 21 Feb 2019 10:39:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550774341; cv=none;
        d=google.com; s=arc-20160816;
        b=sdOteLI+cV2ktdpCLo4gy6KyGEjXle2oFNo3UI5Cd5DcuZ4FEC8drgPSSGcTojVQLj
         I2WxWPjNSj9u3oEBYBBCyNDbgsaIB+BVb7f/5NqUkxpzgciRPE/Q1aMKIXca/f/gChdB
         PlXJMmKaFQYPgZOn7SNiwAQsW03zIGSoVtpLeZ04RhxJn5Yb3a3tRsUFSVMzm87k3dxO
         snpjba3H40lspQcKLGwbOpGa/ZgjZOCfmx7y4RoY228tPLvTss9P089kIwMH6TBHGeWr
         QZe63LDiKKPa+Hj3BhMfres/5R30c0qNbNyP1EzI+ydSZ+UaDDOmIx//8pB1bbG2oSWO
         opdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=z5WDqReEwlGQt8J9k92HeC/9A5s8C70b5fder7AqGTs=;
        b=xIQhl5CcgAJNOYcHx1dLYtDPVf22Gbr9pKiB1X8yWTuBXjoiQHytCFmjpQEoI63li6
         T5CIw0oDO+WRckx7ymG3H9hnveVrxmWqFAaH8BauxQ9OQ6RMaIbjAkpHHWGEthKekD7j
         FvuVSjiCDojV2Vm18R9vtIjjxEkSWRtH+JtuapWeMIKKu3HyZS99MeTMKNHJCH3oXL24
         b5gmHDx3p1Os+aWAUOgzzmf9jEt4mnrAf5dDvPbNiqlsFnw26JfL6MuvCLxwSOu/kci0
         z+LiutpbHMDesmyfeim3C6/RR0LFICzhDHYs5ix+ucxwJ/wo0CW+hj3lxEzsfXIpOaNy
         qIeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x25si3008492qvf.149.2019.02.21.10.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:39:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2FBCCC049E24;
	Thu, 21 Feb 2019 18:39:00 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8949060139;
	Thu, 21 Feb 2019 18:38:52 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:38:51 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 24/26] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP
 documentation update
Message-ID: <20190221183851.GW2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-25-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-25-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 21 Feb 2019 18:39:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:30AM +0800, Peter Xu wrote:
> From: Martin Cracauer <cracauer@cons.org>
> 
> Adds documentation about the write protection support.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> [peterx: rewrite in rst format; fixups here and there]
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  Documentation/admin-guide/mm/userfaultfd.rst | 51 ++++++++++++++++++++
>  1 file changed, 51 insertions(+)
> 
> diff --git a/Documentation/admin-guide/mm/userfaultfd.rst b/Documentation/admin-guide/mm/userfaultfd.rst
> index 5048cf661a8a..c30176e67900 100644
> --- a/Documentation/admin-guide/mm/userfaultfd.rst
> +++ b/Documentation/admin-guide/mm/userfaultfd.rst
> @@ -108,6 +108,57 @@ UFFDIO_COPY. They're atomic as in guaranteeing that nothing can see an
>  half copied page since it'll keep userfaulting until the copy has
>  finished.
>  
> +Notes:
> +
> +- If you requested UFFDIO_REGISTER_MODE_MISSING when registering then
> +  you must provide some kind of page in your thread after reading from
> +  the uffd.  You must provide either UFFDIO_COPY or UFFDIO_ZEROPAGE.
> +  The normal behavior of the OS automatically providing a zero page on
> +  an annonymous mmaping is not in place.
> +
> +- None of the page-delivering ioctls default to the range that you
> +  registered with.  You must fill in all fields for the appropriate
> +  ioctl struct including the range.
> +
> +- You get the address of the access that triggered the missing page
> +  event out of a struct uffd_msg that you read in the thread from the
> +  uffd.  You can supply as many pages as you want with UFFDIO_COPY or
> +  UFFDIO_ZEROPAGE.  Keep in mind that unless you used DONTWAKE then
> +  the first of any of those IOCTLs wakes up the faulting thread.
> +
> +- Be sure to test for all errors including (pollfd[0].revents &
> +  POLLERR).  This can happen, e.g. when ranges supplied were
> +  incorrect.
> +
> +Write Protect Notifications
> +---------------------------
> +
> +This is equivalent to (but faster than) using mprotect and a SIGSEGV
> +signal handler.
> +
> +Firstly you need to register a range with UFFDIO_REGISTER_MODE_WP.
> +Instead of using mprotect(2) you use ioctl(uffd, UFFDIO_WRITEPROTECT,
> +struct *uffdio_writeprotect) while mode = UFFDIO_WRITEPROTECT_MODE_WP
> +in the struct passed in.  The range does not default to and does not
> +have to be identical to the range you registered with.  You can write
> +protect as many ranges as you like (inside the registered range).
> +Then, in the thread reading from uffd the struct will have
> +msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WP set. Now you send
> +ioctl(uffd, UFFDIO_WRITEPROTECT, struct *uffdio_writeprotect) again
> +while pagefault.mode does not have UFFDIO_WRITEPROTECT_MODE_WP set.
> +This wakes up the thread which will continue to run with writes. This
> +allows you to do the bookkeeping about the write in the uffd reading
> +thread before the ioctl.
> +
> +If you registered with both UFFDIO_REGISTER_MODE_MISSING and
> +UFFDIO_REGISTER_MODE_WP then you need to think about the sequence in
> +which you supply a page and undo write protect.  Note that there is a
> +difference between writes into a WP area and into a !WP area.  The
> +former will have UFFD_PAGEFAULT_FLAG_WP set, the latter
> +UFFD_PAGEFAULT_FLAG_WRITE.  The latter did not fail on protection but
> +you still need to supply a page when UFFDIO_REGISTER_MODE_MISSING was
> +used.
> +
>  QEMU/KVM
>  ========
>  
> -- 
> 2.17.1
> 

