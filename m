Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E41C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:43:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47D9D2186A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:43:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47D9D2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F538E0003; Thu, 14 Mar 2019 12:43:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE5118E0001; Thu, 14 Mar 2019 12:43:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5F658E0003; Thu, 14 Mar 2019 12:43:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 781FC8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:43:03 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h28so4852753qkk.7
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:43:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=3Vpq4/bWkvbzw7h14/e9zNh6Y6n7E9bf7xrarichqjw=;
        b=mzBgIXyOkTyY/5fhhoPTXkBsa22LoKO6h5bTRMA+WVwuJzrb4JveLlmQ7+S2M3Ak2Y
         RW3p8lAGiB6JcqD1rLah1iZrPQ9Ch9vP+v60N1WowhqzZR3Zda0K0j27rhLuvSTccMqS
         hA235NAY8ceFcOwrursraO86r2gXpVHfeffLL9dLiXqn1EDO/b4WNwMDTaQ47IZff4g0
         +gS9Vtyz97SBF61YkUu+2dH8qMtgwvOLp9PV5NDpsBDbBVIG4H+p6MXGIrNrkPNJjgkU
         YDSjXtV9Do8v3UtYxH7eeJGK69r5hfHZcdewoLgT6TFVVECryErrOb87ndHmfmfrJWnJ
         uWRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXc6NyEx48baqwDqNBXcqGxkOk8O/OweQTN1vJ9p5cs8wblQ27F
	SRxl269WNmZtzLysFCSxJNyZoR6FRjsVsdw6cVXVNDay1WSrhzXTaL2RMO5glsxy4ACwxXLyjqK
	DOSBdbfpR3zlrEjsaFOB87jiyavUiK5EpFxFHwEx74wDdFPBVVf17FH43Qb5g3FRbUg==
X-Received: by 2002:a0c:acd7:: with SMTP id n23mr40265503qvc.215.1552581783194;
        Thu, 14 Mar 2019 09:43:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygZbjztlTqPUKvrLVuhCG3q0PzvBe65Q77IBXtdqR8XKcs4dQloBzdaMkvurff1N1rMGZq
X-Received: by 2002:a0c:acd7:: with SMTP id n23mr40265436qvc.215.1552581782017;
        Thu, 14 Mar 2019 09:43:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552581782; cv=none;
        d=google.com; s=arc-20160816;
        b=rOUgCALcHE2TZ5Z9kA7eeKXoKpezKUu8/gTDSbYhHjUZvpOKIDaixtn7xAWwyCpTHF
         tP3Pt/t3hS/MmnBmcqy5UHVsXBmBNG/62oSFFMynkwaQLddiY1eIVf8JoPqaLG6K6ciX
         DwKUZauulh2r3OIvw3RUYWpV2JQsNa8pW6NrCH8sDHUPc1JDEER8rkCnylJ9w+Yae5Dt
         IzOrmHD6T1RCIeg+XF2EwUfp5q2v7cVIZxvL8f4fV8xSKDHnW4hDsOW2GU3Hxp4T3WZ8
         KWStxX4tVeAMkHgE+LWKMgQttAGb0yZ128JO+pkQJ3iadoDd63FB4xXdKqbETjq0QEZq
         zghA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=3Vpq4/bWkvbzw7h14/e9zNh6Y6n7E9bf7xrarichqjw=;
        b=RbCw9d8CZq3Eb2b0bRoz8zGgrHrzNE2db2F3zfA/xW2KX8auzl61n9twr75UXsUblG
         /WOmUkj2/SFFuhILbgeha/Zgtj0UARH3zN5VTMWnxG/rQaErtx0pvd866vFdJxZ0Tctd
         XDPBBWADyugQHjpX18nLrVlV4qQve4ZNHBs/JiqI3B5GVRNTP9jQrvRc897aI9Dd/TAV
         BeLYw0+gIUbrkAiw6p21IN1mF1y2HSf1DmyQnHjI+tI8IGe7G5dlFtmcOJMhZ/EjGW5b
         q1fVbKpixzT3ED4bB72ADHcIe9YDhOwGueu6i40Vle7jG/5RheRl1A5JFYNFRreoCq2E
         2U3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x16si237935qtr.184.2019.03.14.09.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:43:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 102F730EEF69;
	Thu, 14 Mar 2019 16:43:01 +0000 (UTC)
Received: from [10.40.205.82] (unknown [10.40.205.82])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A62E963F65;
	Thu, 14 Mar 2019 16:42:40 +0000 (UTC)
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
Date: Thu, 14 Mar 2019 12:42:36 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190306130955-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="UJZzxOXyC1WwQkZTeFpxvN96n6ZaZqUO0"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 14 Mar 2019 16:43:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UJZzxOXyC1WwQkZTeFpxvN96n6ZaZqUO0
Content-Type: multipart/mixed; boundary="l761DRoW01BOGI65Mrp4bgD4xjullzymp";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
 dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com
