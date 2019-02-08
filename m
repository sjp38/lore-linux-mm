Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9B5C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:34:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D2BA20844
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:34:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D2BA20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=free.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E08B8E0091; Fri,  8 Feb 2019 10:34:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B6C18E0002; Fri,  8 Feb 2019 10:34:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CDCF8E0091; Fri,  8 Feb 2019 10:34:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A671C8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 10:34:37 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id w16so1439048wrk.10
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 07:34:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=a8+Ip1p8BC+0Hu/LferDIfjsQRUwC6Onp0nC6Xo41bY=;
        b=jhdiVuBcOplTW2iA4QUJPkkccZs8523IvzgBvwsBhqOflNtD+P2aDvGJ6Jg3SgkFEX
         9Jmg8JbKfYzCp0CrYEIrV+EzGwvrL/YmaCABOyI0nLx69DVvvyhhJTgTt92k5bn+sA53
         rS15MeAY+GA8XX6bn/Hr3qvEHbdJLhby4m/BQ2IKJmL0R2NbyuCYDNDc8ARXKRzsYVuH
         0p7097UFW5W/ylPaSUh1saDQ64v1BtnLczkuftLz+kQZlMY6v/BM66VpxuJBdtBB67V+
         L/PJMDYPTYXDiahhH0aSyuigGjkrm985hK3SQbauCdhU7Hs6Ved+dtw/SLi+Or6X8Ua2
         rsCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
X-Gm-Message-State: AHQUAuZAxJe2mlOVNkbBWUpIrmzXpUGflJBk3Bl3cJb1Y8rFmKLjo14c
	PO1ZH4AWQNN03aUxVbjPczCwt0L5xs2GpSh/NUNBIdseHKWBZwWl/42cCg/ogUDvWTUm5DNw0OC
	rRRX6oCXSn6wUZ+QMlqJuTHIdkttmqJJqPZP6H8KtCsvrko5Y35rpQTFEqr3Zeo+cuA==
X-Received: by 2002:adf:9246:: with SMTP id 64mr18111343wrj.130.1549640077165;
        Fri, 08 Feb 2019 07:34:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbinfW3R0vSZ3MvqUafzsSAoaXDI1jAiSRkgPXWMH9WfFFWOv4wU9uU4rK7JYNalcI5afmV
X-Received: by 2002:adf:9246:: with SMTP id 64mr18111270wrj.130.1549640076016;
        Fri, 08 Feb 2019 07:34:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549640076; cv=none;
        d=google.com; s=arc-20160816;
        b=iywlyBHE4SEYy9cGyFi85xS0qZaDj1908NFu71Pi5qCN5wb6n4wTwXmngvXqcRU/ez
         s1WgK/LjMCPeeE9ueF052RjTUoc2N5/H/UHes6D6pIVX5mSATTf5XPNsE7TjhgWa0ieo
         LGzpLVDptHJ12yWMUAdV7+7FbCyPBLf1yJu/N3MWu8niKhJhX5bbIBRVgXDlBhqvNAJa
         LePBbbezSOKRKlq8TrwSBlglBJ+pXjxgP+Sju+4ZQwq2zU8ycIj0QpR+bfQP0XWY0MQ2
         PxXgDCPJiIsGOQ8tOTA9l4XJ7ZUK8kx3L281v4+cOEVpo7Yjuytw9c+z/q+y4WcO6Idu
         +fcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=a8+Ip1p8BC+0Hu/LferDIfjsQRUwC6Onp0nC6Xo41bY=;
        b=qqDMQKqijnhMYJnFS0kDM1geJzSVYTEo64i23OyLJnZQwC9HTagmE+iZ4+VB7utZ5R
         RICMK0L1HjpO6S+3lilohYxJF2h2AS8lKwZc6+ATuU+OdfzNusAXImTm9eJRcKxCgwMh
         NctacLbFOgInH+Wkd0csj1neE/PnSwo0I+qoGjE35ZZOBeTI0veMfwzIZOH++r07HvFF
         U0m7pMEgxA83r9/I8gabgfxFnWCxvZkaELqx5GzmRA4AB/lLxSsVXAwtoHUw7o+/TQ8S
         w1hQGign9HLyEUMGnstipNXr3YjOHeDrfa4ZmeexgKDPpp86txnbr28fQuiAPqQyy7fB
         3iXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from smtp3-g21.free.fr (smtp3-g21.free.fr. [212.27.42.3])
        by mx.google.com with ESMTPS id a16si2127277wrf.311.2019.02.08.07.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 07:34:36 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) client-ip=212.27.42.3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of marc.w.gonzalez@free.fr designates 212.27.42.3 as permitted sender) smtp.mailfrom=marc.w.gonzalez@free.fr
