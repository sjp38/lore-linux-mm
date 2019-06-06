Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65462C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AB2A2083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:25:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AB2A2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B482D6B0279; Thu,  6 Jun 2019 11:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF6956B027A; Thu,  6 Jun 2019 11:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BE7C6B027D; Thu,  6 Jun 2019 11:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CCF56B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:25:32 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 9so629794ljv.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:25:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5+dOmXeURBRc7VvGwZp4Iip2YXKOWTHfhZLgEEKCtU0=;
        b=ReGkQOdZFH2nO4kG39KfYqveAEAUzE8rcBpLAWPZnxbZVLQ/14ZLReYi7ykTihcotM
         mRDB5HrohAmA2A1kEQR5roodGkMBcFFhyTjxPznE2Ezawt0ysS5ss3gKF2tLK1AFsb5M
         T69CsY0KDCLVQ0HQ4OYjiEOazPkGOWqzUH+nYwLfueM4OsPFKPnJi3SAITot3BBWL1dT
         8SYT/R2z6E5tFlZsUBkgxayDR6VzMQvdhMvAOiZgibObPZ+7cNXxMS8qvF0Q81RrDy6M
         4VTRfaQPaJ64hjVPVZ9v+bnCOF/esZoebKEj+bwUFkYIX4ftl0qv43T1e5cCuXO8UKa5
         0KLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAW0tc/sxpa+Jz6LQ5OGS4Lwm1hGPiS6wll6J+Oznp53uMMftrTz
	mXA1xQxIxKGLb8Zpu13qaBEFY175dP54zvQbPbgBf7Vlr+r07oYi2ioXchQRViKKxyAZde2IfH8
	EM6SoKBDxNPUWTVue64/Ovs7bruK7P34livkb7n5Zwh+nNKEnWcZEol5ip0/QaX5Icw==
X-Received: by 2002:ac2:4d1c:: with SMTP id r28mr9395081lfi.159.1559834731592;
        Thu, 06 Jun 2019 08:25:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXonG3sZ1ZnabNoHa5BffVFMpqd5J7lgrAH7zMY3bEg8hDlOQgFsIEn+vuYPvx2tC4ZgOm
X-Received: by 2002:ac2:4d1c:: with SMTP id r28mr9395051lfi.159.1559834730664;
        Thu, 06 Jun 2019 08:25:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559834730; cv=none;
        d=google.com; s=arc-20160816;
        b=RQiySAKnl+JgJmbObF+a7uUmii4vGjxsV/bWj5rqu1WwlRWBfrkdPjv1CcSMgm3+wz
         n9YpMg7O6COutLu1szNmx8zxJYQ+C6wyNwOWCTmZ5P7GOLM7Vb2+9B2gIpdjwuZ43/9A
         MC92bJUmDbn36ExIXaL3CfeAs+3EO9xGp3yZin3JHBsEUROtMjYIIGGDbLsXm0wYT5ck
         uYEIAn44UUVlmByACcEjNFdy2o86Q7g7Pi2KQHLIFXfGJvG1nVL1C5vRbulIyQQwz/ce
         m3RRSfE7F+TzVnnPjCNUyhj79jJFTAgxxSkDa4PHInReLn86CUgjQXUXHaKL5qO4qysL
         jNjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5+dOmXeURBRc7VvGwZp4Iip2YXKOWTHfhZLgEEKCtU0=;
        b=w0Y6rSCSXMBDifOKoEj7eVNF02wUX14GkzhLehVd+jT6uZ/eG5SZCvxISWsiZaWue+
         ar7/7F7ykPO64IJBVw8Dc0gS38R6nZRsRUE3uTmHA9t3nlUfVPhPu4YPkmzDpn7rKGZY
         +ikm69hWLwNi3OsyBJXCHzIib/TURyikfE3sEot0zFzOJwHPPSCdz3IHTAkPG2VwUoGr
         PfgFpm5p6VgR5aC+7+V+fYKthCEKB6CtrQqsxnmXQ0qEREa68nUfO6NZ4xvuJ3VYf2Bk
         ud3qWYidZ5oxST6/DRG0Rt6bnTGwwGK35js2f9IzJGc0UGRoH+bmAqZD8QE9W/Wn4FVw
         xhbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id n22si2036245ljh.35.2019.06.06.08.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 08:25:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hYuGS-0000sH-Cr; Thu, 06 Jun 2019 18:25:16 +0300
