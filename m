Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37B8DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:37:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF99421773
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 02:37:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF99421773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DABB8E0003; Tue, 19 Feb 2019 21:37:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 789C48E0002; Tue, 19 Feb 2019 21:37:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 678F68E0003; Tue, 19 Feb 2019 21:37:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2657F8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:37:15 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b10so6132465pla.14
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 18:37:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=HP9Cnwm5mA4hdRo3xazu5Jsgd6Igy791Y/HWFPQ6N0k=;
        b=bfu5VaGLgUdf11lT1RGOjv6u7dMK8rkUOgaDIiteRTK3tjIXGWV067SwS6LchDxMA/
         KMd1C6cq4qWsCpq6b/3tv9yzRm7A7xSuqKdkR8DZKR73HnBDaoZem3ksN+PyFOl/xt86
         Vpn2Ph03F07JlV//AE8qJ/XCx0VD25xEIUtZmrPGkhGsjBeg0XQeRs2v6ybjloKiSBlt
         6NCHAMCxOf/sfsAoFVMBsVpNjAfBpFD3pzuAjCMQu1hcWhvPqxMSzLf4stUH6opQIw44
         zkWzN+6+TnMTbzsAufdIrJ0C9tQEdeGf2a9W01rKP6oTsk7nPCaKc5KlsVyLkfI92Moq
         nvGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Gm-Message-State: AHQUAuZb9Uoz8cKUwq9DM5nSGehUqp2Zijv9FvNIfW/IvhlnBfVhn2ZM
	PgqJhCLgZFZWSAykHHXrngoAXrRrdB7NqHrG6sSGgJfotE1flgJz3mY1zWKTF9XeLRafkIox8YE
	eoglzXeksVTdugXMQtJ4PpJXe41PlHNmOI1U5dESrsXZR/EvK+XkfzASYeAGm4l0ILRixsMAd8P
	v7/kcOmj6AVLOuvGFFr74UYLLt2R9q6QuRksoF0D9p2N2F1Yyi8F+bT0+bK2r05YbpdDUmD3ewu
	selWATkr9yJlVNlrYuf617phBglTf+uPFTCyGl0WCTLaziCmsX+BAha+NAehq9kmlJ7odfjH1n7
	X7zV8p8P5QzLfokN/BrMgPEfnEH1vKBn8L/VMnLa5BZXuFBN/OVDU8Gv3wJadCWSylWf2JJl+g=
	=
X-Received: by 2002:a17:902:161:: with SMTP id 88mr35053284plb.306.1550630234792;
        Tue, 19 Feb 2019 18:37:14 -0800 (PST)
X-Received: by 2002:a17:902:161:: with SMTP id 88mr35053225plb.306.1550630233954;
        Tue, 19 Feb 2019 18:37:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550630233; cv=none;
        d=google.com; s=arc-20160816;
        b=F+hTz7mE1rPsfkr1GAHtespTS+HYYNcTaq9Z0CNW6KBoxJYBDCkEWwJS3NEq7B1XT6
         ZUR5UzafGGt8qPJ8NmIYK6KJU3s7ikerafJ+xFqChwxDiT2+lux33fEciUdp/105KQDF
         tRJjhOhfxkxUefEY0qqQu2aHcrc0hs/WYaGOrAJ7JLZNL8QxDvsfvUpdI1nJP1O9BqcC
         gvo2uIDq/Ne7NLO2kLMoiNIQpe91Gx+VeJaly98BTad5Ode/uT3d19CN0jev2/rmvWok
         mqGbQaRvsjoFth2J6wklvwSYQcrIG0LTF1pFJz4RLTPtFKZLov40bjfpXIITD8/VpOiB
         tTmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=HP9Cnwm5mA4hdRo3xazu5Jsgd6Igy791Y/HWFPQ6N0k=;
        b=uNlPSRKLi8t/2zqOgSlB2NJK4u+1G8+t8uSJO6Jk4/kRFAM8kcu4cao7lPWQDlvnFF
         VsSoE2FGJNax+m7lJeEAB4nT9zQlciK3lwW0zFT55THzKe5i3PUpB5rZU5cP+uTFiber
         hNO1KjgbyF6LFzpNfCDrcIxczdl2MB6LEPQMJqPSwkawf2V2Qr8GzoQ+KjMhIeC9/YqI
         0Hd9BVrswhUVPUi4Fs9nIW6XcmllDTHR2GsWyJGo1hC0DQzgm+JxiqMtmuUgZnnRSllu
         Jp5WdAaqrfWXvai/u8SRK7+XUQWAnHTwxX8KjjBZZ1Mg96OMLpMlt5+5DyiGkcAD/7wl
         iJQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t13sor26962735plr.6.2019.02.19.18.37.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 18:37:13 -0800 (PST)
