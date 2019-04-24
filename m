Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ED1CC282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:58:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A00820693
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:58:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A00820693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E9086B0007; Wed, 24 Apr 2019 03:58:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8981C6B0008; Wed, 24 Apr 2019 03:58:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78A0C6B000A; Wed, 24 Apr 2019 03:58:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADC46B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:58:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h10so9385954edn.22
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:58:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vEBcBXf+DqM2twrJw6kDqdh2aZMApzFL8kbj67SqfPk=;
        b=h6sarVpu++svSTD9OE4//dA774qu8gzkum2XAM7728Eux0/iGyW4U86Zk0ykXQrq6A
         EVqKlGyPUrHMKv29ybkCjSTv1FXQniW/wANe4+foFEdNJIax/gPohlyWMXPjn/0CFNFb
         AbxOCTmvA4bXbLFmgTg6CditluGliS3BMipsx4TKf/dDao6XvU+f1Q8KtHqa1IbqkzvH
         ri8QnAHYy8e7o6xDot9JeGxyfHgWITzgC6iAfoyRKcIOwdtDFhJdpLWchoAKM3fpDdYS
         oCURRkezQ1PpoShjdcWFCtRYC/gQg7BI3EbAWouQ7X2ILOX85wCi90IvOayJBmyw0TxV
         4cmw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWseID48Rgp+r/ET6jD16GQ84T6EPdPTGPy8Dv43zAx+FaKQlJ+
	eKclyzYIR81P/lZClKmEZTxEL2iXmFQoB5bPtdEkro46ES1Q6zYj42TuKI408V9k/vr+HNvO4MH
	7jovfdSdh+0HgQKpzfIn8ODeblP1Cox7PI1M3o+4o5eSuk7mxsrCv+a5XNzwvOxs=
X-Received: by 2002:a50:b283:: with SMTP id p3mr19197996edd.105.1556092718690;
        Wed, 24 Apr 2019 00:58:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVH4XYAIZFnPzEVcHZ1Ae4o6S4PHIfuGvow08SM90yVMAVmKJ5BCwqgDbYHDMx76m5h0QV
X-Received: by 2002:a50:b283:: with SMTP id p3mr19197961edd.105.1556092717964;
        Wed, 24 Apr 2019 00:58:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556092717; cv=none;
        d=google.com; s=arc-20160816;
        b=H7KlHJVtXIvFEd2ygUXfC4rqSazU9m+ab9jro7ifx7o41RhigbZnjmzE2rPdjYGpQy
         SotOqA6EaTkohBt2j2OWoZZ6HoY2MvfKVQdNg8R2DofeSBd8Fuh3poPNFy705I96BItX
         lwbRqw+n/HvoPwdq/PVu76sanAkTt0wwCkQAdJBjBWdPjo8qZVy9+jairqlnIv/3iGPb
         bLdA9jK8QWBLApWGF8H6DbBDINLb/O8xKhvgerL4YwAtRcv3qCQFR56hupGvH56vBT+t
         HnR7NZno4IPiIdHTCNCuzqDw4/hDfR4dJN+4ortTPmpfP+Ckat25PukbR2Jeou44WqmA
         IXzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vEBcBXf+DqM2twrJw6kDqdh2aZMApzFL8kbj67SqfPk=;
        b=Lte8htU4owFxyFJefYzWgi+GsMpWXsYk+r+oxVkbrisvWQmqQsbvfgf4bvLgP3hCxG
         2AGZY02YEIkShdwMl5OXNZCAWa7f7L7aeLHKYi6Swa441/5YDvf2WfKTeIL7LZR2d2Ju
         V5wkCqtiA3zUUkoHWuLmzBR6Manln+93bEaPAtMHrmoIZxNNJ/2ZBVh8naZuwcVDAIpL
         xI+9fBykwQxNOaArp4mHrS1M0Yq/W+OI4gWqfsYinJMR3OBdsmVgOVfEIuImYvaXrsA6
         zT10vp6ckXe/7rKkUyAe0ZTxNwnUtSWSmC0VN2GSmJiL6R7Gelw72GZE2pO9Hc9klpjN
         gdfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n46si6052445edd.310.2019.04.24.00.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 00:58:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25D96AE2B;
	Wed, 24 Apr 2019 07:58:36 +0000 (UTC)
Date: Wed, 24 Apr 2019 09:58:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
Message-ID: <20190424075834.GB12751@dhcp22.suse.cz>
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
 <6004f688-99d8-3f8c-a106-66ee52c1f0ee@linux.alibaba.com>
 <dace50e0-b72c-33db-5624-bf7449552ff8@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <dace50e0-b72c-33db-5624-bf7449552ff8@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 23-04-19 17:22:36, Yang Shi wrote:
> 
> 
> On 4/23/19 11:34 AM, Yang Shi wrote:
> > 
> > 
> > On 4/23/19 10:52 AM, Michal Hocko wrote:
> > > On Wed 24-04-19 00:43:01, Yang Shi wrote:
> > > > The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility
> > > > for each
> > > > vma") introduced THPeligible bit for processes' smaps. But, when
> > > > checking
> > > > the eligibility for shmem vma, __transparent_hugepage_enabled() is
> > > > called to override the result from shmem_huge_enabled().  It may result
> > > > in the anonymous vma's THP flag override shmem's.  For example,
> > > > running a
> > > > simple test which create THP for shmem, but with anonymous THP
> > > > disabled,
> > > > when reading the process's smaps, it may show:
> > > > 
> > > > 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
> > > > Size:               4096 kB
> > > > ...
> > > > [snip]
> > > > ...
> > > > ShmemPmdMapped:     4096 kB
> > > > ...
> > > > [snip]
> > > > ...
> > > > THPeligible:    0
> > > > 
> > > > And, /proc/meminfo does show THP allocated and PMD mapped too:
> > > > 
> > > > ShmemHugePages:     4096 kB
> > > > ShmemPmdMapped:     4096 kB
> > > > 
> > > > This doesn't make too much sense.  The anonymous THP flag should not
> > > > intervene shmem THP.  Calling shmem_huge_enabled() with checking
> > > > MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
> > > > dax vma check since we already checked if the vma is shmem already.
> > > Kirill, can we get a confirmation that this is really intended behavior
> > > rather than an omission please? Is this documented? What is a global
> > > knob to simply disable THP system wise?
> > > 
> > > I have to say that the THP tuning API is one giant mess :/
> > > 
> > > Btw. this patch also seem to fix khugepaged behavior because it
> > > previously
> > > ignored both VM_NOHUGEPAGE and MMF_DISABLE_THP.
> 
> Second look shows this is not ignored. hugepage_vma_check() would check this
> for both anonymous vma and shmem vma before scanning. It is called before
> shmem_huge_enabled().

Right. I have missed the earlier check. The main question remains
though.

-- 
Michal Hocko
SUSE Labs

