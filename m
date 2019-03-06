Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 584EAC10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:07:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E938B2064A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:07:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E938B2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89A128E0003; Wed,  6 Mar 2019 14:07:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 848498E0002; Wed,  6 Mar 2019 14:07:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 737B98E0003; Wed,  6 Mar 2019 14:07:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 46A478E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:07:55 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id v67so10680791qkl.22
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:07:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=c099gEyHL/56ut1F55VjE8EgoWWvImxPp1gy/waTSOI=;
        b=APH3oCdZFdUYJnHQBdZZRQSD6cX9+eKpxUkvZXzpxgTYbeRNXmaCAOUvUTx9bY84lM
         hpW/uyNldCBSUOaUuM3H6/tegyUnrn9QjTnvT8jQHFQjfBGKQS/KbWGgo8pSyeN+Rq86
         ECtIpTDJpI03MBN86DikV2QopFj6dVRwKwCRfzuD5Y4A2HfVMhu/Tov/mJlN1kbfH0sz
         oYqds+yOUJKtLGO0cKcIwxS1udw2F7M9JhcRPxxh9xL0+RfaTyoK+EUKuTV6HxQQkSPV
         fSoyQHnprEXfDJYYqxlCwx27nCfThoEUDcyeU8iBfvH0frhcaDpxfqsWww53eI8rcFQU
         UPww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWd/jcBq9flGZFef+e4WZdLzdkO9lj8n87PdLjV6Y0eqZVTcHlQ
	EFKx0VxPNm5R/pMTxSAclXfkRTkSEUtNHWWMjBshDAvuqJ0UhsPcBL9NLa6OieDLYu5O+wP57jG
	3z3egdNv+gfo7LYswbYpqFTQQGU5p4UsoJ2rOZ8tM2EWPjuKu8SideJhOMHqK0CSkGg==
X-Received: by 2002:a0c:879c:: with SMTP id 28mr7390722qvj.63.1551899275002;
        Wed, 06 Mar 2019 11:07:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqxeEVH0SQDFXsWaAqCFqcqL7jsZB1gHCSCJDYs8x1L5G4swCMK8wo7sAid9hYdc9c8AkdH6
X-Received: by 2002:a0c:879c:: with SMTP id 28mr7390656qvj.63.1551899274036;
        Wed, 06 Mar 2019 11:07:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551899274; cv=none;
        d=google.com; s=arc-20160816;
        b=hPIHfxDN6kmtHHDjnCpcvXp2FTzBIj29KDpZkeCF3pbn9UY5Ufthwmc6GvjMCItt8J
         9wQgW8QWkTaLnpksaKMJVYnkV9HMLf9X8z7qviBZhmmJ9tGmIdnBaZgDCNbiwxiNlSvF
         NjAlHs4hw0btVZglF0/cy5T8f0G+OpmxDee9697rD4ziIOf6b/H4UetmNho4uHwbE5xd
         c+/wyrfi8SIPDcg5T2514r86JYuE71Co1CF4p+1YiVncnXtRYldXHZLUxmmRtpLeowcd
         3yxwPe+S1PM+BfMZcBnBvuwvcSeytnmQbUt2J9xMD2Crps27i1OOLugQkg39XWFECKq8
         CBrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=c099gEyHL/56ut1F55VjE8EgoWWvImxPp1gy/waTSOI=;
        b=N7Nh/4DW+5guxaxb6N7NigBBZzLM7Rgg6Uo3rxiPDn2/tLDqp02nW8+x8YnyeMnyj6
         cy+hZxLhGHWf0u7XUHHDhJUoc5AJFUrizBkk9poNWzgIS5+EGsBXuiA/DKPZnvRKS3k/
         zDd+CWfxiz/zFa5W2LbpiMmvBmr2Nmgx810CDKLU6wS7m/Gq9bW635IhXvKFqCWWh7nM
         pvT72ty7lS5hShrT2PvM1GjNATD68nhKDsiBQC5IeWYvQIzppJVRFFrWKO1qJQ2FE6iI
         caGKAzMjqccYee6W/gU0KbJ7hAJ3frSxenIS8rQAnj24Ao0yiHcfi48fDJgWIGBOf2Ex
         k09w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w18si539386qka.41.2019.03.06.11.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 11:07:54 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 37A7158E38;
	Wed,  6 Mar 2019 19:07:53 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D1CCE600C5;
	Wed,  6 Mar 2019 19:07:44 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