Received: from [192.168.108.68] (unknown [213.36.7.13])
	(Authenticated sender: marc.w.gonzalez)
	by smtp3-g21.free.fr (Postfix) with ESMTPSA id 5420E13F8B6;
	Fri,  8 Feb 2019 16:33:42 +0100 (CET)
Subject: Re: dd hangs when reading large partitions
From: Marc Gonzalez <marc.w.gonzalez@free.fr>
To: linux-mm <linux-mm@kvack.org>, linux-block <linux-block@vger.kernel.org>
Cc: Jianchao Wang <jianchao.w.wang@oracle.com>,
 Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@kernel.dk>,
 fsdevel <linux-fsdevel@vger.kernel.org>, SCSI <linux-scsi@vger.kernel.org>,
 Joao Pinto <jpinto@synopsys.com>, Jeffrey Hugo <jhugo@codeaurora.org>,
 Evan Green <evgreen@chromium.org>, Matthias Kaehlcke <mka@chromium.org>,
 Douglas Anderson <dianders@chromium.org>, Stephen Boyd
 <swboyd@chromium.org>, Tomas Winkler <tomas.winkler@intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Alim Akhtar <alim.akhtar@samsung.com>, Avri Altman <avri.altman@wdc.com>,
 Bart Van Assche <bart.vanassche@wdc.com>,
 Martin Petersen <martin.petersen@oracle.com>,
 Bjorn Andersson <bjorn.andersson@linaro.org>, Ming Lei
 <ming.lei@redhat.com>, Omar Sandoval <osandov@fb.com>,
 Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>
References: <f792574c-e083-b218-13b4-c89be6566015@free.fr>
 <398a6e83-d482-6e72-5806-6d5bbe8bfdd9@oracle.com>
 <ef734b94-e72b-771f-350b-08d8054a58f3@kernel.dk>
 <20190119095601.GA7440@infradead.org>
 <07b2df5d-e1fe-9523-7c11-f3058a966f8a@free.fr>
 <985b340c-623f-6df2-66bd-d9f4003189ea@free.fr>
 <b3910158-83d6-21fe-1606-33e88912404a@oracle.com>
 <d082bdee-62e5-d470-b63b-196c0fe3b9fb@free.fr>
 <5132e41b-cb1a-5b81-4a72-37d0f9ea4bb9@oracle.com>
 <7bd8b010-bf0c-ad64-f927-2d2187a18d0b@free.fr>
 <0cfe1ed2-41e1-66a4-8d98-ebc0d9645d21@free.fr>
 <d91e8342-4672-d51d-1bde-74e910e5a959@free.fr>
 <27165898-88c3-ab42-c6c9-dd52bf0a41c8@free.fr>
Message-ID: <66419195-594c-aa83-c19d-f091ad3b296d@free.fr>
Date: Fri, 8 Feb 2019 16:33:42 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <27165898-88c3-ab42-c6c9-dd52bf0a41c8@free.fr>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/02/2019 17:56, Marc Gonzalez wrote:

> Saw a slightly different report from another test run:
> https://pastebin.ubuntu.com/p/jCywbKgRCq/
> 
> [  340.689764] rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
> [  340.689992] rcu:     1-...0: (8548 ticks this GP) idle=c6e/1/0x4000000000000000 softirq=82/82 fqs=6
> [  340.694977] rcu:     (detected by 5, t=5430 jiffies, g=-719, q=16)
> [  340.703803] Task dump for CPU 1:
> [  340.709507] dd              R  running task        0   675    673 0x00000002
> [  340.713018] Call trace:
> [  340.720059]  __switch_to+0x174/0x1e0
> [  340.722192]  0xffffffc0f6dc9600
> 
> [  352.689742] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 33s!
> [  352.689910] Showing busy workqueues and worker pools:
> [  352.696743] workqueue mm_percpu_wq: flags=0x8
> [  352.701753]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
> [  352.706099]     pending: vmstat_update
> 
> [  384.693730] BUG: workqueue lockup - pool cpus=1 node=0 flags=0x0 nice=0 stuck for 65s!
> [  384.693815] Showing busy workqueues and worker pools:
> [  384.700577] workqueue events: flags=0x0
> [  384.705699]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
> [  384.709351]     pending: vmstat_shepherd
> [  384.715587] workqueue mm_percpu_wq: flags=0x8
> [  384.719495]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/256
> [  384.723754]     pending: vmstat_update

