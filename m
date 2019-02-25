Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1695BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:19:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3B8F21841
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:19:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3B8F21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612508E0005; Mon, 25 Feb 2019 16:19:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BD9D8E0004; Mon, 25 Feb 2019 16:19:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45F428E0005; Mon, 25 Feb 2019 16:19:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 05A908E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:19:47 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b15so8697118pfo.12
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:19:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=06RUFWyhr1JNydZFm84M0rLC/o49Iji8GKyu9CLEckU=;
        b=JQIHssNU5a4tIjnRcgObM0S1CPprwDamrK+gvosWgJ5JEXIsMs3yBfE3dqi5EBIe2t
         r4wSI/3RgEz9f7u3TirMOBjnZiU823R1s+Kv+4B7NE43YyT8ylCHW6AgdTS23Q6sNbLb
         Wn/yDMXPy6bddeWUy0ZR0lWRoFpdKh8oEXddQSqjsruZ1h8qAhO7KFCwjfFPzpg8aiU8
         7UBsyluYLNSwDV21rf53jAQ+Uop0b0lrA48JTHTjUC5ysX/FSm8o4LjVbonEkeY5JCan
         mq28nFylLBU5qpQE53LXKMOyFmqDCpoWahS0T/q4iFWAouv+jYW520G/rczWEGqi/aV9
         nNww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuY9GAxrKGjjntzFA6jbeERL1r2zJov10mLiz1ZmBBEeVUaK3jlJ
	Gy3vEKOI8IPUWxvqUpOosZyPGxKjX6mERCdZRz3tVkE4F+G+++F9qLeRfaaxLcZlMRAMwlpqe/X
	lSRsFMg0lgjElJPYULFByVDM5UCFGBlznjcvtjfDKp+EsHYf7wmfWzRjJ2wi1DAA3Xg==
X-Received: by 2002:a65:438a:: with SMTP id m10mr8437136pgp.191.1551129586670;
        Mon, 25 Feb 2019 13:19:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia5cPjUdgFapmjBUyBEmNySI4+EQiDFCaP2qm/0X8hdk93R08QS2dltCMC8hTOAACSlrBfT
X-Received: by 2002:a65:438a:: with SMTP id m10mr8437069pgp.191.1551129585760;
        Mon, 25 Feb 2019 13:19:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551129585; cv=none;
        d=google.com; s=arc-20160816;
        b=FgS+f7QbyK/1qx2P1OVXruCLaOkiW4sMIB1R8nuxPsNoa6IdLMA7a+E6Ma8s2xp4pI
         HKLQPrIhvvjbywwdYOx4szli5W4Jc2CGTRwIqNZyLubPs/ePk9d229VbRL81jMhnYtdY
         Hi3puy7vH4aL78f3PY98mph3FCV22Wbc/cRdGpZtqSQj7VQxSxXKSAg/z0SD8fS0O/6M
         37sLQ7V84eewJV2rSzRUhXlzeuBzjaF1bTqE3tN7IjIDRGAH2uArKgZDYNwKbIgquu+J
         P7+j6Q5+9/YNoedn72TS21hre4tIzBH4qPnhkJ9zi6p2YYJb/3/XQvWW/vfQjHV0lYx5
         jEYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=06RUFWyhr1JNydZFm84M0rLC/o49Iji8GKyu9CLEckU=;
        b=tljn2j/ckkLapINq9ft5MaY+qkqyTbWl7M2CaEsN/CpuBuMyJ0LZQWg/5kPYAOEV/n
         M33aRPB0FLFryGcm0o9l+VfQfW1ItnWlRGV48tfWp/tqHsUquB30LQ9AH0pOKDoba7r7
         i0RZLYTuSuM1Lg5IVjtPhTd6frvwpeUYKuYN/Saos3GXU2JT9cN4hYrQN8uBJTk1HpWl
         nqy/r+JnsffHaJ9+k1ThfcFIPX8Ko6PU4OiXyKF/m0R+wSYZzBnzEhKUEUgG9Ejl4M6L
         +xknwlLrxxEmy1S0B3yRMxaMU2edqW7iE/MUlHadELlLkoucoa2aCiRSJIpl2RqdXaYt
         sM7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d141si5190058pfd.81.2019.02.25.13.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 13:19:45 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PL4pmk016148
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:19:45 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvnu56dbv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:19:44 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 21:19:41 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 21:19:37 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PLJa0l23920710
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 21:19:36 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CBC0311C04A;
	Mon, 25 Feb 2019 21:19:36 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2C6C211C04C;
	Mon, 25 Feb 2019 21:19:34 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.243])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 21:19:34 +0000 (GMT)
Date: Mon, 25 Feb 2019 23:19:32 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 24/26] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP
 documentation update
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-25-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-25-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022521-0020-0000-0000-0000031B21BF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022521-0021-0000-0000-0000216C845B
Message-Id: <20190225211930.GG10454@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250151
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

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

Peter, can you please also update the man pages (1, 2)?

[1] http://man7.org/linux/man-pages/man2/userfaultfd.2.html
[2] http://man7.org/linux/man-pages/man2/ioctl_userfaultfd.2.html

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

-- 
Sincerely yours,
Mike.

