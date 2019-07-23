Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F3BFC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:47:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3654B2239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:47:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3654B2239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C7B56B0003; Tue, 23 Jul 2019 01:47:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 878DF8E0003; Tue, 23 Jul 2019 01:47:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 767FD8E0001; Tue, 23 Jul 2019 01:47:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51D2D6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:47:20 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r200so35563547qke.19
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:47:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=QllcjTl7UsRk7hsG5EpIrv0If2dJcd9NYiph16M9jnM=;
        b=HviJO2+gyy9LAkbBuSbZOPiGC/FMgaMtmDY6BUEMizPqaMlakuRfqkBoZvrndkIcZm
         5heDZ533C54ibaTcaOXkJD/cF/KGsfL3VNGEZqv47Bym0lE0e31eAFgGnY8bKMyymHaR
         AhAahY2PP3qx1j5ekMWEOXLd9ShD99EXh0Xw3c46D3EkTWY52uWArElJo3kXAjsF8dew
         JSagsVkLddtonhrPYVdet3Vghr6+YNJ3OKfQgH7wEp/irZuewJ1K9cYvYFOvHvDx8UfI
         2cW4pAs3xn4K+gD1HsX58V8Ub3ZGFnoHkATAtUTAXjHG4MdFS65XLrpD2ZEmN/No8nkM
         GfwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWWW2mYkWiUCFnaOwSIkJgyq21CXd8DKZ30bzH4i/mN+iqNjQ3T
	HdT7FAW1r6P4ViAyIsoKXpSpcqs9+jicg7HLZOSLvEkeqkKLOnK22eSTmXrG6ROBi6kqSxs548D
	82qBuirXMd76NmPyd1oOc1ulQDs4p0903FG5Wk4I6UGIZucexE5zhaiIGKjjOqpcDnQ==
X-Received: by 2002:a0c:984a:: with SMTP id e10mr53012797qvd.57.1563860840053;
        Mon, 22 Jul 2019 22:47:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyORC0WqbERyaPeFe2TGR2Swr0KGTct0ZvdfCqSAKtAI22rlL3S2vkVsg9jXW7O51TVPig/
X-Received: by 2002:a0c:984a:: with SMTP id e10mr53012758qvd.57.1563860839117;
        Mon, 22 Jul 2019 22:47:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563860839; cv=none;
        d=google.com; s=arc-20160816;
        b=VD/KYL7UblpLhxZBioF2HSny+JFF+ADiTZzNKIq2oKKwP3vjYgtpL7YoyLsLb7QfKv
         ak2VXX3b/fP2aNRA6GUKcsdKK3sl0u9WsrfffoHPLPDh+K7KkRPy9T1N8El8FneS17MR
         Kh8rxXxPBM9UUEMFWmaZkj7F4lhuNGC2YcUHw/4zyikw9gvrOw4i59DE7GjG6Kaw870e
         rqxuzcOeWdpzwjSrg9RrTAgoQ8W+6AuBi0S6Hm7u32dnsqN9ydwwFggORhHom2LDEoAZ
         mdYJMB3iFANFEEuTmwkMe5zD7Eb8ceZu/1wyYRNsSehkLfjrrq/zK6Mz8ouvcnqOjrRj
         bEZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QllcjTl7UsRk7hsG5EpIrv0If2dJcd9NYiph16M9jnM=;
        b=ezQl3PQUiNy+EmCyPvLRxZ5tvVGA6to9Zh1YqFMIt/E1/7AOLRDLNuUjCoWRuJD2Eo
         DMPBASczOwk3KOrXjwBUaKfESs3RQ6mE/n4mJ6aDwH8pkxXUabxxXNIYH7OltWrtqDau
         ZFSDLlADP+kE/bwyEOIvi9hWwwWQHRpujWg75D3KNoxOt+a00rPfLxGx727DCEp2BQVg
         8uRYZsT01AnGSxGz8cgEZEfDZPmPduEEuA8MC3RDhyfAAEWz2Dgxh4uVAYp4Htd6dF8D
         VrTyLXFmnjY/8lVE8ZLcPiI7S89Vxc1OZYYFuou8J2Yz5BtElcAhJWzrm5MyJfRmwi00
         PgPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si8536045qta.391.2019.07.22.22.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:47:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B380E30862BE;
	Tue, 23 Jul 2019 05:47:17 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C08CE5D9C5;
	Tue, 23 Jul 2019 05:47:04 +0000 (UTC)
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
 <20190721081447-mutt-send-email-mst@kernel.org>
 <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
 <20190722040230-mutt-send-email-mst@kernel.org>
 <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
 <20190723010019-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
