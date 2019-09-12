Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 530DBC4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 21:12:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E0CB208E4
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 21:12:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="KFHe5mls"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E0CB208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B83C6B0003; Thu, 12 Sep 2019 17:12:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98F696B0005; Thu, 12 Sep 2019 17:12:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87EA46B0006; Thu, 12 Sep 2019 17:12:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id 72F7F6B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:12:32 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id F2E7520EEF
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 21:12:31 +0000 (UTC)
X-FDA: 75927517302.08.pet13_6d621ed03862b
X-HE-Tag: pet13_6d621ed03862b
X-Filterd-Recvd-Size: 3764
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 21:12:31 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id b136so58321289iof.3
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 14:12:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/b+3OQviYV9Cx8Jpy6PR3N5EIJEAigHA55BiQ/S4UC0=;
        b=KFHe5mlsJrSAVOY+b8QtqMzWGp2l0mvHlF8idD7sMRkAzAt6gvMlVyI1dt7l0GVTEV
         r68o7XgMfPa45PBPj5KdLGLwcVZXgOvaF4DWBEvcTXj5rdvz12i9MXk4tReT7X1Bn37Z
         Q0Xl7qwt4RQNhE0qGpVL/URWy7Xe6hL2vRP9kE9ahRstwRsyqsa07e5TzJ7qVeg1dzMi
         Rj5VDtWA2m4T+zPp0Gwk5QOUQIQbi2EJ+J63BaXwMka0/j4KLnTQDp4/zSCJly/NMNQt
         Cx2VruA+FTJ9QV/VJ5W5Fz8WRikab+4vBv6sfkNBM536ic/0OzTs7wgpIcq9q3ca3l3u
         9yOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=/b+3OQviYV9Cx8Jpy6PR3N5EIJEAigHA55BiQ/S4UC0=;
        b=kpXz5OvBo0qDJZok9TlMc9pgOYZMXsOrMcg9E4UkwT9cBdNCTr2vLDs3gyNxq+aEPn
         /2a9SlnFIuzyhZnxLjLkfiSjJya2y66VRGaolOvP4pBEfZZHjhmGkGoDbXy/ufC0/tcA
         LxVliABvO43BSlK341ibvwE+8QFeEuwdthzDkHY04l7DaUAIGu810jd5RTl7zw0bj/JK
         1h/aPNCmWm/CMqlCPcJVnw+ba0+4e3MoLdMEhYg/hfpIrdiRqI/PWvNom8pCKxe8sz0g
         avTnHQPvEe/E17EQyou6lC/qTOkmFyKLVr4h/pkGS2PdoU3uNbWVjOIRCP+GpqlB25//
         ohiA==
X-Gm-Message-State: APjAAAW2dYtO7Fw7BY1/1KYW0+f7/2N+euxGH1wgdFlDwAwTfA6g76x2
	YWHpq4B2ngkdSorqtsIKeadlBA==
X-Google-Smtp-Source: APXvYqw2RkjLv1cKgS0XZbi4USxP/69EJewLB2yCle/BuXJL6i9wUHOYdh3gbIYey9zyQx1Kua9bTg==
X-Received: by 2002:a02:ca04:: with SMTP id i4mr14195989jak.134.1568322750797;
        Thu, 12 Sep 2019 14:12:30 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:9f3b:444a:4649:ca05])
        by smtp.gmail.com with ESMTPSA id k66sm44404594iof.25.2019.09.12.14.12.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Sep 2019 14:12:30 -0700 (PDT)
Date: Thu, 12 Sep 2019 15:12:26 -0600
From: Yu Zhao <yuzhao@google.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 4/4] mm: lock slub page when listing objects
Message-ID: <20190912211226.GB146974@google.com>
References: <20190912004401.jdemtajrspetk3fh@box>
 <20190912023111.219636-1-yuzhao@google.com>
 <20190912023111.219636-4-yuzhao@google.com>
 <20190912100642.57ycbflh5ykcgttu@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912100642.57ycbflh5ykcgttu@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 12, 2019 at 01:06:42PM +0300, Kirill A. Shutemov wrote:
> On Wed, Sep 11, 2019 at 08:31:11PM -0600, Yu Zhao wrote:
> > Though I have no idea what the side effect of such race would be,
> > apparently we want to prevent the free list from being changed
> > while debugging the objects.
> 
> Codewise looks good to me. But commit message can be better.
> 
> Can we repharase it to indicate that slab_lock is required to protect
> page->objects?

Will do.

