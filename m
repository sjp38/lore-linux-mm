Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65D2EC04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 05:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 219C020818
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 05:54:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 219C020818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D50B6B0005; Thu, 16 May 2019 01:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95F006B0006; Thu, 16 May 2019 01:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D88C6B0007; Thu, 16 May 2019 01:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A67F6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 01:54:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j1so1491185pff.1
        for <linux-mm@kvack.org>; Wed, 15 May 2019 22:54:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=c10NYquO1ht2u06DTAd38ZAXwFqiIhzEP7wfD1Lo0XE=;
        b=cq40CwXP2zSobjFIb3mKLfbhApX3gfnU/OGWDvPW84q60/pmoe29buhGcVYTYX5WeB
         Dd87ehdNOPV3qlEjcUAnIdOp4CBRYTDMoGIdPPPD1cuF2w+LXqOpU/RGwe/LLAhV5S4A
         pUkeb4DfFaAFuvlP+X8cfvCg90j2aX8dPVf/y424mMY5DSWBptZh3CW5Qb4ihTftdNBM
         qJl8O7fCAGhBS7ViGO7ZVEwuwxNY0HCABtcXrvhQSq1JYTb2iAhH9yareCKSQSHZi2t/
         GnkSVee5WZzw7NGegd8Y90GPvPDO1q6k8QCfTMNkWdhro7YurkuqaQyxL159wwRClR54
         93sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVA8xftlreMo36FVBXz7Gf0JNfINiG/wUCQCTC65PfyYE7h+2zE
	PkREltHenBZWHs8oXX46aBrd6BbJzWVCkRFUFWDsCaW6trl03zGzwRAKHzKGmQcK5GyoZHwXifA
	w/x4TbRu53OKs9NjNwBU+I9ih404R8aKNVaWfdYrsm6Gh4Sl7Zif/9i7DmUt2oXdNcw==
X-Received: by 2002:a63:1e0c:: with SMTP id e12mr46211326pge.218.1557986071598;
        Wed, 15 May 2019 22:54:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZeU1yKxZxh3Dy+GlrNNCt/whzYSsXT7ONOc7JpTZNbJH1grAVJ/63bJYfLmjAxUCRm7zI
X-Received: by 2002:a63:1e0c:: with SMTP id e12mr46211260pge.218.1557986070736;
        Wed, 15 May 2019 22:54:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557986070; cv=none;
        d=google.com; s=arc-20160816;
        b=Kd0nw1EqU+vp2B0M2fdHZvACuaOn+TddguRuPKm9ae8Z7OmElT9mXZNtXzYuu/WFEK
         /N7Pvw9vfFFdVwpFcQUgo8FyCr2JsJ6mho0d24aXL2LvmObwok2ZNxxKC1OOebRAc83w
         49DCC1LXvLghbAKIcqnk9Wi2JpA+37U9gnRhYXdn2BdmWVNqBjhIfQ2RlkyfVS2bew0L
         BFXquH4kxV8acsexY2ZSopW1UTp4ftA8wO5idujVku0Q7ZEe6ECXqbztrKDh0Cuj1+T6
         1ZSxEXZZharZC5dY6g76y1kMkE0LcGDnkvbf4bVCoFiefylxu6/Njuo59A0T91fmKMKp
         sFWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=c10NYquO1ht2u06DTAd38ZAXwFqiIhzEP7wfD1Lo0XE=;
        b=B7j4dRZEM1fFaas2NChFulkWGTR9ZViKpGxvxSXwGrvmKUKQ6XeAGn/Lz919LyTqGh
         bFdS/Cc8cZ1Ke/CxI5U/kZEs0JsHzmtEFd1Pb1f3zti3IqDATPnNiNYO8N0tuhjrhkyj
         h9ngbU7iMZtVrrWJ8KXQKVaicoPGyoA5y+z9ZJnVGvQDBaGjR3ryKqx+T6EALEe6Xl+q
         yroaNOTIG9qTCL05MO1raQC0+AyBfiRPTuIxdOdsOHeC3WUNftyUTpo8fVIFogZh/Jgn
         YByFLBXFIiUfGLZt2wYc+7TKJLmgJTqGcg10jWX1WzBPGk46VJjGi4pvHKEXkc+uX8ud
         6z6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id b17si134201pfi.32.2019.05.15.22.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 22:54:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TRt6yLM_1557986065;
Received: from 30.5.117.67(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0TRt6yLM_1557986065)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 16 May 2019 13:54:25 +0800
Subject: Re: [PATCH] fs/writeback: Attach inode's wb to root if needed
To: Dennis Zhou <dennis@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org,
 cgroups@vger.kernel.org, linux-mm@kvack.org
References: <1557389033-39649-1-git-send-email-zhangliguang@linux.alibaba.com>
 <20190509164802.GV374014@devbig004.ftw2.facebook.com>
 <a5bb3773-fef5-ce2b-33b9-18e0d49c33c4@linux.alibaba.com>
 <20190513183053.GA73423@dennisz-mbp>