Running 'dd if=/dev/sda of=/dev/null bs=40M status=progress'
I got a slightly different splat:

[  171.513944] INFO: task dd:674 blocked for more than 23 seconds.
[  171.514131]       Tainted: G S                5.0.0-rc5-next-20190206 #23
[  171.518784] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  171.525728] dd              D    0   674    672 0x00000000
[  171.533525] Call trace:
[  171.538926]  __switch_to+0x174/0x1e0
[  171.541237]  __schedule+0x1e4/0x630
[  171.545041]  schedule+0x34/0x90
[  171.548261]  io_schedule+0x20/0x40
[  171.551401]  blk_mq_get_tag+0x178/0x320
[  171.554852]  blk_mq_get_request+0x13c/0x3e0
[  171.558587]  blk_mq_make_request+0xcc/0x640
[  171.562763]  generic_make_request+0x1d4/0x390
[  171.566924]  submit_bio+0x5c/0x1c0
[  171.571447]  mpage_readpages+0x178/0x1d0
[  171.574730]  blkdev_readpages+0x3c/0x50
[  171.578831]  read_pages+0x70/0x180
[  171.582364]  __do_page_cache_readahead+0x1cc/0x200
[  171.585843]  ondemand_readahead+0x148/0x310
[  171.590613]  page_cache_async_readahead+0xc0/0x100
[  171.594719]  generic_file_read_iter+0x54c/0x860
[  171.599565]  blkdev_read_iter+0x50/0x80
[  171.603998]  __vfs_read+0x134/0x190
[  171.607800]  vfs_read+0x94/0x130
[  171.611273]  ksys_read+0x6c/0xe0
[  171.614745]  __arm64_sys_read+0x24/0x30
[  171.617974]  el0_svc_handler+0xb8/0x140
[  171.621509]  el0_svc+0x8/0xc


For the record, I'll restate the problem:

dd hangs when reading a partition larger than RAM, except when using
iflag=direct or iflag=nocache

# dd if=/dev/sde of=/dev/null bs=64M iflag=direct
64+0 records in
64+0 records out
4294967296 bytes (4.3 GB, 4.0 GiB) copied, 51.1532 s, 84.0 MB/s

# dd if=/dev/sde of=/dev/null bs=64M iflag=nocache
64+0 records in
64+0 records out
4294967296 bytes (4.3 GB, 4.0 GiB) copied, 60.6478 s, 70.8 MB/s

# dd if=/dev/sde of=/dev/null bs=64M count=56
56+0 records in
56+0 records out
3758096384 bytes (3.8 GB, 3.5 GiB) copied, 50.5897 s, 74.3 MB/s

# dd if=/dev/sde of=/dev/null bs=64M
/*** CONSOLE LOCKS UP ***/



I've been looking at the differences between iflag=direct and no-flag.
Using the following script to enable relevant(?) logs:

mount -t debugfs nodev /sys/kernel/debug/
cd /sys/kernel/debug/tracing/events
echo 1 > filemap/enable
echo 1 > pagemap/enable
echo 1 > vmscan/enable
echo 1 > kmem/mm_page_free/enable
echo 1 > kmem/mm_page_free_batched/enable
echo 1 > kmem/mm_page_alloc/enable
echo 1 > kmem/mm_page_alloc_zone_locked/enable
echo 1 > kmem/mm_page_pcpu_drain/enable
echo 1 > kmem/mm_page_alloc_extfrag/enable
echo 1 > kmem/kmalloc_node/enable
echo 1 > kmem/kmem_cache_alloc_node/enable
echo 1 > kmem/kmem_cache_alloc/enable
echo 1 > kmem/kmem_cache_free/enable


# dd if=/dev/sde of=/dev/null bs=64M count=1 iflag=direct
https://pastebin.ubuntu.com/p/YWp4pydM6V/
(114942 lines)

# dd if=/dev/sde of=/dev/null bs=64M count=1
https://pastebin.ubuntu.com/p/xpzgN5H3Hp/
(247439 lines)


Does anyone see what's going sideways in the no-flag case?

Regards.

