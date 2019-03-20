Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8D8AC10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B53F2186A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:56:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B53F2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6D636B0003; Wed, 20 Mar 2019 05:56:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF6A76B0006; Wed, 20 Mar 2019 05:56:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE8246B0007; Wed, 20 Mar 2019 05:56:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2D86B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:56:52 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id p13so337768lfc.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:56:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:cc:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=+7rzd8TIkczZq2kBjY7Bs6oUvOtuK6x6OhyPFei2NIo=;
        b=O/VgZZydpITLWNKD0Z8CDmyaCCHU4OsUZkFXyv6HG2rq5MqJgWziE2sWvYcHWrAoDp
         SZpjEGvyRXzjO2QdK8GpTsZm3Vj65vOQpclFuo0PqQ4M6tBBf9bAp0oQcVtgoMaOovmT
         aovz/koFOXv/ZRUWCpcvVy1MfOITIFSdurX8LGb4z1XsIDNw5AyBj2p9isOaMf/71gyo
         9DTBlgxXry/un+jVyqSsdAelKY0c32p3uJM96Ys3Av3tRBHqhF06CkaoW1h/qaeIN1JO
         5WU4sW5zhN5sRrsi7w1+Mql1RPAeUE/UuEWO4/t3/ZnA9b0N6E4aZyhAiVjBMaUCqiEI
         NYeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXkrj2GgkAR7RZvQOLzf715Xf0yXmcFSBt7JfHYNlXKVhTwGP+a
	amq6UJLXO3bTsn0ULw+rYJWGqS/Z2SKLSqEt9dzRMbf5ohQvpYL9Y+yHRvC7XJ2n/fdzt771oGi
	i6yoI5xkbSrj2pI3YSIUOEKq0opyDpT07S4onIs8Xe0U7024NcGULCgYwNP4dnGP66A==
X-Received: by 2002:a2e:9d53:: with SMTP id y19mr15881591ljj.37.1553075811773;
        Wed, 20 Mar 2019 02:56:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+nOQEglFxuoneH0jnYmWSRpVt+KOeWY7URK5u3DVmjrysgDBl/P7tC8vkVfjvbNTv93v8
X-Received: by 2002:a2e:9d53:: with SMTP id y19mr15881544ljj.37.1553075810726;
        Wed, 20 Mar 2019 02:56:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553075810; cv=none;
        d=google.com; s=arc-20160816;
        b=y2UlAxFy/r3I8QtFbvCcf7F6+P/UcivC87WI2YdsxxGUHIZwJzJ0VXA9w9obJklNSd
         9t+Oy15Yyuha/uT4HJxJfnV3qA4JgI8ycQgTa7EA3aTlqdSs8um7o9x35qqHSjXIOsG7
         tjAG+4Hoidorib5x79s4ANonPdWj4N7XQFw/dF3zd+TRn2OdatbK8L/jG9vchgDFIwWI
         74WchnWYsDa6Ixh6YdMxQ9o84z54JGA0qpM/e5zAX0y5FHPUrbf6GUi7Md/ZO+u9oUUu
         j5E13waPu8uVdaO13PKvgeVPKqqU6Mv+Bb9n+9DxIJEWyLiTARcPUoD0/eOplIXj6h7D
         XcOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:cc:from:references:to:subject;
        bh=+7rzd8TIkczZq2kBjY7Bs6oUvOtuK6x6OhyPFei2NIo=;
        b=LyBktvd1OhD7Z3JoHClmTxvtWwrtQJoj2tJ3+z2ama7txnZKrPy7DUY2MBNA/hvBl5
         vkY7M5BvEJTYVohW7rR68x9PQo3voDTt6FKckehEkrinXTc41wZsgiUvTV6fLSehI6fW
         x7I5x15iAvrB/hsnbHSQfnJ1EeaxMWpcEifo7/xBr782Xlzwl2jvHJ2IjTJdbNQnaYq0
         4BO09Bwl29HSb9XYIhMUlC7P8tMUzoJDKj5LAxux4AgnCMyMiAD1tL4tExtAB8D4NE+a
         0J/M0I6sL3BoFWbVickjFYl0by3wtn2lRbfOaAnYz5JPv9N4c1/KlAotpLrQg8zTSYJn
         xmoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 22si1101870lfy.134.2019.03.20.02.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 02:56:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1h6XxM-0007BT-M9; Wed, 20 Mar 2019 12:56:20 +0300
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>,
 akpm@linux-foundation.org, cai@lca.pw, davem@davemloft.net,
 dvyukov@google.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com,
 ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-sctp@vger.kernel.org, mgorman@techsingularity.net, mhocko@suse.com,
 netdev@vger.kernel.org, nhorman@tuxdriver.com, shakeelb@google.com,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
 vyasevich@gmail.com, willy@infradead.org
