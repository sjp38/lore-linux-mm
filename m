Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25273C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:37:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB073206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 19:37:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB073206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 960998E0003; Wed, 31 Jul 2019 15:37:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E9F18E0001; Wed, 31 Jul 2019 15:37:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AF948E0003; Wed, 31 Jul 2019 15:37:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 544158E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:37:41 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id j140so29775994vke.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:37:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=+bKc7B4JzgT9DtuNjUTDcn35OMgA2VDnh+9KjBEbSOU=;
        b=XLchoF4iv6pXBE7bX+FRiaNh7uGu5fOgjgARQ+raqIgmhY77jmBcOxinDaxTZwDsk7
         zp56morVkRxcG8xrNyMg9KAlinn9OdpWWA68J7L5cAN/+4FihAve6nVyHdGgv6YJqwiy
         OiiUNJg38nfK85WX43F1pDQD2Pa/cL0buXUTPBVSvB7LvnneLhb3ZWDIFJF29mbrFFyY
         csLfCi7FK6Tu8okXdJ5Tfg9dltJ8US5qyzd4F/1pKSpCBAPNcoShKAux0TT5YKp5+/3z
         Xef58IEK6LIaTSjTWDX/sPUSsUpe7acjN3B2L94KaGcE7lmkfo/W8tqK4KDRtPHi8g2W
         5jIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUyuRzvrWEe8S9ql9b5GCxefCJfpO9HSn6UtjPB4jLeVWTqUwXt
	gpIfCe4PBhwszzwxHeH6LpxvhI1mVvmrSXnk7wfFeo6aAsKhHm2iG+D9KUjRCHnx/5R3/W3IOya
	ZVTKavWNOyibqhiO83yN0m5cJc4hCJeekZld9np+OpgS9MZKUCpHOR7aH6zwIc4cycQ==
X-Received: by 2002:a1f:9ad7:: with SMTP id c206mr48637175vke.31.1564601861040;
        Wed, 31 Jul 2019 12:37:41 -0700 (PDT)
X-Received: by 2002:a1f:9ad7:: with SMTP id c206mr48637128vke.31.1564601860525;
        Wed, 31 Jul 2019 12:37:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564601860; cv=none;
        d=google.com; s=arc-20160816;
        b=s3iS5N0dUlB7M9pc+TE3RXY2neRs+CRKmkgR3wwwrFvsiWFn/147ccrz+fHIDLpUUm
         Amy67lpP6L75sssLI7kehvhsUaFGGEzqy4mOQ97WcfHA7wdjS82iOZs6DRyVXuGXXWae
         MrFCW8FYSWPLEttG6h6+Mh5hiq/3dm3O3iGTMBRbLQojDRwxKOdog7oBrkJErkkssQvV
         0Z2kaIcrhu0jf5Lu/eWrsh+DQ+oPvSkHZmIA6GUjmp7UGUk8UYcAMFuZcunN+6taGyRA
         f9aqHmprXgxkMr+OWI6hF4j57hd0agPPIx6wdhP5kSCqYYyh0eUMPQDaYt8/G6eHUEZp
         7tYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=+bKc7B4JzgT9DtuNjUTDcn35OMgA2VDnh+9KjBEbSOU=;
        b=Um7GVQZ7/kpYuYLwgwIIQ8X/4XW4C9gP5L4tahV8kQFPNeIY/z2+XNt1L/XNw0Kn9D
         pZ6dTSDAuS2RAw181bKRqi2cnuqUhjmBAwgzGkvbPBACiYuGPpwKFMbdlqMOLZptdS65
         LikCT0PByoAMFwsggM+NviTueXGzIQKAAZ6vIEyXjoWhRA+KV+4Xb4L/9Lb1fwbaOo4N
         WfSWv/Rlvna/N7AfEBqjAzt4eQ0ChOkqLThsrdjX1sY0HGk3UO3GrZ8mJHNeXB0JkmVU
         b+ntWRgzT8ulwhixOlDaiXNMoTzKvwbOrPBI0TN14x/CwAXbMpaIC+CtTnUl0bkc1bbg
         0mcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor33808377uan.13.2019.07.31.12.37.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 12:37:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw/uC7Sg0RgYeqV/6ZnjT1WzyZlwnkKUfrWxPSyTzC349Dq5/eLPf4Pq8CVGYdLBk+RnFtD3Q==
X-Received: by 2002:ab0:175:: with SMTP id 108mr75476010uak.136.1564601860284;
        Wed, 31 Jul 2019 12:37:40 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id a23sm8006371vkl.52.2019.07.31.12.37.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 12:37:39 -0700 (PDT)
Date: Wed, 31 Jul 2019 15:37:34 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 4/9] vhost: reset invalidate_count in
 vhost_set_vring_num_addr()
Message-ID: <20190731153640-mutt-send-email-mst@kernel.org>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-5-jasowang@redhat.com>
 <20190731124124.GD3946@ziepe.ca>
 <31ef9ed4-d74a-3454-a57d-fa843a3a802b@redhat.com>
 <20190731193252.GH3946@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190731193252.GH3946@ziepe.ca>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 04:32:52PM -0300, Jason Gunthorpe wrote:
> On Wed, Jul 31, 2019 at 09:29:28PM +0800, Jason Wang wrote:
> > 
> > On 2019/7/31 下午8:41, Jason Gunthorpe wrote:
> > > On Wed, Jul 31, 2019 at 04:46:50AM -0400, Jason Wang wrote:
> > > > The vhost_set_vring_num_addr() could be called in the middle of
> > > > invalidate_range_start() and invalidate_range_end(). If we don't reset
> > > > invalidate_count after the un-registering of MMU notifier, the
> > > > invalidate_cont will run out of sync (e.g never reach zero). This will
> > > > in fact disable the fast accessor path. Fixing by reset the count to
> > > > zero.
> > > > 
> > > > Reported-by: Michael S. Tsirkin <mst@redhat.com>
> > > Did Michael report this as well?
> > 
> > 
> > Correct me if I was wrong. I think it's point 4 described in
> > https://lkml.org/lkml/2019/7/21/25.
> 
> I'm not sure what that is talking about
> 
> But this fixes what I described:
> 
> https://lkml.org/lkml/2019/7/22/554
> 
> Jason

These are two reasons for a possible counter imbalance.
Unsurprisingly they are both fixed if you reset the counter to 0.

-- 
MST