Date: Wed, 6 Mar 2019 14:07:43 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="dRDaSzssymHtsRfrS36m7IfOIFpVkpG3R"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 06 Mar 2019 19:07:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dRDaSzssymHtsRfrS36m7IfOIFpVkpG3R
Content-Type: multipart/mixed; boundary="s88sWQsaJltwgeGmpg6DNlYbCx6gnM26D";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <1d5e27dc-aade-1be7-2076-b7710fa513b6@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>
In-Reply-To: <CAKgT0Ud35pmmfAabYJijWo8qpucUWS8-OzBW=gsotfxZFuS9PQ@mail.gmail.com>

--s88sWQsaJltwgeGmpg6DNlYbCx6gnM26D
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/6/19 1:00 PM, Alexander Duyck wrote:
> On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> w=
rote:
>> The following patch-set proposes an efficient mechanism for handing fr=
eed memory between the guest and the host. It enables the guests with no =
page cache to rapidly free and reclaims memory to and from the host respe=
ctively.
>>
>> Benefit:
>> With this patch-series, in our test-case, executed on a single system =
and single NUMA node with 15GB memory, we were able to successfully launc=
h 5 guests(each with 5 GB memory) when page hinting was enabled and 3 wit=
hout it. (Detailed explanation of the test procedure is provided at the b=
ottom under Test - 1).
>>
>> Changelog in v9:
>>         * Guest free page hinting hook is now invoked after a page has=
 been merged in the buddy.
>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(curre=
ntly defined as MAX_ORDER - 1) are captured.
>>         * Removed kthread which was earlier used to perform the scanni=
ng, isolation & reporting of free pages.
> Without a kthread this has the potential to get really ugly really
> fast. If we are going to run asynchronously we should probably be
> truly asynchonous and just place a few pieces of data in the page that
> a worker thread can use to identify which pages have been hinted and
> which pages have not.=20

Can you please explain what do you mean by truly asynchronous?

With this implementation also I am not reporting the pages synchronously.=


> Then we can have that one thread just walking
> through the zone memory pulling out fixed size pieces at a time and
> providing hints on that. By doing that we avoid the potential of
> creating a batch of pages that eat up most of the system memory.
>
>>         * Pages, captured in the per cpu array are sorted based on the=
 zone numbers. This is to avoid redundancy of acquiring zone locks.
>>         * Dynamically allocated space is used to hold the isolated gue=
st free pages.
> I have concerns that doing this per CPU and allocating memory
> dynamically can result in you losing a significant amount of memory as
> it sits waiting to be hinted.
It should not as the buddy will keep merging the pages and we are only
capturing MAX_ORDER - 1.
This was the issue with the last patch-series when I was capturing all
order pages resulting in the per-cpu array to be filled with lower order
pages.
>
>>         * All the pages are reported asynchronously to the host via vi=
rtio driver.
>>         * Pages are returned back to the guest buddy free list only wh=
en the host response is received.
> I have been thinking about this. Instead of stealing the page couldn't
> you simply flag it that there is a hint in progress and simply wait in
> arch_alloc_page until the hint has been processed?=20
With the flag, I am assuming you mean to block the allocation until
hinting is going on, which is an issue. That was one of the issues
discussed earlier which I wanted to solve with this implementation.
> The problem is in
> stealing pages you are going to introduce false OOM issues when the
> memory isn't available because it is being hinted on.
I think this situation will arise when the guest is under memory
pressure. In such situations any attempt to perform isolation will
anyways fail and we may not be reporting anything at that time.
>
>> Pending items:
>>         * Make sure that the guest free page hinting's current impleme=
ntation doesn't break hugepages or device assigned guests.
>>         * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side supp=
ort. (It is currently missing)
>>         * Compare reporting free pages via vring with vhost.
>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>         * Analyze overall performance impact due to guest free page hi=
nting.
>>         * Come up with proper/traceable error-message/logs.
> I'll try applying these patches and see if I can reproduce the results
> you reported.=20
Thanks. Let me know if you run into any issues.
> With the last patch set I couldn't reproduce the results
> as you reported them.=20
If I remember correctly then the last time you only tried with multiple
vcpus and not with 1 vcpu.
> It has me wondering if you were somehow seeing
> the effects of a balloon instead of the actual memory hints as I
> couldn't find any evidence of the memory ever actually being freed
> back by the hints functionality.