Subject: Re: KASAN: use-after-free Read in unregister_shrinker
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
 syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, bfields@redhat.com,
 Chris Down <chris@chrisdown.name>, Daniel Jordan
 <daniel.m.jordan@oracle.com>, guro@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Jeff Layton <jlayton@kernel.org>,
 laoar.shao@gmail.com, LKML <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>, linux-nfs@vger.kernel.org,
 Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yang.shi@linux.alibaba.com
References: <0000000000005a4b99058a97f42e@google.com>
 <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
 <20190606131334.GA24822@fieldses.org>
 <275f77ad-1962-6a60-e60b-6b8845f12c34@virtuozzo.com>
 <CACT4Y+aJQ6J5WdviD+cOmDoHt2Dj=Q4uZ4vHbCfHe+_TCEY6-Q@mail.gmail.com>
 <00ec828a-0dcb-ca70-e938-ca26a6a8b675@virtuozzo.com>
 <CACT4Y+aZNxZyhJEjZjxYqh34BKz+VnfZPpZO9rDn0B_9Z_gZcw@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <ae7ccef7-6972-370f-e9df-951771d1e234@virtuozzo.com>
Date: Thu, 6 Jun 2019 18:25:16 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aZNxZyhJEjZjxYqh34BKz+VnfZPpZO9rDn0B_9Z_gZcw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.06.2019 18:18, Dmitry Vyukov wrote:
> On Thu, Jun 6, 2019 at 4:54 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> On 06.06.2019 17:40, Dmitry Vyukov wrote:
>>> On Thu, Jun 6, 2019 at 3:43 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>>>
>>>> On 06.06.2019 16:13, J. Bruce Fields wrote:
>>>>> On Thu, Jun 06, 2019 at 10:47:43AM +0300, Kirill Tkhai wrote:
>>>>>> This may be connected with that shrinker unregistering is forgotten on error path.
>>>>>
>>>>> I was wondering about that too.  Seems like it would be hard to hit
>>>>> reproduceably though: one of the later allocations would have to fail,
>>>>> then later you'd have to create another namespace and this time have a
>>>>> later module's init fail.
>>>>
>>>> Yes, it's had to bump into this in real life.
>>>>
>>>> AFAIU, syzbot triggers such the problem by using fault-injections
>>>> on allocation places should_failslab()->should_fail(). It's possible
>>>> to configure a specific slab, so the allocations will fail with
>>>> requested probability.
>>>
>>> No fault injection was involved in triggering of this bug.
>>> Fault injection is clearly visible in console log as "INJECTING
>>> FAILURE at this stack track" splats and also for bugs with repros it
>>> would be noted in the syzkaller repro as "fault_call": N. So somehow
>>> this bug was triggered as is.
>>>
>>> But overall syzkaller can do better then the old probabilistic
>>> injection. The probabilistic injection tend to both under-test what we
>>> want to test and also crash some system services. syzkaller uses the
>>> new "systematic fault injection" that allows to test specifically each
>>> failure site separately in each syscall separately.
>>
>> Oho! Interesting.
> 
> If you are interested. You write N into /proc/thread-self/fail-nth
> (say, 5) then it will cause failure of the N-th (5-th) failure site in
> the next syscall in this task only. And by reading it back after the
> syscall you can figure out if the failure was indeed injected or not
> (or the syscall had less than 5 failure sites).
> Then, for each syscall in a test (or only for one syscall of
> interest), we start by writing "1" into /proc/thread-self/fail-nth; if
> the failure was injected, write "2" and restart the test; if the
> failure was injected, write "3" and restart the test; and so on, until
> the failure wasn't injected (tested all failure sites).
> This guarantees systematic testing of each error path with minimal
> number of runs. This has obvious extensions to "each pair of failure
> sites" (to test failures on error paths), but it's not supported atm.

And what you do in case of a tested syscall has pre-requisites? Say,
you test close(), which requires open() and some IO before. Are such
the dependencies statically declared in some configuration file? Or
you test any repeatable sequence of syscalls?

Kirill

