Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52F6CC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:00:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAEE9206B7
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:00:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAEE9206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AD6C6B0007; Tue, 19 Mar 2019 14:00:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 735096B0008; Tue, 19 Mar 2019 14:00:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 625266B000A; Tue, 19 Mar 2019 14:00:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1A46B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:00:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l87so18343333qki.10
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:00:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=s9J4LCVW3vMoI0mZogw4Tq2eHGjPpaDawIZQ3Db6/Ks=;
        b=XG2rdav/8Udeqq6Kw267bIgOeo9psfTqj+vvb91/YOeO/0xkPq2MR2sGgkRGZxMEid
         gfjWPsdccnL7yK/yJoHaTxJPO4PraIh0B+nwlhIV9OzSNy8sT68ICk/FnQSZBXEVhY2g
         Y5u5V+LLh6CaMhcsrVstUImv+xXgFMhg8myqJgnrlSTcZMLf8rr4MSBgPcrG5Od5iWLm
         nieZdyE67/lC+oRI7NjrxD9KrV0U4lT4ow9EkFjwK2qnDrAMETeaM9l0VgLVzKfI2c56
         AAn1nQjy+EJBRzockHoHzcnLxr2dKMJh42OJptP/N6/rgcF4ZNlRvSl+x0Vek0kus1j7
         U/fA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVmODzMrCGRnQg0IFu3wu2Czi+FOhSFoMM9NMc7a1gYRb2CEC39
	UeIde+oe29f80ZKMW5GmyHk0pyFsWhJJcTkX2DDl/prkB/DDUMTqAKG/nCH8GDBLrjy5lZtgbym
	SAZ0VTBqFQJALwGHkMd1fCOcX/i8B4a1Al80XFA4YtjzRky+83zSpKRCviUHqAfVRGA==
X-Received: by 2002:a0c:9906:: with SMTP id h6mr3041239qvd.45.1553018405945;
        Tue, 19 Mar 2019 11:00:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyLfW8Qaa3quJ6l/FJ5fO3t6mbUzrx8gMSqvtlUgti23j9/LZNcBgOQRsyIXTSL1POM1eT
X-Received: by 2002:a0c:9906:: with SMTP id h6mr3041090qvd.45.1553018403922;
        Tue, 19 Mar 2019 11:00:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553018403; cv=none;
        d=google.com; s=arc-20160816;
        b=Rp3RFKoga1aAuO4FV+m8DpdEZoofUhPF7MJ5dSN+NAo6YGyYukCdlPX6nrceX+UT7l
         +wFUgalAOOjHy59S8MLxC6PPRk0e5W/rfUJ1ftt5Pb3MVqHamAlX8rm1ntgYIRZgpy/K
         p86wk5DEfgTRx6G/9nqRPoqIZIx0nYeL7Tx1eU0tsO4ZDiZLg1/2eyflI8dEGR4ylL+k
         5QyxhlPej44LfejWfGEYG5YWV9oppUHNeEm1uaaUmbU1daIBgrwM2fjFrpZrdN0X0quK
         5Y7mOLiH2FtcZ4oQcUweNos7D9WKd2pQ1qrNWwOuzism9t2xWrpLxTTHSB4lMYpsERl7
         gSSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=s9J4LCVW3vMoI0mZogw4Tq2eHGjPpaDawIZQ3Db6/Ks=;
        b=Sjapp7yMjSszizY8VbfEBb9xNNyOMqCye4zv5089b/7LuPcKag7bSZmVAwAh7XO6Ay
         I7lw0ZB/uRtpXr7emmKxHJF1d7Fu6dy7G0S342A/3M9NelFQAn+dBNPKT4GBtSM3M7VL
         +jKfvLNjeVJHdo+z1w8G9Kja6cSse8RObPo15JHnwfZltxR+pkhOxHgnesjwlPa7vEc0
         Fw07S1npBXgTsapQXDcFSTkPpyojX3prki7a5gw9a9jaITIfYxShGKb7QdR/u2WDdp1p
         4yo8//UWJ6DI4A9DGgy3e6bBomkPdsYgoaiMWY7jDZRX6aYjeCBGCMO68dopEMN3U/ct
         oVUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p27si2611398qvc.166.2019.03.19.11.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 11:00:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F095E81E0B;
	Tue, 19 Mar 2019 18:00:02 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EE7EE1018A0B;
	Tue, 19 Mar 2019 17:59:38 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <ce55943e-87b6-c102-9827-2cfd45b7192c@redhat.com>
 <CAKgT0UcGCFNQRZFmp8oMkG+wKzRtwN292vtFWgyLsdyRnO04gQ@mail.gmail.com>
 <ed9f7c2e-a7e3-a990-bcc3-459e4f2b4a44@redhat.com>
 <4bd54f8b-3e9a-3493-40be-668962282431@redhat.com>
 <6d744ed6-9c1c-b29f-aa32-d38387187b74@redhat.com>
 <CAKgT0UcBDKr0ACHQWUCvmm8atxM6wSu7aCRFJkFvfjT_W_femQ@mail.gmail.com>
