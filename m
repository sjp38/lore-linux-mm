Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF019C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:23:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EB97207FC
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:23:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EB97207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1609F6B027B; Wed, 11 Sep 2019 11:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 113596B027C; Wed, 11 Sep 2019 11:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 028626B027D; Wed, 11 Sep 2019 11:23:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id D66FF6B027B
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:23:24 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 835A18243776
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:23:24 +0000 (UTC)
X-FDA: 75923008728.09.drink81_3ad19ffccfd07
X-HE-Tag: drink81_3ad19ffccfd07
X-Filterd-Recvd-Size: 4051
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:23:24 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C7BEF1DA2;
	Wed, 11 Sep 2019 15:23:22 +0000 (UTC)
Received: from [10.10.125.194] (ovpn-125-194.rdu2.redhat.com [10.10.125.194])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9212C60BEC;
	Wed, 11 Sep 2019 15:23:21 +0000 (UTC)
Subject: Re: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20190909162804.5694-1-mchristi@redhat.com>
 <5D76995B.1010507@redhat.com>
 <ee39d997-ee07-22c7-3e59-a436cef4d587@I-love.SAKURA.ne.jp>
Cc: axboe@kernel.dk, James.Bottomley@HansenPartnership.com,
 martin.petersen@oracle.com, linux-kernel@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-block@vger.kernel.org,
 Linux-MM <linux-mm@kvack.org>
From: Mike Christie <mchristi@redhat.com>
Message-ID: <5D791169.2090807@redhat.com>
Date: Wed, 11 Sep 2019 10:23:21 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101
 Thunderbird/38.6.0
MIME-Version: 1.0
In-Reply-To: <ee39d997-ee07-22c7-3e59-a436cef4d587@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.71]); Wed, 11 Sep 2019 15:23:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/10/2019 05:12 PM, Tetsuo Handa wrote:
> On 2019/09/10 3:26, Mike Christie wrote:
>> Forgot to cc linux-mm.
>>
>> On 09/09/2019 11:28 AM, Mike Christie wrote:
>>> There are several storage drivers like dm-multipath, iscsi, and nbd that
>>> have userspace components that can run in the IO path. For example,
>>> iscsi and nbd's userspace deamons may need to recreate a socket and/or
>>> send IO on it, and dm-multipath's daemon multipathd may need to send IO
>>> to figure out the state of paths and re-set them up.
>>>
>>> In the kernel these drivers have access to GFP_NOIO/GFP_NOFS and the
>>> memalloc_*_save/restore functions to control the allocation behavior,
>>> but for userspace we would end up hitting a allocation that ended up
>>> writing data back to the same device we are trying to allocate for.
>>>
>>> This patch allows the userspace deamon to set the PF_MEMALLOC* flags
>>> through procfs. It currently only supports PF_MEMALLOC_NOIO, but
>>> depending on what other drivers and userspace file systems need, for
>>> the final version I can add the other flags for that file or do a file
>>> per flag or just do a memalloc_noio file.
> 
> Interesting patch. But can't we instead globally mask __GFP_NOFS / __GFP_NOIO
> than playing games with per a thread masking (which suffers from inability to
> propagate current thread's mask to other threads indirectly involved)?

If I understood you, then that had been discussed in the past:

https://www.spinics.net/lists/linux-fsdevel/msg149035.html

We only need this for specific threads which implement part of a storage
driver in userspace.

> 
>>> +static ssize_t memalloc_write(struct file *file, const char __user *buf,
>>> +			      size_t count, loff_t *ppos)
>>> +{
>>> +	struct task_struct *task;
>>> +	char buffer[5];
>>> +	int rc = count;
>>> +
>>> +	memset(buffer, 0, sizeof(buffer));
>>> +	if (count != sizeof(buffer) - 1)
>>> +		return -EINVAL;
>>> +
>>> +	if (copy_from_user(buffer, buf, count))
> 
> copy_from_user() / copy_to_user() might involve memory allocation
> via page fault which has to be done under the mask? Moreover, since
> just open()ing this file can involve memory allocation, do we forbid
> open("/proc/thread-self/memalloc") ?

I was having the daemons set the flag when they initialize.

