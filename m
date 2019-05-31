Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB7E7C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:10:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 622B226F27
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 21:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="LqZW7pl7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 622B226F27
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 117996B026B; Fri, 31 May 2019 17:10:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C9B16B026C; Fri, 31 May 2019 17:10:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F21676B026E; Fri, 31 May 2019 17:10:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC77D6B026B
	for <linux-mm@kvack.org>; Fri, 31 May 2019 17:10:23 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s3so5504372pgv.12
        for <linux-mm@kvack.org>; Fri, 31 May 2019 14:10:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Lz8j2/GbsW7Epn3mLuVGGGiuS0I0e80KoxHyK1juyRw=;
        b=bJP17P/hs27MAirKZCIbLHPIRGn1YY1RfBY4AT98Lg4AyozXFvSV+hwZRFvPegHclV
         V4Z8t8cDaE2eQx/UqsLIpUI3iGiY73wE5WGakg9fvYtkc2VNLP3i2k+ARTrVPtKbAZJz
         L1VWeB/aFsBiSU/LsTHY4yIEXtGnNs1eBpob8qDG1LZm3Xtef91Wd+GIQ070gkAzNrGJ
         AOltk62VGpG9QDVAD+SL6oxu/OrmlY+9bs4/7XhFq/Je3B56xo1YFwmfUfYK9SFffQrk
         2byRWU3WV0Hj10swnOMqOXHs+4vp2rAcwZ7TDNRT33QtaX1B8vvPFCU6CpZzVelwjyls
         YqgA==
X-Gm-Message-State: APjAAAUerlRseSF3LNLY21f/6KlLE484UegF4AfE1cUvLhOXZQmiEL5c
	po1TVDEzpOqbwChxiK+ku9WFj22xyFtXTLmjkAWa/AbhOtUNwVk7NU1VLKdw6ioZLsvaXBzEQD/
	Ej9CahmhA+AoUd0vK6gDioVJIzAvUKTG18EzLLyVcTAwVJ5OUTk6nkbqec4i5UJ0mpg==
X-Received: by 2002:a17:90a:f48a:: with SMTP id bx10mr12326682pjb.118.1559337023288;
        Fri, 31 May 2019 14:10:23 -0700 (PDT)
X-Received: by 2002:a17:90a:f48a:: with SMTP id bx10mr12326565pjb.118.1559337022240;
        Fri, 31 May 2019 14:10:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559337022; cv=none;
        d=google.com; s=arc-20160816;
        b=DXAf++4Kob3oGRanOxF4Xhy7zXpEyyUvXJZDvke4WSaFFoc002wn86nAf9YXGGX4Hs
         CLAx60PLT+XZbYzVUk5E0bAffLMe1cyPVaYkzOtb+gBwmimaT+p/tmZrUkGSZzBA277U
         wPPF5q+YlD9fIwh0wqxSQ6M8JPX+T0fA3Oq8CI108hi04Kd9GKxOvAxcbhvyIUIbgkRA
         uhxQBnoqyfp/KaQuKfeqroEWDGh0OYY1MRLJgmqZmcxkgWyGDIDiXVpIe9tOoCizAIn1
         apycIQYFi25GdTFg2ln8jXsQnrkwzKONvnH+9z7wEZFd1CgoXrzDViZhvOnIE6wOZbdC
         NbSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Lz8j2/GbsW7Epn3mLuVGGGiuS0I0e80KoxHyK1juyRw=;
        b=L5lKX7PEKWgaOii3cheifCgho/biHXO1KVxsO7M3NZefZEviI1lcLbCPHMBImuRMKm
         lYAKJM7yNs3qqDUNQMdNAgTEzCmzFJ+uhDV2qj6DEZtCg0iUb6twfnzHOPmv3RfHGjE/
         c9zn7TRse+Y2DilABXcQcX3vzZOEHbpX2LQgN3IRliXeaGSHPlK6YpEnq98V+5ND4PD4
         HwEQQtRuLRtFacJSJpMYmb+g4yh6G0tFXyEWx2VXDJoDP5ptbTlIxXQTWS03ylsQmdTv
         qtJHZXk780to9lUOU9YEIQ5kFp3oHARoEtftWjL/FPPL8DudPMXaRTMpkNnt1cDIxmEI
         Zm3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=LqZW7pl7;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k135sor7551536pgc.23.2019.05.31.14.10.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 14:10:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=LqZW7pl7;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=Lz8j2/GbsW7Epn3mLuVGGGiuS0I0e80KoxHyK1juyRw=;
        b=LqZW7pl7C6E00mgNMN1ho8hI4UVvhCJZGEuOsCAdWrw5uvLmdqaIlXsc+gBgPCEGhD
         Cniz1BMS+RNh++lSJfAH/nfipOfqZzd4zDrqAv9RSi04X+HM8PLtBOZR7tFf00XQiMp7
         IF7KQFvcQO4skMBvKq/aqQuCxCChPaqMgZPtbUCMVJEVXXrdSxER+iIo6DXoAH3/VS+J
         QuggoEynarJHVRC/XJSRQ45Whcf4KAOg/cv95SNKai023Beuy887DUi9wVVjWCpXBetJ
         0PnyvSd4pQOyiXkXQpHlXC7CzXVM4YtPVLpAUjG8ZQPs1jvg/v9gwxRzH46aeJHSMXqz
         TLEQ==
