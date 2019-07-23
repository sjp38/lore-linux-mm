Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA8CC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 03:55:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81FBD2182B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 03:55:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81FBD2182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 179EC6B0003; Mon, 22 Jul 2019 23:55:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DDA26B0005; Mon, 22 Jul 2019 23:55:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC0FC8E0001; Mon, 22 Jul 2019 23:55:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C10F66B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 23:55:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e39so37280828qte.8
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:55:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=dj+PDIIcRMni00gK4UtnExAD3ww5g34hbb+qH0WlvD8=;
        b=p0ohN3OFreFLURTYHU7AskOf/OMdcWxTrr/0cLV9hMR5jXOLz0/hHdJd6K1UKmUH4O
         gGnIEu421D7z9emPwjV13WijQ4YOvXbSNpFpKFNVeIA72sb/yGmKEe0UeFSEzl3pfYmC
         7ISUYXqYJUrd19x86Gs39zGZm9qEy3bRryIf0vR5lF0TUajPt3jfwfqUnb29iEJMuJwA
         2PB2JAWpbwp96Q/fXKK7a9MsK3bm+MSSqUxr5X8x8mprreJ9W1QHGDM9zPeCamGBdKnO
         Tcp/h3qk+mdXXLocUVRUtJvUs3G1n5ukgh2bVR/4UKbL3JNOoGfgzwzKwlMb9jduypab
         hqjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUMh2x4DmMppyWsJSumLFxsPZdTRfl2FRCZZHZxmbdIy8ulsRFB
	JX9Gtf+x5jvhdyvBePkpLCffa3QRdhWB3yfyWLVdimEZbS9Ki7jh2ZHWewd/jFOjcce4CHKzWih
	eq2weoo/IS08vLll+kuom0MyyXNeoGCn1XbNWMegzliJ5Ncfhi0GHDkxZKiVI5Rws9g==
X-Received: by 2002:a0c:983b:: with SMTP id c56mr54605206qvd.131.1563854149412;
        Mon, 22 Jul 2019 20:55:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdx47w5cwEqKr8TsLsae1EZoX7MGkBZvPIHT0TMwOaKRszL3zxhFa9BvCURN2NpPdA6iZ0
X-Received: by 2002:a0c:983b:: with SMTP id c56mr54605188qvd.131.1563854148667;
        Mon, 22 Jul 2019 20:55:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563854148; cv=none;
        d=google.com; s=arc-20160816;
        b=HM9CNNY5DIVCHuNYUWgt4eBIadm5n7bHUaTSI80wPNGrHnc5jUgWAEbWcGgF6yd6Js
         95+QAEBXfwrLqtYem+JaVKZJxBd1SRnLF2TA0e9oKk2KF0raftKPFZfZ8vQX7E6ToajS
         FJhABmPDZifavdPPbMLpIkZeTxfLDmQTlBD8KBGQamhgOdhzveXXQ6Th9KT0oXmTjk8q
         x5nHeWZWFCBvn/NzEBKCtuH44yNK3Sh9LFyZymWesD+R6cQTCDr8nySUkJUldNSrs7tK
         oreQOfX/QjXdDyzVaooSTArc+geb9Opcra5S5solzgDLBwVUR+H3t55aIv7y1ThEEpOw
         c4og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dj+PDIIcRMni00gK4UtnExAD3ww5g34hbb+qH0WlvD8=;
        b=RM9h27oDfF6ZyghwlvgkLg3xEDnieHi86v6N96Ksa8i81/RDLxBG7bgrE/I53ls5aS
         0piEMNtG4SHyofkqnRMyFNasCgkJvffj5QW/yB2pKqIerku/VCa4yjoREkNVxbvnT/JN
         SAqGewQjeYMvLXzA6tXbqhzBXWr9eOjuemZOKyJlLyd1urh7pQRftmr2F1If7TV33fWC
         HthfSx29frBHH4r9Us2xwno7uQEcg2wHP6tRqfAdu4zCuAFZDRE3oLFLM21C8AZEjTiE
         mk4egnzQVseFlAemttMmFm9X9YZTboc8QPP9yV4ZmxMn+i1VtLeHIoTGSR7g/1UaQC3e
         jrTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si11294759qkg.326.2019.07.22.20.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 20:55:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 461C43082E51;
	Tue, 23 Jul 2019 03:55:47 +0000 (UTC)
Received: from [10.72.12.57] (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C02205D9C8;
	Tue, 23 Jul 2019 03:55:29 +0000 (UTC)
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
From: Jason Wang <jasowang@redhat.com>
Message-ID: <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
Date: Tue, 23 Jul 2019 11:55:28 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190722035657-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 23 Jul 2019 03:55:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/22 下午4:02, Michael S. Tsirkin wrote:
> On Mon, Jul 22, 2019 at 01:21:59PM +0800, Jason Wang wrote:
>> On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
>>> On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
>>>> syzbot has bisected this bug to:
>>>>
>>>> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
>>>> Author: Jason Wang <jasowang@redhat.com>
>>>> Date:   Fri May 24 08:12:18 2019 +0000
>>>>
>>>>       vhost: access vq metadata through kernel virtual address
>>>>
>>>> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
>>>> start commit:   6d21a41b Add linux-next specific files for 20190718
>>>> git tree:       linux-next
>>>> final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
>>>> console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
>>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
>>>> dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
>>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
>>>>
>>>> Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
>>>> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
>>>> address")
>>>>
>>>> For information about bisection process see: https://goo.gl/tpsmEJ#bisection
>>> OK I poked at this for a bit, I see several things that
>>> we need to fix, though I'm not yet sure it's the reason for
>>> the failures:
>>>
>>>
>>> 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
>>>      That's just a bad hack,
>>
>> This is used to avoid holding lock when checking whether the addresses are
>> overlapped. Otherwise we need to take spinlock for each invalidation request
>> even if it was the va range that is not interested for us. This will be very
>> slow e.g during guest boot.
> KVM seems to do exactly that.
> I tried and guest does not seem to boot any slower.
> Do you observe any slowdown?


Yes I do.


>
> Now I took a hard look at the uaddr hackery it really makes
> me nervious. So I think for this release we want something
> safe, and optimizations on top. As an alternative revert the
> optimization and try again for next merge window.


Will post a series of fixes, let me know if you're ok with that.

Thanks


>
>

