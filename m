Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D18D0C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:02:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 732D5207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:02:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Z4mSKHb6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 732D5207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F05C36B0277; Thu,  6 Jun 2019 10:02:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB6D96B0278; Thu,  6 Jun 2019 10:02:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA5D56B0279; Thu,  6 Jun 2019 10:02:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5A3D6B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:02:42 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id b7so2029298qkk.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:02:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=QdQp9sTpwMz8UO4D5YUcHQREajmmZNXe+7QIFqHQYOg=;
        b=LTIwBjfQBkRHyUfz3vgoxLYX7KPEQTJogzXuUc0LWnw0eZLUXmJZdTFUtolOwSqsYX
         FpqJj+5Q6riRtdmVYbarzw98sk6a3GS/VjhPnxk4LD0dDfwwNeMwEAsBRuUPULd1sOxc
         PvOFA20nit2vdabZTxGhIjL9BFYYWOuVsybAz7TC2C+rrN5OTHTKhlNavYahdHFluseo
         DwXlDFBxiWvrBqoAlWXStVxkE7TY60jMW6qxJkkd/6c5Vnzr0iIOE3Dotq1+9gmjT6rn
         AN6PFWlovdlzzNhMufV0FbNJ5ekZbry0AxiOf+f6TEKyun8LCuyzAmq0KQvgd1VAaq6q
         pV6g==
X-Gm-Message-State: APjAAAWGOUvxGtWx2uAVLa5lMWEb9I+jvfv00VFd3rU4/RHp0Vli7UKI
	0amkWEpQtFPt06IDSyS41myLhyRbkRIn5OKwofv2wdOBYE1sCdcRMBkQ4cYYmt7uDdswRG+j+au
	vPIxIDTpnUqj/D+sD0J5+EkpbSru9/tym7lmbml17tUYrFxmOVIY8xtQv9Pc7WPU1TQ==
X-Received: by 2002:a37:b501:: with SMTP id e1mr19610084qkf.271.1559829762459;
        Thu, 06 Jun 2019 07:02:42 -0700 (PDT)
X-Received: by 2002:a37:b501:: with SMTP id e1mr19609984qkf.271.1559829761620;
        Thu, 06 Jun 2019 07:02:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559829761; cv=none;
        d=google.com; s=arc-20160816;
        b=MO6Vf/k/BDTcJEpfqAqNAY4hVA2tCIoPJQXocgdxdLBQUjj6FmJVurrM6JCYUSNuBR
         2ZWt54QN5NCwKlrlnYHUE/ZJPJpXq8UavqyrsZptSqa10/i+p6ZxylFGpF7oDGfFhnLW
         0t9kBxewC5tTU9MYQaD2FOpA0tMUQDIAjXBc41eeBwzCzC9u/fiK5Jg7j96OYGA4FPDh
         vSC+3ARepqqShGDMiKRBK+FP9ftGjme8mPk/McyCW5VLJ1AEqF1eH7xfuIjG9k2mJJ5o
         x3vJ7D8S0vNt2Jteg3f5vqiOQb5qco+36gs7H+MVT7ngBAdkGYXAvLqREyZnoqNy1IPf
         cn0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=QdQp9sTpwMz8UO4D5YUcHQREajmmZNXe+7QIFqHQYOg=;
        b=SLQVLYelorvafDJ+8w7C3qPTGBHarQI9ylEvoVjfnb96jqhBzdVMAkntFBWggVOqUD
         mX3iW73F7qAVv1O17A9tw1FTg7xpji9OKhAPvJ8YB4c9jsLSVaGcJe7hQmwD4RFS++Cq
         s3vYyy+8FKDd7O+W2tGbTOUww6WnfHsKli500L+ZfiNXRLoiKzRO1b7IDxfyajd6MUDp
         M6IgSwQwIhNCIx9ESXjkfttaLLB4o0dtwrP2Atds5p5ShyIp322RIfofTop4/U6kneOe
         yPRqnjzUYY5s8Ct1cEznbADr1vwK+7fyq1AvTF3IMVxZw3UOsCjm0zyzYwOVtbfWS05O
         /48g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z4mSKHb6;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 187sor1038820qkl.121.2019.06.06.07.02.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 07:02:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Z4mSKHb6;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=QdQp9sTpwMz8UO4D5YUcHQREajmmZNXe+7QIFqHQYOg=;
        b=Z4mSKHb689Oa8wMsTSv8toDWQrSLWCOp4zbPJwy4y9UoJFEXs7wpQZQ5rgvYg6mVHS
         Sm2B76oIRwgW9aLuwMNaWMyoADojdaTXc0ddXyBvRk86gopNn2GBLOgznkPpOHCCSmms
         1iH1JG0gDtz9WjybUoTKMqUOZ2sf5t5ouiIdwcHV41TM4ejRF9TkPhxUUkhOCGDBB4qD
         C9Nmvye3UQy2AlTqrndiuN31xF+Xg60atJPHCrBOnYvKtqEKJabPNGI2YqKh8zQ0SWxl
         FU5XasPYs56HDr2kTd7khg1Bmstq3VQz1HzKPTywPoL03FdeUFixpUyX0I/AV0XKW+GW
         yyrA==
