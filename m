Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A80C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 07:38:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1A032133D
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 07:38:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1A032133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8BE6B0005; Sun, 16 Jun 2019 03:38:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 369538E0002; Sun, 16 Jun 2019 03:38:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 258428E0001; Sun, 16 Jun 2019 03:38:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFCAA6B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 03:38:44 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id i16so2509721oie.1
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 00:38:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=wmP7cfILR/PPevPT+j1b6ha+Bwoun8R2YbTlFnrgACo=;
        b=LavDXg1q4GTJ41qxeUgqtRQ7IvSYZZ+Xnudb3zBs0VbxmEaTgX0HBZn5lvnCn0C9nU
         mKM30WEmqz6ggks/PgUh+k4ocSDuauFMSr58HcgupxDCsnfkSYgg5VMKY6sP5FoWikBn
         VA8798UvBbvzFYPxY4ncKvkxfl/iQnSdsOAVT7AOdOU4DU9Fty355Z9EnjwlZ0abQUhb
         CUk5nnMh5MUA9Ej+pX66PG4mvs38wPeOOAcoE73MCbHCJ7rucy0tDl2e0/84hAaIuqii
         QtVgIdjEWE8ZSvTX69k7RQ+CGTGSzLCJ63NhoxT5DWjOV2aE2NdyyEYuPGe4GgQiLnPZ
         3SlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXnpnlJ6JVV/rfEsLp9QN23aGq+f/qL/Rlfvf1kRKqmi5hpVBDe
	PqiHD7LDul7ydKs1J3w+a5fGKFChJps0D0F87UAWRqbk/RmWHDEclFJp5pELhm9SZXKDnTiTfjg
	3IH8PhwMMTwdpjQDvl0jUnCW8zMFi9Lolct4AUMMPS7y1q57e4u7enCijLFVnBB49KA==
X-Received: by 2002:aca:c715:: with SMTP id x21mr7344860oif.142.1560670724607;
        Sun, 16 Jun 2019 00:38:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+/5l/+zd5CFiiV0r1VGlVmplSvlBNz2AEC808F3H310TGNAuG4D5055A4W74CCPYPC4UK
X-Received: by 2002:aca:c715:: with SMTP id x21mr7344838oif.142.1560670723929;
        Sun, 16 Jun 2019 00:38:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560670723; cv=none;
        d=google.com; s=arc-20160816;
        b=QKWHYr84a0so/sNqsydISBbhO+2pN9/gWBQ/90/KpXdTxUJTDQ/FTOpOB7R6fYaH/w
         6nXug9lKgsWGQkvjyJUwvWJ4VptdHjsMje0TamdELG/LIx4jZW7IDLlhGeGevNWfeFEB
         T5IXJZ8wvU74INI4NoC5EwyNHZBYB/NwwfMMQpm3vc1WO+QoD0KmBJmgp9P3qRgZhnI3
         LiTXk1+8EPLGHCGRALXdEEQtA5HucgHVl0q0y4h8oyDhfesPv055zbsoMSTP3m/5scSv
         duMwlIcjcJs7Ie/BIrhDitFuBFDDcZsWGNDmK3VB57tz1nsx8BSwshBlqa3dLPBB2xmm
         uqXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=wmP7cfILR/PPevPT+j1b6ha+Bwoun8R2YbTlFnrgACo=;
        b=zu+MKL26NQWpiKfYa8UNngLum+n5/CSzOa32f1j+FH4s62OeVxUd+Xpp0GE6U/xGkQ
         r1dgt91Xwol3isz2o+ZFBXAWKzlZg8d8eq52oPNW1bdAvxnXXLeZyEFugTmvXEuOxa+3
         uvaVjW8qwaRO49vXPfkvh4p2a+PtppJv93sYC4PJifA1A1lsiKqYwv7SMaRCm8zXEhbC
         jYzinLgm1pNv/T38trBvZUHflbAKzt0Bdvg31wewKESoiwABPwMZK2UckePeVjDSt2fb
         tKKF1TNNNrhwG+xjp3iFxrj3Ap83ln4VOlRzFcKRyzUyep1I3QNtN+tS0q57xc6XicgS
         3pcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 5si5134405oto.141.2019.06.16.00.38.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 00:38:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav402.sakura.ne.jp (fsav402.sakura.ne.jp [133.242.250.101])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5G7bvkZ065479;
	Sun, 16 Jun 2019 16:37:57 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav402.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp);
 Sun, 16 Jun 2019 16:37:57 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5G7bv3f065476
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sun, 16 Jun 2019 16:37:57 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: general protection fault in oom_unkillable_task
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
        syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
        syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
        yuzhoujian@didichuxing.com
References: <0000000000004143a5058b526503@google.com>
 <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz>
 <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
 <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
 <CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
 <791594c6-45a3-d78a-70b5-901aa580ed9f@i-love.sakura.ne.jp>
Message-ID: <840fa9f1-07e2-e206-2fc0-725392f96baf@i-love.sakura.ne.jp>
Date: Sun, 16 Jun 2019 16:37:56 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <791594c6-45a3-d78a-70b5-901aa580ed9f@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/16 6:33, Tetsuo Handa wrote:
> On 2019/06/16 3:50, Shakeel Butt wrote:
>>> While dump_tasks() traverses only each thread group, mem_cgroup_scan_tasks()
>>> traverses each thread.
>>
>> I think mem_cgroup_scan_tasks() traversing threads is not intentional
>> and css_task_iter_start in it should use CSS_TASK_ITER_PROCS as the
>> oom killer only cares about the processes or more specifically
>> mm_struct (though two different thread groups can have same mm_struct
>> but that is fine).
> 
> We can't use CSS_TASK_ITER_PROCS from mem_cgroup_scan_tasks(). I've tried
> CSS_TASK_ITER_PROCS in an attempt to evaluate only one thread from each
> thread group, but I found that CSS_TASK_ITER_PROCS causes skipping whole
> threads in a thread group (and trivially allowing "Out of memory and no
> killable processes...\n" flood) if thread group leader has already exited.

Seems that CSS_TASK_ITER_PROCS from mem_cgroup_scan_tasks() is now working.
Maybe I was confused due to without commit 7775face207922ea ("memcg: killed
threads should not invoke memcg OOM killer"). We can scan one thread from
each thread group, and remove

	/* Prefer thread group leaders for display purposes */
	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
		goto next;

check.

