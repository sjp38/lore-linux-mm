Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4550AC76197
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:09:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE61321743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:09:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE61321743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F53A6B0003; Wed, 17 Jul 2019 07:09:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CC256B0005; Wed, 17 Jul 2019 07:09:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86C1D8E0001; Wed, 17 Jul 2019 07:09:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2346B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:09:35 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e7so2965448pgm.2
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:09:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=4JuUCBs6DkQNWmPGtqYhOOJ09ZpyR71zko93aYi8pKQ=;
        b=W+BVKXBOjhvz6kSIr3Su9z+SC21dVjQfzinLIAGlwk3a6L0JRpio9rFvZ4MhD/yBuB
         IMPMEQQl/l9gheMBuTzKoJlUrEyXhqQreSmGNNFEOADeLBH2ViBiqB0pKuPTlu0TO4VR
         /Fmlp9SycsjeiqGXY77QivT5iSiJinpZVPLj9mbxp4xbv38ezFXd57PkOCTGpNAYLWVF
         47uZGERfLVx+8gOeUwlnn1U8T9XI0esMmPXj4pjgLj/njoHhccaKdmUYOK/5G+gfuF2L
         hUQ+UChUnt+yCkH7opxzfz5D3W3IRJGMuOZhSFBsSSnjPnDqPJgSdrO8mEkUtBfGmQjr
         zMtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW4r3mG9COuo15e0B9nB8R99aX+bIonVPGYuUd2ZfQ2n2N3v2+m
	Az4FZK9gr8qxebke9xo/UHoPVuwxlHII5XOSt9yjxAgzYbJtFN7+jcb43RXPN5M2LSUezJm9Gau
	rlQ3KvylrOWoPzozebxdGfS+DecC5+dcV3+ZEHh9wN/GMwMFyiXfyMqWC1Ig81/+uiQ==
X-Received: by 2002:a63:20d:: with SMTP id 13mr28518825pgc.253.1563361774867;
        Wed, 17 Jul 2019 04:09:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxN9o0kvTbS1R0Etdk7tXFPRsG3QB6UQah9fd3zzeIOIlcvu6zPPF+gH3QAMBVBOREGxo6Q
X-Received: by 2002:a63:20d:: with SMTP id 13mr28518758pgc.253.1563361774077;
        Wed, 17 Jul 2019 04:09:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563361774; cv=none;
        d=google.com; s=arc-20160816;
        b=dLX6tCUeTGa17qFjvAeO4W5kIhh8lWoUgsfdFbBB+XUHU02WsiiCyeTc2pIRtuNwge
         7c5hD9kITVVqTJoEf2t9MqQ1qzRj1uOZ1XiqbFtQnf+JbQMS35Js8mRb5IXrNiZ0CX3B
         H3Y77DbosdHme7CJzApzd3LxMNDaHjLQkC4GO0vs/u8SlLULQj66VPFYd3Ksf3jvxjOL
         JPZqD6Lq/AHr6IHNmx1evzYcaF96QWKB4pr5ErRoak462kGoFtghIocILgwTcpbBW3l5
         SXN7HpIHyvpLGrYa7/uQEvIaF+DTxdVP+jFWQnNLIMg4eLOlpyo8tCMs39QuPIfDiuKN
         H7zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=4JuUCBs6DkQNWmPGtqYhOOJ09ZpyR71zko93aYi8pKQ=;
        b=sAw6RmFkrsutThAaip5kmNRMX0/Rs49jITBEThoKeFOjGN5Jg6go3L5CFISpCGH0w8
         WSDlK0cX3McI0qeXjGuyzHwo01Y+eGZeHdGmw8PmD6qeiwCAc3I7F0zQJs5fiJqW0eqR
         sHxzbASoxLZbeZ2kCD0dUDhBYsYtdcY7JtxSmPygE3nP/1wjbxoNi7E8iQNpAaWP/pa9
         RKW6CoXHm9RbcDwYZjLJ8r0e5P3kgMsoMxKNLKdafB4XF2Gr18OQ3mOJhe8flOJfPerF
         X+cRo6O5a82uNlH6mRWOTqmKfdTvmdgIQapTnAlVAQegHdWGlo6t5/9uynxNHeXtDq+t
         XxZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l6si22283542pgp.382.2019.07.17.04.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 04:09:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6HB5CJ3132851
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:09:33 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tsyrrfjw5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:09:33 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 17 Jul 2019 12:09:29 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 17 Jul 2019 12:09:19 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6HB9I7C39190742
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 17 Jul 2019 11:09:18 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0C29152063;
	Wed, 17 Jul 2019 11:09:18 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 366B052050;
	Wed, 17 Jul 2019 11:09:15 +0000 (GMT)
