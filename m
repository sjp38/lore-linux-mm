Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47C67C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 04:02:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2C3F218EA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 04:02:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2C3F218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82BCC6B0003; Tue, 23 Jul 2019 00:02:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DD056B0005; Tue, 23 Jul 2019 00:02:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A5568E0001; Tue, 23 Jul 2019 00:02:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9726B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 00:02:01 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t196so35369621qke.0
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 21:02:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=2hMD4/TgU7pGT+iVMVMzFsdXzXnRzL9cUDugW2NOgfY=;
        b=bN+1NDwZfID0EKBpifOcoE2q2Fy8JkgMLVyfvUb/0oLiZNS3979rgnhbZ3Q+B6XmGQ
         A4PnCc2rlMGJodaHCK1xbb+fa+nlfO/4XRCjZNBaSvHt0YrCCs49SGfGTwpG1aXFFN4K
         QMfZz5sZsBg22kECNVuNfC6ca/8+W5M9sWIwe0TE4lfMHRLhA4KDdT3J+PLX9plFWG4E
         rAL1m3dCftL/Q0esJ+ZkID0dKr0e/uBm5W38d4vdS8zx+QNnVk/2BS7uol3z3H2Wzo9o
         ekWRHJ8+IF1GM5Z9zrIEHagyZxgbzvn03Vf/tU45EGB4a1Qe9Ev6h8bGSEXsHAUwgrU6
         Pujw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXxGt0PosgRtLFu+X+rHQ/4VgurTwooWIMvivSPtmep3N7PDD/R
	+NMGAml3FcLelliNdwVCgEQV29FovmDMks4stWA3sWE/sh9a53OJl0RHVD/sxfaEL00EZiGsGVe
	5XKrNtTI5tw9pQot54j7HcMAw9kSXea+1LqAC3CsUJjUtWBLrhYwH9ZDK20+SKOv5Uw==
X-Received: by 2002:a05:6214:2b0:: with SMTP id m16mr52948468qvv.23.1563854520922;
        Mon, 22 Jul 2019 21:02:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy87c7PgE5EIZ/rxVd7DCeH7Ck1g3NcAYfe3rVfvBTZFVufkY1KznQRH76MYTX17tP+6gV4
X-Received: by 2002:a05:6214:2b0:: with SMTP id m16mr52948417qvv.23.1563854519960;
        Mon, 22 Jul 2019 21:01:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563854519; cv=none;
        d=google.com; s=arc-20160816;
        b=jdsuLbZugXcVdmmpnu2vSIe0U6h0VO0gNwEfxSywrywHw0ksKo9hO16LlYLqHC0esS
         1pvHcHgk7g0Deb6kCxKtWSY3C6zywLQKEV4Jr4ft9kb2Ih/1/+InwCRtlxsfNsFTf0IH
         uYF0fzowYkp+idWos4hCzpNh3ROzXL1GDSGc55He3vI/Ko+q6nkt/KbRs5hlfIXHYldZ
         q7Cn591KYDWdI1nXn7Ir+UvCkd5byzAlqZ/MPMscdQVWem1fEyzsFHCiqudeUPQ12iry
         Wq6ngurUGMnlWFgiJ5PLaQrere24sakXjT7j6dr80fBs0mBj8w5n23sbYwgCBX57IBDp
         bEsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2hMD4/TgU7pGT+iVMVMzFsdXzXnRzL9cUDugW2NOgfY=;
        b=jN+MMCvB2AZbxTEs2J1BitL9mfrhA4IbABPVV1megaW8KDEdwl63asui+cn3Rpo+YD
         DxJ2KJGeSioFhMUcRkVAzcnxOrC4hf2tDG8k1JPMJU44+sV4vT3GN8Ggwnr/BuVSLjSJ
         YMX3PAmVgScu7ppwxadYjMHTnRFfnsb8Db+kYI51aEHgVez6wlFABYmbXHtz1KMtdKCs
         aEqY/YqsQzboTitanYpnjZmu1cpHhqehwfF0m1hxKV0YCw8fvv/VA1mFllZGfYR1EIez
         i8mbSOk7Vqf7RJFUn6RAYHNgiIyXfztwQPNwOrBSstj/uzQaXBDcdKq2jy9GNrApqBUb
         L9qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h71si27003602qke.354.2019.07.22.21.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 21:01:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9871C308FBB1;
	Tue, 23 Jul 2019 04:01:58 +0000 (UTC)
