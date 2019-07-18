Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 453D3C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12C2A2083B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 18:07:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12C2A2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A23676B0007; Thu, 18 Jul 2019 14:07:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D3B76B0008; Thu, 18 Jul 2019 14:07:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C42E8E0001; Thu, 18 Jul 2019 14:07:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5D26B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 14:07:47 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id m25so25042607qtn.18
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:07:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=YbxxH1IjD49tWsFcsl1DeGjt0b+saeDtRIBRfwrMgSc=;
        b=jUS1K4mJCZ2q2lpS6mjcxmZniJevIFozMhuT+c9WhZHuldiI98wk40YWIOtsm7LJZR
         +iF2WRGn4jXBAUtdsewzK6siNRbwEPd3BvBRKkn8x/veaK0ZBWzct0HkgwrfiRNmeHW6
         B7Nikm393oTnSilqyK3dmI0jc6y7BxWc7KYCjUqNpa5d49tpwK695Ar7EXF+VC3YWSAo
         JluxQYCeLKBC5kgx7RX8GvaNpgpW4Ke8yvqOtKSvy8iMdrTDHYI/bwhHA+FqmO3lZ/dx
         /MtHGxrbkGzDyg5wLHTA+zXtYMrpz41oCgxU584dvCQPDrekw9OxTVlXCtppBY3f4yA9
         wsBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXRj7oGtWsCwTGSXXZpsFcpk3QKWydDx6qyhOuMKw3iFvErApD+
	ykS1x55HYRl65jxEaUQfKRgODGBi/uHP7nuitbUkIckGJMe5sIhGPxmKN+Bd//AMtA4E00kBnbm
	XscXZvX+5e3dnFoXW2cgNrdNBTwzOKFN9F+nhzGIveoohMsh4FVXHgY5f0b7lZIAd5Q==
X-Received: by 2002:ae9:e608:: with SMTP id z8mr31497172qkf.182.1563473267254;
        Thu, 18 Jul 2019 11:07:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjnUDbEQMHIeKmjvH9ZT0fiEmr5VjKr98Cuob0/M5ozUhw2NVxmDEijpU3Fzd/Lz49Hw0+
X-Received: by 2002:ae9:e608:: with SMTP id z8mr31497137qkf.182.1563473266672;
        Thu, 18 Jul 2019 11:07:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563473266; cv=none;
        d=google.com; s=arc-20160816;
        b=HoAFw32AO80eXgXhampHvHH48ELLaNjBRs6V/Jceni2/JS3t33fzYLRqnEI6NCUD8y
         Kzt2mM085qu7l2oPk2xgoliG1JromMEq6VGcuiNeRHclfvdSk6u7yxRss3Q53gU0yCRj
         o+NmMUGSBw5H/G1bfASLXokUHYCsRy4O1K3dyFWH1v7i2mYrA3X+2u9yVuUsISQeoI+V
         o6/I4yuZXYp26LmUPtJMd/oRDsjKZHCSJpA5AOEOGHEDxwvUpBI2PL/7q+Iw8GMzecTL
         TpkLyc36MdDj1CmVf+Omz8avd4uQQoHJEeChuUpxRZJIhhWmsSH7WqNLYx1NqZTNi8VW
         xi2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=YbxxH1IjD49tWsFcsl1DeGjt0b+saeDtRIBRfwrMgSc=;
        b=CpJjocFo1FmWh6P01X4gVBBc5Uw4mLMCQY4WyN5XmpLkb27sdnTmSVP6anwg2PE0vX
         wRP/8Pg4KdyqhoRu1WCmZpa3wt8KzIDGyKXsZquw7Ak6zl9bn9Apzt0fsSKDbUDcPLzs
         JtGf5ygx9p4hDhRJJtUP7ufGRue4cKS6jl3dGvAGzegLrj7Nvd6XSHXRJmfTzN4MqJGJ
         y8VaMFvDopMw5+xI0CfAfxg5mQ8C49nLj5lF5QI3p6CwvolVtNSb132911rXK++AfOZA
         Rm/hD0YyZ58gBej55ZqEu2opQZcZ7hkxWvMIfOLVNrGMwc063mYbyb/wSG0A9h0ptoe+
         /clA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d35si1437175qvc.10.2019.07.18.11.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 11:07:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CE9728CB4B;
	Thu, 18 Jul 2019 18:07:45 +0000 (UTC)
Received: from llong.com (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 507F060922;
	Thu, 18 Jul 2019 18:07:42 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH v2 0/2] mm, slab: Extend slab/shrink to shrink all memcg caches
Date: Thu, 18 Jul 2019 14:07:31 -0400
Message-Id: <20190718180733.18596-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 18 Jul 2019 18:07:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

 v2:
  - Just extend the shrink sysfs file to shrink all memcg caches without
    adding new semantics.
  - Add a patch to report the time of the shrink operation.

This patchset enables the slab/shrink sysfs file to shrink all the
memcg caches that are associated with the given root cache. The time of
the shrink operation can now be read from the shrink file.

Waiman Long (2):
  mm, slab: Extend slab/shrink to shrink all memcg caches
  mm, slab: Show last shrink time in us when slab/shrink is read

 Documentation/ABI/testing/sysfs-kernel-slab | 14 +++++---
 include/linux/slub_def.h                    |  1 +
 mm/slab.h                                   |  1 +
 mm/slab_common.c                            | 37 +++++++++++++++++++++
 mm/slub.c                                   | 14 +++++---
 5 files changed, 59 insertions(+), 8 deletions(-)

-- 
2.18.1

