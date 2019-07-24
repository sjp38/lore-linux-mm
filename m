Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 502D6C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:40:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 069B62173B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:40:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 069B62173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901E76B0007; Wed, 24 Jul 2019 14:40:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B4046B000A; Wed, 24 Jul 2019 14:40:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 753A88E0003; Wed, 24 Jul 2019 14:40:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF8E6B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:40:07 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id u202so20770647vku.5
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:40:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=alrDnqVaDUAWqH5ELz7ujvbBrCMpTtGLzx35o+lse1A=;
        b=lCVn0jJHyJ/pey2OlU4bDeuVKclG0h6YUWBM13/Nsin7emja/EBese6eLhdYnOEe9t
         KU2C9WRauqFhUfVDarvM370EnwUzBBL9qHNs69yJYQc6DkpP1Ej2/9DtBRvU+u+yD637
         yiW2T0VP0vnrNCICN3ptHZ8J4MUs08gFI0h1CljuOfBrpOFcTEjY7/+FADSFT0LiTmT5
         2xjgzqd0pq8HNJ4Ss/69dcwK7Yx6l6j7n0BhYmS57joreefcpdaLDXxBKM25IaqVZ2g2
         jEMqx/sUIjiC619eR2mjfeosoHRM24IB/Vp+W3LQUDyXWaLh0ApB/HAsIIWclZShpL/D
         rvdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUtpiySTvgaz4hVTTL2QwRbNl7Kmv56ZgSO8gJgMvpr4tm1gdQR
	Cpc8vyQqF1Uu9v+WF4nNvFnFwwI9YNOWpl7z1xl6cJnVEfdsA2XG+PUy7ZhT+enX67BDQvrGcLi
	izu9Y9ydG85Yn/Hegsr5yhH5zV6F8bQiMGTfNnnP1N6lcrYbSuRywjvFtlGjnFmb3+Q==
X-Received: by 2002:ab0:23ce:: with SMTP id c14mr26247883uan.77.1563993606988;
        Wed, 24 Jul 2019 11:40:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYzmyqk9/8S1BDQNV+6FUIN0bbBA0XYlBwO6k/+kFd6GbMSFBxeRjWzqhPclL3jHkRuRI6
X-Received: by 2002:ab0:23ce:: with SMTP id c14mr26247821uan.77.1563993606296;
        Wed, 24 Jul 2019 11:40:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563993606; cv=none;
        d=google.com; s=arc-20160816;
        b=tS68GMkvwZpkNrTIox9wJDo22P38jYcesSOQzZJmOBTPDlCkYwaTxrqh9EBbpnVqDY
         d9dCfr7Y14VtC1dyupdFpwkfbbnRJk0Rx8ws0X52EKL02wwBSkzTx+ei5Jv64a4E+tNA
         8TpArz5f2Yx6jo8j0i3ppPKH9ThmMKGoJLzu985XbLMinKezJy7vj7YPbdSLK87G47bZ
         dLrC9V1AMKaE+722I7wjSC0VZ8vjk99kqBkLMCEW3Sx4e/I2bV/dC8kgnG6H0cw8hGdj
         acQ/KExIDe/folKczg1BuTKuceceGJWmDAsPyC7aUGJVWNCfLtMAgg/jS0SCnsTRg8lp
         Ymag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=alrDnqVaDUAWqH5ELz7ujvbBrCMpTtGLzx35o+lse1A=;
        b=tXk+v3s/uY1OQfAOjBbzHCBRY43PyYsFlXIO145rmjXIX/vMjl1IdignEerPPRmcAJ
         9huWDUDqhBK5nb9b94v8O8H+i6GxVtN75mNuxheaWbOP9MRczpG1B4g+fEaScV9bvDMH
         VOhb6J9+2BHbeYr9GwbXL+F3Vnylpd0KGKMpYvbEcHkp2UbQhy7027mtxQAq0wwZQ7IU
         bFOTnuF2RzdJC1GHosrjaKW1i1sGivdThgWm/I9IXcKxIkD8RHwKaxHy44VK8KKr+dfU
         EKE0Y1IHYxRFUlTHxaQ1TTuSxCOgqFZrrf3+BWsJ59kUkahDjKhAec4yW2e1Zb5ry+oH
         kwNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w23si9311941vsq.62.2019.07.24.11.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:40:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1C219308421A;
	Wed, 24 Jul 2019 18:40:05 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3BED260BF7;
	Wed, 24 Jul 2019 18:40:03 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] mm / virtio: Provide support for page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>, kvm@vger.kernel.org,
 david@redhat.com, mst@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <0c520470-4654-cdf2-cf4d-d7c351d25e8b@redhat.com>
