Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F5D6C31E49
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 02:25:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1454E2089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 02:25:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Y68zjNB4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1454E2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 831848E0003; Sun, 16 Jun 2019 22:25:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2DB8E0001; Sun, 16 Jun 2019 22:25:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D01D8E0003; Sun, 16 Jun 2019 22:25:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB8F8E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 22:25:28 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l11so7974158qtp.22
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 19:25:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=zVCq6iQjd8y+MdsDtmpkIiWvfWaJhRLMSgJUV6RtXtc=;
        b=CYSnvOPjFIEiZUlQEq5QoxomUJP+saId5vPjShEdr5mYIgbWwGY9YDLe9ePXuSgVwK
         RQkyoh+Z7mdl/KtiClrisSskPeX83j9R57Q3M2cNPesZBkpBgvNXjtkyvz6Va5fOH2N/
         XJ5B4JZjwHgcgj30HTu0avE7fD9LPXIzryspJh/wuve0USSBHc0QBOC57Faj8hAdAWTk
         JDC01+Qn/ntk92l1Oac5YVbm5v9yvF7wu9hVJWz7EmFF3TcC/V5rPwKkLu3YS+PdNpJ1
         j7MwZ7aZUCx/RrzU7gYiAj0hMY4JpEIHfxXHlDu4O+sjbE42P0xz/622Y23I6gtAciot
         cToQ==
X-Gm-Message-State: APjAAAWqteQ7mGD8LgXlKN3U6YyqItEJ5hJPoIH8KTsRb1ZUlUoLAd7q
	od0ZMutV2rbsTP5b1ufWRW3CJfW+YKGHps7xMszOsYkEnaMP8157TmTlfL7VoSS3ZW5xx4T/MHC
	x6COnChUtRWHcpT6xgifGjStuVbH0zQ6WZr7dAgFj06iHCrSnQX7urmPsGjBaDQGKZQ==
X-Received: by 2002:aed:228d:: with SMTP id p13mr32655094qtc.208.1560738328045;
        Sun, 16 Jun 2019 19:25:28 -0700 (PDT)
X-Received: by 2002:aed:228d:: with SMTP id p13mr32655060qtc.208.1560738327227;
        Sun, 16 Jun 2019 19:25:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560738327; cv=none;
        d=google.com; s=arc-20160816;
        b=tOPsl7qHeLKJJWuFSvzhjtLsPApy/F+I+b9QTSxw9DtQDd0V0qew+ca0T/fA9fN/U9
         85/nP9PlqoE/sqL8YuSaU4vtjIheVFYSZFrFDfGkf1agr1SaWKP5pXXXn7C10yzjNHP+
         hQx2zjRL807qptSBLMQFiP8AFk5Vzsfj10QhiyHBi2V/G6STrQ4O1pSYBVIMHVfbb/I8
         0c20jaYGKM/yew5fQqaYROprywV8Fh7PcNWoEP6mVWVViYoC/BSy/7/4GzLsbhe9JaKX
         +poH3HKO3PFEmxfA5SkO0saFUNPerS4doXSe/2tfLPkFdcmkEGVFEeZeM9AL8MfURImx
         xmKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=zVCq6iQjd8y+MdsDtmpkIiWvfWaJhRLMSgJUV6RtXtc=;
        b=GwR3S+mwDhXW9Lh7Go2xziORil2MTsrWgFh8i+gosFi+LMFYEU50e1t/msO5ATWECf
         3adpsGp0pt51BZ71AlwAMDsFzO8O1RMIvnabujSFJlQ42vlLIDybI0WrvOrncO9CP2cR
         pv+u/AbnpeFj7L2KKyGs2rxHzBl2q6XzPw7FPS1NJMSyssErwXiTwtCI+IX6Ow/8i3RE
         a/+dlTDNkwJZp9Hcx/s9adL7M39TBdTkkdS6jb8/qxeMRynMelay4HXrGIh85MDx6Ccz
         uv42gxV0EazowHde6h8aRaViqw4Il5oOisitOwubvpk/hFGZVDqNIYFtIqgkvhNH670q
         ZGfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Y68zjNB4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j70sor1914769qke.83.2019.06.16.19.25.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 19:25:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Y68zjNB4;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=zVCq6iQjd8y+MdsDtmpkIiWvfWaJhRLMSgJUV6RtXtc=;
        b=Y68zjNB4WWeZsh+LN43S1Q77LOG6Lkmvy8jA/X3y3qY9+aU84X8ZE6N5ajtMFZdqRe
         SI7/y0pIbPD7ZVPFM5BRVkEnuQZLwUslxJwRwMKIdVJJzt3HxQcOYbVjc3CqlEXReNod
         WgeEhIb9hGsh3iOlLLgLvyvkSvxmnysINjRiMgR4yYvW6/gkqFlIc7yJ/UE5GoPts+0h
         whh2cPfZPM/CJpv1/+cDhf8ICkSmmBDXzLpukgWnfPqFBvCab5BiOGnI4h8XjAhR4Bhb
         yhqcvLK7M1Jvtn7UVS3WgvtW0ugsS4Xv+CrSRhwxxZEaq9a4N4B8Hh5vu7TahjcJOc29
         hgnw==