Date: Wed, 17 Jul 2019 14:09:13 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        linux-kselftest@vger.kernel.org,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>,
        Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
        Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>,
        Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
        Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v18 08/15] userfaultfd: untag user pointers
References: <cover.1561386715.git.andreyknvl@google.com>
 <d8e3b9a819e98d6527e506027b173b128a148d3c.1561386715.git.andreyknvl@google.com>
 <20190624175120.GN29120@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624175120.GN29120@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19071711-0020-0000-0000-00000354AA32
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071711-0021-0000-0000-000021A87C56
Message-Id: <20190717110910.GA12017@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-17_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907170135
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 06:51:21PM +0100, Catalin Marinas wrote:
> On Mon, Jun 24, 2019 at 04:32:53PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends kernel ABI to allow to pass
> > tagged user pointers (with the top byte set to something else other than
> > 0x00) as syscall arguments.
> > 
> > userfaultfd code use provided user pointers for vma lookups, which can
> > only by done with untagged pointers.
> > 
> > Untag user pointers in validate_range().
> > 
> > Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  fs/userfaultfd.c | 22 ++++++++++++----------
> >  1 file changed, 12 insertions(+), 10 deletions(-)
> 
> Same here, it needs an ack from Al Viro.

The userfault patches usually go via -mm tree, not sure if Al looks at them :) 
 
FWIW, you can add 

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index ae0b8b5f69e6..c2be36a168ca 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -1261,21 +1261,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
> >  }
> >  
> >  static __always_inline int validate_range(struct mm_struct *mm,
> > -					  __u64 start, __u64 len)
> > +					  __u64 *start, __u64 len)
> >  {
> >  	__u64 task_size = mm->task_size;
> >  
> > -	if (start & ~PAGE_MASK)
> > +	*start = untagged_addr(*start);
> > +
> > +	if (*start & ~PAGE_MASK)
> >  		return -EINVAL;
> >  	if (len & ~PAGE_MASK)
> >  		return -EINVAL;
> >  	if (!len)
> >  		return -EINVAL;
> > -	if (start < mmap_min_addr)
> > +	if (*start < mmap_min_addr)
> >  		return -EINVAL;
> > -	if (start >= task_size)
> > +	if (*start >= task_size)
> >  		return -EINVAL;
> > -	if (len > task_size - start)
> > +	if (len > task_size - *start)
> >  		return -EINVAL;
> >  	return 0;
> >  }
> > @@ -1325,7 +1327,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >  		goto out;
> >  	}
> >  
> > -	ret = validate_range(mm, uffdio_register.range.start,
> > +	ret = validate_range(mm, &uffdio_register.range.start,
> >  			     uffdio_register.range.len);
> >  	if (ret)
> >  		goto out;
> > @@ -1514,7 +1516,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> >  	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
> >  		goto out;
> >  
> > -	ret = validate_range(mm, uffdio_unregister.start,
> > +	ret = validate_range(mm, &uffdio_unregister.start,
> >  			     uffdio_unregister.len);
> >  	if (ret)
> >  		goto out;
> > @@ -1665,7 +1667,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
> >  	if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
> >  		goto out;
> >  
> > -	ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
> > +	ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
> >  	if (ret)
> >  		goto out;
> >  
> > @@ -1705,7 +1707,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
> >  			   sizeof(uffdio_copy)-sizeof(__s64)))
> >  		goto out;
> >  
> > -	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
> > +	ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
> >  	if (ret)
> >  		goto out;
> >  	/*
> > @@ -1761,7 +1763,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
> >  			   sizeof(uffdio_zeropage)-sizeof(__s64)))
> >  		goto out;
> >  
> > -	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
> > +	ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
> >  			     uffdio_zeropage.range.len);
> >  	if (ret)
> >  		goto out;
> > -- 
> > 2.22.0.410.gd8fdbe21b5-goog

-- 
Sincerely yours,
Mike.

