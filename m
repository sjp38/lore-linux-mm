Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47594C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 05:22:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10B6E21F26
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 05:22:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10B6E21F26
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 856F96B0003; Mon, 22 Jul 2019 01:22:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8084C8E0001; Mon, 22 Jul 2019 01:22:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F5296B0007; Mon, 22 Jul 2019 01:22:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E61E6B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:22:19 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id m25so34520809qtn.18
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 22:22:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=DuZVFkrEDjFPPHoOg9j7vJ00Sgrkx8nLFXFg17OSjj8=;
        b=SUxIWuAAmiWfkISc8JBIfoyjd3/xGeSwSt5Js/swJtvLSuxSSdBceF+i5HkZN6AhMW
         wB6vm8Umj3/Sk5zAnLnQWo+pQqsSZnQvKiKCIdon2cuR1SVtC4VSahnEwC0VOmn1aiDv
         KQT6d8Fqyg+lL0Bbats5g60T52qo7lVwJok/Rgf4hKrXJWzcW3BZ22kHwvB0SJxeR1zg
         uiMtb1IzL4EyzHbJVl+8r/5+NwN9/vCGJo4XYYpaaeJKzd3Mgj6qtaCejhPpAA0P/uEB
         gahze3qXcvGBcggPNjSmr9HrjDabs14/cS7Tgv+nZ/MoN5o0SQ8Q2lyObXi0g4N+5gxW
         W3tw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUJvJMYpL5nwKSClIkaJAbfoNvA6tQo/Fs59ME2N1VhGp5Iitpc
	euwhho97Uj988BzHgaH8LKblKa4aVG5X5Is68DW0lvr0ZAr3a2BSQ4SfWkiYqXlW+NDMWBSXzrB
	Fbn5oO9MC8aruIQ8rh50qalgqLio7dyzYsZitpQvq/zTexqqu0EJ7ho4VSfnj1dnF1w==
X-Received: by 2002:ac8:2bd4:: with SMTP id n20mr48990576qtn.131.1563772939001;
        Sun, 21 Jul 2019 22:22:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOoDNwLBVmS6/FZC8ZM4a+t8fPTTQ2HFLpLhw1yhiSQdO01KFFqj+SYpDYbsxyoepHNt44
X-Received: by 2002:ac8:2bd4:: with SMTP id n20mr48990549qtn.131.1563772938125;
        Sun, 21 Jul 2019 22:22:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563772938; cv=none;
        d=google.com; s=arc-20160816;
        b=jUa3aDxa+Wjk3VTfX3+H6hmHlMi4lEISDMdbPgGIWi1538q3ADGAAKqrGgid3FQs0h
         Rx5c63512mo/TL4gDMdp26trFRn2/134YPmNGztMQslBL6UXm6A7v1xo1rcJAnB4mgoi
         e+9aGpRqSNxdyH0ynJitJXrnKKrwYrXh/oGX+Po9l5+f0gOXHjtjdQ9785jSk4yrHvg1
         cLRlPFtQxaDam3UoO6pbadj77JTESuZ6WUfpjWlErAKoFdBbcgRd7ZYoHOZo0RCBi98D
         Cxiq0lDRkj3Q86hck3sQT0iFVdfvP1bUFjHth7MCgAhuR8C1Wy2meRdFtQkYDQwM+g90
         lz3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DuZVFkrEDjFPPHoOg9j7vJ00Sgrkx8nLFXFg17OSjj8=;
        b=zgmAEOgq4yuFBa2bFdAuGlBhLbmBMTXo4GjHoxSPze2eUPtDi8A3b8hEy6aUHNH5zj
         w9Th74aDjuusTCO60LDOHyTfWChklzYBDDiTRJXUxXL11bTX3NoPNSM+Uss+mgc+s1Zk
         YPiCUVE7G9avcszGvVv/v4uqjqh8YzrFM1kvBtlW1uYmnmjWRdjhLkZe688wyXl8heJd
         xIHC5G/VmUP5SXB4F3n6tvthG6+XOqWaINYvALcZvGMoPqmIeMpUThuXHOHNtozy4LWh
         03E7/WCywfbED1iPfNuw2OcyVxfHpk2bhS5MO7ARpJwLM3S5UtPchG9ev9W3G+tRKtCI
         NPZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w49si25949028qta.277.2019.07.21.22.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 22:22:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 911E9335CF;
	Mon, 22 Jul 2019 05:22:16 +0000 (UTC)
Received: from [10.72.12.30] (ovpn-12-30.pek2.redhat.com [10.72.12.30])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B99D65DA2E;
	Mon, 22 Jul 2019 05:22:03 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>,
 syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
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
From: Jason Wang <jasowang@redhat.com>
Message-ID: <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
Date: Mon, 22 Jul 2019 13:21:59 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190721044615-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 22 Jul 2019 05:22:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>> syzbot has bisected this bug to:
>>
>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>> Author: Jason Wang <jasowang@redhat.com>
>> Date:   Fri May 24 08:12:18 2019 +0000
>>
>>      vhost: access vq metadata through kernel virtual address
>>
>> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>> start commit:   6d21a41b Add linux-next specific files for 20190718
>> git tree:       linux-next
>> final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>> console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>> dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>
>> Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>> address")
>>
>> For information about bisection process see: https://goo.gl/tpsmEJ#bisection
>
> OK I poked at this for a bit, I see several things that
> we need to fix, though I'm not yet sure it's the reason for
> the failures:
>
>
> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>     That's just a bad hack,


This is used to avoid holding lock when checking whether the addresses 
are overlapped. Otherwise we need to take spinlock for each invalidation 
request even if it was the va range that is not interested for us. This 
will be very slow e.g during guest boot.


>   in particular I don't think device
>     mutex is taken and so poking at two VQs will corrupt
>     memory.


The caller vhost_net_ioctl() (or scsi and vsock) will hold device mutex 
before calling us.


>     So what to do? How about a per vq notifier?
>     Of course we also have synchronize_rcu
>     in the notifier which is slow and is now going to be called twice.
>     I think call_rcu would be more appropriate here.
>     We then need rcu_barrier on module unload.


So this seems unnecessary.


>     OTOH if we make pages linear with map then we are good
>     with kfree_rcu which is even nicer.


It could be an optimization on top.


>
> 2. Doesn't map leak after vhost_map_unprefetch?
>     And why does it poke at contents of the map?
>     No one should use it right?


Yes, it's not hard to fix just kfree map in this function.


>
> 3. notifier unregister happens last in vhost_dev_cleanup,
>     but register happens first. This looks wrong to me.


I'm not sure I get the the exact issue here.


>
> 4. OK so we use the invalidate count to try and detect that
>     some invalidate is in progress.
>     I am not 100% sure why do we care.
>     Assuming we do, uaddr can change between start and end
>     and then the counter can get negative, or generally
>     out of sync.


Yes, so the fix is as simple as zero the invalidate_count after 
unregister  the mmu notifier in vhost_set_vring_num_addr().


>
> So what to do about all this?
> I am inclined to say let's just drop the uaddr optimization
> for now. E.g. kvm invalidates unconditionally.
> 3 should be fixed independently.


Maybe it's better to try to fix with the exist uaddr optimization first.

I did spot two other issues:

1) we don't check the return value mmu_register in vhost_set_vring_num()

2) we try to setup vq address even if set_vring_addr() fail


For the bug it self, it looks to me that the mm refcount was messed up 
since we try to register and unregister MMU notifier. But I haven't 
figured out why, will do more investigation.

Thanks


>
>