X-Google-Smtp-Source: APXvYqy14pKpIo5D468BgTMoKIvQEBc9dbEDaWKaf4TPQWMdKIwtImOPCPOSk5lFyoOo1JIKyZ9lWg==
X-Received: by 2002:a37:b904:: with SMTP id j4mr59875274qkf.27.1560738326850;
        Sun, 16 Jun 2019 19:25:26 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id u19sm6794763qka.35.2019.06.16.19.25.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 19:25:26 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
From: Qian Cai <cai@lca.pw>
In-Reply-To: <CAPcyv4hyQsAhw35hc4S7hJ2Mh7qwu6ANuh9Bs174okWZZwujgg@mail.gmail.com>
Date: Sun, 16 Jun 2019 22:25:24 -0400
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Oscar Salvador <osalvador@suse.de>,
 Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <642FC723-2FCB-415D-8EE0-AE013D5AAF10@lca.pw>
References: <1560366952-10660-1-git-send-email-cai@lca.pw>
 <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com>
 <1560524365.5154.21.camel@lca.pw>
 <CAPcyv4jAzMzFjSD22VU9Csw+kgGbf8r=XHbdJYzgL_uH_GVEvw@mail.gmail.com>
 <CAPcyv4hjvBPDYKpp2Gns3-cc2AQ0AVS1nLk-K3fwXeRUvvzQLg@mail.gmail.com>
 <1560541220.5154.23.camel@lca.pw>
 <CAPcyv4i5iUop_H-Ai4q_hn2-3L6aRuovY44tuV50bp1oZj29TQ@mail.gmail.com>
 <1560544982.5154.24.camel@lca.pw>
 <CAPcyv4hyQsAhw35hc4S7hJ2Mh7qwu6ANuh9Bs174okWZZwujgg@mail.gmail.com>
