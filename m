Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9784FC28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:57:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51361242BC
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:57:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="HE9E00Ev"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51361242BC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D092B6B026E; Wed, 29 May 2019 18:57:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBA3D6B026F; Wed, 29 May 2019 18:57:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B810C6B0270; Wed, 29 May 2019 18:57:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82AED6B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 18:57:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id k22so3009360pfg.18
        for <linux-mm@kvack.org>; Wed, 29 May 2019 15:57:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ccsFrMe6KP8aiz8EyYKirxWsnxkvhC/brM0NiqqoSf0=;
        b=mQ8IXs64wI+oa5eOYrYb5C40SzUtWbtydVFs3ZF87Vq42YwODwfDcroqtoKHiedPUK
         9eHcmIySB+S6Lbg+/qsSpnG7//jShn8t4aIfA4OS9PPcOrlffMlw3WTCLGVuq2Gerfae
         /FDXEuW+15s3C3bDmCqiP8xb0f/oZwhSeFrA2BkMLAy62wa2Vfu51dqeMoaz8FsTSL1c
         Ag3vyPtT+khYIUpH7rraR+k26eyyhH8qPoKmixt/iMaAt5wUdUnq118IAbsojJ0uKC1p
         sRxLgMZs+v+LARb3jQLlTUzGivv6S3Owtay/KZfI6d8ya7E0XVystsN5hXeop9Ptpi37
         tNTA==
X-Gm-Message-State: APjAAAVR1sC8o5I9TApiEb4wn4SIg1RcSueTlQwwFpbWEPoOJ6dvaHDz
	VXoKisnOlr/VvbXAl0fs5TqHs5V822gI8qy2ylhJr4I7PfX2BRPFA1L23tBMidi3GvzVc2gE8+R
	fT6zQowSzwlS8fUMNO2o86Ta5JtlwFSh8yDFE8wFt3lmghwDhnZR0AP+3Kyy2oaqlhA==
X-Received: by 2002:a17:902:1347:: with SMTP id r7mr462000ple.45.1559170637189;
        Wed, 29 May 2019 15:57:17 -0700 (PDT)
X-Received: by 2002:a17:902:1347:: with SMTP id r7mr461954ple.45.1559170636449;
        Wed, 29 May 2019 15:57:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559170636; cv=none;
        d=google.com; s=arc-20160816;
        b=nTpejFLWxMP+C0qtY9db9AclcWoH6bMf9jotysfGxUi3f7L9mPkNtJtb8fsZ9hPor/
         TXTn7sfn1farDVzgHpj7xswo/ObRodgRYn7jtbk00JXccJPbaaSYe4u+4JQLAWGW+jk0
         QqwPuyZwIaKtZjMgxJUbaRoZHUiOVLYp08mIwhMfA3EKSg1Sza2uXMD+2h/cNo5EX5MX
         mhjZx3WI29PKz1dAA9rSr9VqjZm4AilhvkfpNFKCCi3Ev+npbjSauonMjFE0kAZD0Yds
         IVVJanEkXOzc0WOZIqQfdXWgY+W+8XM/YsHjxPqWhAuqoLzH1qlwXeBqRo90BvJh54pr
         YjZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=ccsFrMe6KP8aiz8EyYKirxWsnxkvhC/brM0NiqqoSf0=;
        b=K1B2NRNza76IaVLfQDe8LoN+BlSU+zK6gdeCct7hTdK/3vyRm+j8N6rKGqWX8rR7pI
         Lbnk3b1foxf12ZkAf9R0r/QSi4zEVTocspSTbORu+eVfUd5SbvKCcSIJ0RuOehh/4sKB
         usJD8DsYB5wsDGeSQUrx+CzPqqhqxQzyqwPAjrXxk8LL+PzlzwvVhgWS0ZiTIaJ89cHd
         ekTuZ5bM8EMtLfkw5YA3Rw3O1pYxLda7cuRYszMTBWIrYOQecySrTLr1K/86IphjFrz4
         8+8SWD60wkku2Jhn8D7/UzoYiGdrx/v5VDo5dB+xFX5du6w6tHEGB3NkMyH7/imCQCyU
         0JlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=HE9E00Ev;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p65sor1158209pfg.64.2019.05.29.15.57.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 15:57:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=HE9E00Ev;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ccsFrMe6KP8aiz8EyYKirxWsnxkvhC/brM0NiqqoSf0=;
        b=HE9E00EvJ7o8sB9u2IBisHlbg8URix/DMrkDq4JGbmITr2VrN3s9bocIka9bOjVbSx
         XKjZuu1jeBy8klRSNbkhUj+zTwSokHfMq6/fPdW1tvDTdY2Ln5FWZPl4jyJQhJoorS0U
         lBjyThtI+5+YK2Z8a1kGNCEIw0pUngfWmMtSyvmi7q28Dq4UoCwQudZDb3NmzCJAiZJo
         muuq+5j8JFJggBKvWWGN7lJHG48lfw8D5np8mpFEbC1mv4bWF6DdacLSkSQGpkkmadBw
         VUekQcV0HcvWDJbUqFIG4sU0Rkdxsb3Hy8yMvT9vosUtmEZTkCiN/qXLpMCiCOAWzhB3
         08fw==
