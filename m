Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB945C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:13:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DAD0207E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:13:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="CWdWEdXP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DAD0207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20A4C6B0274; Fri,  7 Jun 2019 18:13:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BC896B0275; Fri,  7 Jun 2019 18:13:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CFD06B0276; Fri,  7 Jun 2019 18:13:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id DCB616B0274
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:13:02 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id q79so3384339ywg.13
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:13:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=w3a7b9rytavrVqWAu68ZTBiYbQdXk8HyDqOvXxODynI=;
        b=Ien5hVtni0P0up++U1ebM8EMRqlm73cI70QR3ddfrC4RfRtGTrlPKHDita1mXryI7b
         ZJlHX40FIHCAby0IkCWlInjL94gXj9ZWtXQMAWBMCdGQ2H9VKcneax/yKUTvOX0mUXed
         dlx5HUShPrjpQQeb5uusu/SntW2hjWf8VsWPteTpjd/GkWb8kUZADlOOH/bLZbF8KvzA
         gyjNsnH0YjZ3Zko+/zIDTiNyCS/6+RIFuZ+w8iKyJALYsvXtVTp7UvKYJlLnbbMbmX5J
         64Ul1yBK26YdvVBFVzUrEYAosNIpnL4sHdfKPep8SPXf3gFs+LaZ3Nvzj8ngcvKREm30
         Ri+A==
X-Gm-Message-State: APjAAAXuQC7CQg2j8IsdIAx+D5ortIhDHfJhki5OkNPvKYeZdSAGLLNt
	/fWqdRV6XHfRlLSC9e5eqbU8PB+mpgyAO3Ce1A7/yBJHJ6DF+t1dAk8pNTUT6AelzHu7luP8vSv
	eyJg9Ei7lBL93+T+oDjQ4KSLkGwMMHQxn5BndzhEw10ieVeRqew+LPTsT4GxQWzytNA==
X-Received: by 2002:a81:1c11:: with SMTP id c17mr30330267ywc.402.1559945582622;
        Fri, 07 Jun 2019 15:13:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsbDUJ9k7OgQThG7FC3z3DOwt/A4NzIsSyG0BFhWLdsIYM+7iWqNDmD3Bj9ivcKsRJ03vb
X-Received: by 2002:a81:1c11:: with SMTP id c17mr30330229ywc.402.1559945581888;
        Fri, 07 Jun 2019 15:13:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559945581; cv=none;
        d=google.com; s=arc-20160816;
        b=EDMvuUiLnW/ZAwo6EYPSBktbmue8XFlt2ZsRZ+r+sd1GFHICUyfplPqgJEKx+2fZnf
         jC+3dO58Mv6sxvoFi4+gkm751eueCQos8M+OnpaWOuGrPcmT3cjpV9TRDSZWRjeY0nuW
         U2+bF7SpuXni7qi2cE6yo9t0FqF02nwkdrVNBhAJKojCyjzuDVAqGSjl2lYZP0efcmES
         2kABdcLcK02mq0Vy++tHdBqJYN2WMxamCbMKzgewTMqtPb9pIbNPsrrfXZEWLdx45ir3
         eiGhqcI9Cxgy6zBEVsES/Kig6rcoT1LzMwnZjSxCZqev4eDoyEotp1pZe9kh40AkQ+eS
         E28w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=w3a7b9rytavrVqWAu68ZTBiYbQdXk8HyDqOvXxODynI=;
        b=lDqJhf/7IUc7NsagSpJAk2Dv4HeX5r7D1yD5xn+C85gS5QCJPD1TARSiubT50DOGD6
         mlPHeo8XQlF6zb0MWMygZWLrxtXZtqgBkMuzsspSgwHER4980SCI9GzdplsZlgOvJbcG
         FVLM7xmgAjAqGW9sSPYaEWGsXmM2tLRxuUesOoGLYaiAkOcI9O7vRFgdfYHWnywdiLze
         W4/AvENr7plarpd28XVAXZD9d23qw1BVBPfeEAtOxJ0nyxFi11EZLZj2qxxwiRuU+RWZ
         QnolI2oL8QdTdWvpH1ARMC7VOpA2G1LfpRoHP1wUhbJXXOUX4r/RlwHR7nO3npwyEnDg
         3yxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CWdWEdXP;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 129si897609yba.427.2019.06.07.15.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 15:13:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=CWdWEdXP;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfae15d0000>; Fri, 07 Jun 2019 15:12:45 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 15:13:00 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 15:13:00 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 22:13:00 +0000
Subject: Re: [PATCH v2 hmm 05/11] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	<Felix.Kuehling@amd.com>, <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-6-jgg@ziepe.ca>
 <6833be96-12a3-1a1c-1514-c148ba2dd87b@nvidia.com>
 <20190607191302.GR14802@ziepe.ca>
 <e17aa8c5-790c-d977-2eb8-c18cdaa4cbb3@nvidia.com>
 <20190607204427.GU14802@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <ba55e382-c982-8e50-4ee7-7f05c9f7fafa@nvidia.com>