To: Dan Williams <dan.j.williams@intel.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 16, 2019, at 11:42 AM, Dan Williams <dan.j.williams@intel.com> =
wrote:
>=20
> On Fri, Jun 14, 2019 at 1:43 PM Qian Cai <cai@lca.pw> wrote:
>>=20
>> On Fri, 2019-06-14 at 12:48 -0700, Dan Williams wrote:
>>> On Fri, Jun 14, 2019 at 12:40 PM Qian Cai <cai@lca.pw> wrote:
>>>>=20
>>>> On Fri, 2019-06-14 at 11:57 -0700, Dan Williams wrote:
>>>>> On Fri, Jun 14, 2019 at 11:03 AM Dan Williams =
<dan.j.williams@intel.com>
>>>>> wrote:
>>>>>>=20
>>>>>> On Fri, Jun 14, 2019 at 7:59 AM Qian Cai <cai@lca.pw> wrote:
>>>>>>>=20
>>>>>>> On Fri, 2019-06-14 at 14:28 +0530, Aneesh Kumar K.V wrote:
>>>>>>>> Qian Cai <cai@lca.pw> writes:
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>> 1) offline is busted [1]. It looks like test_pages_in_a_zone()
>>>>>>>>> missed
>>>>>>>>> the
>>>>>>>>> same
>>>>>>>>> pfn_section_valid() check.
>>>>>>>>>=20
>>>>>>>>> 2) powerpc booting is generating endless warnings [2]. In
>>>>>>>>> vmemmap_populated() at
>>>>>>>>> arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION =
to
>>>>>>>>> PAGES_PER_SUBSECTION, but it alone seems not enough.
>>>>>>>>>=20
>>>>>>>>=20
>>>>>>>> Can you check with this change on ppc64.  I haven't reviewed =
this
>>>>>>>> series
>>>>>>>> yet.
>>>>>>>> I did limited testing with change . Before merging this I need =
to go
>>>>>>>> through the full series again. The vmemmap poplulate on ppc64 =
needs
>>>>>>>> to
>>>>>>>> handle two translation mode (hash and radix). With respect to =
vmemap
>>>>>>>> hash doesn't setup a translation in the linux page table. Hence =
we
>>>>>>>> need
>>>>>>>> to make sure we don't try to setup a mapping for a range which =
is
>>>>>>>> arleady convered by an existing mapping.
>>>>>>>=20
>>>>>>> It works fine.
>>>>>>=20
>>>>>> Strange... it would only change behavior if valid_section() is =
true
>>>>>> when pfn_valid() is not or vice versa. They "should" be identical
>>>>>> because subsection-size =3D=3D section-size on PowerPC, at least =
with the
>>>>>> current definition of SUBSECTION_SHIFT. I suspect maybe
>>>>>> free_area_init_nodes() is too late to call subsection_map_init() =
for
>>>>>> PowerPC.
>>>>>=20
>>>>> Can you give the attached incremental patch a try? This will break
>>>>> support for doing sub-section hot-add in a section that was only
>>>>> partially populated early at init, but that can be repaired later =
in
>>>>> the series. First things first, don't regress.
>>>>>=20
>>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>> index 874eb22d22e4..520c83aa0fec 100644
>>>>> --- a/mm/page_alloc.c
>>>>> +++ b/mm/page_alloc.c
>>>>> @@ -7286,12 +7286,10 @@ void __init free_area_init_nodes(unsigned =
long
>>>>> *max_zone_pfn)
>>>>>=20
>>>>>        /* Print out the early node map */
>>>>>        pr_info("Early memory node ranges\n");
>>>>> -       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, =
&end_pfn,
>>>>> &nid) {
>>>>> +       for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, =
&end_pfn,
>>>>> &nid)
>>>>>                pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
>>>>>                        (u64)start_pfn << PAGE_SHIFT,
>>>>>                        ((u64)end_pfn << PAGE_SHIFT) - 1);
>>>>> -               subsection_map_init(start_pfn, end_pfn - =
start_pfn);
>>>>> -       }
>>>>>=20
>>>>>        /* Initialise every node */
>>>>>        mminit_verify_pageflags_layout();
>>>>> diff --git a/mm/sparse.c b/mm/sparse.c
>>>>> index 0baa2e55cfdd..bca8e6fa72d2 100644
>>>>> --- a/mm/sparse.c
>>>>> +++ b/mm/sparse.c
>>>>> @@ -533,6 +533,7 @@ static void __init sparse_init_nid(int nid,
>>>>> unsigned long pnum_begin,
>>>>>                }
>>>>>                check_usemap_section_nr(nid, usage);
>>>>>                sparse_init_one_section(__nr_to_section(pnum), =
pnum,
>>>>> map, usage);
>>>>> +               subsection_map_init(section_nr_to_pfn(pnum),
>>>>> PAGES_PER_SECTION);
>>>>>                usage =3D (void *) usage + =
mem_section_usage_size();
>>>>>        }
>>>>>        sparse_buffer_fini();
>>>>=20
>>>> It works fine except it starts to trigger slab debugging errors =
during boot.
>>>> Not
>>>> sure if it is related yet.
>>>=20
>>> If you want you can give this branch a try if you suspect something
>>> else in -next is triggering the slab warning.
>>>=20
>>> =
https://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git/log/?h=3Ds=
ubsect
>>> ion-v9
>>>=20
>>> It's the original v9 patchset + dependencies backported to v5.2-rc4.
>>>=20
>>> I otherwise don't see how subsections would effect slab caches.
>>=20
>> It works fine there.
>=20
> Much appreciated Qian!
>=20
> Does this change modulate the x86 failures?

Yes, it also fix the kmemleak_scan() and offline issues on x86.

