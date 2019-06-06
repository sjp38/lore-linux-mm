Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A8D1C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:50:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB1BF20868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:50:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="UDAQv/GI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB1BF20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52F036B0279; Thu,  6 Jun 2019 14:50:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 506326B027C; Thu,  6 Jun 2019 14:50:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F4266B027D; Thu,  6 Jun 2019 14:50:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15E156B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:50:18 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id y81so974975oig.19
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:50:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=lnWmoYy7kAn4bLm7t9cFbOMXhWsLoa4EfFFlm+lwmig=;
        b=eCDk0qFmt0ogfpqqvprSZ8YWk47xEHz78emXJGRcQA7/xVAzZ/UoPjuow7IAHulpbf
         Di3q8okrpIcZ++XXmNWFzBIvPKPxORchdrrixk92wQiwISoIV5spfrYsnDzQJZRpYc8N
         NbbSA5et6j80EkpK4tx4I9DSh4xSaT1jJdwcKpvygXfd8qrskLJytfpLFvBmm0y6jJs5
         8/LW88hr/C0B9pKrQTfrVSIr7YM1yHihaK4IZ+IYcTkvd7Gvrhd3zoNE4nSz6Tj7EhuB
         I9LdCpXa3kMF2APCsndoK/PpwFDDz/i0TWus/h21YQiNUJkA/RnzE+7yiGUmUCA7xOVJ
         XgJQ==
X-Gm-Message-State: APjAAAU1oh7rSGjJR43IXShk3oLcethASjU2U/4SdqXeHZ+MtTvyO6Ue
	1O6emA36tb4STf6yvJnL4cnXe9tcRbTphS5lvpYniMrcWC9Gy0y/Rhd5bAnNDYiMaEQ81CvbNpN
	PGhVifgn50k+RiJU8yawRlbezK62MgQgPB+cKzEj906jH+MWBg2pW+zk5WCW/0HOmNA==
X-Received: by 2002:a05:6830:148c:: with SMTP id s12mr6998939otq.274.1559847017566;
        Thu, 06 Jun 2019 11:50:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfaJ8ovRVGMLCQhFpWRLB6PH3H6zLZSzNDMUriItllNp6OmmjTmHwH7HPSTNRw1CmsUKAW
X-Received: by 2002:a05:6830:148c:: with SMTP id s12mr6998897otq.274.1559847016803;
        Thu, 06 Jun 2019 11:50:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559847016; cv=none;
        d=google.com; s=arc-20160816;
        b=eiVRdkNXpYvHFrYwXQyNOx+de/UM6TrUU2pqJtC2QQivE+Bur8T++LZZNcHTyOZUPB
         jm3Ob0GnK8vGf7dY4TzGwhOIKBGJ3VAP4rmeSaDUH4bnGGMwbZaXbMvyMPjHHZwV+Kc5
         4J4nKfglSc3+VqPbkHJ1sIxQ1I6j3Og7NTlQ+LErMFqDaT5IOSAARRi7JiJbcAqb314X
         cl1krQ6qU5KLO7DRelwiZhiTouqic6j8WNWcjhVp/lzTYZQN8hfYeB6gUDHbRVtDQ7PL
         bpsH+3SB4SPzaSHYWvmpqiqHoet/rOozwRid7PxAy9QDdEgaMRmDm8Fbkp/EaT9fagBt
         WRkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=lnWmoYy7kAn4bLm7t9cFbOMXhWsLoa4EfFFlm+lwmig=;
        b=z/TBEormj4WUfzcDx5dYwT2WnzwqibeZ6hOpUh79zrUa81brMVBiz7sIwhtT8hmEDX
         ejPdhzWRsXDCusEQylJoahpiNpu94xRduCmiada6xYPmQ1T6A982eF/VJrR2/5RGXdIX
         W3WRxiAvLnPqTnxX1oWrgbKg+YNChi0YYrFK3S1MTkK1ngJVMoz+FvyRUkeNFFCnbczh
         uW3/OmZnBGXL+2XDIp0vmx9oMeosij2PeViawzmLXgPAe7pCCaiIB8NCecIg+oWKyvFr
         PrH/RfB7+2sB7oelZKcp4hsA32uNsSwwvFZeCPlDMAPib4zsFs/fcR9nV9927WSi3JG1
         gtFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="UDAQv/GI";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s83si1892800oie.129.2019.06.06.11.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 11:50:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="UDAQv/GI";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf960590000>; Thu, 06 Jun 2019 11:50:01 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 11:50:15 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 06 Jun 2019 11:50:15 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 6 Jun
 2019 18:50:15 +0000
Subject: Re: [PATCH 1/5] mm/hmm: Update HMM documentation
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan Williams
	<dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
	<bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, "Matthew
 Wilcox" <willy@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>,
	"Andrew Morton" <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-2-rcampbell@nvidia.com>
 <20190606140239.GA21778@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <e1fad454-ac9b-4069-1bc8-8149c72655ca@nvidia.com>
