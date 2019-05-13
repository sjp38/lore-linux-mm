Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61860C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8B46208C2
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 10:38:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8B46208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 332B06B0279; Mon, 13 May 2019 06:38:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E3A66B027A; Mon, 13 May 2019 06:38:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D1506B027B; Mon, 13 May 2019 06:38:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE4626B0279
	for <linux-mm@kvack.org>; Mon, 13 May 2019 06:38:56 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id l10so428915ljj.18
        for <linux-mm@kvack.org>; Mon, 13 May 2019 03:38:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9Li4SO9HMenFNFq/6Vli8uiQ34IKkiUmLjzOGtl6ymg=;
        b=jhVXdMKsjbhfb+JSc2iAKp/u1jp3YXbg7YrsX5pm1zCPwmVi4Q+q1k4GTKRFkR9ids
         kaNVoGN0Y/4mFzqZXeLwwurL+TKOZ8ysBNmJmsymESW5UTPb1mlH2YfB00vYiTCDefxD
         lKJiAkbYfPN2rGcNgCmYJ9egxy92PVAS8Z1jolpu9xqwy1FO9gzyf9KZ/AdZaVrfapxw
         AzTevYx/IV4zxhJ2Mgm/MomZVXZqRr9+WRqEl/nJzda7Qm8k15ZSucb2PSGodkZx0b5v
         0XaGPPrzUxL4TOyzBXefccuHA/H+BjtV12kONMxGI1Ye2ip2qrjp1B1GFi2Lpihj4a8r
         scNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUS7ldooFkwcI5JReI/h2CUUEWuHQem38IY/xRkCAWHyuq1hy0m
	dzYKixuzq/sQXpKeWMC9hk27TYUZBPOiWa+z8WXR7uU0ABWSyoF+89pSZQWEnPzD0OLzxBFZe9j
	hrvltHpryo2tX2GqpdPqt/0Ynbl4qrFAe/J9HD4+X9OBHCxWs2hIOEn4yJxsHXbvBaQ==
X-Received: by 2002:a2e:4b19:: with SMTP id y25mr12388517lja.149.1557743935926;
        Mon, 13 May 2019 03:38:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7ZK7qFDlzGfus94y7gz0Ig369fVzOB434qZs6qxxl6SF5l5+w1jL68bFzj8lJWHjMOWip
X-Received: by 2002:a2e:4b19:: with SMTP id y25mr12388478lja.149.1557743934898;
        Mon, 13 May 2019 03:38:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557743934; cv=none;
        d=google.com; s=arc-20160816;
        b=hzA3UVXa8p+yhvhwjtmp78DAS/Kue7BykKO3xV3k0TOw2MlI0Unzvj6dSvW7jX8uGe
         UgRPuDh/aN5vYr6ZH3wL0qc2NsNuFHUj/UGfellB0qF+by2ADu3Ksyhzcqx+DJABfb/Y
         zEgVrr+02xfOESO7iFAWhuycHwu0GSfH4uXbbrBQQsw188iVt5z5RyeRXyVYQzsC8T/S
         eREXHdlYrW/R4W6wwHZ9AYrNjqadhcebQQIpSNBZCZlzHy5OaN1PFwwiuEQRwDZzJpwN
         ICeAXLahcCu9jtYgtclbPwy5XsLrEBPMVnF4yg3/nJrZQ1kSAwM9kBFRTwkFLszqdqLj
         uXSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=9Li4SO9HMenFNFq/6Vli8uiQ34IKkiUmLjzOGtl6ymg=;
        b=vyah6oTh/BWSkiq8o/QL1uI0ydbsY7HksKgkyrU7jwSrzHEkRbp4k9v4qCeNBfXo5a
         sFAFtnsRTpFRTVwyWGHB8nMMSx13QElg5HS0ue23X3INv62zfVnI8yUzF5MN5E6/Q6Th
         Tf0gb4sNEPsCYof4ee6NQZqXjK9glQ8Y7qslKy+5gSX1tan9+ZUE7r1e05nYpw2r7/yO
         03qsATKny+6qjJfsmgoRJPj8Iv/2Zajlfa4vK2+kXpzm+CbI49p9j158crQbS5nSot1Q
         gZkZirStaN6pIyuV4ozwlHxVtUttJmZzhXs8W8+wcnPijxKvGHf1oTeIsxXCCE/KqjnB
         39yA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id p7si10125806ljh.25.2019.05.13.03.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 03:38:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQ8M3-0005RO-PD; Mon, 13 May 2019 13:38:48 +0300
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
To: Oleksandr Natalenko <oleksandr@redhat.com>, linux-kernel@vger.kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>,
 Pavel Tatashin <pasha.tatashin@oracle.com>,
 Timofey Titovets <nefelim4ag@gmail.com>, Aaron Tomlin <atomlin@redhat.com>,
 linux-mm@kvack.org