X-Google-Smtp-Source: APXvYqzLlrOQZWugqyrKN41ULF1+5YeDLgwvVvKDI1/jQhTQ3jxca7MdYURwWl7+Wfew8EdBwCR0Cg==
X-Received: by 2002:ae9:e20c:: with SMTP id c12mr38555647qkc.210.1559829761101;
        Thu, 06 Jun 2019 07:02:41 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id l3sm902129qkd.49.2019.06.06.07.02.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 07:02:40 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYsyV-00064G-JQ; Thu, 06 Jun 2019 11:02:39 -0300
Date: Thu, 6 Jun 2019 11:02:39 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/5] mm/hmm: Update HMM documentation
Message-ID: <20190606140239.GA21778@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-2-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190506232942.12623-2-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:29:38PM -0700, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> Update the HMM documentation to reflect the latest API and make a few minor
> wording changes.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
>  Documentation/vm/hmm.rst | 139 ++++++++++++++++++++-------------------
>  1 file changed, 73 insertions(+), 66 deletions(-)

Okay, lets start picking up hmm patches in to the new shared hmm.git,
as promised I will take responsibility to send these to Linus. The
tree is here:

https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=hmm

This looks fine to me with one minor comment:

> diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
> index ec1efa32af3c..7c1e929931a0 100644
> +++ b/Documentation/vm/hmm.rst
>  
> @@ -151,21 +151,27 @@ registration of an hmm_mirror struct::
>  
>   int hmm_mirror_register(struct hmm_mirror *mirror,
>                           struct mm_struct *mm);
> - int hmm_mirror_register_locked(struct hmm_mirror *mirror,
> -                                struct mm_struct *mm);
>  
> -
> -The locked variant is to be used when the driver is already holding mmap_sem
> -of the mm in write mode. The mirror struct has a set of callbacks that are used
> +The mirror struct has a set of callbacks that are used
>  to propagate CPU page tables::
>  
>   struct hmm_mirror_ops {
> +     /* release() - release hmm_mirror
> +      *
> +      * @mirror: pointer to struct hmm_mirror
> +      *
> +      * This is called when the mm_struct is being released.
> +      * The callback should make sure no references to the mirror occur
> +      * after the callback returns.
> +      */

This is not quite accurate (at least, as the other series I sent
intends), the struct hmm_mirror is valid up until
hmm_mirror_unregister() is called - specifically it remains valid
after the release() callback.

I will revise it (and the hmm.h comment it came from) to read the
below. Please let me know if you'd like something else:

	/* release() - release hmm_mirror
	 *
	 * @mirror: pointer to struct hmm_mirror
	 *
	 * This is called when the mm_struct is being released.  The callback
	 * must ensure that all access to any pages obtained from this mirror
	 * is halted before the callback returns. All future access should
	 * fault.
	 */

The key task for release is to fence off all device access to any
related pages as the mm is about to recycle them and the device must
not cause a use-after-free.

I applied it to hmm.git

Thanks,
Jason