From: =?UTF-8?B?5Lmx55+z?= <zhangliguang@linux.alibaba.com>
Message-ID: <4ebf1f8e-0f77-37df-da32-037384643527@linux.alibaba.com>
Date: Thu, 16 May 2019 13:54:24 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190513183053.GA73423@dennisz-mbp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dennis,

Sorry for the later reply. Becase I cann't reproduce this problem by 
local test,

and online environment is not allowed to operate, I am constructing 
scenario

to reproduce it in recent days.


在 2019/5/14 2:30, Dennis Zhou 写道:
> Hi Liguang,
>
> On Fri, May 10, 2019 at 09:54:27AM +0800, 乱石 wrote:
>> Hi Tejun,
>>
>> 在 2019/5/10 0:48, Tejun Heo 写道:
>>> Hi Tejun,
>>>
>>> On Thu, May 09, 2019 at 04:03:53PM +0800, zhangliguang wrote:
>>>> There might have tons of files queued in the writeback, awaiting for
>>>> writing back. Unfortunately, the writeback's cgroup has been dead. In
>>>> this case, we reassociate the inode with another writeback cgroup, but
>>>> we possibly can't because the writeback associated with the dead cgroup
>>>> is the only valid one. In this case, the new writeback is allocated,
>>>> initialized and associated with the inode. It causes unnecessary high
>>>> system load and latency.
>>>>
>>>> This fixes the issue by enforce moving the inode to root cgroup when the
>>>> previous binding cgroup becomes dead. With it, no more unnecessary
>>>> writebacks are created, populated and the system load decreased by about
>>>> 6x in the online service we encounted:
>>>>       Without the patch: about 30% system load
>>>>       With the patch:    about  5% system load
>>> Can you please describe the scenario with more details?  I'm having a
>>> bit of hard time understanding the amount of cpu cycles being
>>> consumed.
>>>
>>> Thanks.
>> Our search line reported a problem, when containerA was removed,
>> containerB and containerC's system load were up to 30%.
>>
>> We record the trace with 'perf record cycles:k -g -a', found that wb_init
>> was the hotspot function.
>>
>> Function call:
>>
>> generic_file_direct_write
>>     filemap_write_and_wait_range
>>        __filemap_fdatawrite_range
>>           wbc_attach_fdatawrite_inode
>>              inode_attach_wb
>>                 __inode_attach_wb
>>                    wb_get_create
>>              wbc_attach_and_unlock_inode
>>                 if (unlikely(wb_dying(wbc->wb)))
>>                    inode_switch_wbs
>>                       wb_get_create
>>                          ; Search bdi->cgwb_tree from memcg_css->id
>>                          ; OR cgwb_create
>>                             kmalloc
>>                             wb_init       // hot spot
>>                             ; Insert to bdi->cgwb_tree, mmecg_css->id as key
>>
>> We discussed it through, base on the analysis:  When we running into the
>> issue, there is cgroups are being deleted. The inodes (files) that were
>> associated with these cgroups have to switch into another newly created
>> writeback. We think there are huge amount of inodes in the writeback list
>> that time. So we don't think there is anything abnormal. However, one
>> thing we possibly can do: enforce these inodes to BDI embedded wirteback
>> and we needn't create huge amount of writebacks in that case, to avoid
>> the high system load phenomenon. We expect correct wb (best candidate) is
>> picked up in next round.
>>
>> Thanks,
>> Liguang
>>
> If I understand correctly, this is mostlikely caused by a file shared by
> cgroup A and cgroup B. This means cgroup B is doing direct io against
> the file owned by the dying cgroup A. In this case, the code tries to do
> a wb switch. However, it fails to reallocate the wb as it's deleted and
> for the original cgrouip A's memcg id.
>
> I think the below may be a better solution. Could you please test it? If
> it works, I'll spin a patch with a more involved description.
>
> Thanks,
> Dennis
>
> ---
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 36855c1f8daf..fb331ea2a626 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -577,7 +577,7 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
>   	 * A dying wb indicates that the memcg-blkcg mapping has changed
>   	 * and a new wb is already serving the memcg.  Switch immediately.
>   	 */
> -	if (unlikely(wb_dying(wbc->wb)))
> +	if (unlikely(wb_dying(wbc->wb)) && !css_is_dying(wbc->wb->memcg_css))
>   		inode_switch_wbs(inode, wbc->wb_id);
>   }
>   
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 72e6d0c55cfa..685563ed9788 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -659,7 +659,7 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
>   
>   	might_sleep_if(gfpflags_allow_blocking(gfp));
>   
> -	if (!memcg_css->parent)
> +	if (!memcg_css->parent || css_is_dying(memcg_css))
>   		return &bdi->wb;
>   
>   	do {