Message-ID: <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190306130955-mutt-send-email-mst@kernel.org>

--l761DRoW01BOGI65Mrp4bgD4xjullzymp
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wrote:
>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wrote:
>>>> The following patch-set proposes an efficient mechanism for handing =
freed memory between the guest and the host. It enables the guests with n=
o page cache to rapidly free and reclaims memory to and from the host res=
pectively.
>>>>
>>>> Benefit:
>>>> With this patch-series, in our test-case, executed on a single syste=
m and single NUMA node with 15GB memory, we were able to successfully lau=
nch 5 guests(each with 5 GB memory) when page hinting was enabled and 3 w=
ithout it. (Detailed explanation of the test procedure is provided at the=
 bottom under Test - 1).
>>>>
>>>> Changelog in v9:
>>>> 	* Guest free page hinting hook is now invoked after a page has been=
 merged in the buddy.
>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORDER(cur=
rently defined as MAX_ORDER - 1) are captured.
>>>> 	* Removed kthread which was earlier used to perform the scanning, i=
solation & reporting of free pages.
>>>> 	* Pages, captured in the per cpu array are sorted based on the zone=
 numbers. This is to avoid redundancy of acquiring zone locks.
>>>>         * Dynamically allocated space is used to hold the isolated g=
uest free pages.
>>>>         * All the pages are reported asynchronously to the host via =
virtio driver.
>>>>         * Pages are returned back to the guest buddy free list only =
when the host response is received.
>>>>
>>>> Pending items:
>>>>         * Make sure that the guest free page hinting's current imple=
mentation doesn't break hugepages or device assigned guests.
>>>> 	* Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side support. =
(It is currently missing)
>>>>         * Compare reporting free pages via vring with vhost.
>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>> 	* Analyze overall performance impact due to guest free page hinting=
=2E
>>>> 	* Come up with proper/traceable error-message/logs.
>>>>
>>>> Tests:
>>>> 1. Use-case - Number of guests we can launch
>>>>
>>>> 	NUMA Nodes =3D 1 with 15 GB memory
>>>> 	Guest Memory =3D 5 GB
>>>> 	Number of cores in guest =3D 1
>>>> 	Workload =3D test allocation program allocates 4GB memory, touches =
it via memset and exits.
>>>> 	Procedure =3D
>>>> 	The first guest is launched and once its console is up, the test al=
location program is executed with 4 GB memory request (Due to this the gu=
est occupies almost 4-5 GB of memory in the host in a system without page=
 hinting). Once this program exits at that time another guest is launched=
 in the host and the same process is followed. We continue launching the =
guests until a guest gets killed due to low memory condition in the host.=

>>>>
>>>> 	Results:
>>>> 	Without hinting =3D 3
>>>> 	With hinting =3D 5
>>>>
>>>> 2. Hackbench
>>>> 	Guest Memory =3D 5 GB=20
>>>> 	Number of cores =3D 4
>>>> 	Number of tasks		Time with Hinting	Time without Hinting
>>>> 	4000			19.540			17.818
>>>>
>>> How about memhog btw?
>>> Alex reported:
>>>
>>> 	My testing up till now has consisted of setting up 4 8GB VMs on a sy=
stem
>>> 	with 32GB of memory and 4GB of swap. To stress the memory on the sys=
tem I
>>> 	would run "memhog 8G" sequentially on each of the guests and observe=
 how
>>> 	long it took to complete the run. The observed behavior is that on t=
he
>>> 	systems with these patches applied in both the guest and on the host=
 I was
>>> 	able to complete the test with a time of 5 to 7 seconds per guest. O=
n a
>>> 	system without these patches the time ranged from 7 to 49 seconds pe=
r
>>> 	guest. I am assuming the variability is due to time being spent writ=
ing
>>> 	pages out to disk in order to free up space for the guest.
>>>
>> Here are the results:
>>
>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with=

>> total memory of 15GB and no swap. In each of the guest, memhog is run
>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
>> using Free command.
>>
>> Without Hinting:
>> =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=
=A0=C2=A0 Time of execution=C2=A0=C2=A0=C2=A0 Host used memory
>> Guest 1:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 45 seconds=C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 5.4 GB
>> Guest 2:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 45 seconds=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 10 GB
>> Guest 3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 1=C2=A0 minute=C2=A0=C2=A0=
=C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 15 GB
>>
>> With Hinting:
>> =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0=
 Time of execution =C2=A0=C2=A0=C2=A0 Host used memory