Organization: Red Hat Inc,
Message-ID: <6709bb82-5e99-019d-7de0-3fded385b9ac@redhat.com>
Date: Tue, 19 Mar 2019 13:59:34 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UcBDKr0ACHQWUCvmm8atxM6wSu7aCRFJkFvfjT_W_femQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8ELtNhs0R6qHWeem999JcPH9ce8DbRfR3"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 19 Mar 2019 18:00:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8ELtNhs0R6qHWeem999JcPH9ce8DbRfR3
Content-Type: multipart/mixed; boundary="XcIH1IRibTrXwwEPmyCBkPdN89R5Xncki";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <6709bb82-5e99-019d-7de0-3fded385b9ac@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--XcIH1IRibTrXwwEPmyCBkPdN89R5Xncki
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/19/19 1:38 PM, Alexander Duyck wrote:
> On Tue, Mar 19, 2019 at 9:04 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
>> On 3/19/19 9:33 AM, David Hildenbrand wrote:
>>> On 18.03.19 16:57, Nitesh Narayan Lal wrote:
>>>> On 3/14/19 12:58 PM, Alexander Duyck wrote:
>>>>> On Thu, Mar 14, 2019 at 9:43 AM Nitesh Narayan Lal <nitesh@redhat.c=
om> wrote:
>>>>>> On 3/6/19 1:12 PM, Michael S. Tsirkin wrote:
>>>>>>> On Wed, Mar 06, 2019 at 01:07:50PM -0500, Nitesh Narayan Lal wrot=
e:
>>>>>>>> On 3/6/19 11:09 AM, Michael S. Tsirkin wrote:
>>>>>>>>> On Wed, Mar 06, 2019 at 10:50:42AM -0500, Nitesh Narayan Lal wr=
ote:
>>>>>>>>>> The following patch-set proposes an efficient mechanism for ha=
nding freed memory between the guest and the host. It enables the guests =
with no page cache to rapidly free and reclaims memory to and from the ho=
st respectively.
>>>>>>>>>>
>>>>>>>>>> Benefit:
>>>>>>>>>> With this patch-series, in our test-case, executed on a single=
 system and single NUMA node with 15GB memory, we were able to successful=
ly launch 5 guests(each with 5 GB memory) when page hinting was enabled a=
nd 3 without it. (Detailed explanation of the test procedure is provided =
at the bottom under Test - 1).
>>>>>>>>>>
>>>>>>>>>> Changelog in v9:
>>>>>>>>>>    * Guest free page hinting hook is now invoked after a page =
has been merged in the buddy.
>>>>>>>>>>         * Free pages only with order FREE_PAGE_HINTING_MIN_ORD=
ER(currently defined as MAX_ORDER - 1) are captured.
>>>>>>>>>>    * Removed kthread which was earlier used to perform the sca=
nning, isolation & reporting of free pages.
>>>>>>>>>>    * Pages, captured in the per cpu array are sorted based on =
the zone numbers. This is to avoid redundancy of acquiring zone locks.
>>>>>>>>>>         * Dynamically allocated space is used to hold the isol=
ated guest free pages.
>>>>>>>>>>         * All the pages are reported asynchronously to the hos=
t via virtio driver.
>>>>>>>>>>         * Pages are returned back to the guest buddy free list=
 only when the host response is received.
>>>>>>>>>>
>>>>>>>>>> Pending items:
>>>>>>>>>>         * Make sure that the guest free page hinting's current=
 implementation doesn't break hugepages or device assigned guests.
