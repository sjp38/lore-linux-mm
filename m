Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 756E1C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 432F921473
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 16:00:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 432F921473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E18DB6B0006; Sat, 15 Jun 2019 12:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC8CF8E0002; Sat, 15 Jun 2019 12:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C91008E0001; Sat, 15 Jun 2019 12:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8FC76B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 12:00:21 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y5so6588768ioj.10
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:00:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=fZtKRlbKkoLC0F7ZP0yLtohG6N1YbGXigirTYFBVsdc=;
        b=ELyENYSd7iZfMyXgblMGjGc3Jo0fYYkJXyREjAo9OqVZQTxppmargVTPCqkbak0IcT
         bTxouMomgmVQKr+3uSwmxVLxhLSekFPXD/B40CsZ0eIfPIhYBCJoUFYSRW51bKCiQmHs
         /Mhz5CeqLGGIdyWYQw/Bj7KYfLWAHmyFqx9N/DkJAP8DpG8GKXwVZF/RZ2+2lvQ84N+v
         olpWX1JJUzk4U5i8HjgVKA9GYFSRhA9sotc0O3cjLNSAOrNa/bOvyZD5t1QUtDD5Cbo3
         z4FwPnejLkEZMFO5D56GouYfOMKEf5wbXwNT2kPg/Pfa2WvOrMGDs0Pj9Qh32Ckx6qh8
         Hhkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAVcLZ+o8VVk+q74CNKqNShzn02nNn3+33BWzOH0TL8yuvP2kcg9
	O/eAHyzKXy7//EhGL15hrEBe99vI0Z30/rEs7DAje2PF561pNSZY2BIdB3vANJzQ5+F4nSD7PwY
	D3w22ywqwkvhquBpdjbl7yw2I195sFfx1g7T9QchNb9IQ2G5gc2fgzPk8P9yCLvZZ9g==
X-Received: by 2002:a5e:cb43:: with SMTP id h3mr7053970iok.252.1560614421416;
        Sat, 15 Jun 2019 09:00:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2+JdjrvzpjiB9jjYzcVShAUQJu8D9ekamf64hXAe3ky5Xi5/H3yx6L5UZ0w9m0MHYJ+N6
X-Received: by 2002:a5e:cb43:: with SMTP id h3mr7053922iok.252.1560614420726;
        Sat, 15 Jun 2019 09:00:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560614420; cv=none;
        d=google.com; s=arc-20160816;
        b=qt2IAMgLEkK0Nk/ev0v8q/wHxlVvGphAmJe4L5jRRN2TGOrU+3mXe1IFJfLrm8hsE8
         9ilQWF7r56oGM4TnrIVvR6QHm0QEMy8wW6EDMnJBSlrJvlTQFWybuk5NpEv7w/5NxrhL
         /uL+aBKlIXr40qAQCrlGPvQbn6HmaXeZiSIZ6ADG5Rnsa9xdcbxusGha28An+3PkKJ6t
         aZjDpvBoykOhRBqeikMjqoyUvv358vmW0vjG3WM2V7guURXSg2USFUOV+YcSKpZHPPAZ
         NMaUWKNcxhYifNLTCuZ1b4tHu11KVVq9snZ40m5zxPuahsalgC3difuIjmeWj1SCq1vH
         JNQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=fZtKRlbKkoLC0F7ZP0yLtohG6N1YbGXigirTYFBVsdc=;
        b=I5OCFrF2CK1TblQjsRSt6sWm08HlSjZowAhps42aeTBIwaFEgkitTmmYhAOG1EJqw3
         YiHjTu+a4SwbL2not5p6sAHECVlEmT0LiFYhDMaqdapPIVYbI87VEqAMKfTYQEJyylR9
         LGi+jaf6tjtHzUYzPQZA77Bg99s+nR7ukcqei4QfgNrfJ9qEjaRvdksKWpznaH9FKt8m
         BzMqSjmBDT1OmxBA21R419ms9mNgXso+NbemznMxL4MzKK++k9IjquQrUh3tB7U+qCXx
         DhdWLv/vtsnZf3qLm6bfivIB93zvw4IU7sGE7vl2Yyag9wlP0kQGIFudr8jjiOBTqcnq
         m8yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x95si8537057jah.46.2019.06.15.09.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 09:00:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5FFxdWl046712;
	Sun, 16 Jun 2019 00:59:39 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav107.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp);
 Sun, 16 Jun 2019 00:59:39 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5FFxYoZ046678
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sun, 16 Jun 2019 00:59:39 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: general protection fault in oom_unkillable_task
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
        akpm@linux-foundation.org, mhocko@kernel.org
Cc: ebiederm@xmission.com, guro@fb.com, hannes@cmpxchg.org, jglisse@redhat.com,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com,
        syzkaller-bugs@googlegroups.com, yuzhoujian@didichuxing.com
References: <0000000000004143a5058b526503@google.com>
 <cc3d5247-855d-a124-041f-64c4659d95c3@i-love.sakura.ne.jp>
Message-ID: <8c50ca8c-3869-6f50-3a3f-bc7726c39975@i-love.sakura.ne.jp>
Date: Sun, 16 Jun 2019 00:59:32 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <cc3d5247-855d-a124-041f-64c4659d95c3@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/15 10:10, Tetsuo Handa wrote:
> I'm not sure this patch is correct/safe. Can you try memcg OOM torture
> test (including memcg group OOM killing enabled) with this patch applied?

Well, I guess this patch was wrong. The ordering of removing threads
does not matter as long as we start traversing via signal_struct.
The reason why crashed at for_each_thread() is unknown...

