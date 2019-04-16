Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B66FC282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:34:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB1A220656
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 23:34:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB1A220656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E02A6B026B; Tue, 16 Apr 2019 19:34:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F666B026C; Tue, 16 Apr 2019 19:34:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A4B86B026D; Tue, 16 Apr 2019 19:34:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB4F6B026B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 19:34:14 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q21so20901094qtf.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:34:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Piew9yEdGVKY508EbIp2DXZt6pwyFajcV3O41BEtfug=;
        b=okHms/ZG25FgcN9C/MrbBINx8JzkGdUTTEwk6uEx7vNPhKcH+UO0ONnUPSspk8h0g0
         ghB26v94hLZJTw0Mkq0hG4tGTzh4aIWHHe8U6C5a3TunqR18rlHH4y71mIHBX428j2oR
         0U7Y7CQj5ijMExV672ngpH9ClqlsDppkVrbh082EHmOfg/qXcW2+22WinxAPEFbsZ8BH
         llX1R7ERNEq2Jhr43GUfsufclDib9yq05x86ZwwSZPbRusszXBtmqu69FUusZ2sqOVFy
         d+jridleW3p8AQgu7NgGK5FcBa2XTSzAzB3AzSnNi633/MEkM5q/gVMrZA2jinduakNI
         y1qA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWtGbaZB8xJinQ583xsRZ9RcsTP+77BuB7YWuuDnT8MLWg4C8vC
	afvjp8RpwT2mWD24vOdq7eI976EIrMzRVeNG9zEiAJdo0MHGnc1tmevhl0yPsYd1J8olb195MrS
	F+XlGd/gXxG9oQY4D2ttOSkk4JQxrJPCL51WyP3hjBOvPRWCf3GEb1mvtCrSRyc7G4w==
X-Received: by 2002:a0c:9849:: with SMTP id e9mr67869400qvd.193.1555457654072;
        Tue, 16 Apr 2019 16:34:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtMUjbT/2vz7/3g/AZNyYdXwacE2eiflctjNPcrBEh9GKTpqxqFo/URrkkIOB/23rrSc95
X-Received: by 2002:a0c:9849:: with SMTP id e9mr67869368qvd.193.1555457653393;
        Tue, 16 Apr 2019 16:34:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555457653; cv=none;
        d=google.com; s=arc-20160816;
        b=iyrRfrhOuZygS1mBGrL4b7duLAmNZnemQFDR06oqf0VGdtVUrHWIC7TGrl3iTEBxaY
         df3fBklJkC87j7B4Pmx7kbPNXIvyv+Lq5Az0d/hkRA3mSJvmY4AlGyBjlpxlzV1slsEx
         f1pQZVzToJ6/4B8vWI4EXaTKos+n3gVW8lRv6DxaDkKxXGLX6ne7mkjIMHwefzuXBxKf
         FvsetVsPFVHyp44fHqmzNY0D7evwTvnmolb2i7uWMUuH3rbXZ65AfG9P+DiAlDHvjxQj
         pSXYsAhHP4TOfq5g4osfWgxUPPq9FBvaqpqClTi44UmzxXHiwyXao7QAJ76nOqeIDw9M
         ZqMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Piew9yEdGVKY508EbIp2DXZt6pwyFajcV3O41BEtfug=;
        b=qDcpEzh/NHff5Wpjpu3h/nCgmlP/lXf4dizaIWtZPTashWCZjqitHVHddabHw1oEXR
         5MgOjZURtuspr56eCxcFqixOO+qVexCaoS9BcBGBJ19qxh6xgC/l4Z6as6B8WLAr28pu
         YnsWj9V1sdBWPJwFWtOdDsMFMp7aluFofrWY1mdsiXm4lvV2E7as+bey0J8T0/PJkcPG
         i7etgpWR6Ht4xuxgW6XU9VMD6vH9s6rp8AxAY2yNkrbvHv6lNp+6AGzZ1rmsYRDpmN3+
         Tudth10c5kEU8PDDr4a12X/5OvLXBdwWCv1YP7t4HsK6qJDbZun4Cwy0YUgfV2/j5vAl
         ORbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v28si1087627qvc.26.2019.04.16.16.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 16:34:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4B7183199363;
	Tue, 16 Apr 2019 23:34:12 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BA40E60C61;
	Tue, 16 Apr 2019 23:34:04 +0000 (UTC)
Date: Tue, 16 Apr 2019 19:34:03 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Boaz Harrosh <boaz@plexistor.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
	ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Ernesto =?iso-8859-1?Q?A=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Message-ID: <20190416233402.GC22465@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
 <20190416195735.GE21526@redhat.com>
 <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 16 Apr 2019 23:34:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 01:09:22AM +0300, Boaz Harrosh wrote:
> On 16/04/19 22:57, Jerome Glisse wrote:
> <>
> > 
> > A very long thread on this:
> > 
> > https://lkml.org/lkml/2018/12/3/1128
> > 
> > especialy all the reply to this first one
> > 
> > There is also:
> > 
> > https://lkml.org/lkml/2019/3/26/1395
> > https://lwn.net/Articles/753027/
> > 
> 
> OK I have re-read this patchset and a little bit of the threads above (not all)
> 
> As I understand the long term plan is to keep two separate ref-counts one
> for GUP-ref and one for the regular page-state/ownership ref.
> Currently looking at page-ref we do not know if we have a GUP currently held.
> With the new plan we can (Still not sure what's the full plan with this new info)
> 
> But if you make it such as the first GUP-ref also takes a page_ref and the
> last GUp-dec also does put_page. Then the all of these becomes a matter of
> matching every call to get_user_pages or iov_iter_get_pages() with a new
> put_user_pages or iov_iter_put_pages().

So sorry forgot to answer that part. So idea is to do:
    GUP() {
        ...
-       page_ref_inc(page);
+       page_ref_add(page, GUP_BIAS);
        ...
    }

with GUP_BIAS = 1024 or something big but not too big to avoid risk of
overflow by GUP. Then put_user_page() just ref_sub instead of ref_dec
the same amount.

We can have false GUP positive if a page is map so many time or reference
so many time that its refcount reach the GUP_BIAS value but considering
such page as GUPed should not be too harmful (not more harmful than what
we do with GUPed page).

So we want to call put_user_page() for GUPed page and only GUPed page so
that we keep the reference count properly balance.

Cheers,
Jérôme