Date: Thu, 6 Jun 2019 11:50:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606140239.GA21778@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559847001; bh=lnWmoYy7kAn4bLm7t9cFbOMXhWsLoa4EfFFlm+lwmig=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=UDAQv/GI8zoEqSn7mrswFwJ98G2U/yQQD/Aj0+YO7Qf5+Xr8LIE45i/9Kf0DT9xG3
	 JPPWSe0ZAVdjMHx+2C0ISnDMM3NkNkQqa5NXSEs50jcCB4GiVbS7uUaIN4pcELz3g+
	 MfSt7NTboICB1mkUbEx3mzD15NkILVLfyY7W7hCxGsr/Vew7TUf7Kead9IDlmuVFZ6
	 0g3htFBOh79b75YZGU+BAEjA89isoq7X+Uy0Kb8zWa5u3BVH/ZZ7h3FAU9N5uKCy4N
	 M3lK8+o+d2kh73ZkQKQwz0Fm+222atCS0/SR5UcSUSCqkOPa9W54dbdognW0U2lnZN
	 46ZaurvMxolKw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 7:02 AM, Jason Gunthorpe wrote:
> On Mon, May 06, 2019 at 04:29:38PM -0700, rcampbell@nvidia.com wrote:
>> From: Ralph Campbell <rcampbell@nvidia.com>
>>
>> Update the HMM documentation to reflect the latest API and make a few mi=
nor
>> wording changes.
>>
>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> Cc: John Hubbard <jhubbard@nvidia.com>
>> Cc: Ira Weiny <ira.weiny@intel.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Balbir Singh <bsingharora@gmail.com>
>> Cc: Dan Carpenter <dan.carpenter@oracle.com>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Souptick Joarder <jrdr.linux@gmail.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>   Documentation/vm/hmm.rst | 139 ++++++++++++++++++++-------------------
>>   1 file changed, 73 insertions(+), 66 deletions(-)
>=20
> Okay, lets start picking up hmm patches in to the new shared hmm.git,
> as promised I will take responsibility to send these to Linus. The
> tree is here:
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=3Dhm=
m
>=20
> This looks fine to me with one minor comment:
>=20
>> diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
>> index ec1efa32af3c..7c1e929931a0 100644
>> +++ b/Documentation/vm/hmm.rst
>>  =20
>> @@ -151,21 +151,27 @@ registration of an hmm_mirror struct::
>>  =20
>>    int hmm_mirror_register(struct hmm_mirror *mirror,
>>                            struct mm_struct *mm);
>> - int hmm_mirror_register_locked(struct hmm_mirror *mirror,
>> -                                struct mm_struct *mm);
>>  =20
>> -
>> -The locked variant is to be used when the driver is already holding mma=
p_sem
>> -of the mm in write mode. The mirror struct has a set of callbacks that =
are used
>> +The mirror struct has a set of callbacks that are used
>>   to propagate CPU page tables::
>>  =20
>>    struct hmm_mirror_ops {
>> +     /* release() - release hmm_mirror
>> +      *
>> +      * @mirror: pointer to struct hmm_mirror
>> +      *
>> +      * This is called when the mm_struct is being released.
>> +      * The callback should make sure no references to the mirror occur
>> +      * after the callback returns.
>> +      */
>=20
> This is not quite accurate (at least, as the other series I sent
> intends), the struct hmm_mirror is valid up until
> hmm_mirror_unregister() is called - specifically it remains valid
> after the release() callback.
>=20
> I will revise it (and the hmm.h comment it came from) to read the
> below. Please let me know if you'd like something else:
>=20
> 	/* release() - release hmm_mirror
> 	 *
> 	 * @mirror: pointer to struct hmm_mirror
> 	 *
> 	 * This is called when the mm_struct is being released.  The callback
> 	 * must ensure that all access to any pages obtained from this mirror
> 	 * is halted before the callback returns. All future access should
> 	 * fault.
> 	 */
>=20
> The key task for release is to fence off all device access to any
> related pages as the mm is about to recycle them and the device must
> not cause a use-after-free.
>=20
> I applied it to hmm.git
>=20
> Thanks,
> Jason
>=20

Yes, I agree this is better.

Also, I noticed the sample code for hmm_range_register() is wrong.
If you could merge this minor change into this patch, that
would be appreciated.

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index dc8fe4241a18..b5fb9bc02aa2 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -245,7 +245,7 @@ The usage pattern is::
              hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
              goto again;
            }
-          hmm_mirror_unregister(&range);
+          hmm_range_unregister(&range);
            return ret;
        }
        take_lock(driver->update);
@@ -257,7 +257,7 @@ The usage pattern is::

        // Use pfns array content to update device page table

-      hmm_mirror_unregister(&range);
+      hmm_range_unregister(&range);
        release_lock(driver->update);
        up_read(&mm->mmap_sem);
        return 0;