Date: Fri, 7 Jun 2019 15:13:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190607204427.GU14802@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559945565; bh=w3a7b9rytavrVqWAu68ZTBiYbQdXk8HyDqOvXxODynI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=CWdWEdXPdbaJqJvgBK8un2hHaJjvd5blgVCjnqh9s/ui4hx87u/PJ98EsE3qmq6Qu
	 1W50vUYw1wY0Qu8QqArvY53uYzlLZ8EkYK+2k62MiFKOdIsVhEE7Gzv4g3wnvDXtD5
	 8pYFkrEtJoIqZ9LyuyvmlNSpvhmXLsYcW9r73wlDH8OG6Pl1/sKkUaQ2HV6PkV61/Z
	 efjBqzJjkpXoY7LY2JKKbOGi0PFCKWjp0sHy67fAO92y2bEogWuGzdZmw1y4bzEVGW
	 tmZOCvZJeqxrnQZ9gAn/6QduMPBBZq+PkRyjmTnXOJhExey4BRW0jLc8st2oDC44/D
	 qk8qFJQluW+dQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/7/19 1:44 PM, Jason Gunthorpe wrote:
> On Fri, Jun 07, 2019 at 01:21:12PM -0700, Ralph Campbell wrote:
> 
>>> What I want to get to is a pattern like this:
>>>
>>> pagefault():
>>>
>>>      hmm_range_register(&range);
>>> again:
>>>      /* On the slow path, if we appear to be live locked then we get
>>>         the write side of mmap_sem which will break the live lock,
>>>         otherwise this gets the read lock */
>>>      if (hmm_range_start_and_lock(&range))
>>>            goto err;
>>>
>>>      lockdep_assert_held(range->mm->mmap_sem);
>>>
>>>      // Optional: Avoid useless expensive work
>>>      if (hmm_range_needs_retry(&range))
>>>         goto again;
>>>      hmm_range_(touch vmas)
>>>
>>>      take_lock(driver->update);
>>>      if (hmm_range_end(&range) {
>>>          release_lock(driver->update);
>>>          goto again;
>>>      }
>>>      // Finish driver updates
>>>      release_lock(driver->update);
>>>
>>>      // Releases mmap_sem
>>>      hmm_range_unregister_and_unlock(&range);
>>>
>>> What do you think?
>>>
>>> Is it clear?
>>>
>>> Jason
>>>
>>
>> Are you talking about acquiring mmap_sem in hmm_range_start_and_lock()?
>> Usually, the fault code has to lock mmap_sem for read in order to
>> call find_vma() so it can set range.vma.
> 
>> If HMM drops mmap_sem - which I don't think it should, just return an
>> error to tell the caller to drop mmap_sem and retry - the find_vma()
>> will need to be repeated as well.
> 
> Overall I don't think it makes a lot of sense to sleep for retry in
> hmm_range_start_and_lock() while holding mmap_sem. It would be better
> to drop that lock, sleep, then re-acquire it as part of the hmm logic.
> 
> The find_vma should be done inside the critical section created by
> hmm_range_start_and_lock(), not before it. If we are retrying then we
> already slept and the additional CPU cost to repeat the find_vma is
> immaterial, IMHO?
> 
> Do you see a reason why the find_vma() ever needs to be before the
> 'again' in my above example? range.vma does not need to be set for
> range_register.

Yes, for the GPU case, there can be many faults in an event queue
and the goal is to try to handle more than one page at a time.
The vma is needed to limit the amount of coalescing and checking
for pages that could be speculatively migrated or mapped.

>> I'm also not sure about acquiring the mmap_sem for write as way to
>> mitigate thrashing. It seems to me that if a device and a CPU are
>> both faulting on the same page,
> 
> One of the reasons to prefer this approach is that it means we don't
> need to keep track of which ranges we are faulting, and if there is a
> lot of *unrelated* fault activity (unlikely?) we can resolve it using
> mmap sem instead of this elaborate ranges scheme and related
> locking.
> 
> This would reduce the overall work in the page fault and
> invalidate_start/end paths for the common uncontended cases.
> 
>> some sort of backoff delay is needed to let one side or the other
>> make some progress.
> 
> What the write side of the mmap_sem would do is force the CPU and
> device to cleanly take turns. Once the device pages are registered
> under the write side the CPU will have to wait in invalidate_start for
> the driver to complete a shootdown, then the whole thing starts all
> over again.
> 
> It is certainly imaginable something could have a 'min life' timer for
> a device mapping and hold mm invalidate_start, and device pagefault
> for that min time to promote better sharing.
> 
> But, if we don't use the mmap_sem then we can livelock and the device
> will see an unrecoverable error from the timeout which means we have
> risk that under load the system will simply obscurely fail. This seems
> unacceptable to me..
> 
> Particularly since for the ODP use case the issue is not trashing
> migration as a GPU might have, but simple system stability under swap
> load. We do not want the ODP pagefault to permanently fail due to
> timeout if the VMA is still valid..
> 
> Jason
> 

OK, I understand.
If you come up with a set of changes, I can try testing them.