X-Google-Smtp-Source: APXvYqw6Z+KcPoaQ5yIAnQ055ieAIXfUyBwwmKI99T3gUkL7mzAPKw5N2QmTZmBFV/yvhC9n3STIcw==
X-Received: by 2002:a62:fb10:: with SMTP id x16mr162681pfm.112.1559170635534;
        Wed, 29 May 2019 15:57:15 -0700 (PDT)
Received: from [192.168.1.121] (66.29.164.166.static.utbb.net. [66.29.164.166])
        by smtp.gmail.com with ESMTPSA id r44sm532812pjb.13.2019.05.29.15.57.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 15:57:14 -0700 (PDT)
Subject: Re: [PATCH] mm/page_io: fix a crash in do_task_dead()
To: Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>
Cc: hch@lst.de, peterz@infradead.org, oleg@redhat.com, gkohli@codeaurora.org,
 mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559156813-30681-1-git-send-email-cai@lca.pw>
 <20190529154424.c0fe2758cf5af42ff258714a@linux-foundation.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <73a24780-6760-926b-40be-7a31562704d8@kernel.dk>
Date: Wed, 29 May 2019 16:57:11 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190529154424.c0fe2758cf5af42ff258714a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/29/19 4:44 PM, Andrew Morton wrote:
> On Wed, 29 May 2019 15:06:53 -0400 Qian Cai <cai@lca.pw> wrote:
> 
>> The commit 0619317ff8ba ("block: add polled wakeup task helper")
>> replaced wake_up_process() with blk_wake_io_task() in
>> end_swap_bio_read() which triggers a crash when running heavy swapping
>> workloads.
>>
>> [T114538] kernel BUG at kernel/sched/core.c:3462!
>> [T114538] Process oom01 (pid: 114538, stack limit = 0x000000004f40e0c1)
>> [T114538] Call trace:
>> [T114538]  do_task_dead+0xf0/0xf8
>> [T114538]  do_exit+0xd5c/0x10fc
>> [T114538]  do_group_exit+0xf4/0x110
>> [T114538]  get_signal+0x280/0xdd8
>> [T114538]  do_notify_resume+0x720/0x968
>> [T114538]  work_pending+0x8/0x10
>>
>> This is because shortly after set_special_state(TASK_DEAD),
>> end_swap_bio_read() is called from an interrupt handler that revive the
>> task state to TASK_RUNNING causes __schedule() to return and trip the
>> BUG() later.
>>
>> [  C206] Call trace:
>> [  C206]  dump_backtrace+0x0/0x268
>> [  C206]  show_stack+0x20/0x2c
>> [  C206]  dump_stack+0xb4/0x108
>> [  C206]  blk_wake_io_task+0x7c/0x80
>> [  C206]  end_swap_bio_read+0x22c/0x31c
>> [  C206]  bio_endio+0x3d8/0x414
>> [  C206]  dec_pending+0x280/0x378 [dm_mod]
>> [  C206]  clone_endio+0x128/0x2ac [dm_mod]
>> [  C206]  bio_endio+0x3d8/0x414
>> [  C206]  blk_update_request+0x3ac/0x924
>> [  C206]  scsi_end_request+0x54/0x350
>> [  C206]  scsi_io_completion+0xf0/0x6f4
>> [  C206]  scsi_finish_command+0x214/0x228
>> [  C206]  scsi_softirq_done+0x170/0x1a4
>> [  C206]  blk_done_softirq+0x100/0x194
>> [  C206]  __do_softirq+0x350/0x790
>> [  C206]  irq_exit+0x200/0x26c
>> [  C206]  handle_IPI+0x2e8/0x514
>> [  C206]  gic_handle_irq+0x224/0x228
>> [  C206]  el1_irq+0xb8/0x140
>> [  C206]  _raw_spin_unlock_irqrestore+0x3c/0x74
>> [  C206]  do_task_dead+0x88/0xf8
>> [  C206]  do_exit+0xd5c/0x10fc
>> [  C206]  do_group_exit+0xf4/0x110
>> [  C206]  get_signal+0x280/0xdd8
>> [  C206]  do_notify_resume+0x720/0x968
>> [  C206]  work_pending+0x8/0x10
>>
>> Before the offensive commit, wake_up_process() will prevent this from
>> happening by taking the pi_lock and bail out immediately if TASK_DEAD is
>> set.
>>
>> if (!(p->state & TASK_NORMAL))
>> 	goto out;
> 
> Nice description, thanks.
> 
> And...  ouch.  blk_wake_io_task() is a scary thing - changing a task to
> TASK_RUNNING state from interrupt context.  I wonder whether the
> assumptions which that is making hold true in all situations even after
> this change.
> 
> Is polled block IO important enough for doing this stuff?

Andrew, you missed the improved patch, you were CC'ed on that one too
and I queued it up a few hours ago:

http://git.kernel.dk/cgit/linux-block/commit/?h=for-linus&id=6f3ead091fe2a8fb57a5996fe8b94237a896c6e9

Please drop this one.

>> Fixes: 0619317ff8ba ("block: add polled wakeup task helper")
> 
> That will be needing a cc:stable, no?

Also added that when I did.

-- 
Jens Axboe

