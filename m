Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DC27C49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 21:57:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7A2720872
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 21:57:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="q0awtSEw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7A2720872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3205F6B027D; Wed, 11 Sep 2019 17:57:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A9566B027E; Wed, 11 Sep 2019 17:57:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 170D36B027F; Wed, 11 Sep 2019 17:57:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id E35A36B027D
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:57:47 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7852D824376B
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 21:57:47 +0000 (UTC)
X-FDA: 75924002574.06.milk75_9c3ece33b856
X-HE-Tag: milk75_9c3ece33b856
X-Filterd-Recvd-Size: 8692
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 21:57:46 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id g13so26852753qtj.4
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 14:57:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=BiFTutYwV7WV5DTyUFMki78gS/6bcfMhuRhUhPM02wk=;
        b=q0awtSEwQpMikevefu0T5iDrpyNVuEqLab3ASXSI3OPhsNK8YZrfg0yvG/pDMazPN6
         qSxV7yRyX3G2ls1linDGBO+564XnEKqw6m+bMPmKC9LLKr9osKpMSEndnySLnToSlTjI
         O0y5/ig/n+u+iqMPQN9IJgSZqbDqREvoECT7+j0s3weOgJr3Bnw2JtoT21ojnCztjZog
         YTDuU/lo9yxG4TFCQo6Yxnruh14FPxxC5nPAQoO3v+0UPfLJQDbj9dl+b43aU1KAfGub
         w/95lofeKUVDU5AzHzwQaO97cWZORANP/Mecsf8ih1MQN6aaaygGy+F33g8uKa1V8Avx
         ecfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=BiFTutYwV7WV5DTyUFMki78gS/6bcfMhuRhUhPM02wk=;
        b=C8V/Q9RgLLq1J4dJ59hFOqTBkqqbyDgJ/L64lOyfKvBy93IeUloPuX6LiR7pr8OMTR
         98vbBhkAqSRHiDK3JwAM4tl8YzwP4jAZuuK1NDgNc/81w2ltrcSd//l+iOKpveTYqLLz
         xBlqOhTtHhhXnKK+HoqRxG/GZrGVBi8eOvr4lClt4k46Y1xx9FHamVS0KCMaNCfLmAMN
         vVFYss7Dz2kgnQs3TXivPj04wY2XOGxXWWlReQsofkNLgJlr+wkBDpSehEIg3De1EQSf
         bBNhkVa3bVKPnXpp5Jx0uOKZ+g7KKDPuf7j9mCV2hsRAp8E1zwLeLCUZbfjXdE3VzwrT
         4dJA==
X-Gm-Message-State: APjAAAWISKi3xZGXcFQ46SLeJcMvSpcvXYP/lhV4JPFvEA22n+TuEBlq
	FVRrcP3GPm5Dq/CYtHQEfK8azA==
X-Google-Smtp-Source: APXvYqyCWOJ3rjZ/V0ODkA3YcXn1qSynuCFqbmhNBntxeVQmYkQlLe7JfZdCiEET9EjhKsi3aTCWHQ==
X-Received: by 2002:ac8:2c86:: with SMTP id 6mr19594990qtw.113.1568239066370;
        Wed, 11 Sep 2019 14:57:46 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id d134sm11584329qkg.133.2019.09.11.14.57.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Sep 2019 14:57:45 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
From: Qian Cai <cai@lca.pw>
In-Reply-To: <211b144f-0e86-d891-e1ec-9879ceb53e36@redhat.com>
Date: Wed, 11 Sep 2019 17:57:44 -0400
Cc: Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>,
 Will Deacon <will.deacon@arm.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org,
 Davidlohr Bueso <dave@stgolabs.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <B06C5D2C-94E2-4C25-AB16-DC96A0900015@lca.pw>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <B97932F4-7A2D-4265-9BB2-BF6E19B45DB7@lca.pw>
 <1a8e6c0a-6ba6-d71f-974e-f8a9c623c25b@redhat.com>
 <70714929-2CE3-42F4-BD31-427077C9E24E@lca.pw>
 <211b144f-0e86-d891-e1ec-9879ceb53e36@redhat.com>
