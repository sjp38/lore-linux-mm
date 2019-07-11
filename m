Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E2DC74A4B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 11:38:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 576F821655
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 11:38:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 576F821655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E973F8E00B6; Thu, 11 Jul 2019 07:38:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E484D8E0032; Thu, 11 Jul 2019 07:38:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D106F8E00B6; Thu, 11 Jul 2019 07:38:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADFDD8E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:38:01 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id 64so961337uam.22
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 04:38:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=ha8W1YbSWF0McAaUiqFUaKioYmPLoPK9otlpotPAm1g=;
        b=pa2dkuUPQAuqf4Y4t+IJe0p35SdDCNtb5nBwGp2yEBd0uZsC9usXwfDzHF87S+LhEP
         SWmblaUss90O1GbQxcrea+l1+XsJV9FBnmVwxZIQKEB7EDOHYNgiEafZqgiHqE4+RQ17
         p+IxXHh9bVt8UQcvgfMRzbioO3Wg+Wf6TREFZSUcvxuUUGTDGpxy4+hKaQJf3Mroz2ip
         l/WyjKttDUfcp/IU9dgcm1OZwigFF01XuQjH5pD/EKafkZT95uHgKCCjqM/SeqfyFPF8
         C0YkJ6o9lovLpeJqwQVLBPNQQNU5aXM1ISuhcdra72RSSOrdVdi9QFNJ5auDiXHlZ5nE
         Vp7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU3Lay3b0l7C1HCruU2sHUrL9/SX/IJlLBb0A+fRg2+VzQE7HC3
	E0DJg400yTK+QJVnAV2acQsDW7xHNvTPGBqzoCMbLApiaBGX59iXmBOrt6JD7smSA8N9XQ0+DgP
	2yTWqXmvkYm5jaTotfE9uB9UXQgmRQWepN9MRRbigNCAAN2q3RYyQWr+oiUIbKzeszA==
X-Received: by 2002:a67:bb01:: with SMTP id m1mr3542160vsn.88.1562845081397;
        Thu, 11 Jul 2019 04:38:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPwDkGqXp+kYnObKt80D3B5MT9sSg1kyUYEs0K2+W+nOtXL0wyPJOPuuyVqIvA6L7Igd7h
X-Received: by 2002:a67:bb01:: with SMTP id m1mr3542108vsn.88.1562845080821;
        Thu, 11 Jul 2019 04:38:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562845080; cv=none;
        d=google.com; s=arc-20160816;
        b=GyWbARL9F9cJtEg8pyHlyBMrWo1mBZpGmTmPseNESA4zbi6x4dDt5yzqswe+qnuwWC
         8s5nzRjLJIkQkkpaM2YHOT3X47uBwo2OqiicxAtJQkf1N52d9nOOwmdKFvifgNjpHqgw
         bxeC3PJjAqnBGp+5algcF7Es0YiwVAVGcSdj327PwQpjjMskJBMDDdf+NphobWRo7DUe
         zM3oMWgzb3fQZdpEEboP9xYiIKTe8zPAvj0D0lNr5f+6KkJshNe/LZhSRU3Qo63ZUOOq
         A0SxABCyEwEXRusgNWtJvSht4fErZWLtZqMWt0vhYnTRCq+uNfxMwAM0qXr1INslnFtr
         yCTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=ha8W1YbSWF0McAaUiqFUaKioYmPLoPK9otlpotPAm1g=;
        b=gLTFUcrZA/HjP2bCDNoyHBDlQKBQ33cIyz04ilQARSfyAjWcqzo0fT2tni1jlGnHIP
         qR1p8478upctUKvtOWxvW+NTjqbJqznVU25o6ebIXPUogK1EHsXztz01mC2kHr3tPrjj
         xsbFMlQ7XzmGswbT+QbeyBEkQxDm57188zrh1C3YlQsVA2bVLP7WqZQfdZ66YxBDqhDd
         0U6weQRzoIFKWUoI0hxwbfjWnPnz2wEGPqulOuDl2TBLeVyDIU9DZ2v73X04akfsurP9
         s4oyjmZWSzbcfZsKTOAsCZJunouCjTGqZ350aKO7vqRbxfwx7LovtmV5hgM7OnmfdiKj
         GvKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v20si1483942vsq.14.2019.07.11.04.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 04:38:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 93CBB3082135;
	Thu, 11 Jul 2019 11:37:59 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8C59C194B3;
	Thu, 11 Jul 2019 11:37:50 +0000 (UTC)
