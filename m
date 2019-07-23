Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07CB6C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:42:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F4352253E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:42:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F4352253E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22B386B000A; Tue, 23 Jul 2019 04:42:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DB268E0003; Tue, 23 Jul 2019 04:42:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CA5F8E0002; Tue, 23 Jul 2019 04:42:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2E016B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:42:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so37799802qte.8
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:42:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=uGGixrVX39bMz6z2pl330D6fM43fnXqlK5xcSlglNq0=;
        b=gtDKBhiCDjXoTtxliPs32aSdoylLlYJUrcpKV93JwEgrojIYVAM4aQ37VtFUHNt15i
         ra6lI0UvOVN9A8Y4JzuhG7MG15na057Oe69/0+R+D/hHmL6Pt1wZSACQzOdnqmc4Skqe
         sj6f5+RoS7CwFhtCmVPHNPvs/tLjCIRpkka7wJ/dBvwbZc50Erg5JS/+N6cUJECjIMkR
         vX4IkjbXkVWeEUQMU5nYRh4PGYZjz/h2IkJbqn8qvH/90pfZaLrMn+UQJGDPlk5rXSj9
         bgg3egCvTFtIo1suA83V0KBzEgSeFXVHk78GJtJz9HFCE+VDAqXs/nw6c6vlxJc6I+Ho
         UIuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUwqee0jq2pPPHVnHy/0A50T1EXgSWBNixWgSpudBoGR7HdE5WY
	dYCuWF4tkME5gDzrhS3KCJrA21htYX7l7JZzWdDOhlTzKryhlZdRb2WvZPj30Oyn89P27K9jew0
	OaJExawbW7BnxcWE02EW8IBj9HpMYO6CRMR5tjAFD2a5VujXcgOV6LXjmg+RLykhMXg==
X-Received: by 2002:a05:620a:166a:: with SMTP id d10mr46782525qko.195.1563871352670;
        Tue, 23 Jul 2019 01:42:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTQCQ9cAZMDJ0tgl2NndXA1j1L2XsoUIYAlEnoyrI0wsQN26jDlSppVbcqHKzWo6+tL4HE
X-Received: by 2002:a05:620a:166a:: with SMTP id d10mr46782494qko.195.1563871351844;
        Tue, 23 Jul 2019 01:42:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563871351; cv=none;
        d=google.com; s=arc-20160816;
        b=cjcMh+2Q793+bpYIZOO6Qnu5NYeKkVFBCwpJVoX/S8atG+5W4/RWxR9lYBkIULmA9p
         CiFed0O1whwhBXBkID0fS3v0MQoP04tVQWygQPqrfa4gukjl3QkBT0njeVPnJFeakbJK
         RGvVkduuLepYLRrzztFTl4YbskZ0msXrU+j3pOOcqBy9Z7u9g2viUKpeQ1wFulA8dEVN
         vQy7D0KeU1biGY+cRfMa3L+pjrnplYrfeuXxPUfc4+G756h3H70h6FvSat19EPeQnCTd
         n+dnRzZVdtooCmc6Syp8/w1gwiO2hGPORT5Lyutf79DP96rAY/SUQKtSVnIhRP/mBChX
         7ALg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uGGixrVX39bMz6z2pl330D6fM43fnXqlK5xcSlglNq0=;
        b=QTedPWQ6GFPeZu/z0W/6gIlhYd/tJK3Ct/QqzABkIMaj5ICaQmRmzo2GVWj8Jf3NFA
         IvSyGST6Stbr4O5p5yFTcurjFsln/ACENCttWPxlxaD+XScdLWYJfKKioFDQvDpsD8GW
         k8kvY4qtKVxPG3csMgg7yymPkPMK6tspMeSioz4FXH40uepX0RNzUohQQyipO1ygfVqj
         cmSOcH/C8Hby3JxY8osRkKA6KKfhDXEZtdObhdn24EqoAlDH6pHD8kRBY5Ii7B9k66+4
         iRUf78YBE2WSB8JEodGSQ2ZNoKvkSPDpW+D6eTiijhSxbeaRqmxrennldxVb+6/Rveqc
         o8Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q20si27083744qke.380.2019.07.23.01.42.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 01:42:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A801B59455;
	Tue, 23 Jul 2019 08:42:30 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BA57B608A5;
	Tue, 23 Jul 2019 08:42:18 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