To: Waiman Long <longman@redhat.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Sep 11, 2019, at 4:54 PM, Waiman Long <longman@redhat.com> wrote:
>=20
> On 9/11/19 8:42 PM, Qian Cai wrote:
>>=20
>>> On Sep 11, 2019, at 12:34 PM, Waiman Long <longman@redhat.com> =
wrote:
>>>=20
>>> On 9/11/19 5:01 PM, Qian Cai wrote:
>>>>> On Sep 11, 2019, at 11:05 AM, Waiman Long <longman@redhat.com> =
wrote:
>>>>>=20
>>>>> When allocating a large amount of static hugepages (~500-1500GB) =
on a
>>>>> system with large number of CPUs (4, 8 or even 16 sockets), =
performance
>>>>> degradation (random multi-second delays) was observed when =
thousands
>>>>> of processes are trying to fault in the data into the huge pages. =
The
>>>>> likelihood of the delay increases with the number of sockets and =
hence
>>>>> the CPUs a system has.  This only happens in the initial setup =
phase
>>>>> and will be gone after all the necessary data are faulted in.
>>>>>=20
>>>>> These random delays, however, are deemed unacceptable. The cause =
of
>>>>> that delay is the long wait time in acquiring the mmap_sem when =
trying
>>>>> to share the huge PMDs.
>>>>>=20
>>>>> To remove the unacceptable delays, we have to limit the amount of =
wait
>>>>> time on the mmap_sem. So the new down_write_timedlock() function =
is
>>>>> used to acquire the write lock on the mmap_sem with a timeout =
value of
>>>>> 10ms which should not cause a perceivable delay. If timeout =
happens,
>>>>> the task will abandon its effort to share the PMD and allocate its =
own
>>>>> copy instead.
>>>>>=20
>>>>> When too many timeouts happens (threshold currently set at 256), =
the
>>>>> system may be too large for PMD sharing to be useful without undue =
delay.
>>>>> So the sharing will be disabled in this case.
>>>>>=20
>>>>> Signed-off-by: Waiman Long <longman@redhat.com>
>>>>> ---
>>>>> include/linux/fs.h |  7 +++++++
>>>>> mm/hugetlb.c       | 24 +++++++++++++++++++++---
>>>>> 2 files changed, 28 insertions(+), 3 deletions(-)
>>>>>=20
>>>>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>>>>> index 997a530ff4e9..e9d3ad465a6b 100644
>>>>> --- a/include/linux/fs.h
>>>>> +++ b/include/linux/fs.h
>>>>> @@ -40,6 +40,7 @@
>>>>> #include <linux/fs_types.h>
>>>>> #include <linux/build_bug.h>
>>>>> #include <linux/stddef.h>
>>>>> +#include <linux/ktime.h>
>>>>>=20
>>>>> #include <asm/byteorder.h>
>>>>> #include <uapi/linux/fs.h>
>>>>> @@ -519,6 +520,12 @@ static inline void i_mmap_lock_write(struct =
address_space *mapping)
>>>>> 	down_write(&mapping->i_mmap_rwsem);
>>>>> }
>>>>>=20
>>>>> +static inline bool i_mmap_timedlock_write(struct address_space =
*mapping,
>>>>> +					 ktime_t timeout)
>>>>> +{
>>>>> +	return down_write_timedlock(&mapping->i_mmap_rwsem, timeout);
>>>>> +}
>>>>> +
>>>>> static inline void i_mmap_unlock_write(struct address_space =
*mapping)
>>>>> {
>>>>> 	up_write(&mapping->i_mmap_rwsem);
>>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>>>> index 6d7296dd11b8..445af661ae29 100644
>>>>> --- a/mm/hugetlb.c
>>>>> +++ b/mm/hugetlb.c
>>>>> @@ -4750,6 +4750,8 @@ void =
adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
>>>>> 	}
>>>>> }
>>>>>=20
>>>>> +#define PMD_SHARE_DISABLE_THRESHOLD	(1 << 8)
>>>>> +
>>>>> /*
>>>>> * Search for a shareable pmd page for hugetlb. In any case calls =
pmd_alloc()
>>>>> * and returns the corresponding pte. While this is not necessary =
for the
>>>>> @@ -4770,11 +4772,24 @@ pte_t *huge_pmd_share(struct mm_struct =
*mm, unsigned long addr, pud_t *pud)
>>>>> 	pte_t *spte =3D NULL;
>>>>> 	pte_t *pte;
>>>>> 	spinlock_t *ptl;
>>>>> +	static atomic_t timeout_cnt;
>>>>>=20
>>>>> -	if (!vma_shareable(vma, addr))
>>>>> -		return (pte_t *)pmd_alloc(mm, pud, addr);
>>>>> +	/*
>>>>> +	 * Don't share if it is not sharable or locking attempt timed =
out
>>>>> +	 * after 10ms. After 256 timeouts, PMD sharing will be =
permanently
>>>>> +	 * disabled as it is just too slow.
>>>> It looks like this kind of policy interacts with kernel debug =
options like KASAN (which is going to slow the system down
>>>> anyway) could introduce tricky issues due to different timings on a =
debug kernel.
>>> With respect to lockdep, down_write_timedlock() works like a =
trylock. So
>>> a lot of checking will be skipped. Also the lockdep code won't be =
run
>>> until the lock is acquired. So its execution time has no effect on =
the
>>> timeout.
>> No only lockdep, but also things like KASAN, debug_pagealloc, =
page_poison, kmemleak, debug
>> objects etc that  all going to slow down things in huge_pmd_share(), =
and make it tricky to get a
>> right timeout value for those debug kernels without changing the =
previous behavior.
>=20
> Right, I understand that. I will move to use a sysctl parameters for =
the
> timeout and then set its default value to either 10ms or 20ms if some
> debug options are detected. Usually the slower than should not be more
> than 2X.

That 2X is another magic number which has no testing data back for it. =
We need a way to disable timeout
completely in Kconfig, so it can ship in the part of a debug kernel =
package.