Date: Wed, 24 Jul 2019 14:40:02 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190724165158.6685.87228.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 24 Jul 2019 18:40:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 12:54 PM, Alexander Duyck wrote:
> This series provides an asynchronous means of hinting to a hypervisor
> that a guest page is no longer in use and can have the data associated
> with it dropped. To do this I have implemented functionality that allow=
s
> for what I am referring to as page hinting
>
> The functionality for this is fairly simple. When enabled it will alloc=
ate
> statistics to track the number of hinted pages in a given free area. Wh=
en
> the number of free pages exceeds this value plus a high water value,
> currently 32,
Shouldn't we configure this to a lower number such as 16?
>  it will begin performing page hinting which consists of
> pulling pages off of free list and placing them into a scatter list. Th=
e
> scatterlist is then given to the page hinting device and it will perfor=
m
> the required action to make the pages "hinted", in the case of
> virtio-balloon this results in the pages being madvised as MADV_DONTNEE=
D
> and as such they are forced out of the guest. After this they are place=
d
> back on the free list, and an additional bit is added if they are not
> merged indicating that they are a hinted buddy page instead of a standa=
rd
> buddy page. The cycle then repeats with additional non-hinted pages bei=
ng
> pulled until the free areas all consist of hinted pages.
>
> I am leaving a number of things hard-coded such as limiting the lowest
> order processed to PAGEBLOCK_ORDER,
Have you considered making this option configurable at the compile time?
>  and have left it up to the guest to
> determine what the limit is on how many pages it wants to allocate to
> process the hints.
It might make sense to set the number of pages to be hinted at a time fro=
m the
hypervisor.
>
> My primary testing has just been to verify the memory is being freed af=
ter
> allocation by running memhog 79g on a 80g guest and watching the total
> free memory via /proc/meminfo on the host. With this I have verified mo=
st
> of the memory is freed after each iteration. As far as performance I ha=
ve
> been mainly focusing on the will-it-scale/page_fault1 test running with=

> 16 vcpus. With that I have seen at most a 2% difference between the bas=
e
> kernel without these patches and the patches with virtio-balloon disabl=
ed.
> With the patches and virtio-balloon enabled with hinting the results
> largely depend on the host kernel. On a 3.10 RHEL kernel I saw up to a =
2%
> drop in performance as I approached 16 threads,
I think this is acceptable.
>  however on the the lastest
> linux-next kernel I saw roughly a 4% to 5% improvement in performance f=
or
> all tests with 8 or more threads.=20
Do you mean that with your patches the will-it-scale/page_fault1 numbers =
were
better by 4-5% over an unmodified kernel?
> I believe the difference seen is due to
> the overhead for faulting pages back into the guest and zeroing of memo=
ry.
It may also make sense to test these patches with netperf to observe how =
much
performance drop it is introducing.
> Patch 4 is a bit on the large side at about 600 lines of change, howeve=
r
> I really didn't see a good way to break it up since each piece feeds in=
to
> the next. So I couldn't add the statistics by themselves as it didn't
> really make sense to add them without something that will either read o=
r
> increment/decrement them, or add the Hinted state without something tha=
t
> would set/unset it. As such I just ended up adding the entire thing as
> one patch. It makes it a bit bigger but avoids the issues in the previo=
us
> set where I was referencing things before they had been added.
>
> Changes from the RFC:
> https://lore.kernel.org/lkml/20190530215223.13974.22445.stgit@localhost=
=2Elocaldomain/
> Moved aeration requested flag out of aerator and into zone->flags.
> Moved bounary out of free_area and into local variables for aeration.
> Moved aeration cycle out of interrupt and into workqueue.
> Left nr_free as total pages instead of splitting it between raw and aer=
ated.
> Combined size and physical address values in virtio ring into one 64b v=
alue.
>
> Changes from v1:
> https://lore.kernel.org/lkml/20190619222922.1231.27432.stgit@localhost.=
localdomain/
> Dropped "waste page treatment" in favor of "page hinting"
We may still have to try and find a better name for virtio-balloon side c=
hanges.
As "FREE_PAGE_HINT" and "PAGE_HINTING" are still confusing.
> Renamed files and functions from "aeration" to "page_hinting"
> Moved from page->lru list to scatterlist
> Replaced wait on refcnt in shutdown with RCU and cancel_delayed_work_sy=
nc
> Virtio now uses scatterlist directly instead of intermedate array
> Moved stats out of free_area, now in seperate area and pointed to from =
zone
> Merged patch 5 into patch 4 to improve reviewability
> Updated various code comments throughout
>
> ---
>
> Alexander Duyck (5):
>       mm: Adjust shuffle code to allow for future coalescing
>       mm: Move set/get_pcppage_migratetype to mmzone.h
>       mm: Use zone and order instead of free area in free_list manipula=
tors
>       mm: Introduce Hinted pages
>       virtio-balloon: Add support for providing page hints to host
>
>
>  drivers/virtio/Kconfig              |    1=20
>  drivers/virtio/virtio_balloon.c     |   47 ++++++
>  include/linux/mmzone.h              |  116 ++++++++------
>  include/linux/page-flags.h          |    8 +
>  include/linux/page_hinting.h        |  139 ++++++++++++++++
>  include/uapi/linux/virtio_balloon.h |    1=20
>  mm/Kconfig                          |    5 +
>  mm/Makefile                         |    1=20
>  mm/internal.h                       |   18 ++
>  mm/memory_hotplug.c                 |    1=20
>  mm/page_alloc.c                     |  238 ++++++++++++++++++++-------=
-
>  mm/page_hinting.c                   |  298 +++++++++++++++++++++++++++=
++++++++
>  mm/shuffle.c                        |   24 ---
>  mm/shuffle.h                        |   32 ++++
>  14 files changed, 796 insertions(+), 133 deletions(-)
>  create mode 100644 include/linux/page_hinting.h
>  create mode 100644 mm/page_hinting.c
>
> --
--=20
Thanks
Nitesh