Date: Tue, 23 Jul 2019 16:42:19 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723032800-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 23 Jul 2019 08:42:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午3:56, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 01:48:52PM +0800, Jason Wang wrote:
>> On 2019/7/23 下午1:02, Michael S. Tsirkin wrote:
>>> On Tue, Jul 23, 2019 at 11:55:28AM +0800, Jason Wang wrote:
>>>> On 2019/7/22 下午4:02, Michael S. Tsirkin wrote:
>>>>> On Mon, Jul 22, 2019 at 01:21:59PM +0800, Jason Wang wrote:
>>>>>> On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
>>>>>>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>>>>>>> syzbot has bisected this bug to:
>>>>>>>>
>>>>>>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>>>>>>> Author: Jason Wang <jasowang@redhat.com>
>>>>>>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>>>>>>
>>>>>>>>         vhost: access vq metadata through kernel virtual address
>>>>>>>>
>>>>>>>> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>>>>>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>>>>>>> git tree:       linux-next
>>>>>>>> final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>>>>>>> console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>>>>>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>>>>>>> dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>>>>>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>>>>>>
>>>>>>>> Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>>>>>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>>>>>>> address")
>>>>>>>>
>>>>>>>> For information about bisection process see: https://goo.gl/tpsmEJ#bisection
>>>>>>> OK I poked at this for a bit, I see several things that
>>>>>>> we need to fix, though I'm not yet sure it's the reason for
>>>>>>> the failures:
>>>>>>>
>>>>>>>
>>>>>>> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>>>>>>>        That's just a bad hack,
>>>>>> This is used to avoid holding lock when checking whether the addresses are
>>>>>> overlapped. Otherwise we need to take spinlock for each invalidation request
>>>>>> even if it was the va range that is not interested for us. This will be very
>>>>>> slow e.g during guest boot.
>>>>> KVM seems to do exactly that.
>>>>> I tried and guest does not seem to boot any slower.
>>>>> Do you observe any slowdown?
>>>> Yes I do.
>>>>
>>>>
>>>>> Now I took a hard look at the uaddr hackery it really makes
>>>>> me nervious. So I think for this release we want something
>>>>> safe, and optimizations on top. As an alternative revert the
>>>>> optimization and try again for next merge window.
>>>> Will post a series of fixes, let me know if you're ok with that.
>>>>
>>>> Thanks
>>> I'd prefer you to take a hard look at the patch I posted
>>> which makes code cleaner,
>>
>> I did. But it looks to me a series that is only about 60 lines of code can
>> fix all the issues we found without reverting the uaddr optimization.
> Another thing I like about the patch I posted is that
> it removes 60 lines of code, instead of adding more :)
> Mostly because of unifying everything into
> a single cleanup function and using kfree_rcu.


Yes.


>
> So how about this: do exactly what you propose but as a 2 patch series:
> start with the slow safe patch, and add then return uaddr optimizations
> on top. We can then more easily reason about whether they are safe.


If you stick, I can do this.


> Basically you are saying this:
> 	- notifiers are only needed to invalidate maps
> 	- we make sure any uaddr change invalidates maps anyway
> 	- thus it's ok not to have notifiers since we do
> 	  not have maps
>
> All this looks ok but the question is why do we
> bother unregistering them. And the answer seems to
> be that this is so we can start with a balanced
> counter: otherwise we can be between _start and
> _end calls.


Yes, since there could be multiple co-current invalidation requests. We 
need count them to make sure we don't pin wrong pages.


>
> I also wonder about ordering. kvm has this:
>         /*
>           * Used to check for invalidations in progress, of the pfn that is
>           * returned by pfn_to_pfn_prot below.
>           */
>          mmu_seq = kvm->mmu_notifier_seq;
>          /*
>           * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
>           * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
>           * risk the page we get a reference to getting unmapped before we have a
>           * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
>           *
>           * This smp_rmb() pairs with the effective smp_wmb() of the combination
>           * of the pte_unmap_unlock() after the PTE is zapped, and the
>           * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
>           * mmu_notifier_seq is incremented.
>           */
>          smp_rmb();
>
> does this apply to us? Can't we use a seqlock instead so we do
> not need to worry?


I'm not familiar with kvm MMU internals, but we do everything under of 
mmu_lock.

Thanks