>>>>>>>>>>    * Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side s=
upport. (It is currently missing)
>>>>>>>>>>         * Compare reporting free pages via vring with vhost.
>>>>>>>>>>         * Decide between MADV_DONTNEED and MADV_FREE.
>>>>>>>>>>    * Analyze overall performance impact due to guest free page=
 hinting.
>>>>>>>>>>    * Come up with proper/traceable error-message/logs.
>>>>>>>>>>
>>>>>>>>>> Tests:
>>>>>>>>>> 1. Use-case - Number of guests we can launch
>>>>>>>>>>
>>>>>>>>>>    NUMA Nodes =3D 1 with 15 GB memory
>>>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>>>    Number of cores in guest =3D 1
>>>>>>>>>>    Workload =3D test allocation program allocates 4GB memory, =
touches it via memset and exits.
>>>>>>>>>>    Procedure =3D
>>>>>>>>>>    The first guest is launched and once its console is up, the=
 test allocation program is executed with 4 GB memory request (Due to thi=
s the guest occupies almost 4-5 GB of memory in the host in a system with=
out page hinting). Once this program exits at that time another guest is =
launched in the host and the same process is followed. We continue launch=
ing the guests until a guest gets killed due to low memory condition in t=
he host.
>>>>>>>>>>
>>>>>>>>>>    Results:
>>>>>>>>>>    Without hinting =3D 3
>>>>>>>>>>    With hinting =3D 5
>>>>>>>>>>
>>>>>>>>>> 2. Hackbench
>>>>>>>>>>    Guest Memory =3D 5 GB
>>>>>>>>>>    Number of cores =3D 4
>>>>>>>>>>    Number of tasks         Time with Hinting       Time withou=
t Hinting
>>>>>>>>>>    4000                    19.540                  17.818
>>>>>>>>>>
>>>>>>>>> How about memhog btw?
>>>>>>>>> Alex reported:
>>>>>>>>>
>>>>>>>>>     My testing up till now has consisted of setting up 4 8GB VM=
s on a system
>>>>>>>>>     with 32GB of memory and 4GB of swap. To stress the memory o=
n the system I
>>>>>>>>>     would run "memhog 8G" sequentially on each of the guests an=
d observe how
>>>>>>>>>     long it took to complete the run. The observed behavior is =
that on the
>>>>>>>>>     systems with these patches applied in both the guest and on=
 the host I was
>>>>>>>>>     able to complete the test with a time of 5 to 7 seconds per=
 guest. On a
