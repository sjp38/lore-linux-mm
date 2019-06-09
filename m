Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B96D7C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 09:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F46220868
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 09:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="0jVhzKzl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F46220868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 907626B0005; Sun,  9 Jun 2019 05:07:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B9396B0006; Sun,  9 Jun 2019 05:07:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A6B06B0007; Sun,  9 Jun 2019 05:07:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 181716B0005
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 05:07:40 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id v23so724594ljj.1
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 02:07:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=41wRH7O1RjuIycZL3bPObSY6mj/mQBPhNsOrunGAB0I=;
        b=fZ3Ke/3RhE0fnyHdVYQlZUQNKXSOlrxdjw2WhVXaSkDun+2QfrnHWauAYKYQIJu930
         rvMGMkJFBao2PEqeJqYUFNuWMKwagSqSG0TCsKFUzqDsxyFFDTIehm6oBglFwpJAczcr
         Srg5QRVfBLfZ1pqceINbyDNqDXdQj0FHPvwCOJlbe9RVwkS3ZWbtLUkpBijeylBasTWS
         rdXkukl87nU5i6kvjodoJzeAnSfjKDFmuH3aFhkeeWyMyjflAvII36ToYrW9a/0r1R5d
         +Kbf+xbqRrGoZs4gSPSo2BtSRlyhoVJK74IUwDAMewd9pIwI4/RN3Eln+MFZaSvD5EVv
         DmaA==
X-Gm-Message-State: APjAAAXHzs1S4NGKKRQfa8avaoHeJVaF884MbDx3/3akGYnrCdxpc56j
	cV9oTeIHmSKtsIWmjmHcJ3RzdXahpjljwrpevwy+0ClSCZAunLPnYdVkbEBQLfwmK/6S7OQ1Evx
	kG0BCsF457+5pvw9BIZcdMkJ+gS0DiQqMEArhN/orDvuC/n0wVkELVBnasgsfHWa3kQ==
X-Received: by 2002:a2e:b0c4:: with SMTP id g4mr5927287ljl.155.1560071259254;
        Sun, 09 Jun 2019 02:07:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGStZY7uGCFBBZGQ3meCx2Wa5eJstIkDUMZYQ5TP+jstmnhFAki9G7Qjma/Ud5pELChm/9
X-Received: by 2002:a2e:b0c4:: with SMTP id g4mr5927251ljl.155.1560071258217;
        Sun, 09 Jun 2019 02:07:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560071258; cv=none;
        d=google.com; s=arc-20160816;
        b=Pqqg1tqfqMFa7y5tvVLuSyaEsf+EI1Zqdl9THKreWh1ZWnZTTLrwI9izfJ+LcwTqGr
         qhpwY7LUkpghRH8e9aTjy5YZI0D3xFPol2ZqYHD3TkK9jABbrMJEHc/E1UVmL1UVtXHA
         uD/O86p8tiXMcex7xAEOpNcPfjIBc3GabaHuOhELwu9Cyr9SdWp1Cp2AvFQ57TmjHPpG
         HOvSTKZtljkqukDy/CSDkz+3XSrQdJbtMLmE2I3vOv2UumysTxAoj1pKAFeKWquqC89f
         zVB18gNC2H5KiuPLwtRAsL1kr5redLExuTm4peTBNqctAceh7As5lEHMlv+HQpYWYb6/
         CUmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=41wRH7O1RjuIycZL3bPObSY6mj/mQBPhNsOrunGAB0I=;
        b=PnyuMevePMvIt3XOxmHOz+zsCr8ODFeim2OQD6y7YcZslK0LhkFEclPsdW3CO1YeYm
         DweeDZ2hu+b72gPB479tGBOeBSnHd7PmpzxNMiQhYJTyv6WGsNyATDc2hUvQut+fBdaS
         g9yJ0s1GoFyy4I/5ckcvL1wUXNb+eMkwSxftmvkS/3Dl62+O7Qy3VUzF/2DLrdhcEwPM
         XJqtn0iy+gfEc8SBJpmBaODVWF2WhsOvCuuUdZra2EwhloY/iNHgODpphZ18/Q3ODsxM
         Ei4qRO2IJN92itZ3JXFfiJWzWW33RV6rrDrETZeoWFwpdWlJ0Dtp/qyTrEstBsWqzMMj
         kIGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=0jVhzKzl;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id y18si5995821lfh.18.2019.06.09.02.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 02:07:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=0jVhzKzl;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 521032E124D;
	Sun,  9 Jun 2019 12:07:37 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id BaPFd0wpux-7aOmKXh4;
	Sun, 09 Jun 2019 12:07:37 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560071257; bh=41wRH7O1RjuIycZL3bPObSY6mj/mQBPhNsOrunGAB0I=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=0jVhzKzlm7ekF4gqCcSRHE3zB0d1+MmxgUtbU/fZQ52gJg7IzdFK1aIjhwNxQnUux
	 2sha+8LU3Ip2YddsJOh0RTALXTtaKQBSjaxzbtoQgwIS/qk8wb600Nuaghzruo9WfZ
	 WuH8FrXwUzjYH8knG4DqeBrfK+Z8L2zfxeb1lA2Y=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id F3GBYaKJYR-7aemMl4x;
	Sun, 09 Jun 2019 12:07:36 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 2/5] proc: use down_read_killable for
 /proc/pid/smaps_rollup
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>, Al Viro <viro@zeniv.linux.org.uk>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
 <155790967469.1319.14744588086607025680.stgit@buzz>
 <20190517124555.GB1825@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <bda80d9c-7594-94c9-db2c-37b8bc3b58c8@yandex-team.ru>
Date: Sun, 9 Jun 2019 12:07:36 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190517124555.GB1825@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 17.05.2019 15:45, Michal Hocko wrote:
> On Wed 15-05-19 11:41:14, Konstantin Khlebnikov wrote:
>> Ditto.
> 
> Proper changelog or simply squash those patches into a single patch if
> you do not feel like copy&paste is fun
> 
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> ---
>>   fs/proc/task_mmu.c |    8 ++++++--
>>   1 file changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 2bf210229daf..781879a91e3b 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -832,7 +832,10 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
>>   
>>   	memset(&mss, 0, sizeof(mss));
>>   
>> -	down_read(&mm->mmap_sem);
>> +	ret = down_read_killable(&mm->mmap_sem);
>> +	if (ret)
>> +		goto out_put_mm;
> 
> Why not ret = -EINTR. The seq_file code seems to be handling all errors
> AFAICS.
> 

I've missed your comment. Sorry.

down_read_killable returns 0 for success and exactly -EINTR for failure.

>> +
>>   	hold_task_mempolicy(priv);
>>   
>>   	for (vma = priv->mm->mmap; vma; vma = vma->vm_next) {
>> @@ -849,8 +852,9 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
>>   
>>   	release_task_mempolicy(priv);
>>   	up_read(&mm->mmap_sem);
>> -	mmput(mm);
>>   
>> +out_put_mm:
>> +	mmput(mm);
>>   out_put_task:
>>   	put_task_struct(priv->task);
>>   	priv->task = NULL;
> 