Received: from [10.72.12.57] (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D8ABF60BEC;
	Tue, 23 Jul 2019 04:01:42 +0000 (UTC)
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
From: Jason Wang <jasowang@redhat.com>
Message-ID: <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
Date: Tue, 23 Jul 2019 12:01:40 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190722040230-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Tue, 23 Jul 2019 04:01:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/22 下午4:08, Michael S. Tsirkin wrote:
> On Mon, Jul 22, 2019 at 01:24:24PM +0800, Jason Wang wrote:
>> On 2019/7/21 下午8:18, Michael S. Tsirkin wrote:
>>> On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
>>>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>>>> syzbot has bisected this bug to:
>>>>>
>>>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>>>> Author: Jason Wang<jasowang@redhat.com>
>>>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>>>
>>>>>       vhost: access vq metadata through kernel virtual address
>>>>>
>>>>> bisection log:https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>>>> git tree:       linux-next
>>>>> final crash:https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>>>> console output:https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>>>> kernel config:https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>>>> dashboard link:https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>>>> syz repro:https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>>>
>>>>> Reported-by:syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>>>> address")
>>>>>
>>>>> For information about bisection process see:https://goo.gl/tpsmEJ#bisection
>>>> OK I poked at this for a bit, I see several things that
>>>> we need to fix, though I'm not yet sure it's the reason for
>>>> the failures:
>>>>
>>>>
>>>> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>>>>      That's just a bad hack, in particular I don't think device
>>>>      mutex is taken and so poking at two VQs will corrupt
>>>>      memory.
>>>>      So what to do? How about a per vq notifier?
>>>>      Of course we also have synchronize_rcu
>>>>      in the notifier which is slow and is now going to be called twice.
>>>>      I think call_rcu would be more appropriate here.
>>>>      We then need rcu_barrier on module unload.
>>>>      OTOH if we make pages linear with map then we are good
>>>>      with kfree_rcu which is even nicer.
>>>>
>>>> 2. Doesn't map leak after vhost_map_unprefetch?
>>>>      And why does it poke at contents of the map?
>>>>      No one should use it right?
>>>>
>>>> 3. notifier unregister happens last in vhost_dev_cleanup,
>>>>      but register happens first. This looks wrong to me.
>>>>
>>>> 4. OK so we use the invalidate count to try and detect that
>>>>      some invalidate is in progress.
>>>>      I am not 100% sure why do we care.
>>>>      Assuming we do, uaddr can change between start and end
>>>>      and then the counter can get negative, or generally
>>>>      out of sync.
>>>>
>>>> So what to do about all this?
>>>> I am inclined to say let's just drop the uaddr optimization
>>>> for now. E.g. kvm invalidates unconditionally.
>>>> 3 should be fixed independently.
>>> Above implements this but is only build-tested.
>>> Jason, pls take a look. If you like the approach feel
>>> free to take it from here.
>>>
>>> One thing the below does not have is any kind of rate-limiting.
>>> Given it's so easy to restart I'm thinking it makes sense
>>> to add a generic infrastructure for this.
>>> Can be a separate patch I guess.
>>
>> I don't get why must use kfree_rcu() instead of synchronize_rcu() here.
> synchronize_rcu has very high latency on busy systems.
> It is not something that should be used on a syscall path.
> KVM had to switch to SRCU to keep it sane.
> Otherwise one guest can trivially slow down another one.


I think you mean the synchronize_rcu_expedited()? Rethink of the code, 
the synchronize_rcu() in ioctl() could be removed, since it was 
serialized with memory accessor.

Btw, for kvm ioctl it still uses synchronize_rcu() in kvm_vcpu_ioctl(), 
(just a little bit more hard to trigger):


     case KVM_RUN: {
...
         if (unlikely(oldpid != task_pid(current))) {
             /* The thread running this VCPU changed. */
             struct pid *newpid;

             r = kvm_arch_vcpu_run_pid_change(vcpu);
             if (r)
                 break;

             newpid = get_task_pid(current, PIDTYPE_PID);
             rcu_assign_pointer(vcpu->pid, newpid);
             if (oldpid)
                 synchronize_rcu();
             put_pid(oldpid);
         }
...
         break;


>
>>> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
>>
>> Let me try to figure out the root cause then decide whether or not to go for
>> this way.
>>
>> Thanks
> The root cause of the crash is relevant, but we still need
> to fix issues 1-4.
>
> More issues (my patch tries to fix them too):
>
> 5. page not dirtied when mappings are torn down outside
>     of invalidate callback


Yes.


>
> 6. potential cross-VM DOS by one guest keeping system busy
>     and increasing synchronize_rcu latency to the point where
>     another guest stars timing out and crashes
>
>
>

This will be addressed after I remove the synchronize_rcu() from ioctl path.

Thanks