Subject: Re: [RFC][PATCH v11 0/2] mm: Support for page hinting
To: Dave Hansen <dave.hansen@intel.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, david@redhat.com, mst@redhat.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com, john.starks@microsoft.com,
 mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <b6da49e4-5007-08f9-104a-aeca5dca4719@intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <f781e5db-cfed-6acf-c844-4825f2336567@redhat.com>
Date: Thu, 11 Jul 2019 07:37:49 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <b6da49e4-5007-08f9-104a-aeca5dca4719@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 11 Jul 2019 11:37:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/10/19 4:19 PM, Dave Hansen wrote:
> On 7/10/19 12:51 PM, Nitesh Narayan Lal wrote:
>> This patch series proposes an efficient mechanism for reporting free m=
emory
>> from a guest to its hypervisor. It especially enables guests with no p=
age cache
>> (e.g., nvdimm, virtio-pmem) or with small page caches (e.g., ram > dis=
k) to
>> rapidly hand back free memory to the hypervisor.
>> This approach has a minimal impact on the existing core-mm infrastruct=
ure.
>>
>> Measurement results (measurement details appended to this email):
>> *Number of 5GB guests (each touching 4GB memory) that can be launched
>> without swap usage on a system with 15GB:
> This sounds like a reasonable measurement, but I think you're missing a=

> sentence or two explaining why this test was used.
I will re-work the cover email to better communicate the numbers.
>
>> unmodified kernel - 2, 3rd with 2.5GB  =20
> What does "3rd with 2.5GB" mean?  The third gets 2.5GB before failing a=
n
> allocation and crashing?
It doesn't crash or fail. To complete the execution of the test
application which allocates 4GB memory in the 3rd guest 2.5GB swap has
been accessed.
>
>> v11 page hinting - 6, 7th with 26MB   =20
>> v1 bubble hinting[1] - 6, 7th with 1.8GB (bubble hinting is another se=
ries
>> proposed to solve the same problems)
> Could you please make an effort to format things so that reviewers can
> easily read them?  Aligning columns and using common units would be ver=
y
> helpful, for instance:
>
>      unmodified kernel - 2, 3rd with 2.50 GB
>       v11 page hinting - 6, 7th with 0.03 GB
>   v1 bubble hinting[1] - 6, 7th with 1.80 GB
>
> See how you can scan that easily and compare between the rows?
>
> I think you did some analysis below.  But, that seems misplaced.  It's
> better to include the conclusion here and the details to back it up
> later.  As it stands, the cover letter just throws some data at a
> reviewer and hopes they can make sense of it.
I will improve this. Thanks.
>
>> *Memhog execution time (For 3 guests each of 6GB on a system with 15GB=
):
>> unmodified kernel - Guest1:21s, Guest2:27s, Guest3:2m37s swap used =3D=
 3.7GB      =20
>> v11 page hinting - Guest1:23s, Guest2:26s, Guest3:21s swap used =3D 0 =
         =20
>> v1 bubble hinting - Guest1:23, Guest2:11s, Guest3:26s swap used =3D 0 =
         =20
> Again, I'm finding myself having to reformat your data just so I can
> make sense of it.  You also forgot the unit for Guest 1 in row 3.
>
>    unmodified - Guest1:21s, Guest2:27s, Guest3:2m37s swap used =3D 3.7G=
B
>
>   v11 hinting - Guest1:23s, Guest2:26s, Guest3:21s swap used =3D 0
>   v1 bubble   - Guest1:23s, Guest2:11s, Guest3:26s swap used =3D 0
>
> So, what is this supposed to show?  What does it mean?  Why do the
> numbers vary *so* much?

Basically, the idea was to communicate that with hinting swap was not
accessed and hence the time of execution is lower.

But as you already mentioned next time around I will format this and add
the conclusion along with these numbers.
I agree with Alexander's comment that there is no point of having the
same thing at two place.

--=20
Thanks
Nitesh