>>>>>>>>>     system without these patches the time ranged from 7 to 49 s=
econds per
>>>>>>>>>     guest. I am assuming the variability is due to time being s=
pent writing
>>>>>>>>>     pages out to disk in order to free up space for the guest.
>>>>>>>>>
>>>>>>>> Here are the results:
>>>>>>>>
>>>>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA nod=
e with
>>>>>>>> total memory of 15GB and no swap. In each of the guest, memhog i=
s run
>>>>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitor=
ed by
>>>>>>>> using Free command.
>>>>>>>>
>>>>>>>> Without Hinting:
>>>>>>>>                  Time of execution    Host used memory
>>>>>>>> Guest 1:        45 seconds            5.4 GB
>>>>>>>> Guest 2:        45 seconds            10 GB
>>>>>>>> Guest 3:        1  minute               15 GB
>>>>>>>>
>>>>>>>> With Hinting:
>>>>>>>>                 Time of execution     Host used memory
>>>>>>>> Guest 1:        49 seconds            2.4 GB
>>>>>>>> Guest 2:        40 seconds            4.3 GB
>>>>>>>> Guest 3:        50 seconds            6.3 GB
>>>>>>> OK so no improvement. OTOH Alex's patches cut time down to 5-7 se=
conds
>>>>>>> which seems better. Want to try testing Alex's patches for compar=
ison?
>>>>>>>
>>>>>> I realized that the last time I reported the memhog numbers, I did=
n't
>>>>>> enable the swap due to which the actual benefits of the series wer=
e not
>>>>>> shown.
>>>>>> I have re-run the test by including some of the changes suggested =
by
>>>>>> Alexander and David:
>>>>>>     * Reduced the size of the per-cpu array to 32 and minimum hint=
ing
>>>>>> threshold to 16.
>>>>>>     * Reported length of isolated pages along with start pfn, inst=
ead of
>>>>>> the order from the guest.
>>>>>>     * Used the reported length to madvise the entire length of add=
ress
>>>>>> instead of a single 4K page.
>>>>>>     * Replaced MADV_DONTNEED with MADV_FREE.
>>>>>>
>>>>>> Setup for the test:
>>>>>> NUMA node:1
>>>>>> Memory: 15GB
>>>>>> Swap: 4GB
>>>>>> Guest memory: 6GB
>>>>>> Number of core: 1
>>>>>>
>>>>>> Process: A guest is launched and memhog is run with 6GB. As its
>>>>>> execution is over next guest is launched. Everytime memhog executi=
on
>>>>>> time is monitored.
>>>>>> Results:
>>>>>>     Without Hinting:
>>>>>>                  Time of execution
>>>>>>     Guest1:    22s
>>>>>>     Guest2:    24s
>>>>>>     Guest3: 1m29s
>>>>>>
>>>>>>     With Hinting:
>>>>>>                 Time of execution
>>>>>>     Guest1:    24s
>>>>>>     Guest2:    25s
>>>>>>     Guest3:    28s
>>>>>>
>>>>>> When hinting is enabled swap space is not used until memhog with 6=
GB is
>>>>>> ran in 6th guest.
>>>>> So one change you may want to make to your test setup would be to
>>>>> launch the tests sequentially after all the guests all up, instead =
of
>>>>> combining the test and guest bring-up. In addition you could run
>>>>> through the guests more than once to determine a more-or-less stead=
y
>>>>> state in terms of the performance as you move between the guests af=
ter
>>>>> they have hit the point of having to either swap or pull MADV_FREE
>>>>> pages.
>>>> I tried running memhog as you suggested, here are the results:
>>>> Setup for the test:
>>>> NUMA node:1
>>>> Memory: 15GB
>>>> Swap: 4GB
>>>> Guest memory: 6GB
>>>> Number of core: 1
>>>>
>>>> Process: 3 guests are launched and memhog is run with 6GB. Results a=
re
>>>> monitored after 1st-time execution of memhog. Memhog is launched
>>>> sequentially in each of the guests and time is observed after the
>>>> execution of all 3 memhog is over.
>>>>
>>>> Results:
>>>> Without Hinting
>>>>     Time of Execution
>>>> 1.    6m48s
>>>> 2.    6m9s
>>>>
>>>> With Hinting
>>>> Array size:16 Minimum Threshold:8
>>>> 1.    2m57s
>>>> 2.    2m20s
>>>>
>>>> The memhog execution time in the case of hinting is still not that l=
ow
>>>> as we would have expected. This is due to the usage of swap space.
>>>> Although wrt to non-hinting when swap used space is around 3.5G, wit=
h
>>>> hinting it remains to around 1.1-1.5G.
>>>> I did try using a zone free page barrier which prevented hinting whe=
n
>>>> free pages of order HINTING_ORDER goes below 256. This further bring=
s
>>>> down the swap usage to 100-150 MB. The tricky part of this approach =
is
>>>> to configure this barrier condition for different guests.
>>>>
>>>> Array size:16 Minimum Threshold:8
>>>> 1.    1m16s
>>>> 2.    1m41s
>>>>
>>>> Note: Memhog time does seem to vary a little bit on every boot with =
or
>>>> without hinting.
>>>>
>>> I don't quite understand yet why "hinting more pages" (no free page
>>> barrier) should result in a higher swap usage in the hypervisor
>>> (1.1-1.5GB vs. 100-150 MB). If we are "hinting more pages" I would ha=
ve
>>> guessed that runtime could get slower, but not that we need more swap=
=2E
>>>
>>> One theory:
>>>
>>> If you hint all MAX_ORDER - 1 pages, at one point it could be that al=
l
>>> "remaining" free pages are currently isolated to be hinted. As MM nee=
ds
>>> more pages for a process, it will fallback to using "MAX_ORDER - 2"
>>> pages and so on. These pages, when they are freed, you won't hint
>>> anymore unless they get merged. But after all they won't get merged
>>> because they can't be merged (otherwise they wouldn't be "MAX_ORDER -=
 2"
