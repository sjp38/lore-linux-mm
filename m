Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A999C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:41:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAF3E2085A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:41:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAF3E2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E5856B0008; Tue, 14 May 2019 10:41:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 596596B000A; Tue, 14 May 2019 10:41:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45D8F6B000C; Tue, 14 May 2019 10:41:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E997C6B0008
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:41:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n52so23668879edd.2
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:41:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4pBFWQ4DnvT7PXcFjZRNsJcu+Bsqbpj8f0CIeSOBqkE=;
        b=tmhLN0MyDQ/MpnOqNe3W21kmgDsbGYOJrdVjOOqDVvYNuunm7QP5yMoqKpHrfjk7z+
         ys+3dvxVKu9tU99RVZAcmlacAKetiGlpMDBg/hXP4zdpxT/6MfuWGvPBIUv+BjYBotm9
         JAqNphEwG9JYkMd5EGppd1CCaJgg9FpTOmXCbuBXjODqhgU6+hWvyz+gVw26oWOHIIy0
         UNBQ7kOzYA0hqNZjjSDZB5CT1f79p+yfV14lWPX3p13O9XDXHGRzAS6pQaYQeWWhaV8j
         zx0BuhK20FtRNtEv2cw2BZIktggSZfgA2p7kmtosaXf6BzZ7dkF+IEuQJP3IPfXEMibZ
         yU9Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU8syUBZ7/UkBiT1J0DHFY2zRRZjzwJSbOJj2S0yIASfbuoWQ1u
	7fc2uI+0xZqlCDK+qNeMO72laDCUxg7zU0PE62TvuNz3T4trjM6SK7VWrCXMz1c2PUpUoHc8y0C
	FHaTzKm4/h8BHk4iv22Vmb/vxpzDRD4593GJpaiLBnPDEp2Gp76b8xVR5TMLRGYY=
X-Received: by 2002:a50:a3a2:: with SMTP id s31mr36532089edb.254.1557844867452;
        Tue, 14 May 2019 07:41:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkS4iMTs86ieoPrznzQsXMbMgmIgYKA0n6thxnE/BvRXFtb/sqaRUoJ0y6DNhD9Zi6GwvW
X-Received: by 2002:a50:a3a2:: with SMTP id s31mr36532018edb.254.1557844866699;
        Tue, 14 May 2019 07:41:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557844866; cv=none;
        d=google.com; s=arc-20160816;
        b=cp7wlVb7Wq5M32sfpp8CjyJfedsjMEEPjjY2a0EcAVmD0kcK9ODz2FA4K7sFu7pRo5
         JFJSyBgcPSyqO/0+PCxFgeGt9Pw3wKuWymJdffspmBXh8BlFnXdssPg8E0dDNhggRWOb
         8DQ2vnMALJsdObI3AwzG4ouQDNq2UdOsxiAykoOQRvfRcBs36U6F2OOKQmmYHN/GDMAK
         582T1qxKxL0/Q3rn2Vqh8RPFEizkDZOZsJngSAa6973i4c6DFxkmvSaPwSu+tHJadSSl
         NrX/yg7oSH1FyrXsRq3a/BCT2dwHKHDq4OatwwgU9dcyFBCKlc4iWiy0XRwu29nsgY/O
         +KTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4pBFWQ4DnvT7PXcFjZRNsJcu+Bsqbpj8f0CIeSOBqkE=;
        b=bi6keWeOW+Qez6rrIqZL0WbbnlFIzxcQsbYzm3qZk/sWghzN3kVFa5ISkYULatzUFH
         mtodPJ3Gbz3KakvTIBRIpSIiAJ9dRGli0Kbs6+7WRRkPpnho+H46DrrfMfMlMHElSGBg
         avP0Lu4/DuQxmKOIEv3PehgYkH8sXn9ETfw9M3cI3vFk+9FH2Fb8KS3JgghYAhE6MRTT
         Lof5+AR6nBlfLMwsV8O2cCjwXXTeBVzq+3O2UXoZ1wvITfC73AsDCySv1Qblcfm63Hy+
         nyMLAPMjNRGk4SNiOJFEiHUmTbU0KqcEvPssLGeMclt1HIGbD10cY+BSw8sKfoqbcGAM
         2Sjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c3si1051445ejb.187.2019.05.14.07.41.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 07:41:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 16AAFAC38;
	Tue, 14 May 2019 14:41:06 +0000 (UTC)
Date: Tue, 14 May 2019 16:41:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190514144105.GF4683@dhcp22.suse.cz>
References: <20190514131654.25463-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514131654.25463-1-oleksandr@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[This is adding a new user visible interface so you should be CCing
linux-api mailing list. Also CC Hugh for KSM in general. Done now]

On Tue 14-05-19 15:16:50, Oleksandr Natalenko wrote:
> By default, KSM works only on memory that is marked by madvise(). And the
> only way to get around that is to either:
> 
>   * use LD_PRELOAD; or
>   * patch the kernel with something like UKSM or PKSM.
> 
> Instead, lets implement a sysfs knob, which allows marking VMAs as
> mergeable. This can be used manually on some task in question or by some
> small userspace helper daemon.
> 
> The knob is named "force_madvise", and it is write-only. It accepts a PID
> to act on. To mark the VMAs as mergeable, use:
> 
>    # echo PID > /sys/kernel/mm/ksm/force_madvise
> 
> To unmerge all the VMAs, use the same approach, prepending the PID with
> the "minus" sign:
> 
>    # echo -PID > /sys/kernel/mm/ksm/force_madvise
> 
> This patchset is based on earlier Timofey's submission [1], but it doesn't
> use dedicated kthread to walk through the list of tasks/VMAs. Instead,
> it is up to userspace to traverse all the tasks in /proc if needed.
> 
> The previous suggestion [2] was based on amending do_anonymous_page()
> handler to implement fully automatic mode, but this approach was
> incorrect due to improper locking and not desired due to excessive
> complexity.
> 
> The current approach just implements minimal interface and leaves the
> decision on how and when to act to userspace.

Please make sure to describe a usecase that warrants adding a new
interface we have to maintain for ever.

> 
> Thanks.
> 
> [1] https://lore.kernel.org/patchwork/patch/1012142/
> [2] http://lkml.iu.edu/hypermail/linux/kernel/1905.1/02417.html
> 
> Oleksandr Natalenko (4):
>   mm/ksm: introduce ksm_enter() helper
>   mm/ksm: introduce ksm_leave() helper
>   mm/ksm: introduce force_madvise knob
>   mm/ksm: add force merging/unmerging documentation
> 
>  Documentation/admin-guide/mm/ksm.rst |  11 ++
>  mm/ksm.c                             | 160 +++++++++++++++++++++------
>  2 files changed, 137 insertions(+), 34 deletions(-)
> 
> -- 
> 2.21.0
> 

-- 
Michal Hocko
SUSE Labs