Can you please elaborate what kind of evidence you are looking for?

I did trace the hints on the QEMU/host side.

>
> Also do you have any idea if this patch set will work with an SMP
> setup or is it still racy? I might try enabling SMP in my environment
> to see if I can test the scalability of the VM with something like a
> will-it-scale test.
I did try running page_fault1_threads in will-it-scale with 4 vcpus.
It didn't give me any issue.
>
>> Tests:
>> 1. Use-case - Number of guests we can launch
>>
>>         NUMA Nodes =3D 1 with 15 GB memory
>>         Guest Memory =3D 5 GB
>>         Number of cores in guest =3D 1
>>         Workload =3D test allocation program allocates 4GB memory, tou=
ches it via memset and exits.
>>         Procedure =3D
>>         The first guest is launched and once its console is up, the te=
st allocation program is executed with 4 GB memory request (Due to this t=
he guest occupies almost 4-5 GB of memory in the host in a system without=
 page hinting). Once this program exits at that time another guest is lau=
nched in the host and the same process is followed. We continue launching=
 the guests until a guest gets killed due to low memory condition in the =
host.
>>
>>         Results:
>>         Without hinting =3D 3
>>         With hinting =3D 5
>>
>> 2. Hackbench
>>         Guest Memory =3D 5 GB
>>         Number of cores =3D 4
>>         Number of tasks         Time with Hinting       Time without H=
inting
>>         4000                    19.540                  17.818
>>
>>
--=20
Nitesh


--s88sWQsaJltwgeGmpg6DNlYbCx6gnM26D--

--dRDaSzssymHtsRfrS36m7IfOIFpVkpG3R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyAGn8ACgkQo4ZA3AYy
ozlcpA/+M2yz4zBSPI4bcJRgJLgRUFR3N07g2HjQ7/he1oiumZyAU12b9P5VH8Li
7JVMd6aYMeJ7lotWU4g9kzzQaSe7YnJoVBeICXIEyeuKuq1g2lyIcCRJpOzUV0Bn
RqcamKVY0ndX2MYJXq31LWdm/0ux9wlqlyR+WEZT1wSmiIhLLnJ6S9wAbFPFK4tn
gq2ttDHDIiCs1YemM9QhTH+YYIGPKtrQOgprCbL85JvpbY7rCqi9QoELIxXi+cUM
Wjb88EMVcr6gXBKiS1ta9GJh6IQm8Y3PJPsRZRmEOTROZyLY/7Toujmcz+1uQm+v
o8G3BMSsyqOHw0KbIFy1l7RrB1mVQJVsUo5zqp80NnKBFlLlmr9jn7EieH1UbxGM
IwToFqR8p8wOCNLHM8ujfQ6TUEaY9fwonCWsWDb9KrkaAAZtjZgaRU+rKSwOP1VZ
9OMgHYst6Hzp+1yuA7T1QfsOOa1xAjv2SpXnNT8aS9k4HJ1N/W4MYfgpOqdXqDzT
4xXTXCg5UIMbjy1Ib2PAvtaK8qP0zvGrYFBk4Qw+DpW+MRYYTmVHZ0ddULCrxgdc
bENegLQ7eLIbk1ttsTylZHN+ok48oTFUGYtX9DQjUM4j1zqRlfl3OZy9jyMkEC81
iYxpV/KRe9Lwq8J/xcXvMifzkH9Pua6oMElqxNN9GDCrxIFHvaM=
=cUBW
-----END PGP SIGNATURE-----

--dRDaSzssymHtsRfrS36m7IfOIFpVkpG3R--

