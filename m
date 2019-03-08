Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01034C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:50:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C11820684
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:50:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C11820684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7D778E0003; Fri,  8 Mar 2019 03:50:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2CE78E0002; Fri,  8 Mar 2019 03:50:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D42D18E0003; Fri,  8 Mar 2019 03:50:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC1AE8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 03:50:50 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k21so15504123qkg.19
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 00:50:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=9enBgOU8y+sWTs3bRAOAEeGMAvftWKvi1kqpH53zTEk=;
        b=BaLg+/m/QueKkc3emrI4qEIFS3pyFuHeb1qhsCt8iu67/c0h5CVQu0aSVP1WMHfwfY
         MBgs/nyFKnEZzKXuIHUtGlB7mCPFTHDhIa0PwKiPS56nYqLro/aOvcAnVMefLcx91kcX
         +ukQfcxqcpwdYm0mTRgK+4+ZGuJ1gJXCx5yCQk+W8zAhJMzximw0h56oMPJhfOGgMSqb
         CCbU6yoUZIGhI6wN9f2bS0dRersgLirlIVhl0B25ctevkJLj314iA6aBFHDQQT6JNanD
         oBVNIATulCtYQaWFxVdRsSr5TzwL0Xo6u7sEvq8zu1iyK+P6OweXRN1V8rOiMoUmTYIt
         dgHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUJlYFexLTOFO+E83WeU+LmJLlg7hLUIg0V1PqOcNVmR9ovq41z
	qfuu4y2jCChBBE9QA6Xp+QR12CqtKfVPMpD/MmG3yqhl2x/nSsvNfOGb3mkBvmkRWOYvEILkp9c
	AC+0ECbL2QH8Et6OvFNYrAhClSR1mZN6bd3xesaS9QS8sheaE/8Qt9PK8lZErpB8MSA==
X-Received: by 2002:a37:c30d:: with SMTP id a13mr13381271qkj.18.1552035050413;
        Fri, 08 Mar 2019 00:50:50 -0800 (PST)
X-Google-Smtp-Source: APXvYqwKXuN1usroZ10gPHBGvbmT3E3LkYVKj361uLaGTk3Poi0iIlXaswT18dLOCTizYcHjQSON
X-Received: by 2002:a37:c30d:: with SMTP id a13mr13381226qkj.18.1552035049299;
        Fri, 08 Mar 2019 00:50:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552035049; cv=none;
        d=google.com; s=arc-20160816;
        b=FmrPI3imdC71eeheLhiCdazJFfUiIFB6p8sp78OYWr1zGYZ/asgLTtfNqd1PY8eIxQ
         w2mSl68BrW5Iw6q+3pF0em5nwTg1ULzwfdrn28v+F3tl7kvT89qqmamrXETaHhbOBaxk
         gBC+dyvZluwaGXLGygwRYi2ZzWCoLuMTwuZmE7+zKOMbHKCubqS5wreU/Drc0nCcSleC
         bcJqLrVbvt8xzJYJKkejXmxiCCTK3+Q9UqbHVrfG6endImVhUt0hn8g+HtZDNCDGeF4s
         TRc+kpkI/sr0Kak+5oW2fUlhBfntYfLjfo1ICsUcasRhUClLRStco1qCOx1oqSY8Gffl
         1Pjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9enBgOU8y+sWTs3bRAOAEeGMAvftWKvi1kqpH53zTEk=;
        b=W8+faj4rbiouMpusgZu8IHX5k4T6Ly/KYZid8lYtVqF07pcegvn2pgsvGtauxI0EI2
         M1l0nqcstvP9aqxIE3w/7SFUE95PAeIBMS9/tpeaziFH+h+xh9rIvjY3hsMWkQsh6NLr
         la2lGu2nSVbM+KUoGxPVSD4F5StlrTSjRzJ7MGFYYirtT3At7GRtQH2N/nEmT2dLICUB
         Vq61RlhrgkXTMxPCD4xQyoXKsbXB5BksvPSKdWw6O1a70ouZffclCsRUVPkaSA7brb7G
         gkJuvgz7K9M3Qpv31rJqfTAAI8ovHMdG0OwqJ/qpJ8lO/giMSMRGp3b05xiTZw2Ehrg6
         rEkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f12si1936346qvh.98.2019.03.08.00.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 00:50:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6D5C788306;
	Fri,  8 Mar 2019 08:50:48 +0000 (UTC)