X-Google-Smtp-Source: APXvYqzHASPiXHgBhr4WbEqYBLUvnzBLNIBhrlzvnblg1WeM7e9QFmzQtnjD/q7x0YnhNkl7kKrx3Q==
X-Received: by 2002:a63:ef56:: with SMTP id c22mr11484982pgk.13.1559337021857;
        Fri, 31 May 2019 14:10:21 -0700 (PDT)
Received: from [192.168.1.121] (66.29.164.166.static.utbb.net. [66.29.164.166])
        by smtp.gmail.com with ESMTPSA id x23sm8329971pfn.160.2019.05.31.14.10.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 14:10:20 -0700 (PDT)
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Oleg Nesterov <oleg@redhat.com>, Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, hch@lst.de, peterz@infradead.org,
 gkohli@codeaurora.org, mingo@redhat.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530111519.GC22536@redhat.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <52fc81e0-b6d4-3c29-8250-9da336aaa62a@kernel.dk>
Date: Fri, 31 May 2019 15:10:18 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190530111519.GC22536@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/30/19 5:15 AM, Oleg Nesterov wrote:
> On 05/29, Qian Cai wrote:
>>
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
> I don't understand this code at all but I am just curious, can we do
> something like incomplete patch below ?
> 
> Oleg.
> 
> --- x/mm/page_io.c
> +++ x/mm/page_io.c
> @@ -140,8 +140,10 @@ int swap_readpage(struct page *page, bool synchronous)
>   	unlock_page(page);
>   	WRITE_ONCE(bio->bi_private, NULL);
>   	bio_put(bio);
> -	blk_wake_io_task(waiter);
> -	put_task_struct(waiter);
> +	if (waiter) {
> +		blk_wake_io_task(waiter);
> +		put_task_struct(waiter);
> +	}
>   }
>   
>   int generic_swapfile_activate(struct swap_info_struct *sis,
> @@ -398,11 +400,12 @@ int swap_readpage(struct page *page, boo
>   	 * Keep this task valid during swap readpage because the oom killer may
>   	 * attempt to access it in the page fault retry time check.
>   	 */
> -	get_task_struct(current);
> -	bio->bi_private = current;
>   	bio_set_op_attrs(bio, REQ_OP_READ, 0);
> -	if (synchronous)
> +	if (synchronous) {
>   		bio->bi_opf |= REQ_HIPRI;
> +		get_task_struct(current);
> +		bio->bi_private = current;
> +	}
>   	count_vm_event(PSWPIN);
>   	bio_get(bio);
>   	qc = submit_bio(bio);

I think this would solve it for swap.

-- 
Jens Axboe

