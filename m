Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 186DDC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:15:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82ED320866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:15:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="Z3ugz+Ff"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82ED320866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23B596B0003; Thu, 13 Jun 2019 04:15:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EB5F6B0005; Thu, 13 Jun 2019 04:15:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C946B0006; Thu, 13 Jun 2019 04:15:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93EFF6B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:15:55 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id v2so3079784lja.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:15:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3Pp0FZ+SZZPig9cVc4N4kq00quoG1v3rR/FRnc5nQlo=;
        b=DjiWfgZtRHNr2vDCcsk7MMnD0FfQto89LYFhwzpafGJOmMsF4xz7dVMSuTJfSsyVHy
         DdUmCalhAIr1W7vURfF4MtZavHfXnzHQvMhG/FpLcuONhg5TabbK0aQLD0KJus4thoBu
         yzYBSczCVJJKIgkXvWg5eZDW/hVfN8mJ1b0KPCYBMvtgRYF5R97X6n7525a1O7mba5jq
         MXiE0/Cs/DPOpX1wd9LcuEPWoclUwnyYkjM8tR0G7Tg6+YOYkREj+MU/nGpMJtbot4Pn
         Gz876F4Chc5gI+sRi6txH97cKTGpm7KFrfkYbAASJrdrwcFFp1Pbki0101ZWBSOZVgHh
         KaiA==
X-Gm-Message-State: APjAAAUqW/R8RRMBcw36Y+SfQstmMAobpnMBfHgle8qB/R8hPD1MGcWz
	+vJ2meROdpMZJC43vHskEQ94uczVKLHsgxd0BYFsq2F4z8uz7P71Y737eyhJLIFd9dwDKLySbVr
	VUAy4JFUscBB+7FQ2dmlvIvC9dfzJMo6/QreNe1OlYdOyMFLr3RgN67ADhfufijW5yQ==
X-Received: by 2002:a05:651c:92:: with SMTP id 18mr19427598ljq.35.1560413754741;
        Thu, 13 Jun 2019 01:15:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyWH5pRxIVuJ8Hs4zZATBnQYOHnW8abyNEnviCtgSYAdzUocJ1rNGe7IBFUvxd4fYEb/Sq
X-Received: by 2002:a05:651c:92:: with SMTP id 18mr19427564ljq.35.1560413753911;
        Thu, 13 Jun 2019 01:15:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560413753; cv=none;
        d=google.com; s=arc-20160816;
        b=Idx0u+3CfUgtd6JcndSbru9pb7jTburpstEYM0ZoISQ/ZAaQ8X7v8EdIl16qxV5PqK
         vT5eHbuc8egzqDL6w1dZknJJCzwCJB0wbBDvD2EdLLzNgiIJp8pUy/9wR3TojWNQRsax
         zn20KK9nAb594GCl6qvEBxDAGwASERrH34rP0JLsfAZ/J4XZlact8py6u2768v56WDlo
         UBDymZDcO6Dt1zuiPkK/OOtpebRTpJUAXxnW8jnBugdJP7TmQJO8v+fy0Ox745B+unNA
         SdifDI9y6ijzSwJqC8gW5SABdmVOP/SVLoL1c0QA4iabm2iUHkzJUn+Q6tOJZA8OtLVA
         7iag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=3Pp0FZ+SZZPig9cVc4N4kq00quoG1v3rR/FRnc5nQlo=;
        b=A+/+qE8uUDscv/dcHMtoRWsCY1/wZhuGLARHimMRSUK8F77S0EXfNsFoMa21XfhWtK
         Skh9+f6GEVettDY6MzoTsSGeRNF8tsPMsi5ExJ8yg7Hk+qg9ofTAXdBuMTORixu6pF2E
         BAQ/vTejzGXwxKNZsaqeoqor4DpG4lxpM4OuIi7YfVgo5QPzbGCY08HfeCuqfJdrwX9N
         7olXsoWr2swYtotMZkwHVEwLmy7TGg3WaZWVCrNP+6odvQhIvaZhFS1oiVPGZh7zm4RC
         0tJbyv1gr0oee+lJCySm2R3g/TnD4fDKicvn/50d7N0Oh5NhlFTZssIdvng9bEXFfQvr
         Lt5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=Z3ugz+Ff;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTPS id y11si2049651lfe.38.2019.06.13.01.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 01:15:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=Z3ugz+Ff;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 2D01A2E0DEC;
	Thu, 13 Jun 2019 11:15:53 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id r33Oi2NKnn-FpIOJvba;
	Thu, 13 Jun 2019 11:15:53 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560413753; bh=3Pp0FZ+SZZPig9cVc4N4kq00quoG1v3rR/FRnc5nQlo=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=Z3ugz+Ff549FVPYbsW1FwYyvrcEZnCU0PtHmVPrvXyN4Lwa+e0Ncw0EPOZxhQcz1O
	 k69Sg5wa/tGpn+qp7b9yMZ/YcGaHrZ4YTLLl0asqjhVGNUXzHC+405WiI7iP38ZC3h
	 78oUFV1856+tDNRRZcBk4TrEGY0so2vdR+NqmNSc=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:a1b1:2ca9:8cc0:4c56])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id ued3RSeVec-FoYS30hb;
	Thu, 13 Jun 2019 11:15:51 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH v2 5/6] proc: use down_read_killable mmap_sem for
 /proc/pid/map_files