References: <20190510072125.18059-1-oleksandr@redhat.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
Date: Mon, 13 May 2019 13:38:43 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190510072125.18059-1-oleksandr@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Oleksandr,

On 10.05.2019 10:21, Oleksandr Natalenko wrote:
> By default, KSM works only on memory that is marked by madvise(). And the
> only way to get around that is to either:
> 
>   * use LD_PRELOAD; or
>   * patch the kernel with something like UKSM or PKSM.
>
> Instead, lets implement a so-called "always" mode, which allows marking
> VMAs as mergeable on do_anonymous_page() call automatically.
>
> The submission introduces a new sysctl knob as well as kernel cmdline option
> to control which mode to use. The default mode is to maintain old
> (madvise-based) behaviour.
>
> Due to security concerns, this submission also introduces VM_UNMERGEABLE
> vmaflag for apps to explicitly opt out of automerging. Because of adding
> a new vmaflag, the whole work is available for 64-bit architectures only.
>> This patchset is based on earlier Timofey's submission [1], but it doesn't
> use dedicated kthread to walk through the list of tasks/VMAs.
> 
> For my laptop it saves up to 300 MiB of RAM for usual workflow (browser,
> terminal, player, chats etc). Timofey's submission also mentions
> containerised workload that benefits from automerging too.

This all approach looks complicated for me, and I'm not sure the shown profit
for desktop is big enough to introduce contradictory vma flags, boot option
and advance page fault handler. Also, 32/64bit defines do not look good for
me. I had tried something like this on my laptop some time ago, and
the result was bad even in absolute (not in memory percentage) meaning.
Isn't LD_PRELOAD trick enough to desktop? Your workload is same all the time,
so you may statically insert correct preload to /etc/profile and replace
your mmap forever.

Speaking about containers, something like this may have a sense, I think.
The probability of that several containers have the same pages are higher,
than that desktop applications have the same pages; also LD_PRELOAD for
containers is not applicable. 

But 1)this could be made for trusted containers only (are there similar
issues with KSM like with hardware side-channel attacks?!); 2) the most
shared data for containers in my experience is file cache, which is not
supported by KSM.

There are good results by the link [1], but it's difficult to analyze
them without knowledge about what happens inside them there.

Some of tests have "VM" prefix. What the reason the hypervisor don't mark
their VMAs as mergeable? Can't this be fixed in hypervisor? What is the
generic reason that VMAs are not marked in all the tests?

In case of there is a fundamental problem of calling madvise, can't we
just implement an easier workaround like a new write-only file:

#echo $task > /sys/kernel/mm/ksm/force_madvise

which will mark all anon VMAs as mergeable for a passed task's mm?

A small userspace daemon may write mergeable tasks there from time to time.

Then we won't need to introduce additional vm flags and to change
anon pagefault handler, and the changes will be small and only
related to mm/ksm.c, and good enough for both 32 and 64 bit machines.

Thanks,
Kirill

