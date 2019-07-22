Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D337BC76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 05:24:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 914A021F26
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 05:24:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 914A021F26
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C1596B0006; Mon, 22 Jul 2019 01:24:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34C2C6B0007; Mon, 22 Jul 2019 01:24:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C72A8E0001; Mon, 22 Jul 2019 01:24:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED30B6B0006
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:24:40 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e32so34568306qtc.7
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 22:24:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=kYD2hoRdv/qSPKpU30GC2pluWYvaqhBUU23NFILZ6a4=;
        b=B032JN/84T8l82SkrRFQA6rVYO+9MlbEz7o5TeeWXubVSgt7TkGV2Rr1nPLdZRqBTr
         bSNDKf9Laritg5815ZQnZALYhtQBJojBRis6pJ0YHRUuPhFDrn1JrTLaIH9UBeVYQMDf
         uJC8JeNYh6fARemWEdYmeYQww4vM9F4nCyLXkTo+THwTpbaYWdByXsTOzijUYIHSVIkV
         cGqndj4ZTGTHeIDfKXgAILgCLrmI/VoEAf1XT3agu2MSGK5/BNnQehn1iez2Lfi+B3Gc
         iwc6b04Z8Lf5DmNHMP9cwo5vEgyP6kEc3WD1Z1QXldwljiKsOaS7ifhduCizgCSdod58
         Sk8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXFklhfLO5CIRxk4xWHRU1q+eLx3y62BQUzOLpwX7DhTUdp0LiJ
	lGITiLky7y+4Vj9EqSSxTQjJlL7SrxYEZC4z6jc+2mmvpqqFdVYAIEWHhyHlsnRbS8nkm52MlwT
	bHgzqRlcrAuK5mKZJabeTqYnszwDdZq7GWAXvQBkJTZIgR2D7cqZ1HQv1uoA0s2nprA==
X-Received: by 2002:aed:3bb5:: with SMTP id r50mr46325116qte.89.1563773080716;
        Sun, 21 Jul 2019 22:24:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx67kI44fyZBh7pFES4V7p5ClfLhOeCqFOtR8G4xerL/Y8drNKTfN05HAZycHLUC2Hd022A
X-Received: by 2002:aed:3bb5:: with SMTP id r50mr46325100qte.89.1563773080122;
        Sun, 21 Jul 2019 22:24:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563773080; cv=none;
        d=google.com; s=arc-20160816;
        b=dPXVNMTkGcllSuUj7w41aGH1TK9X2xSwbZkgjkRvIwgGYQfa8LUZ0MlHNoHI1y/+72
         7s5AJ5ReRsIVnannlLF24n4sWoC6B/8ywKwouFOyl2bo6/PEL+cbf10WMjLDaEq5XEM5
         lsIrmK0P9uZIA/Wm9pNW1QOLAS4XpebjBKO8KlJVxDGZQlVPcP7oO42zit8IGy+8QM5G
         zAs/D0A42DTzpi2Od9pC7HeD6Xjj9LlL7rlydaINDvPbC26CXrr5FWV8zW0Ms7Q3KqMF
         TBTAGevRreL6Z0IDwj4bpma1O83j/g4YGUFBIcfg2JIWg94yA37vVeDtqsm1tOEly2TQ
         Hp7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=kYD2hoRdv/qSPKpU30GC2pluWYvaqhBUU23NFILZ6a4=;
        b=lMz03MMwXm8QQ0tE/QFi+UeATQIgppKsEnHKuRrm5alw80F9JOowj+uG2ZpqBL4myb
         EKDxIWchDxIHq8pOg51C3iL8d1VFsHtWloyvWq66kpWU9S+27Iw9em4gPPcJ9hlUaeRj
         BBMZdqPMghXQzYqN2rBjTJ1EyPP8gkMPxybyNLGEMEKMdtykYX5wNgFI9AYe7E94NliX
         elHI8cnLHxISLNGfAi6WBXt9ErvdhTbyazhXS8QJAoZC/qBphRNgbwBjSGqrdvxUpghv
         3CaB/gM3CJQIf6xcOgw+WvkZEzIH4ko6OEI7+cYT+fzGkxMeZYe974qqGR5d/O2fEwwK
         FUJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f15si10231505qkg.57.2019.07.21.22.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 22:24:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 145078535C;
	Mon, 22 Jul 2019 05:24:39 +0000 (UTC)
Received: from [10.72.12.30] (ovpn-12-30.pek2.redhat.com [10.72.12.30])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C6EBC1001DE1;
	Mon, 22 Jul 2019 05:24:28 +0000 (UTC)
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
 <20190721081447-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
Date: Mon, 22 Jul 2019 13:24:24 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190721081447-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 22 Jul 2019 05:24:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/21 下午8:18, Michael S. Tsirkin wrote:
> On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>> syzbot has bisected this bug to:
>>>
>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>> Author: Jason Wang<jasowang@redhat.com>
>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>
>>>      vhost: access vq metadata through kernel virtual address
>>>
>>> bisection log:https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>> git tree:       linux-next
>>> final crash:https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>> console output:https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>> kernel config:https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>> dashboard link:https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>> syz repro:https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>
>>> Reported-by:syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>> address")
>>>
>>> For information about bisection process see:https://goo.gl/tpsmEJ#bisection
>> OK I poked at this for a bit, I see several things that
>> we need to fix, though I'm not yet sure it's the reason for
>> the failures:
>>
>>
>> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>>     That's just a bad hack, in particular I don't think device
>>     mutex is taken and so poking at two VQs will corrupt
>>     memory.
>>     So what to do? How about a per vq notifier?
>>     Of course we also have synchronize_rcu
>>     in the notifier which is slow and is now going to be called twice.
>>     I think call_rcu would be more appropriate here.
>>     We then need rcu_barrier on module unload.
>>     OTOH if we make pages linear with map then we are good
>>     with kfree_rcu which is even nicer.
>>
>> 2. Doesn't map leak after vhost_map_unprefetch?
>>     And why does it poke at contents of the map?
>>     No one should use it right?
>>
>> 3. notifier unregister happens last in vhost_dev_cleanup,
>>     but register happens first. This looks wrong to me.
>>
>> 4. OK so we use the invalidate count to try and detect that
>>     some invalidate is in progress.
>>     I am not 100% sure why do we care.
>>     Assuming we do, uaddr can change between start and end
>>     and then the counter can get negative, or generally
>>     out of sync.
>>
>> So what to do about all this?
>> I am inclined to say let's just drop the uaddr optimization
>> for now. E.g. kvm invalidates unconditionally.
>> 3 should be fixed independently.
> Above implements this but is only build-tested.
> Jason, pls take a look. If you like the approach feel
> free to take it from here.
>
> One thing the below does not have is any kind of rate-limiting.
> Given it's so easy to restart I'm thinking it makes sense
> to add a generic infrastructure for this.
> Can be a separate patch I guess.


I don't get why must use kfree_rcu() instead of synchronize_rcu() here.


>
> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>


Let me try to figure out the root cause then decide whether or not to go 
for this way.

Thanks