Received: from [10.72.12.27] (ovpn-12-27.pek2.redhat.com [10.72.12.27])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BD200611DF;
	Fri,  8 Mar 2019 08:50:37 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: Andrea Arcangeli <aarcange@redhat.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, Jerome Glisse <jglisse@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
Date: Fri, 8 Mar 2019 16:50:36 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190307191622.GP23850@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 08 Mar 2019 08:50:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/8 上午3:16, Andrea Arcangeli wrote:
> On Thu, Mar 07, 2019 at 12:56:45PM -0500, Michael S. Tsirkin wrote:
>> On Thu, Mar 07, 2019 at 10:47:22AM -0500, Michael S. Tsirkin wrote:
>>> On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
>>>> +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
>>>> +	.invalidate_range = vhost_invalidate_range,
>>>> +};
>>>> +
>>>>   void vhost_dev_init(struct vhost_dev *dev,
>>>>   		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
>>>>   {
>>> I also wonder here: when page is write protected then
>>> it does not look like .invalidate_range is invoked.
>>>
>>> E.g. mm/ksm.c calls
>>>
>>> mmu_notifier_invalidate_range_start and
>>> mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.
>>>
>>> Similarly, rmap in page_mkclean_one will not call
>>> mmu_notifier_invalidate_range.
>>>
>>> If I'm right vhost won't get notified when page is write-protected since you
>>> didn't install start/end notifiers. Note that end notifier can be called
>>> with page locked, so it's not as straight-forward as just adding a call.
>>> Writing into a write-protected page isn't a good idea.
>>>
>>> Note that documentation says:
>>> 	it is fine to delay the mmu_notifier_invalidate_range
>>> 	call to mmu_notifier_invalidate_range_end() outside the page table lock.
>>> implying it's called just later.
>> OK I missed the fact that _end actually calls
>> mmu_notifier_invalidate_range internally. So that part is fine but the
>> fact that you are trying to take page lock under VQ mutex and take same
>> mutex within notifier probably means it's broken for ksm and rmap at
>> least since these call invalidate with lock taken.
> Yes this lock inversion needs more thoughts.
>
>> And generally, Andrea told me offline one can not take mutex under
>> the notifier callback. I CC'd Andrea for why.
> Yes, the problem then is the ->invalidate_page is called then under PT
> lock so it cannot take mutex, you also cannot take the page_lock, it
> can at most take a spinlock or trylock_page.
>
> So it must switch back to the _start/_end methods unless you rewrite
> the locking.
>
> The difference with _start/_end, is that ->invalidate_range avoids the
> _start callback basically, but to avoid the _start callback safely, it
> has to be called in between the ptep_clear_flush and the set_pte_at
> whenever the pfn changes like during a COW. So it cannot be coalesced
> in a single TLB flush that invalidates all sptes in a range like we
> prefer for performance reasons for example in KVM. It also cannot
> sleep.
>
> In short ->invalidate_range must be really fast (it shouldn't require
> to send IPI to all other CPUs like KVM may require during an
> invalidate_range_start) and it must not sleep, in order to prefer it
> to _start/_end.
>
> I.e. the invalidate of the secondary MMU that walks the linux
> pagetables in hardware (in vhost case with GUP in software) has to
> happen while the linux pagetable is zero, otherwise a concurrent
> hardware pagetable lookup could re-instantiate a mapping to the old
> page in between the set_pte_at and the invalidate_range_end (which
> internally calls ->invalidate_range). Jerome documented it nicely in
> Documentation/vm/mmu_notifier.rst .


Right, I've actually gone through this several times but some details 
were missed by me obviously.


>
> Now you don't really walk the pagetable in hardware in vhost, but if
> you use gup_fast after usemm() it's similar.
>
> For vhost the invalidate would be really fast, there are no IPI to
> deliver at all, the problem is just the mutex.


Yes. A possible solution is to introduce a valid flag for VA. Vhost may 
only try to access kernel VA when it was valid. Invalidate_range_start() 
will clear this under the protection of the vq mutex when it can block. 
Then invalidate_range_end() then can clear this flag. An issue is 
blockable is  always false for range_end().


>
>> That's a separate issue from set_page_dirty when memory is file backed.
> Yes. I don't yet know why the ext4 internal __writepage cannot
> re-create the bh if they've been freed by the VM and why such race
> where the bh are freed for a pinned VM_SHARED ext4 page doesn't even
> exist for transient pins like O_DIRECT (does it work by luck?), but
> with mmu notifiers there are no long term pins anyway, so this works
> normally and it's like the memory isn't pinned. In any case I think
> that's a kernel bug in either __writepage or try_to_free_buffers, so I
> would ignore it considering qemu will only use anon memory or tmpfs or
> hugetlbfs as backing store for the virtio ring. It wouldn't make sense
> for qemu to risk triggering I/O on a VM_SHARED ext4, so we shouldn't
> be even exposed to what seems to be an orthogonal kernel bug.
>
> I suppose whatever solution will fix the set_page_dirty_lock on
> VM_SHARED ext4 for the other places that don't or can't use mmu
> notifiers, will then work for vhost too which uses mmu notifiers and
> will be less affected from the start if something.
>
> Reading the lwn link about the discussion about the long term GUP pin
> from Jan vs set_page_dirty_lock: I can only agree with the last part
> where Jerome correctly pointed out at the end that mellanox RDMA got
> it right by avoiding completely long term pins by using mmu notifier
> and in general mmu notifier is the standard solution to avoid long
> term pins. Nothing should ever take long term GUP pins, if it does it
> means software is bad or the hardware lacks features to support on
> demand paging. Still I don't get why transient pins like O_DIRECT
> where mmu notifier would be prohibitive to use (registering into mmu
> notifier cannot be done at high frequency, the locking to do so is
> massive) cannot end up into the same ext4 _writepage crash as long
> term pins: long term or short term transient is a subjective measure
> from VM standpoint, the VM won't know the difference, luck will
> instead.
>
>> It's because of all these issues that I preferred just accessing
>> userspace memory and handling faults. Unfortunately there does not
>> appear to exist an API that whitelists a specific driver along the lines
>> of "I checked this code for speculative info leaks, don't add barriers
>> on data path please".
> Yes that's unfortunate, __uaccess_begin_nospec() is now making
> prohibitive to frequently access userland code.
>
> I doubt we can do like access_ok() and only check it once. access_ok
> checks the virtual address, and if the virtual address is ok doesn't
> wrap around and it points to userland in a safe range, it's always
> ok. There's no need to run access_ok again if we keep hitting on the
> very same address.
>
> __uaccess_begin_nospec() instead is about runtime stuff that can
> change the moment copy-user has completed even before returning to
> userland, so there's no easy way to do it just once.
>
> On top of skipping the __uaccess_begin_nospec(), the mmu notifier soft
> vhost design will further boost the performance by guaranteeing the
> use of gigapages TLBs when available (or 2M TLBs worst case) even if
> QEMU runs on smaller pages.


Just to make sure I understand here. For boosting through huge TLB, do 
you mean we can do that in the future (e.g by mapping more userspace 
pages to kenrel) or it can be done by this series (only about three 4K 
pages were vmapped per virtqueue)?

Thanks


>
> Thanks,
> Andrea

