Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99846C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 10:47:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4230B2054F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 10:47:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4230B2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E0506B0005; Tue,  7 May 2019 06:47:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 791C56B0006; Tue,  7 May 2019 06:47:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67FA36B0007; Tue,  7 May 2019 06:47:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 171A86B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 06:47:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b22so14255904edw.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 03:47:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=exQydsRsuNLlVkrAYWeNATsUHctANXViPZH8mHLZc3Y=;
        b=Wpd9j5UCKbseKBDn91ocv1iWpmH4Ozw2TKn1kk3AEwfv3Vgf9igM/cLfCS4L99ZG4D
         EH9Wh+Bjw79SWovBszy0wupkP5z21zNWwsIRjhF5zUs5sjVY73p9tAFjMepLDFpgFLL4
         TjCbi2GaYwuQl941FYbtwK9OYb+ym3Tzg/gKn9A2sL3LJCjuLbVlVU3xpVwGkEYda7R4
         sm0BBjL9bQE0Z5AEukHsIAkDIUpUWkuuGQUNXmBivK/hNBv7FLgtpMBtDjcFiuEk6LlQ
         Lb6YsBffCg4fb1NqVR2MiOPbNM3bAQBktzglfbtDUMy4Xl/EiyKNXG7Tn0Uew8ZdYpfj
         fB/Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWRZvT1gd2W8D4OaUpGwDj0d2QUESCb7akB2QTDv0I6iGFU5Zfj
	OWo7tQ9krsfwbASSNBl18/SwCYBcTcEtMachYPoGcpcZz4chfYhM0yCOSCECKESqv+kGVBFt9JR
	lzeLaxbl9ddocO9hU7/Xwlz8Jhqe1LhzArotFaW1AjO0YZ28pKGpl1z6hns6eW10=
X-Received: by 2002:aa7:db0c:: with SMTP id t12mr32315230eds.170.1557226033501;
        Tue, 07 May 2019 03:47:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrC4nfmu2JX4Z6pY8ZQ0ApAf+1OmgLdsTZp5zaFMP7X7jXnGgkdCGqeXt7BEfTnxDtmdiT
X-Received: by 2002:aa7:db0c:: with SMTP id t12mr32315131eds.170.1557226032344;
        Tue, 07 May 2019 03:47:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557226032; cv=none;
        d=google.com; s=arc-20160816;
        b=eWdb4QFYTFqLR+p55/Ht5NV5j6HFZO1OtPGPzyQNhoRY1B6zjNN8vkUD5LWlxYKHRv
         gNXmcHa0Ki3RmQifJxF3sOD/k2QXCf7C54U3omMuCCnHNZHCd28Xxiw1tr8dobIIz2Fi
         sJOFFfulBmrywR6EFwQsO5negMRizR4xsdCUy2yMk5Ky4AAMAZtCkQur8PeJAHQwuIvz
         xjVkdkn+N7ou3zQ4mgoQwnay5fR9eBe4uep1FkwQzQA6aVYfu+SA5tp4Aeen6pEej7IW
         fGEgt9xlHzuBHCj0XVABfIN+H3EbtbfPV2b6GtFKoYvOxI7gximsz4Tdx8YlKg4+NTWv
         c+Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=exQydsRsuNLlVkrAYWeNATsUHctANXViPZH8mHLZc3Y=;
        b=Y9/M9pWDf8sNoZOpcjP1BHUuN2RIl70UtRkIoPJrA5BOwLn2J69xo5dbVNdOkxmmJy
         0rltXN5u7Pnrxdbamxnd8AEHKZGmqdIPl1BvjqFDdRoxMMtAsYCpN6qTQCI33N7Y3TMW
         NbE+7BvybdNgUQOsCkBBfW6vU+eHuYuARjjRvIO8rkMNwdIrLTtTYKU5RNeHY9qNd53/
         Vf2LHywyMek9kvTHOy5n7vR3jcB3bhVUlhMNvbQ/TrKgppLp/okyU9aFzJATwBJ6r+x2
         MpPf3RyvVDobE4g3M2n+DyA7WkF8BGWlBx6Xeq0PXxRyPOhqBpO08PRI9SWuWOBRJNGr
         bUYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v28si5410286edc.12.2019.05.07.03.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 03:47:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3D211AD56;
	Tue,  7 May 2019 10:47:11 +0000 (UTC)
Date: Tue, 7 May 2019 12:47:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
	rientjes@google.com, kirill@shutemov.name,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
Message-ID: <20190507104709.GP31017@dhcp22.suse.cz>
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
 <5a571d64-bfce-aa04-312a-8e3547e0459a@linux.alibaba.com>
 <859fec1f-4b66-8c2c-98ee-2aee9358a81a@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <859fec1f-4b66-8c2c-98ee-2aee9358a81a@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


[Hmm, I thought, Hugh was CCed]

On Mon 06-05-19 16:37:42, Yang Shi wrote:
> 
> 
> On 4/28/19 12:13 PM, Yang Shi wrote:
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
> > 
> > Hi Kirill,
> > 
> > Ping. Any comment?
> 
> Talked with Kirill at LSFMM, it sounds this is kind of intended behavior
> according to him. But, we all agree it looks inconsistent.
> 
> So, we may have two options:
>     - Just fix the false negative issue as what the patch does
>     - Change the behavior to make it more consistent
> 
> I'm not sure whether anyone relies on the behavior explicitly or implicitly
> or not.

Well, I would be certainly more happy with a more consistent behavior.
Talked to Hugh at LSFMM about this and he finds treating shmem objects
separately from the anonymous memory. And that is already the case
partially when each mount point might have its own setup. So the primary
question is whether we need a one global knob to controll all THP
allocations. One argument to have that is that it might be helpful to
for an admin to simply disable source of THP at a single place rather
than crawling over all shmem mount points and remount them. Especially
in environments where shmem points are mounted in a container by a
non-root. Why would somebody wanted something like that? One example
would be to temporarily workaround high order allocations issues which
we have seen non trivial amount of in the past and we are likely not at
the end of the tunel.

That being said I would be in favor of treating the global sysfs knob to
be global for all THP allocations. I will not push back on that if there
is a general consensus that shmem and fs in general are a different
class of objects and a single global control is not desirable for
whatever reasons.

Kirill, Hugh othe folks?
-- 
Michal Hocko
SUSE Labs