>> Guest 1:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 49 seconds=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 2.4 GB
>> Guest 2:=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 40 seconds=C2=A0=C2=A0=C2=A0 =
=C2=A0=C2=A0 =C2=A0=C2=A0 =C2=A0 4.3 GB
>> Guest 3:=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 50 seconds=C2=A0=C2=A0=C2=
=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 6.3 GB
> OK so no improvement. OTOH Alex's patches cut time down to 5-7 seconds
> which seems better. Want to try testing Alex's patches for comparison?
>
I realized that the last time I reported the memhog numbers, I didn't
enable the swap due to which the actual benefits of the series were not
shown.
I have re-run the test by including some of the changes suggested by
Alexander and David:
=C2=A0=C2=A0=C2=A0 * Reduced the size of the per-cpu array to 32 and mini=
mum hinting
threshold to 16.
=C2=A0=C2=A0=C2=A0 * Reported length of isolated pages along with start p=
fn, instead of
the order from the guest.
=C2=A0=C2=A0=C2=A0 * Used the reported length to madvise the entire lengt=
h of address
instead of a single 4K page.
=C2=A0=C2=A0=C2=A0 * Replaced MADV_DONTNEED with MADV_FREE.

Setup for the test:
NUMA node:1
Memory: 15GB
Swap: 4GB
Guest memory: 6GB
Number of core: 1

Process: A guest is launched and memhog is run with 6GB. As its
execution is over next guest is launched. Everytime memhog execution
time is monitored.=C2=A0=C2=A0=C2=A0
Results:
=C2=A0=C2=A0=C2=A0 Without Hinting:
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 Time of execution
=C2=A0=C2=A0=C2=A0 Guest1:=C2=A0=C2=A0=C2=A0 22s
=C2=A0=C2=A0=C2=A0 Guest2:=C2=A0=C2=A0=C2=A0 24s
=C2=A0=C2=A0=C2=A0 Guest3: 1m29s

=C2=A0=C2=A0=C2=A0 With Hinting:
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 Time of execution
=C2=A0=C2=A0=C2=A0 Guest1:=C2=A0=C2=A0=C2=A0 24s
=C2=A0=C2=A0=C2=A0 Guest2:=C2=A0=C2=A0=C2=A0 25s
=C2=A0=C2=A0=C2=A0 Guest3:=C2=A0=C2=A0=C2=A0 28s

When hinting is enabled swap space is not used until memhog with 6GB is
ran in 6th guest.


--=20
Regards
Nitesh


--l761DRoW01BOGI65Mrp4bgD4xjullzymp--

--UJZzxOXyC1WwQkZTeFpxvN96n6ZaZqUO0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyKhHwACgkQo4ZA3AYy
ozlEoA//VwKzRN/OZmcnzMr5uXBWcy9XTpTsnA8QUUhhEr9bIXbQkfdC/lzlhqD8
cs36Y2qqwKGkf0m8x1lHzOPppPLKUP3yM9V+cgzYDKb9gEAn+QxwcprnJ+5xvSeW
NUdObFJ3PpOSFTpD6zE1aAGd68MsoYJvz0WLkSJyMOKe8TImvmkjRM/jk8Kp5Spb
B0p1YxWZ7NY3cGynnz5f5vMapQAq68P9oxAAhYHuSovQ+P+Zc2iBO046JUNiex5o
eM5A8fRsimsvNweCsJGmcAjYzP/xGj7VUP+x1/QIvrJqeVlyg1F971XaxnFy4ZLd
uOBhSkCILSV2AOn4LfpAR5BGTkPwEa9kPZmbMzyehv12B9vO6j1SZRIVTgtQUfA2
b+Bh+2Z/MQRmDPzei0XZZ7awq+LFy4txib8SBtetpUu7CkmOpN5d8A88R0BRlDDc
Wi0xJXJlvFQtYkTB51mSMAG/Jy4v+Nw8jDQ2zAW24utxZWpHeh+emveoOeMpc4+X
Zl1C+kFwHNieLlubj5XTEGGhs71ttNDCsTwFPBou4Zg1wLGkUuPszSMmsThK7AQR
Tj5/6w9QS9K8eGpqO/nERE8Ia9k6GxGaCQP1HKhlb1RFyBERbMfhof8KpXUAWdBi
j8kTOpT+nkfrPC0FcPRwsPa5Er2e3McKkutXqWXVLWPVFuRh1MM=
=K55Q
-----END PGP SIGNATURE-----

--UJZzxOXyC1WwQkZTeFpxvN96n6ZaZqUO0--

