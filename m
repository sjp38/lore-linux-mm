Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E58AC31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 06:30:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B6D4216C8
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 06:30:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B6D4216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2ADC6B0005; Sun, 16 Jun 2019 02:30:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DC836B0006; Sun, 16 Jun 2019 02:30:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CABB8E0001; Sun, 16 Jun 2019 02:30:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58E9F6B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 02:30:20 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so5215531pgh.11
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 23:30:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=fFEA8zdSlEnQuWcdFSG3Cpntvj8uFz7RX2klKKQGmWI=;
        b=eyQ8JtpeGrb11d6GeHujfNh1Ds/orsmQy/+JJpm/FiuIg+dDCFDUF3TWitpSocl7Ve
         7NkcUSOJ84CjVNTrPOFIvTZf9GD8S9CzH22M1whw4TonzM7OqmEp2v6NawWZafqWF5Tq
         qPzkvCyc/2yLxbPzJpG3ozpAaPaeJupLTRH/5w9yKPBf6sVdQEjtlJEmhxOWiYBd2UpW
         lNCSBTnq2/sSV12Rz4esH4W4iPNprbkk84D5K4DcB4ES2Xw7l/SeSEJ2DVUroiVZNMnw
         g7ZFza2XiXWgIrR6m7bdaNeK2xxCNK1a5hBtGfvE2aORQVueC5Rzj9rwkoRemBowezX8
         P1sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUuueJLaIPn+YpB8UE9qk+FhAIJj5oryk0sNhkMecuRw87NLZBd
	f6BEZaBwngT8RppNFZ2+lhJH6eRNK8lfeXczWwnrJPLunt1lKk231aQaOnkl70Irt7/8gcmySN9
	2kVylrO81xPt2MPXE+HBNAtlAx8Lpw+uo0jlpCviN1SC7/LbK94OkVSFgRPjE3TFfgA==
X-Received: by 2002:a63:6a47:: with SMTP id f68mr24930119pgc.230.1560666619810;
        Sat, 15 Jun 2019 23:30:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEfxVZkQr+KGxWotEu9f6Zs+u1raIXpodJXg6GhC+1dC7VI+CrcFneIvDhqJbG+PELWbwU
X-Received: by 2002:a63:6a47:: with SMTP id f68mr24930044pgc.230.1560666618795;
        Sat, 15 Jun 2019 23:30:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560666618; cv=none;
        d=google.com; s=arc-20160816;
        b=afCy+svh/bYQA1vD9EchSBPwb13kDN5Cs81i2h9umZutMqN3Kr+uMr+tUGJ+6esjZT
         VL8Cmy7npkOLHmP5cGVCfHWRh0hyZFkSjtCCk28kue1OTwkjM4vHN2TYk02fSbW6QyYv
         GQjrJXGYHokT4Y2kPy1wMdKB5YaWa7oJALIDoz28y8p7HnPb76BTiAtvWiUQ9ET8kND8
         yfY/sohuAHhiGmQP8XHvfYYGsj3QMb+BzW+uXWq031oBNC0x7XVHqflCuvMgtP4HMAlB
         D3BJTQQEAHS7YzI5z1/cUChrJwNT+kDYte+g+wMy/EIRerp3aEEL3iJJVPH3z9PYSrWJ
         D6QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject:reply-to;
        bh=fFEA8zdSlEnQuWcdFSG3Cpntvj8uFz7RX2klKKQGmWI=;
        b=nTQAXnpca9FEKGCTI7CMjmlL/lnCgU4SyzyTDdgKq/z3BoQpfklVV7KhZCx1sWIAi3
         rIxEYyVRKOmo5qIBZYaSE7Jv/RUPn/w1ao6ofAVVtDo8KrJLE58jkd0nCQmOGHfUPMB4
         GnZHZEHhTm98Xb9SQ+xiGRdq22MEJITqSE+KkLzYiqZxZ/99kheDKZDlY11KbHtV+dGt
         kM8uiJsqrh82Q0047Aj20RjVbeNd2Sd2J8NuSJ4s7thGgYFNmXEV1LXp665NJhGmxpRK
         mKHLpoiOHd/xZ2UtehAdTa/v4XNLBOw0FR4UV/mtjWpcNOAujWHkQuWazE0+GIbhuuhU
         rPIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id s3si7242827pgm.208.2019.06.15.23.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 23:30:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=xlpang@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TUIXG5o_1560666600;
Received: from xunleideMacBook-Pro.local(mailfrom:xlpang@linux.alibaba.com fp:SMTPD_---0TUIXG5o_1560666600)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sun, 16 Jun 2019 14:30:01 +0800
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH] memcg: Ignore unprotected parent in
 mem_cgroup_protected()
To: Chris Down <chris@chrisdown.name>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190615111704.63901-1-xlpang@linux.alibaba.com>
 <20190615160820.GB1307@chrisdown.name>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <711f086e-a2e5-bccd-72b6-b314c4461686@linux.alibaba.com>
Date: Sun, 16 Jun 2019 14:30:00 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190615160820.GB1307@chrisdown.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001028, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chirs,

On 2019/6/16 AM 12:08, Chris Down wrote:
> Hi Xunlei,
> 
> Xunlei Pang writes:
>> Currently memory.min|low implementation requires the whole
>> hierarchy has the settings, otherwise the protection will
>> be broken.
>>
>> Our hierarchy is kind of like(memory.min value in brackets),
>>
>>               root
>>                |
>>             docker(0)
>>              /    \
>>         c1(max)   c2(0)
>>
>> Note that "docker" doesn't set memory.min. When kswapd runs,
>> mem_cgroup_protected() returns "0" emin for "c1" due to "0"
>> @parent_emin of "docker", as a result "c1" gets reclaimed.
>>
>> But it's hard to maintain parent's "memory.min" when there're
>> uncertain protected children because only some important types
>> of containers need the protection.  Further, control tasks
>> belonging to parent constantly reproduce trivial memory which
>> should not be protected at all.  It makes sense to ignore
>> unprotected parent in this scenario to achieve the flexibility.
> 
> I'm really confused by this, why don't you just set memory.{min,low} in
> the docker cgroup and only propagate it to the children that want it?
> 
> If you only want some children to have the protection, only request it
> in those children, or create an additional intermediate layer of the
> cgroup hierarchy with protections further limited if you don't trust the
> task to request the right amount.
> 
> Breaking the requirement for hierarchical propagation of protections
> seems like a really questionable API change, not least because it makes
> it harder to set systemwide policies about the constraints of
> protections within a subtree.

docker and various types(different memory capacity) of containers
are managed by k8s, it's a burden for k8s to maintain those dynamic
figures, simply set "max" to key containers is always welcome.

Set "max" to docker also protects docker cgroup memory(as docker
itself has tasks) unnecessarily.

This patch doesn't take effect on any intermediate layer with
positive memory.min set, it requires all the ancestors having
0 memory.min to work.

Nothing special change, but more flexible to business deployment...

