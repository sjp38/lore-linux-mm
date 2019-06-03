Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACDA7C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:23:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7027C23F94
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:23:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="QGgQrPwV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7027C23F94
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4CA16B000C; Mon,  3 Jun 2019 12:23:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFD5A6B000D; Mon,  3 Jun 2019 12:23:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CECF96B000E; Mon,  3 Jun 2019 12:23:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9850F6B000C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:23:13 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id u10so1916663plq.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:23:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=JANRXtNq/OlXEVUckmhj0Gl/WVjY8ue45Pv7dcHW6sM=;
        b=NDCOahglMAU6yWF28GrtXxNB8Q2i2rUGrny8l2vtfs3qXftmnuLhAw8RUy5X/uo8Ny
         ko9q1udS9um04FXQePU+Bo6PnkvsKfyYVnX0LZ9Ein4tMT9ul+W9mPBN4aAn+4eafkjk
         q1IOogTfbVbpWtwwP+6Zm6VXc/v0ocLCxnPo8bazx7F3EuLgS1Vc3P1K/7rHeCXIy7S0
         udp7XlAwWfos6syfR4B3SBo0bYlkrkVikHvPzV1RjzxPpeRQ6uSnBTS+EeAcaxb3P61f
         a+D3/5pEhft+2aIOTzLAn5xK8SeiROI4DyMt/idK4d2rQVXcUC8KlRJMeZqiCSfDFwIt
         H7zw==
X-Gm-Message-State: APjAAAWvmekEt8hks6v6NqwJ2HO34Sr6e+X5LBPXpxIa1Xywu+ZHiEqJ
	6kWAIxFuKIfQYzYlft0ZVpx3DBejXI5Y9Yb8xqskKHjeIXEMncNclC69v206GL8j+skWIh8n7fI
	5/0qGeUTHtYYACZeoq8QAlIze6iN8Jl0tXcVVwIMRcLyCX9JE93bglTdDUxmrTSNjKQ==
X-Received: by 2002:a63:e708:: with SMTP id b8mr30066774pgi.168.1559578993052;
        Mon, 03 Jun 2019 09:23:13 -0700 (PDT)
X-Received: by 2002:a63:e708:: with SMTP id b8mr30066687pgi.168.1559578992401;
        Mon, 03 Jun 2019 09:23:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559578992; cv=none;
        d=google.com; s=arc-20160816;
        b=P1Yhvx36TxOcY619ocYLtV+HBFcEu9beDyu7YSJcao4c+VKAbG9w/xjsd/yhbZuV8A
         29/RzyT5tcB+K037z1LlecJfUt53oGDC9F2TlfIgekc+2+KX9H8jgp5XF+zsEu7IIhve
         sNzxP18in7JUTNaebKeAJ8vmD2HHp2TVg1l6BaWv+oxtkdZYAJzS2MdsPYyuwQcj0UO0
         Lfn2K4XenQWiFNDDLLuHv/yFidu9VOqR6Ubv3YsQvEGEGrMRiCQH3Zi2PFB+Ap+dzjcq
         lQ2cSaN2S9YD2IrIO45OSCYo8ghYMTw2lXuVObx4QwY7sly0tuaZGyOzQTF5p21A3V1m
         3ePA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=JANRXtNq/OlXEVUckmhj0Gl/WVjY8ue45Pv7dcHW6sM=;
        b=ga7xb9egsDdcAdG8KO+15iUdWbSFzWoUnqTUz3sVO3vbPmRCr1ufnp5shN29VvakCa
         2Gi5bQ7uCOvzOQtQP9XWW7OV0B/ZXGn68ruv5CdM1C/rELDDD4lLJYUKktlCBARv0d/U
         BLsiahrnVAmiMhIigkmyiUF2y0Pc1njxPpgq4HYxnM2xyYNod1vXBTX94yqaVFH0D02Q
         LZKxaFkp5/ziiNFQulIf1z2+Laaz3tn1H6GUwNlNdisv8N4BwI7YRP/4WwEdcjgUfUKo
         oDWSLKWl62A51zGW858bRd/NqJr4uQX2NNRTtBX8t3e/c/RZRnAIf9Qxzxn3t0RqcxW1
         X1dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=QGgQrPwV;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l96sor17298720plb.68.2019.06.03.09.23.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:23:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=QGgQrPwV;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=JANRXtNq/OlXEVUckmhj0Gl/WVjY8ue45Pv7dcHW6sM=;
        b=QGgQrPwVRdf1FporyJuiYg8dww4nmTS56JSFMbwI0B2HL2g870kOaQE9Ywt0x006N6
         PjQFzmPuMSqVgpLiHGQiHxKi+RNegLkeQbj9M/kqEAraRxIHkA9uTMK+9MY40yM1oNUU
         5RSFX82A4bupgDJL3ID6O1kJCNBQ58xyApRr93QMRGu7ilTUQKe3S+1NMJg8dP1ccaFA
         H9LgGRGjK46Hz1/8qSOzwXc4iBACaNU/zFlTIHtoP7vs7a5etSrbMcZ3Xa4KVMiZdd7M
         27X98Iw/B26uLHcsFuTvb75LvBV0snxsJTFjnQkkPdtn8eciopq44UTkUBjqPGHN3ZFh
         JbLg==
