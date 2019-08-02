Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BA58C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:19:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1217205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:19:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1217205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 778306B0006; Fri,  2 Aug 2019 05:19:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 729716B0008; Fri,  2 Aug 2019 05:19:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 619B66B000A; Fri,  2 Aug 2019 05:19:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 282A76B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 05:19:35 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t2so41292989plo.10
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 02:19:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:organization:in-reply-to:cc
         :references:message-id:user-agent:subject:date;
        bh=OoiXq+x2gP5mJqlBXgE2AZzJ6mRWJpA+0PzWl/UovTk=;
        b=ckoxHvrc2a6joWDt0RM+cOKfPuVtkFCErbVGMy5agCyUzIZcNij6b+VMK5KbcsIfNZ
         E7sAFMJ8vkSTHK2z8byGrcMNtyvUDtv36Sz7b+OJzQ9pJjoDx7uHZwKubi+4EdTW0ozc
         LcMceUs6dhbiiEBTaQtyaQALiYMsab6qIeMZ/TGwdLcuBNaXf/C3Oz+TKgK2dhmS3NJu
         W08t31fa4uVz7+mXv11AZ2x+DjqtcrzhGfw1iXWm6RPuoW6yOB3WgezapaQvGSkkZftT
         Xb61ltkqfji1BHyYqndmCdZ18vJDk/x7pEISqf8jtFoRBIfcfkFCA9oVOnOpF7q3UThT
         LhqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXDXKR4/jeFq9bMwIFQFyDa0SG3vub1VvYlUvB8RUsGkdiDmrOo
	1933osPD4+6SHMcv353Le142GOplf4H+nswW5CwlnKPPfLYtBwmkzjUFSBjBH1eemhMXD4SN0ZA
	6bJVgjFTzz76rmwACr08QPzWXX4f7aX2kMIAMVAfmWMWdrqtF3Vr8h+pWIZh9DUIakA==
X-Received: by 2002:a17:902:4643:: with SMTP id o61mr101919643pld.101.1564737574833;
        Fri, 02 Aug 2019 02:19:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn0YR2AX6z3YH6QKLIAEopVc88qk0C4frWXXTxbcyqmLYdSS1nHRCe8e/Cns1RESelavRs
X-Received: by 2002:a17:902:4643:: with SMTP id o61mr101919608pld.101.1564737574051;
        Fri, 02 Aug 2019 02:19:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564737574; cv=none;
        d=google.com; s=arc-20160816;
        b=MLCgPIlGQ6OHFUvGkH+bcH/wn1WUOaevJVJrwypbbkQy6Gsry2UTyR2N6bBbC99gMQ
         +gmO4hNtVgTcWIPecDRYz2IMtFskGKGyTu9+fOGEwiMph80vSOEoX/Hro7286mkJC9jV
         dbAeeRa5QOjIlJlksyflRGjFBS+KubuEyPIp/MU1nY4OgXfrfFOKUEwFqWhCkPt6yIZ5
         7H0zJ2q64QzMcfOJ3hVXm7dnGcOklv532qJ/2+XAgfA0PW0lgXWgQh3ez33Us0mx7LX9
         h4MvpGbMBC8jfRjwm1d9qkUfHRcRB4tK2tMEl1SEaNjw5n3w3/rBghKkY+bcVf5g93TQ
         WmWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to
         :organization:from:to:content-transfer-encoding:mime-version;
        bh=OoiXq+x2gP5mJqlBXgE2AZzJ6mRWJpA+0PzWl/UovTk=;
        b=FTjvEhJUz6TV+JjI0W7Q08HEwCewpeGUgIBs3EIjvdA0vNvmXMsyiZEgdJTcgmEjni
         1+KNyeNbKwUgT89z+aX1hovt67mjMLC9g+Izjlx9mum+dAx64KkQur9GJcnbBVnYpmNy
         Wb5Hugj0dCk1x3rtEocR62ZHbyBkR+rkU0XpWgifa1/Z6jnRVzIlU+e9TI1DKpTEp+bb
         qYHFqGej2NZqIK6ISuc1v3ZqRYgUxr1xMkpQWE6Cpk0gJRzGzpKykjoiERifgMFx2kAL
         81WU10q9vknRBwHXfy7dESZU9chIgaHlbff1HNzGivI+ekyZRr3CAucWojqFMSgTVnPL
         tmYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c10si37748588pgw.174.2019.08.02.02.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 02:19:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of joonas.lahtinen@linux.intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=joonas.lahtinen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Aug 2019 02:19:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,337,1559545200"; 
   d="scan'208";a="178105348"
Received: from jlahtine-desk.ger.corp.intel.com (HELO localhost) ([10.252.3.11])
  by orsmga006.jf.intel.com with ESMTP; 02 Aug 2019 02:19:23 -0700
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
In-Reply-To: <20190802022005.5117-7-jhubbard@nvidia.com>
Cc: Christoph Hellwig <hch@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>,
 Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
 =?utf-8?b?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
 ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
 devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
 linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-rpi-kernel@lists.infradead.org, linux-xfs@vger.kernel.org,
 netdev@vger.kernel.org, rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
 x86@kernel.org, xen-devel@lists.xenproject.org,
 John Hubbard <jhubbard@nvidia.com>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-7-jhubbard@nvidia.com>
Message-ID: <156473756254.19842.12384378926183716632@jlahtine-desk.ger.corp.intel.com>
User-Agent: alot/0.7
Subject: Re: [PATCH 06/34] drm/i915: convert put_page() to put_user_page*()
Date: Fri, 02 Aug 2019 12:19:22 +0300
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting john.hubbard@gmail.com (2019-08-02 05:19:37)
> From: John Hubbard <jhubbard@nvidia.com>
> =

> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> =

> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> =

> Note that this effectively changes the code's behavior in
> i915_gem_userptr_put_pages(): it now calls set_page_dirty_lock(),
> instead of set_page_dirty(). This is probably more accurate.

We've already fixed this in drm-tip where the current code uses
set_page_dirty_lock().

This would conflict with our tree. Rodrigo is handling
drm-intel-next for 5.4, so you guys want to coordinate how
to merge.

Regards, Joonas

