Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92B36C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 20:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61AED21851
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 20:25:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61AED21851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0E356B0005; Wed, 17 Jul 2019 16:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBF216B0006; Wed, 17 Jul 2019 16:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BADEC6B0007; Wed, 17 Jul 2019 16:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9317C6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 16:25:32 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id u202so11723172vku.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:25:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=YbxxH1IjD49tWsFcsl1DeGjt0b+saeDtRIBRfwrMgSc=;
        b=gSaEoxFbMkifYX36aAVUvfLJ+6dmhCCF8ez6HtrWoTaL27whgkK4nbri4zsuUXBXng
         GrF1R0Rsj5R+hBsSruSPp7NmChu+eOyapisEeJuLdz+g7O2T07p7R7c3ABEaIcq0mcrZ
         7ZXybZAB4tBsJxiTU92wCgJvgk0KfQivJiZ37YPeDIp6jU8VBy2EF4LOG02bZPvQsCiT
         ny4mF4iPx4ef0KylBNcmPmJGu1Pq3HchfPFtbrvCNA7N0Qg2wplqsqF8Br8daft7f5bA
         yZx343BDGhmBG3iFUWN3lQwU4LjBLQZb0yd6lkSIQaPwvmzq+k9xWwRUH+67IdP1Dwyj
         ZNvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWe/5rjn6V2b2lgKTuWp64/IL3UhugqjKjqooh/J7F7xVATzKdM
	oVHOSj578YDBhPpM5fnfoJZelYAaPpC6RWyR20Cmn3JldFPBAi9kZeKn2wJsTC0tmCiYZNQxQJk
	T8A+AramT31yvjPAl0HZ0XcO2St5KfpMKDhe7S4NB6OQTfa1BHnNdZTKXJFyYu8myxA==
X-Received: by 2002:a67:9946:: with SMTP id b67mr28153809vse.37.1563395132311;
        Wed, 17 Jul 2019 13:25:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy431cmr0KaeI80clgpDNjSK35CzvLzkUIUbBReRxD29fw1yEvu7vGDK5VrNg3nVhHZNcHi
X-Received: by 2002:a67:9946:: with SMTP id b67mr28153736vse.37.1563395131694;
        Wed, 17 Jul 2019 13:25:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563395131; cv=none;
        d=google.com; s=arc-20160816;
        b=wwYv0qRrZDWBfla0467xfCNvTWz/arMyBVKuIBJbpZV+dFt/tE4btad+oMw7mcZRAl
         3vITLA0BDiUH3ZVl5IOt3tn+jJJt7s4lYidOf2OyV960+eAZ7vT31UkegfEfxJF6HYwH
         C3JJ/H2YCisl/ADeiG6xf+nUnzyh1GOSit64A6lo+/G5mCURN5U/UfSkAYEYkhh277kO
         +hWTk4XSnD6NLyQh4QQ0MzP98Dsxtjer66ccyuhbnZ8syEFKrbGRCc+UxIbsCLbrvRZs
         4A5x2aFWI+GwoBfsk2G1P3pg2VlXoy3Ww1G+RzUcbbCs7CbUeGHcIEBFlSBr7p3Xns0K
         x/bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=YbxxH1IjD49tWsFcsl1DeGjt0b+saeDtRIBRfwrMgSc=;
        b=kSA4DUXYsXGvqll/Ms8U76b1Q8Hdkop1KWBHSWU0uZAky2gyUWgAKYkWk2OpEc/q90
         WHKP9dFaRPHnRzJqGwIzcODe1CelYFfiZ4aNJ1ZiMcPIx8CAwBkbzJ2UG+IvTS2bYhHA
         Ztppz5cl5fQn14NNuda28PetfYy3TI3bt17TLnxS0EGm1sreAiyoZ1CQn5FRP0iB4xxq
         269Fmp0ZI964kd8k9L0GLO5hw9DBKCZ98ybr3KQuEAoO/GuEz6FGr1WDPVqvjCyr9QsH
         P6MBEbNG+6nD2K9iETzRd/2q3V+po7Px+HxZrijg4t35qKg6Hj+xEFuJGIgTbVDINSAp
         Uojw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g23si6060412uam.244.2019.07.17.13.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 13:25:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16CCC302246C;
	Wed, 17 Jul 2019 20:25:30 +0000 (UTC)
Received: from llong.com (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 862655C260;
	Wed, 17 Jul 2019 20:25:25 +0000 (UTC)
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
Date: Wed, 17 Jul 2019 16:24:11 -0400
Message-Id: <20190717202413.13237-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 17 Jul 2019 20:25:30 +0000 (UTC)
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