X-Google-Smtp-Source: APXvYqwCufEoyFE7wi6ZCH5aXURbYNyTbhnYSnr2KtWTknjUQ1XLoDXrpTilRUIYKKwXpC5/rlOvWQ==
X-Received: by 2002:a17:90a:195e:: with SMTP id 30mr31687487pjh.116.1559578991519;
        Mon, 03 Jun 2019 09:23:11 -0700 (PDT)
Received: from [192.168.1.158] ([65.144.74.34])
        by smtp.gmail.com with ESMTPSA id d10sm16947450pgh.43.2019.06.03.09.23.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 09:23:10 -0700 (PDT)
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Peter Zijlstra <peterz@infradead.org>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
 oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <9a75cc4f-bd14-1d98-6653-b49a2842dd16@kernel.dk>
Date: Mon, 3 Jun 2019 10:23:09 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603123705.GB3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 6:37 AM, Peter Zijlstra wrote:
> On Fri, May 31, 2019 at 03:12:13PM -0600, Jens Axboe wrote:
>> On 5/30/19 2:03 AM, Peter Zijlstra wrote:
> 
>>> What is the purpose of that patch ?! The Changelog doesn't mention any
>>> benefit or performance gain. So why not revert that?
>>
>> Yeah that is actually pretty weak. There are substantial performance
>> gains for small IOs using this trick, the changelog should have
>> included those. I guess that was left on the list...
> 
> OK. I've looked at the try_to_wake_up() path for these exact
> conditions and we're certainly sub-optimal there, and I think we can put
> much of this special case in there. Please see below.
> 
>> I know it's not super kosher, your patch, but I don't think it's that
>> bad hidden in a generic helper.
> 
> How about the thing that Oleg proposed? That is, not set a waiter when
> we know the loop is polling? That would avoid the need for this
> alltogether, it would also avoid any set_current_state() on the wait
> side of things.
> 
> Anyway, Oleg, do you see anything blatantly buggered with this patch?
> 
> (the stats were already dodgy for rq-stats, this patch makes them dodgy
> for task-stats too)
> 
> ---
>   kernel/sched/core.c | 38 ++++++++++++++++++++++++++++++++------
>   1 file changed, 32 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 102dfcf0a29a..474aa4c8e9d2 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -1990,6 +1990,28 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>   	unsigned long flags;
>   	int cpu, success = 0;
>   
> +	if (p == current) {
> +		/*
> +		 * We're waking current, this means 'p->on_rq' and 'task_cpu(p)
> +		 * == smp_processor_id()'. Together this means we can special
> +		 * case the whole 'p->on_rq && ttwu_remote()' case below
> +		 * without taking any locks.
> +		 *
> +		 * In particular:
> +		 *  - we rely on Program-Order guarantees for all the ordering,
> +		 *  - we're serialized against set_special_state() by virtue of
> +		 *    it disabling IRQs (this allows not taking ->pi_lock).
> +		 */
> +		if (!(p->state & state))
> +			goto out;
> +
> +		success = 1;
> +		trace_sched_waking(p);
> +		p->state = TASK_RUNNING;
> +		trace_sched_woken(p);
> +		goto out;
> +	}
> +
>   	/*
>   	 * If we are going to wake up a thread waiting for CONDITION we
>   	 * need to ensure that CONDITION=1 done by the caller can not be
> @@ -1999,7 +2021,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>   	raw_spin_lock_irqsave(&p->pi_lock, flags);
>   	smp_mb__after_spinlock();
>   	if (!(p->state & state))
> -		goto out;
> +		goto unlock;
>   
>   	trace_sched_waking(p);
>   
> @@ -2029,7 +2051,7 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>   	 */
>   	smp_rmb();
>   	if (p->on_rq && ttwu_remote(p, wake_flags))
> -		goto stat;
> +		goto unlock;
>   
>   #ifdef CONFIG_SMP
>   	/*
> @@ -2089,12 +2111,16 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
>   #endif /* CONFIG_SMP */
>   
>   	ttwu_queue(p, cpu, wake_flags);
> -stat:
> -	ttwu_stat(p, cpu, wake_flags);
> -out:
> +unlock:
>   	raw_spin_unlock_irqrestore(&p->pi_lock, flags);
>   
> -	return success;
> +out:
> +	if (success) {
> +		ttwu_stat(p, cpu, wake_flags);
> +		return true;
> +	}
> +
> +	return false;
>   }
>   
>   /**

Let me run some tests with this vs mainline vs blk wakeup hack removed.


-- 
Jens Axboe

