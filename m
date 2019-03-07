Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17407C10F03
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:09:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 950BB20675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 19:09:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 950BB20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F13A68E0003; Thu,  7 Mar 2019 14:09:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC3468E0002; Thu,  7 Mar 2019 14:09:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB1FC8E0003; Thu,  7 Mar 2019 14:09:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD4B98E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 14:09:19 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 35so16271935qtq.5
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 11:09:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=32zrO7xBXs0KROXy8g7w0rZEmlukD4hz2w9EGiPJ94M=;
        b=kGj83mQC1op6WllCOSpVOh4soZU6DbBdcosjeBskhtbRs2Sq7H+bL9SZQl2Db1V7CU
         P0D7WyEv18eKcxRW9wq6+wNLgy8lhxxVU3SH9I5IPAwNJ2T0bSrCXDGWWZ9lxeAZViNl
         NUsWbjnUekFnWz9KEddgqTXz5g+83XAGFvEf7v4DGXE/OBHUQMGdPPpi2vsGFv4IXFwa
         Hz1tMdZJGQJsc0XjabeW7xUAbrmAeSIe3ZBLRO52yfky/VoXeJjNhEkzolL/LiYJmTBC
         jYhB/+fsvy3LLskhasYC+mcsRK0rWTLEk91GRrCTN7TiiFNptEpMV5w0QqOgzsKa/Klr
         ywOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUchjLSpBmIc5CVJTj/F5ZRKzFPlBtZweJn8hrTC1d94uNTXHHf
	Iq2VyjV5aczr/dX1BL9kre2wWOjqdm+ilYJfXZbqY58shXkazc7n71ys2+/uvWzo/JwNGlcO/NT
	XmJXWAt7AUVUU2trdGQ2GLr7azHMs9ksFYFsfwuzxw6v4enXbE45mUq5JzoLMS+A5BA==
X-Received: by 2002:a37:c313:: with SMTP id a19mr10693163qkj.220.1551985759476;
        Thu, 07 Mar 2019 11:09:19 -0800 (PST)
X-Google-Smtp-Source: APXvYqy/CBYQQ22699z0M8f9KwdwCGa+YFQoT6Rmw4J6NIYDYQghpOUMT/NF+SJpq55dqsEXiaQw
X-Received: by 2002:a37:c313:: with SMTP id a19mr10693121qkj.220.1551985758770;
        Thu, 07 Mar 2019 11:09:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551985758; cv=none;
        d=google.com; s=arc-20160816;
        b=wSrbcVZ9+QDr+d3FJDMLq/oipSzi6saYVmVhm1rML2SOQ+i3S++vjqqqLPzTcIapuk
         YieJzHGQi8grRm6xyl9eMX2UJoetWwtNfRsrJ4HYhd330ZHzASOlFdd43XmKhCSajThY
         q8JrkuABZK1jca96n15O/uePC1wWh49MkrOQphAuIPeToglbTWZK2/WnUhtRHZCfG5z2
         nVfi8stjxXaISHXEvvHxntK7gUA9C7vDcJnnuu1BoZeYOmdJ0Oa5jvnbOlOro8KmzMsf
         qdyyKLGXIaFOYg2xIvD1Hu1JH2sVUCTc7yGR9kz6t+CfCsfzQ6Myo8x9XgWnzhaZ/dEf
         b60A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=32zrO7xBXs0KROXy8g7w0rZEmlukD4hz2w9EGiPJ94M=;
        b=fJpj5OWUR4/Ta8oPc4YxlaCd8PSB4vx2RkIv2Q1UVhMQza/wu0/TPIym+IR7oEaAhy
         7ON/XUivbmDxrI4guLV/yeDtpf2UxotUalx4gT9uqGK+GOYai9wnYD4xVld50WAKl1xT
         8dgTanPwOPcbzM+W7uHvdSWfQQkjWrrIF/TOhzXDoMk+DwXoLFNZ4eK9Y+GGlL/HKESj
         bj24eP/r/eMMkF5trkS62HahU4ZGBdEtoBfHfcPHUJRB2lNvUk1xCE5clGhti8Y/TxaY
         Dd9agU02Cd1o4w2x4FwY5aHs6afhTwsONQZHjFgPuIf0w2uvJaKggQAxH2N+mEFkZbiZ
         N1eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c21si1322833qtc.197.2019.03.07.11.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 11:09:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 137B9882F0;
	Thu,  7 Mar 2019 19:09:18 +0000 (UTC)
Received: from redhat.com (ovpn-125-54.rdu2.redhat.com [10.10.125.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BD4136013F;
	Thu,  7 Mar 2019 19:09:12 +0000 (UTC)
Date: Thu, 7 Mar 2019 14:09:10 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307190910.GE3835@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190307101708-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 07 Mar 2019 19:09:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:34:39AM -0500, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 10:45:57AM +0800, Jason Wang wrote:
> > 
> > On 2019/3/7 上午12:31, Michael S. Tsirkin wrote:
> > > > +static void vhost_set_vmap_dirty(struct vhost_vmap *used)
> > > > +{
> > > > +	int i;
> > > > +
> > > > +	for (i = 0; i < used->npages; i++)
> > > > +		set_page_dirty_lock(used->pages[i]);
> > > This seems to rely on page lock to mark page dirty.
> > > 
> > > Could it happen that page writeback will check the
> > > page, find it clean, and then you mark it dirty and then
> > > invalidate callback is called?
> > > 
> > > 
> > 
> > Yes. But does this break anything?
> > The page is still there, we just remove a
> > kernel mapping to it.
> > 
> > Thanks
> 
> Yes it's the same problem as e.g. RDMA:
> 	we've just marked the page as dirty without having buffers.
> 	Eventually writeback will find it and filesystem will complain...
> 	So if the pages are backed by a non-RAM-based filesystem, it’s all just broken.
> 
> one can hope that RDMA guys will fix it in some way eventually.
> For now, maybe add a flag in e.g. VMA that says that there's no
> writeback so it's safe to mark page dirty at any point?

I thought this patch was only for anonymous memory ie not file back ?
If so then set dirty is mostly useless it would only be use for swap
but for this you can use an unlock version to set the page dirty.

Cheers,
Jérôme