To: Andrei Vagin <avagin@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>,
 Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>,
 Dmitry Safonov <dima@arista.com>
References: <156007465229.3335.10259979070641486905.stgit@buzz>
 <156007493995.3335.9595044802115356911.stgit@buzz>
 <20190612231426.GA3639@gmail.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <f15478b5-098f-e1be-0928-62f46cff77e7@yandex-team.ru>
Date: Thu, 13 Jun 2019 11:15:50 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190612231426.GA3639@gmail.com>
Content-Type: text/plain; charset=koi8-r; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.06.2019 2:14, Andrei Vagin wrote:
> On Sun, Jun 09, 2019 at 01:09:00PM +0300, Konstantin Khlebnikov wrote:
>> Do not stuck forever if something wrong.
>> Killable lock allows to cleanup stuck tasks and simplifies investigation.
> 
> This patch breaks the CRIU project, because stat() returns EINTR instead
> of ENOENT:
> 
> [root@fc24 criu]# stat /proc/self/map_files/0-0
> stat: cannot stat '/proc/self/map_files/0-0': Interrupted system call

Good catch.

It seems CRIU tests has good coverage for darkest corners of kernel API.
Kernel CI projects should use it. I suppose you know how to promote this. =)

> 
> Here is one inline comment with the fix for this issue.
> 
>>
>> It seems ->d_revalidate() could return any error (except ECHILD) to
>> abort validation and pass error as result of lookup sequence.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Reviewed-by: Roman Gushchin <guro@fb.com>
>> Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
>> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> It was nice to see all four of you in one place :).
> 
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> ---
>>   fs/proc/base.c |   27 +++++++++++++++++++++------
>>   1 file changed, 21 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/proc/base.c b/fs/proc/base.c
>> index 9c8ca6cd3ce4..515ab29c2adf 100644
>> --- a/fs/proc/base.c
>> +++ b/fs/proc/base.c
>> @@ -1962,9 +1962,12 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
>>   		goto out;
>>   
>>   	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
>> -		down_read(&mm->mmap_sem);
>> -		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
>> -		up_read(&mm->mmap_sem);
>> +		status = down_read_killable(&mm->mmap_sem);
>> +		if (!status) {
>> +			exact_vma_exists = !!find_exact_vma(mm, vm_start,
>> +							    vm_end);
>> +			up_read(&mm->mmap_sem);
>> +		}
>>   	}
>>   
>>   	mmput(mm);
>> @@ -2010,8 +2013,11 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
>>   	if (rc)
>>   		goto out_mmput;
>>   
>> +	rc = down_read_killable(&mm->mmap_sem);
>> +	if (rc)
>> +		goto out_mmput;
>> +
>>   	rc = -ENOENT;
>> -	down_read(&mm->mmap_sem);
>>   	vma = find_exact_vma(mm, vm_start, vm_end);
>>   	if (vma && vma->vm_file) {
>>   		*path = vma->vm_file->f_path;
>> @@ -2107,7 +2113,10 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
>>   	if (!mm)
>>   		goto out_put_task;
>>   
>> -	down_read(&mm->mmap_sem);
>> +	result = ERR_PTR(-EINTR);
>> +	if (down_read_killable(&mm->mmap_sem))
>> +		goto out_put_mm;
>> +
> 
> 	result = ERR_PTR(-ENOENT);
> 
>>   	vma = find_exact_vma(mm, vm_start, vm_end);
>>   	if (!vma)
>>   		goto out_no_vma;
>> @@ -2118,6 +2127,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
>>   
>>   out_no_vma:
>>   	up_read(&mm->mmap_sem);
>> +out_put_mm:
>>   	mmput(mm);
>>   out_put_task:
>>   	put_task_struct(task);
>> @@ -2160,7 +2170,12 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
>>   	mm = get_task_mm(task);
>>   	if (!mm)
>>   		goto out_put_task;
>> -	down_read(&mm->mmap_sem);
>> +
>> +	ret = down_read_killable(&mm->mmap_sem);
>> +	if (ret) {
>> +		mmput(mm);
>> +		goto out_put_task;
>> +	}
>>   
>>   	nr_files = 0;
>>   