>>> after all right from the beginning).
>>>
>>> Try hinting a smaller granularity to see if this could actually be th=
e case.
>> So I have two questions in my mind after looking at the results now:
>> 1. Why swap is coming into the picture when hinting is enabled?
>> 2. Same to what you have raised.
>> For the 1st question, I think the answer is: (correct me if I am wrong=
=2E)
>> Memhog while writing the memory does free memory but the pages it free=
s
>> are of a lower order which doesn't merge until the memhog write
>> completes. After which we do get the MAX_ORDER - 1 page from the buddy=

>> resulting in hinting.
>> As all 3 memhog are running parallelly we don't get free memory until
>> one of them completes.
>> This does explain that when 3 guests each of 6GB on a 15GB host tries =
to
>> run memhog with 6GB parallelly, swap comes into the picture even if
>> hinting is enabled.
> Are you running them in parallel or sequentially?=20
I was running them parallelly but then I realized to see any benefits,
in that case, I should have run less number of guests.
> I had suggested
> running them serially so that the previous one could complete and free
> the memory before the next one allocated memory. In that setup you
> should see the guests still swapping without hints, but with hints the
> guest should free the memory up before the next one starts using it.
Yeah, I just realized this. Thanks for the clarification.
> If you are running them in parallel then you are going to see things
> going to swap because memhog does like what the name implies and it
> will use all of the memory you give it. It isn't until it completes
> that the memory is freed.
>
>> This doesn't explain why putting a barrier or avoid hinting reduced th=
e
>> swap usage. It seems I possibly had a wrong impression of the delaying=

>> hinting idea which we discussed.
>> As I was observing the value of the swap at the end of the memhog
>> execution which is logically incorrect. I will re-run the test and
>> observe the highest swap usage during the entire execution of memhog f=
or
>> hinting vs non-hinting.
> So one option you may look at if you are wanting to run the tests in
> parallel would be to limit the number of tests you have running at the
> same time. If you have 15G of memory and 6G per guest you should be
> able to run 2 sessions at a time without going to swap, however if you
> run all 3 then you are likely going to be going to swap even with
> hinting.
>
> - Alex
--=20
Regards
Nitesh


--XcIH1IRibTrXwwEPmyCBkPdN89R5Xncki--

--8ELtNhs0R6qHWeem999JcPH9ce8DbRfR3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyRLgcACgkQo4ZA3AYy
ozmlGA//XON3L4HUNmk8dYwOlZ9uDO709tuWITFl2QxsrHAcgc+u0EoUejPLd0cZ
R7jMS1qGGt4zqETzG48gG+KzbGZK9X9qSYuO1qyvSP8765nS195rPZBUcyIenrVg
cOYkz23uVWRjwKZqR0bffAErijwNWYtSaFX9Zxf0tmbA8pTnY+vWNhzXnO6Al/qv
IskygP6j6eoeMCmpTxG6pBVHs+kIdBR3+ste1g8LGf1U5h/AMJnp3n8XFC9mRrwU
tzin5h27VRD+i8dqLqA0br6/7VomWuFwPb9DbMduQREX30F//mTkqsKCWWTlC7jO
Qm5QfW0GekzvkenQbSJDniV6EvnP7HClwfbybhA90Yt21pOhf/3t3/eJM0m7PrZj
RqNZ5FTEm/x+BRJbXy91pwNF9TTMoNjntSQARe3fyGh0QD1EcsYThGcQj9r71r5t
XyFa2QqhKnqvrbZSeX+IFk7YB4H2BOFNCNjTOWq9FNjg8JAUv18cavhmEALfwmn1
dFc33hXjudbE6VRF57Q5kwZuxHSfArWg7lyDZgYq/jZttBxN8/iVH7pOmjesmERF
o2AIgTf39/LbS1ymPdkoyEhfySbKQGgY86idgUx6HR2ycb9yzzlAb3Q5oOBTS8MC
M/O31Ker1UcoEve+R0YgBBkfThtsXjhiA9XjDsWQA8croY2FsU4=
=67VF
-----END PGP SIGNATURE-----

--8ELtNhs0R6qHWeem999JcPH9ce8DbRfR3--

