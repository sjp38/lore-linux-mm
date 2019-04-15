Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7869FC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:12:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3370B2077C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:12:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3370B2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0A996B0003; Mon, 15 Apr 2019 11:12:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B92146B0006; Mon, 15 Apr 2019 11:12:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A59446B0007; Mon, 15 Apr 2019 11:12:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81CE86B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 11:12:05 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g17so16208716qte.17
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 08:12:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xJ0SjR0hZQnYy/yKGzIYan6xq1V7J9UCtRxctImHP38=;
        b=XsPE5821XRY6AXizL52RV3AC/NiGormK5+W59Dm42UXqtDALXu6ZQfR90ylty4vrhe
         p5svUmK29VswQ9kyzEienUXLeKH76WmLTMQPVINIqj0cUSVl/w7oxHh77Pa/NNWfuF5l
         TCGORsPqiDqHw2VkqqZwM8D1IUp2/73D8rX5ZUayF/4FILAZLgb5JV8Ah5cRFDw8mSAQ
         0VikTCwI9iatq9HBXglNm48af/75ZiL25fcseTtmPjXwCQlpzfa1BX5Um6WmutpL5clF
         KEEvDaFeTQniw2PWxdbXf2hTQUeGBNixVMD0134fmR9X1GZ6H4wlV5UIVQUQybgOtgZ9
         A05A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU3OJS3LfFs6/L9hBtruhJD6WHFS5sGd2i0O9qnzpBUqhScwBXx
	VXakqX9++YmNhwXrUiCoWX0IwXKfrYcgkqSc5q/Jl5SbWkARwk4IIP0xlCICUNHZCa2GvUp76sU
	8ptFVi6/ilGTEua21WVAs8/aGNjt91sVBylNvaIbNVtHx8ip1aZ6MBBsC3l9v1VOh2A==
X-Received: by 2002:ac8:32fb:: with SMTP id a56mr63107094qtb.338.1555341125230;
        Mon, 15 Apr 2019 08:12:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQuyXFKYbJpLPp9cczUUzsj5zgJdcAeXXRAQa0YOH3yFgyquK6KQwovv36KDklWYWIvW2y
X-Received: by 2002:ac8:32fb:: with SMTP id a56mr63107012qtb.338.1555341124415;
        Mon, 15 Apr 2019 08:12:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555341124; cv=none;
        d=google.com; s=arc-20160816;
        b=J5LgTPvhih8Z5KD8gJoePJqfShI5P6aCeZaELh+e2G2pNEjveG4QtwLYsxy4Mu9+QU
         Zi+XzZoSn7WVZ0w4TpuXlaEthEV4Ct8tQxWfo5ud4tPzfFUgM0OySXoLYAKVzYgata/i
         ITFGQiWfZDkbMGwpttrSB+pYMyJ5G+qMqb3+nSvss8lzRUa9lUaGILgr/SDmk17IEKqY
         SG2B5g/MUZCr6gj0OhthOB3WWWeW9RiI/THSi4ADd7GwcyDZ98axQwECUMqrkuEIgYg6
         EVNMXHlN0LZuKk8Eko91HmjRUH2X0Z593+9JByIkXP4oiLpfPynu4UmIEzd6DQKyQSyf
         0IDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=xJ0SjR0hZQnYy/yKGzIYan6xq1V7J9UCtRxctImHP38=;
        b=Lpcp8eCUom1CtJqCzQesJLRe/MBLh34JLEv66aijKYKaC/dQOV/aJNIvxU6w6BjQaf
         M3TNr0T6hF+lQk1tG1rNi53J8kVdy8zn+2PI1tNY2CJQZnBJqUyLLwT/AVcycxqF2vDJ
         qr5EnTOEUkl3y66IEH7vnbM8m8LKSZoU3+Oyu7OchEB2ChJrLr+UY14rQ3fBXlA5rP2G
         vjSoHIUav7GGTHW+ffMyM1aXZgImL7wq+yXbwFaqkQXtamfCSVpYf9aVaVN/3ROQiekl
         iRiGcTB3jplLxV8pw4Q9Uw3LIa8vyMrJBIazACckhWp/e2lhfSnKx//UKU20xVizugQz
         vN3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a184si1584506qkf.45.2019.04.15.08.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 08:12:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 116D581F0F;
	Mon, 15 Apr 2019 15:11:57 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8A56460F9B;
	Mon, 15 Apr 2019 15:11:48 +0000 (UTC)
Date: Mon, 15 Apr 2019 11:11:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: "Yan, Zheng" <zyan@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>, Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>, ceph-devel@vger.kernel.org
Subject: Re: [PATCH v1 15/15] ceph: use put_user_pages() instead of
 ceph_put_page_vector()
Message-ID: <20190415151146.GA3436@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-16-jglisse@redhat.com>
 <df4da184-fe8b-c189-43e5-fac58adb3ed9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <df4da184-fe8b-c189-43e5-fac58adb3ed9@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 15 Apr 2019 15:12:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 15, 2019 at 03:46:59PM +0800, Yan, Zheng wrote:
> On 4/12/19 5:08 AM, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > When page reference were taken through GUP (get_user_page*()) we need
> > to drop them with put_user_pages().
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: linux-fsdevel@vger.kernel.org
> > Cc: linux-block@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Jan Kara <jack@suse.cz>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: Johannes Thumshirn <jthumshirn@suse.de>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: Jens Axboe <axboe@kernel.dk>
> > Cc: Ming Lei <ming.lei@redhat.com>
> > Cc: Dave Chinner <david@fromorbit.com>
> > Cc: Jason Gunthorpe <jgg@ziepe.ca>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: Yan Zheng <zyan@redhat.com>
> > Cc: Sage Weil <sage@redhat.com>
> > Cc: Ilya Dryomov <idryomov@gmail.com>
> > Cc: ceph-devel@vger.kernel.org
> > ---
> >   fs/ceph/file.c | 3 ++-
> >   1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> > index 6c5b85f01721..5842ad3a4218 100644
> > --- a/fs/ceph/file.c
> > +++ b/fs/ceph/file.c
> > @@ -667,7 +667,8 @@ static ssize_t ceph_sync_read(struct kiocb *iocb, struct iov_iter *to,
> >   			} else {
> >   				iov_iter_advance(to, 0);
> >   			}
> > -			ceph_put_page_vector(pages, num_pages, false);
> > +			/* iov_iter_get_pages_alloc() did call GUP */
> > +			put_user_pages(pages, num_pages);
> 
> pages in pipe were not from get_user_pages(). Am I missing anything?

Oh my mistake i miss-read iov_iter_is_pipe() and iov_iter_get_pages_alloc()
missed the special case for pipe before iterate_all_kinds() Thanks for
catching that.

Cheers,
Jérôme