References: <000000000000db3d130584506672@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Xin Long <lucien.xin@gmail.com>
Message-ID: <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
Date: Wed, 20 Mar 2019 12:56:50 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <000000000000db3d130584506672@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/17/19 11:49 PM, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit c981f254cc82f50f8cb864ce6432097b23195b9c
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Sun Jan 7 18:19:09 2018 +0000
> 
>     sctp: use vmemdup_user() rather than badly open-coding memdup_user()
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=137bcecf200000
> start commit:   c981f254 sctp: use vmemdup_user() rather than badly open-c..
> git tree:       upstream
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=10fbcecf200000
> console output: https://syzkaller.appspot.com/x/log.txt?x=177bcecf200000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=5e7dc790609552d7
> dashboard link: https://syzkaller.appspot.com/bug?extid=ec1b7575afef85a0e5ca
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16a9a84b400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17199bb3400000
> 
> Reported-by: syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com
> Fixes: c981f254 ("sctp: use vmemdup_user() rather than badly open-coding memdup_user()")

From bisection log:

	testing release v4.17
	testing commit 29dcea88779c856c7dc92040a0c01233263101d4 with gcc (GCC) 8.1.0
	run #0: crashed: kernel panic: corrupted stack end in wb_workfn
	run #1: crashed: kernel panic: corrupted stack end in worker_thread
	run #2: crashed: kernel panic: Out of memory and no killable processes...
	run #3: crashed: kernel panic: corrupted stack end in wb_workfn
	run #4: crashed: kernel panic: corrupted stack end in wb_workfn
	run #5: crashed: kernel panic: corrupted stack end in wb_workfn
	run #6: crashed: kernel panic: corrupted stack end in wb_workfn
	run #7: crashed: kernel panic: corrupted stack end in wb_workfn
	run #8: crashed: kernel panic: Out of memory and no killable processes...
	run #9: crashed: kernel panic: corrupted stack end in wb_workfn
	testing release v4.16
	testing commit 0adb32858b0bddf4ada5f364a84ed60b196dbcda with gcc (GCC) 8.1.0
	run #0: OK
	run #1: OK
	run #2: OK
	run #3: OK
	run #4: OK
	run #5: crashed: kernel panic: Out of memory and no killable processes...
	run #6: OK
	run #7: crashed: kernel panic: Out of memory and no killable processes...
	run #8: OK
	run #9: OK
	testing release v4.15
	testing commit d8a5b80568a9cb66810e75b182018e9edb68e8ff with gcc (GCC) 8.1.0
	all runs: OK
	# git bisect start v4.16 v4.15

Why bisect started between 4.16 4.15 instead of 4.17 4.16?


	testing commit c14376de3a1befa70d9811ca2872d47367b48767 with gcc (GCC) 8.1.0
	run #0: crashed: kernel panic: Out of memory and no killable processes...
	run #1: crashed: kernel panic: Out of memory and no killable processes...
	run #2: crashed: kernel panic: Out of memory and no killable processes...
	run #3: crashed: kernel panic: Out of memory and no killable processes...
	run #4: OK
	run #5: OK
	run #6: crashed: WARNING: ODEBUG bug in netdev_freemem
	run #7: crashed: no output from test machine
	run #8: OK
	run #9: OK
	# git bisect bad c14376de3a1befa70d9811ca2872d47367b48767

Why c14376de3a1befa70d9811ca2872d47367b48767 is bad? There was no stack corruption.
It looks like the syzbot were bisecting a different bug - "kernel panic: Out of memory and no killable processes..."
And bisection for that bug seems to be correct. kvmalloc() in vmemdup_user() may eat up all memory unlike kmalloc which is limited by KMALLOC_MAX_SIZE (4MB usually).

