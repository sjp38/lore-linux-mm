Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C95E5C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 07:07:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 983B8217F4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 07:07:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 983B8217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 452B18E0005; Wed, 24 Jul 2019 03:07:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 403828E0002; Wed, 24 Jul 2019 03:07:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F2E78E0005; Wed, 24 Jul 2019 03:07:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 12F9E8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 03:07:15 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o11so32008844qtq.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:07:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xHX2WDTI21qg/bqit5Yi8vXuC+eiihK7yBIpAg2rJNo=;
        b=VW19Q0I5ycz/538LxmDLv13xzwZA+XHz4wMDbxYsc1AdTKmizy/ZFttTUi4FnbInRQ
         MOxKNpYrGP/m9LOKd4xTO+RfqVnjrJlJhYcuk6naPeulB1K7siEcifFuPXtcc51qOVrq
         X4e/1jNdAnLMwwQfiSSOzTTn0w8Je0+VQ8tqVaWzKi/g68kVBAhDQNdUsh2Xod+BOaUI
         5nAhtMHGvF7yhJdghrEmLBqQDh9bNCx9VJ9iHWLx32RhoYjcT6mt3yK2Tv1PBjLQqcU8
         b1a2GMrJ4ZMOMll5414tfFN//T/bHRzJtyD4l9SEobTiNoOqnYgtCdkf/BKvzDEb3kHX
         Tejg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVhqtZh79wKuxvshsCrMzmxbP2Achhtf6iV3KfKgfccrZn9zHj2
	vGW+wjgxvemrgyT8Q4ebXgFaN8QMY5OzOdfCOsdbGn532LsB+0adeqQfM/690uoak+Mkxhi8ig4
	9vg0TTglXse8ybUP9tydZc8w+DfEinqdTQGhQMefLgzrA5oztWYEmqrWBK7tLcegz8Q==
X-Received: by 2002:ae9:e411:: with SMTP id q17mr50550547qkc.465.1563952034826;
        Wed, 24 Jul 2019 00:07:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVxWjPGvTT/5AZ2jNrbxy4ftaXLFRht28kZ5Chl/d+ufbffQccE1g92cDlc0mgJ/HBA4O9
X-Received: by 2002:ae9:e411:: with SMTP id q17mr50550523qkc.465.1563952034083;
        Wed, 24 Jul 2019 00:07:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563952034; cv=none;
        d=google.com; s=arc-20160816;
        b=sK7KZz18NUI5MMqnl9S+2zcPhnMoTFKklz8lZOnt1szfQNORTamhj9Qs2myf3t9OG5
         ypF3uavihiwZJm12EcYXdEKWRGvHKyodriFngKDTH9oOZ4k3zS3yMRVqI5vyfIZvHC6W
         mtGK5Zk6y4yary1l/0e4zmBHKkLOO1mCNUDMX7RTx2lJ7EL8HKgQMnq/HZDUCdcmSFdq
         9hIC3y8Mc6Ww6JX4AQBb7X7a9/ohuQihMBBUH7ANr9adXtTkvQ6g/cI95jW2XfaSPXTF
         jJ5jLJQESC0I/TkPIf5TMori57cG/8Cj+jvicu/mgzftY60TzO2EB+MZ3as93rYn3j8U
         4Zhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=xHX2WDTI21qg/bqit5Yi8vXuC+eiihK7yBIpAg2rJNo=;
        b=ONYwi+t8bhS5Fi3n9ud+yoCE2x7lljqzAeLT6HuzjZP5UPE+7lRCrHY5gFQOIVGSCb
         ljEDOv8pzKyumtN063RrSm16dTTff3jwPci+MRgk0H6POi+pSTR8XmmLpfjdV7pHP709
         UkUX5id6DjD5lelo7GEi3ETxI+hC+6kROidzYAyWGlODOgdFWsbuMd4w4HEd7/BR+N2C
         mCOLxYmlAzwIUAFftL+HnzuMAN94CCUICnB7C7xSSQLbpc0krKaCNI0KjweUEKtPlR0R
         sRn9B0tyJeg5riVtdxa3XwQNoQS3XKzzIAiN1LVeNbMGp1FvBRVacLpzjIl4/w03I0vB
         fa3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n37si30119693qtk.173.2019.07.24.00.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 00:07:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8A41A3179174;
	Wed, 24 Jul 2019 07:07:12 +0000 (UTC)
Received: from [10.72.12.106] (ovpn-12-106.pek2.redhat.com [10.72.12.106])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC5A260148;
	Wed, 24 Jul 2019 07:06:59 +0000 (UTC)
Subject: Re: KASAN: use-after-free Read in finish_task_switch (2)
To: syzbot <syzbot+7f067c796eee2acbc57a@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, mst@redhat.com, namit@vmware.com,
 peterz@infradead.org, syzkaller-bugs@googlegroups.com, wad@chromium.org,
 yuehaibing@huawei.com
References: <00000000000027494e058e0b4b3f@google.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <fc935344-4f35-3f05-dc33-398655b38330@redhat.com>
Date: Wed, 24 Jul 2019 15:06:56 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <00000000000027494e058e0b4b3f@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 24 Jul 2019 07:07:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/20 上午12:34, syzbot wrote:
> syzbot has bisected this bug to:
>
> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Fri May 24 08:12:18 2019 +0000
>
>     vhost: access vq metadata through kernel virtual address
>
> bisection log: 
> https://syzkaller.appspot.com/x/bisect.txt?x=123faf70600000
> start commit:   22051d9c Merge tag 'platform-drivers-x86-v5.3-2' of 
> git://..
> git tree:       upstream
> final crash: https://syzkaller.appspot.com/x/report.txt?x=113faf70600000
> console output: https://syzkaller.appspot.com/x/log.txt?x=163faf70600000
> kernel config: https://syzkaller.appspot.com/x/.config?x=135cb826ac59d7fc
> dashboard link: 
> https://syzkaller.appspot.com/bug?extid=7f067c796eee2acbc57a
> syz repro: https://syzkaller.appspot.com/x/repro.syz?x=12c1898fa00000
>
> Reported-by: syzbot+7f067c796eee2acbc57a@syzkaller.appspotmail.com
> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual 
> address")
>
> For information about bisection process see: 
> https://goo.gl/tpsmEJ#bisection


#syz dup: WARNING in __mmdrop