Date: Tue, 23 Jul 2019 13:47:04 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723010019-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 23 Jul 2019 05:47:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午1:01, Michael S. Tsirkin wrote:
> On Tue, Jul 23, 2019 at 12:01:40PM +0800, Jason Wang wrote:
>> On 2019/7/22 下午4:08, Michael S. Tsirkin wrote:
>>> On Mon, Jul 22, 2019 at 01:24:24PM +0800, Jason Wang wrote:
>>>> On 2019/7/21 下午8:18, Michael S. Tsirkin wrote:
>>>>> On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
>>>>>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>>>>>> syzbot has bisected this bug to:
>>>>>>>
>>>>>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>>>>>> Author: Jason Wang<jasowang@redhat.com>
>>>>>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>>>>>
>>>>>>>        vhost: access vq metadata through kernel virtual address
>>>>>>>
>>>>>>> bisection log:https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>>>>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>>>>>> git tree:       linux-next
>>>>>>> final crash:https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>>>>>> console output:https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>>>>>> kernel config:https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>>>>>> dashboard link:https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>>>>>> syz repro:https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>>>>>
>>>>>>> Reported-by:syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>>>>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>>>>>> address")
>>>>>>>
>>>>>>> For information about bisection process see:https://goo.gl/tpsmEJ#bisection
>>>>>> OK I poked at this for a bit, I see several things that
>>>>>> we need to fix, though I'm not yet sure it's the reason for
>>>>>> the failures:
>>>>>>
>>>>>>
>>>>>> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>>>>>>       That's just a bad hack, in particular I don't think device
>>>>>>       mutex is taken and so poking at two VQs will corrupt
>>>>>>       memory.
>>>>>>       So what to do? How about a per vq notifier?
>>>>>>       Of course we also have synchronize_rcu
>>>>>>       in the notifier which is slow and is now going to be called twice.
>>>>>>       I think call_rcu would be more appropriate here.
>>>>>>       We then need rcu_barrier on module unload.
>>>>>>       OTOH if we make pages linear with map then we are good
>>>>>>       with kfree_rcu which is even nicer.
>>>>>>
>>>>>> 2. Doesn't map leak after vhost_map_unprefetch?
>>>>>>       And why does it poke at contents of the map?
>>>>>>       No one should use it right?
>>>>>>
>>>>>> 3. notifier unregister happens last in vhost_dev_cleanup,
>>>>>>       but register happens first. This looks wrong to me.
>>>>>>
>>>>>> 4. OK so we use the invalidate count to try and detect that
>>>>>>       some invalidate is in progress.
>>>>>>       I am not 100% sure why do we care.
>>>>>>       Assuming we do, uaddr can change between start and end
>>>>>>       and then the counter can get negative, or generally
>>>>>>       out of sync.
>>>>>>
>>>>>> So what to do about all this?
>>>>>> I am inclined to say let's just drop the uaddr optimization
>>>>>> for now. E.g. kvm invalidates unconditionally.
>>>>>> 3 should be fixed independently.
>>>>> Above implements this but is only build-tested.
>>>>> Jason, pls take a look. If you like the approach feel
>>>>> free to take it from here.
>>>>>
>>>>> One thing the below does not have is any kind of rate-limiting.
>>>>> Given it's so easy to restart I'm thinking it makes sense
>>>>> to add a generic infrastructure for this.
>>>>> Can be a separate patch I guess.
>>>> I don't get why must use kfree_rcu() instead of synchronize_rcu() here.
>>> synchronize_rcu has very high latency on busy systems.
>>> It is not something that should be used on a syscall path.
>>> KVM had to switch to SRCU to keep it sane.
>>> Otherwise one guest can trivially slow down another one.
>>
>> I think you mean the synchronize_rcu_expedited()? Rethink of the code, the
>> synchronize_rcu() in ioctl() could be removed, since it was serialized with
>> memory accessor.
>
> Really let's just use kfree_rcu. It's way cleaner: fire and forget.


Looks not, you need rate limit the fire as you've figured out? And in 
fact, the synchronization is not even needed, does it help if I leave a 
comment to explain?


>
>> Btw, for kvm ioctl it still uses synchronize_rcu() in kvm_vcpu_ioctl(),
>> (just a little bit more hard to trigger):
>
> AFAIK these never run in response to guest events.
> So they can take very long and guests still won't crash.


What if guest manages to escape to qemu?

Thanks


>
>
>>      case KVM_RUN: {
>> ...
>>          if (unlikely(oldpid != task_pid(current))) {
>>              /* The thread running this VCPU changed. */
>>              struct pid *newpid;
>>
>>              r = kvm_arch_vcpu_run_pid_change(vcpu);
>>              if (r)
>>                  break;
>>
>>              newpid = get_task_pid(current, PIDTYPE_PID);
>>              rcu_assign_pointer(vcpu->pid, newpid);
>>              if (oldpid)
>>                  synchronize_rcu();
>>              put_pid(oldpid);
>>          }
>> ...
>>          break;
>>
>>
>>>>> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
>>>> Let me try to figure out the root cause then decide whether or not to go for
>>>> this way.
>>>>
>>>> Thanks
>>> The root cause of the crash is relevant, but we still need
>>> to fix issues 1-4.
>>>
>>> More issues (my patch tries to fix them too):
>>>
>>> 5. page not dirtied when mappings are torn down outside
>>>      of invalidate callback
>>
>> Yes.
>>
>>
>>> 6. potential cross-VM DOS by one guest keeping system busy
>>>      and increasing synchronize_rcu latency to the point where
>>>      another guest stars timing out and crashes
>>>
>>>
>>>
>> This will be addressed after I remove the synchronize_rcu() from ioctl path.
>>
>> Thanks

