Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65D16C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A5892239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:53:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A5892239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B50676B0003; Tue, 23 Jul 2019 03:53:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADA328E0003; Tue, 23 Jul 2019 03:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97A298E0001; Tue, 23 Jul 2019 03:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 733A86B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:53:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r200so35779648qke.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 00:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=iE+AeocxJ5a/4A2fxz6KZElbBsv8Qdzx2mBWz+s7nd8=;
        b=hb+Jcfd2wYgh7aqYJg80ZiD5G5lKsGNqUYsJses8RKbr3EmRnFfH9UCejVMjHmmren
         7WxTg0ZPcXLZ+c9boMkL2R/itmhLlgONm007QyLtV1q7vodZJl8DebY3Z0+u5k01YEhO
         Oi10B6bmSywrDnGRUag6JJ4UmGQsJlRxgXvTDiITjW6Gx2+3rQgorMu6GDAlSMM5eG+O
         5CT6GlEHxEcDJuRyQ4ie6A1e5aY43Iv1QS/3AmkEBWSdA05dUc+G2XPPL3gllBpz5OEw
         G99TSfkeTgBQvYYUv2OPchdMU6GZ7rWeDEqKQz3jCfpE9D/w4XY5Tctq0GG6vAhbeL3g
         sbAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVBgznNPGUw2xNIsJovACFgpxU2xrsSDfw9eTVDqjJsyQE6UsfW
	XLp5AjKp08DmsCqWkfqbVxIr5aIXL0MleFvE37iLcCyVo9yyqVxmk1CnFV36NEOibtf5r/XS2/e
	tab5SZrY9HF6yJXR6Hl9Noq/KYMgshqysAcWaTSqNeJJSXmZ3MpgOWtem2wU2+iB9Vw==
X-Received: by 2002:aed:22af:: with SMTP id p44mr53701886qtc.348.1563868398233;
        Tue, 23 Jul 2019 00:53:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwUkLwaFULzNKTRa/jj/FQpoWzrvV0w51/tzZtpc0in6pO2CN+5Edvawd7nblV9WZOHQTR
X-Received: by 2002:aed:22af:: with SMTP id p44mr53701865qtc.348.1563868397681;
        Tue, 23 Jul 2019 00:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563868397; cv=none;
        d=google.com; s=arc-20160816;
        b=iP5DP5phb19QOGrPQtXnaQ2KctymLgu6ghozQ8eRWzdT8jI1WS9kkRYwP2r7M1kYQ2
         lbjHFPGNlWvKZ+oxPCJCjq+0iWw1S2YVXeEINrQmPJPqwKiCGKplcsXDfj6O5w7OEQCI
         xcXHUymGJaa6rdPK6lPoZ+B1Bem8LIR4Jjxqh0Zppzg4K0vvp7s1FfELON63zGEG/cTn
         aFbBmWnUo0+u45iLHygoVwmbQP6YRgHQiSdfO0mkrmBmSIeCGeS4Es+DD4JNFt4xQrSn
         gk+Fb0V8wN0ER5WIkk8ZObhLl3r5h5tKVlkujhvqDB17XWrTS0ofxi6Pg05qg5dGK6I9
         HGRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iE+AeocxJ5a/4A2fxz6KZElbBsv8Qdzx2mBWz+s7nd8=;
        b=b6fI1a/OpYxpV3ZKfNA7hNvfVY435zcUiV9ufAduCEpVdP+XiYfjksn8MHZ66Y2BNO
         VfYdraXaBeYk1Oad95EHDUPfYNmIWUAhA1+vZC1vgOtOzpmULxjeCIGaRuJwrp/4gxRy
         20j2wHumfoH9tjL+b+OczPBpPIvVeaoyicEykonunPq2RGLeqiAyZzgjcnwT2Vrpxtq5
         oYHxiI1nk3ujb8D8Os6pmE6uvoklZqxHL/4Xejv7EeYC3m4fr/OD7AmuPZiMBv4OnSJm
         /7PpEja9IQIui5Enmex9CmIP31fPiucJ4xriCCrGdVqyocDore5TiDedGxvbtaN1P0Z3
         DU4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z36si11085907qtz.405.2019.07.23.00.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 00:53:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4F9A983F42;
	Tue, 23 Jul 2019 07:53:16 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 68E0B60497;
	Tue, 23 Jul 2019 07:53:05 +0000 (UTC)
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
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
Date: Tue, 23 Jul 2019 15:53:06 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723032024-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 23 Jul 2019 07:53:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
>>> Really let's just use kfree_rcu. It's way cleaner: fire and forget.
>> Looks not, you need rate limit the fire as you've figured out?
> See the discussion that followed. Basically no, it's good enough
> already and is only going to be better.
>
>> And in fact,
>> the synchronization is not even needed, does it help if I leave a comment to
>> explain?
> Let's try to figure it out in the mail first. I'm pretty sure the
> current logic is wrong.


Here is what the code what to achieve:

- The map was protected by RCU

- Writers are: MMU notifier invalidation callbacks, file operations 
(ioctls etc), meta_prefetch (datapath)

- Readers are: memory accessor

Writer are synchronized through mmu_lock. RCU is used to synchronized 
between writers and readers.

The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized 
it with readers (memory accessors) in the path of file operations. But 
in this case, vq->mutex was already held, this means it has been 
serialized with memory accessor. That's why I think it could be removed 
safely.

Anything I miss here?


>
>>>> Btw, for kvm ioctl it still uses synchronize_rcu() in kvm_vcpu_ioctl(),
>>>> (just a little bit more hard to trigger):
>>> AFAIK these never run in response to guest events.
>>> So they can take very long and guests still won't crash.
>> What if guest manages to escape to qemu?
>>
>> Thanks
> Then it's going to be slow. Why do we care?
> What we do not want is synchronize_rcu that guest is blocked on.
>

Ok, this looks like that I have some misunderstanding here of the reason 
why synchronize_rcu() is not preferable in the path of ioctl. But in kvm 
case, if rcu_expedited is set, it can triggers IPIs AFAIK.

Thanks