Received-SPF: pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Google-Smtp-Source: AHgI3IbH0x7YpgetqxgAAYLMYUJvhs0DuV+3/g3W/yGDT9cyuGtlfaHN5X8Oy5l+iGTZS0YQ6AYgzQ==
X-Received: by 2002:a17:902:788d:: with SMTP id q13mr15744256pll.154.1550630233463;
        Tue, 19 Feb 2019 18:37:13 -0800 (PST)
Received: from asus.site ([2601:647:4000:5dd1:a41e:80b4:deb3:fb66])
        by smtp.gmail.com with ESMTPSA id o5sm16857250pfi.118.2019.02.19.18.37.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 18:37:12 -0800 (PST)
Subject: Re: [dm-devel] [PATCH V15 00/18] block: support multi-page bvec
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Mike Snitzer <snitzer@redhat.com>,
 linux-mm@kvack.org, dm-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
 Sagi Grimberg <sagi@grimberg.me>, "Darrick J . Wong"
 <darrick.wong@oracle.com>, Omar Sandoval <osandov@fb.com>,
 cluster-devel@redhat.com, linux-ext4@vger.kernel.org,
 Kent Overstreet <kent.overstreet@gmail.com>,
 Boaz Harrosh <ooo@electrozaur.com>, Gao Xiang <gaoxiang25@huawei.com>,
 Coly Li <colyli@suse.de>, linux-raid@vger.kernel.org,
 Bob Peterson <rpeterso@redhat.com>, linux-bcache@vger.kernel.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner
 <dchinner@redhat.com>, David Sterba <dsterba@suse.com>,
 linux-block@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
 linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
 <1550250855.31902.102.camel@acm.org> <20190217131128.GB7296@ming.t460p>
 <1550593699.31902.115.camel@acm.org> <20190220011719.GA13035@ming.t460p>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <8253d52d-a77a-b008-1fbd-f2f0a794a022@acm.org>
Date: Tue, 19 Feb 2019 18:37:09 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190220011719.GA13035@ming.t460p>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/19/19 5:17 PM, Ming Lei wrote:
> On Tue, Feb 19, 2019 at 08:28:19AM -0800, Bart Van Assche wrote:
>> With this patch applied test nvmeof-mp/002 fails as follows:
>>
>> [  694.700400] kernel BUG at lib/sg_pool.c:103!
>> [  694.705932] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
>> [  694.708297] CPU: 2 PID: 349 Comm: kworker/2:1H Tainted: G    B             5.0.0-rc6-dbg+ #2
>> [  694.711730] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
>> [  694.715113] Workqueue: kblockd blk_mq_run_work_fn
>> [  694.716894] RIP: 0010:sg_alloc_table_chained+0xe5/0xf0
>> [  694.758222] Call Trace:
>> [  694.759645]  nvme_rdma_queue_rq+0x2aa/0xcc0 [nvme_rdma]
>> [  694.764915]  blk_mq_try_issue_directly+0x2a5/0x4b0
>> [  694.771779]  blk_insert_cloned_request+0x11e/0x1c0
>> [  694.778417]  dm_mq_queue_rq+0x3d1/0x770
>> [  694.793400]  blk_mq_dispatch_rq_list+0x5fc/0xb10
>> [  694.798386]  blk_mq_sched_dispatch_requests+0x2f7/0x300
>> [  694.803180]  __blk_mq_run_hw_queue+0xd6/0x180
>> [  694.808933]  blk_mq_run_work_fn+0x27/0x30
>> [  694.810315]  process_one_work+0x4f1/0xa40
>> [  694.813178]  worker_thread+0x67/0x5b0
>> [  694.814487]  kthread+0x1cf/0x1f0
>> [  694.819134]  ret_from_fork+0x24/0x30
>>
>> The code in sg_pool.c that triggers the BUG() statement is as follows:
>>
>> int sg_alloc_table_chained(struct sg_table *table, int nents,
>> 		struct scatterlist *first_chunk)
>> {
>> 	int ret;
>>
>> 	BUG_ON(!nents);
>> [ ... ]
>>
>> Bart.
> 
> I can reproduce this issue("kernel BUG at lib/sg_pool.c:103") without mp-bvec patches,
> so looks it isn't the fault of this patchset.

Thanks Ming for your feedback.

Jens, I don't see that issue with kernel v5.0-rc6. Does that mean that 
the sg_pool BUG() is a regression in your for-next branch that predates 
Ming's multi-page bvec patch series?

Thanks,

Bart.

