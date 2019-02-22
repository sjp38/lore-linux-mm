Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99057C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 445F2206DD
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:42:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 445F2206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sandeen.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE1418E013C; Fri, 22 Feb 2019 16:42:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3FC88E0137; Fri, 22 Feb 2019 16:42:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 907F18E013C; Fri, 22 Feb 2019 16:42:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5653F8E0137
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 16:42:43 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id q3so2777120ior.1
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:42:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9Vy1zW46vrv6//tb216ooz24cBcbWvdl5wa5WMRpmGs=;
        b=K7fv+gVnUrMFfj1/dYTgDpCV4+TIzWJqHVOGxyBnP8+208VBmjjUbLbxbpreGqWw8b
         oJCB6InjScozZqGnj35BgqIHOZkMvq5eLMhZb4X2YdrRW48GBFGhfKpnicqPde981Gk7
         9lWO8sGNdUkdfqFkem7G3XR/md56DfMseiv4NHuFdFJSdpjX04xIMJtoIz/F0k/F34+Y
         E6qBa4tcaBr58xVqzFdYFR5ZTNGzrfnD/fsw6qK/S9i78ojYD6tGjlQO1Y65CIegOMHe
         +1jbuXyz6O3t4Bz5VfzYhwrtmLYxxzo1xRYjQ3K0rmT0XXvxtC9eOdTMXccS5Z/vcLPD
         /naw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) smtp.mailfrom=sandeen@sandeen.net
X-Gm-Message-State: AHQUAuaUrZ5s0RahqQlr3RwSVi4ds0L/Bokg/55aKcSNWxoreSg3HEK5
	Ry7FF3LVHq+c8l3v5F2quX7qwnz9/vQEyKPPuC2BvRwLocprH4VAVVdiGPAvFdh1CQeI9Re7/LG
	dhQ6q/lr8Wt9qZDP6/m8ACdLcNm4IoaqQhYaOGrUICa20C7sJgXH5Xv20qvJOOsSgJA==
X-Received: by 2002:a24:1fca:: with SMTP id d193mr2263816itd.52.1550871762983;
        Fri, 22 Feb 2019 13:42:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdDR+R9hP24lTbjm3/U4FWSM2ewOz6RPqgQ50+XBbYUgdBYjpdXHHln/IAv/kUaJqYfAav
X-Received: by 2002:a24:1fca:: with SMTP id d193mr2263766itd.52.1550871761755;
        Fri, 22 Feb 2019 13:42:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550871761; cv=none;
        d=google.com; s=arc-20160816;
        b=0Z5tTIoO0o8vd/lR6fr1MKbJ3grcFVtTbKJoOb/LGRTIhwQFgx+V40FCKAmB+Vd1d5
         H9c4k69upxlRorX/wPZ4BgjWmiQPSrWtsC0TWLX8bc72daWSvWg0pHHwe1NhuzPME2iD
         NutBwkk2KFS3ObTMoc+ksgAV1ErhErcboq3/ArQ/DywrU02QMW2XCzS0waRNyrhRttlX
         N9sibMFOLO1VAnC0pczJHs2tjo5pCIAH1+J0JK+5evYl4h6V15mS9vgkukVfcAWs/VWf
         b/Eh6eyN8wc3AXzqzJCSTgkt8FemPsTEni9PDj9WPPvzrMWbSdibSAtZWSjYB71KwVMI
         ncVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=9Vy1zW46vrv6//tb216ooz24cBcbWvdl5wa5WMRpmGs=;
        b=s+tRnx86BoA3ol4BNj46Ydu9fTOjdQ+pYsKRaOq/BggdUw3el2DmCQxiVBlXfPmgxb
         zjVxxgfZgE6TEaKJQYgptlWanavv8IvX9SYmbuey5fLyX2tJcGoMpD0pPEhl2FAVu4nD
         mRRC+F0EUxzSg581OuEj7zYc+ORxEd/2isg0hiA87xSRloh/pPXs0TRfQv6Poklpe6oK
         NDt7gHgI91i+0YaZl/wIt/ZoMMORDQj5R2WNYxSJAcSE0Vjc8Na0noRnPIreIZ+nrRvo
         gcCFMRfh989eZF+4bH+/z1Y2yMHFPVcLTYHlYFHc6/nF9G+8rHoLPcI6MApjCDML/eUo
         NGHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) smtp.mailfrom=sandeen@sandeen.net
Received: from sandeen.net (sandeen.net. [63.231.237.45])
        by mx.google.com with ESMTP id d1si1295518ioh.125.2019.02.22.13.42.41;
        Fri, 22 Feb 2019 13:42:41 -0800 (PST)
Received-SPF: pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) client-ip=63.231.237.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sandeen@sandeen.net designates 63.231.237.45 as permitted sender) smtp.mailfrom=sandeen@sandeen.net
Received: from [10.0.0.4] (liberator [10.0.0.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by sandeen.net (Postfix) with ESMTPSA id B386C326E;
	Fri, 22 Feb 2019 15:42:21 -0600 (CST)
Subject: Re: io_submit with slab free object overwritten
To: Qian Cai <cai@lca.pw>, hch@lst.de
Cc: axboe@kernel.dk, viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>, jthumshirn@suse.de,
 linux-fsdevel@vger.kernel.org, Christoph Lameter <cl@linux.com>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
 <64b860a3-7946-ca72-8669-18ad01a78c7c@lca.pw>
From: Eric Sandeen <sandeen@sandeen.net>
Openpgp: preference=signencrypt
Autocrypt: addr=sandeen@sandeen.net; prefer-encrypt=mutual; keydata=
 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 pA==
Message-ID: <0a28db73-7e52-9879-276c-adc6aaf05d4d@sandeen.net>
Date: Fri, 22 Feb 2019 15:42:39 -0600
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <64b860a3-7946-ca72-8669-18ad01a78c7c@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 3:07 PM, Qian Cai wrote:
> Reverted the commit 75374d062756 ("fs: add an iopoll method to struct
> file_operations") fixed the problem. Christoph mentioned that the field can be
> calculated by the offset (40 bytes).

I'm a little confused, you can't revert just that patch, right, because others
in the iopoll series depend on it.  Is the above commit really the culprit, or do
you mean you backed out the whole series?

thanks,
-Eric
 
> struct kmem_cache {
>         struct kmem_cache_cpu __percpu *cpu_slab; (8 bytes)
>         slab_flags_t flags; (4)
>         unsigned long min_partial; (8)
>         unsigned int size; (4)
>         unsigned int object_size; (4)
>         unsigned int offset; (4)
>         unsigned int cpu_partial; (4)
>         struct kmem_cache_order_objects oo; (4)
> 
>         /* Allocation and freeing of slabs */
>         struct kmem_cache_order_objects max;
> 
> So, it looks like "max" was overwritten after freed.
> 
> # cat /opt/ltp/runtest/syscalls
> fgetxattr02 fgetxattr02
> io_submit01 io_submit01
> 
> # /opt/ltp/runltp -f syscalls
> 
> uname:
> Linux 5.0.0-rc7-next-20190222+ #11 SMP Fri Feb 22 14:57:10 EST 2019 ppc64le
> ppc64le ppc64le GNU/Linux
> 
> /proc/cmdline
> BOOT_IMAGE=/vmlinuz-5.0.0-rc7-next-20190222+
> root=/dev/mapper/rhel_ibm--p8--01--lp5-root ro rd.lvm.lv=rhel_ibm-p8-01-lp5/root
> rd.lvm.lv=rhel_ibm-p8-01-lp5/swap crashkernel=768M numa_balancing=enable earlyprintk
> 
> free reports:
>               total        used        free      shared  buff/cache   available
> Mem:       24305408      919552    23120832       12032      265024    22976896
> Swap:       8388544           0     8388544
> 
> cpuinfo:
> Architecture:        ppc64le
> Byte Order:          Little Endian
> CPU(s):              16
> On-line CPU(s) list: 0-15
> Thread(s) per core:  8
> Core(s) per socket:  1
> Socket(s):           2
> NUMA node(s):        2
> Model:               2.1 (pvr 004b 0201)
> Model name:          POWER8 (architected), altivec supported
> Hypervisor vendor:   pHyp
> Virtualization type: para
> L1d cache:           64K
> L1i cache:           32K
> L2 cache:            512K
> L3 cache:            8192K
> NUMA node0 CPU(s):
> NUMA node1 CPU(s):   0-15
> 
> Running tests.......
> <<<test_start>>>
> tag=fgetxattr02 stime=1550865820
> cmdline="fgetxattr02"
> contacts=""
> analysis=exit
> <<<test_output>>>
> tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
> fgetxattr02.c:174: PASS: fgetxattr(2) on testfile passed
> fgetxattr02.c:188: PASS: fgetxattr(2) on testfile got the right value
> fgetxattr02.c:201: PASS: fgetxattr(2) on testfile passed: SUCCESS
> fgetxattr02.c:174: PASS: fgetxattr(2) on testdir passed
> fgetxattr02.c:188: PASS: fgetxattr(2) on testdir got the right value
> fgetxattr02.c:201: PASS: fgetxattr(2) on testdir passed: SUCCESS
> fgetxattr02.c:174: PASS: fgetxattr(2) on symlink passed
> fgetxattr02.c:188: PASS: fgetxattr(2) on symlink got the right value
> fgetxattr02.c:201: PASS: fgetxattr(2) on symlink passed: SUCCESS
> fgetxattr02.c:201: PASS: fgetxattr(2) on fifo passed: ENODATA
> fgetxattr02.c:201: PASS: fgetxattr(2) on chr passed: ENODATA
> fgetxattr02.c:201: PASS: fgetxattr(2) on blk passed: ENODATA
> fgetxattr02.c:201: PASS: fgetxattr(2) on sock passed: ENODATA
> 
> Summary:
> passed   13
> failed   0
> skipped  0
> warnings 0
> <<<execution_status>>>
> initiation_status="ok"
> duration=0 termination_type=exited termination_id=0 corefile=no
> cutime=0 cstime=1
> <<<test_end>>>
> <<<test_start>>>
> tag=io_submit01 stime=1550865820
> cmdline="io_submit01"
> contacts=""
> analysis=exit
> <<<test_output>>>
> incrementing stop
> tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
> io_submit01.c:125: PASS: io_submit() with invalid ctx failed with EINVAL
> io_submit01.c:125: PASS: io_submit() with invalid nr failed with EINVAL
> io_submit01.c:125: PASS: io_submit() with invalid iocbpp pointer failed with EFAULT
> io_submit01.c:125: PASS: io_submit() with NULL iocb pointers failed with EFAULT
> io_submit01.c:125: PASS: io_submit() with invalid fd failed with EBADF
> io_submit01.c:125: PASS: io_submit() with readonly fd for write failed with EBADF
> io_submit01.c:125: PASS: io_submit() with writeonly fd for read failed with EBADF
> io_submit01.c:125: PASS: io_submit() with zero buf size failed with SUCCESS
> io_submit01.c:125: PASS: io_submit() with zero nr failed with SUCCESS
> 
> Summary:
> passed   9
> failed   0
> skipped  0
> warnings 0
> 
> On 2/22/19 12:40 AM, Qian Cai wrote:
>> This is only reproducible on linux-next (20190221), as v5.0-rc7 is fine. Running
>> two LTP tests and then reboot will trigger this on ppc64le (CONFIG_IO_URING=n
>> and CONFIG_SHUFFLE_PAGE_ALLOCATOR=y).
>>
>> # fgetxattr02
>> # io_submit01
>> # systemctl reboot
>>
>> There is a 32-bit (with all ones) overwritten of free slab objects (poisoned).
>>
>> [23424.121182] BUG aio_kiocb (Tainted: G    B   W    L   ): Poison overwritten
>> [23424.121189]
>> -----------------------------------------------------------------------------
>> [23424.121189]
>> [23424.121197] INFO: 0x000000009f1f5145-0x00000000841e301b. First byte 0xff
>> instead of 0x6b
>> [23424.121205] INFO: Allocated in io_submit_one+0x9c/0xb20 age=0 cpu=7 pid=12174
>> [23424.121212]  __slab_alloc+0x34/0x60
>> [23424.121217]  kmem_cache_alloc+0x504/0x5c0
>> [23424.121221]  io_submit_one+0x9c/0xb20
>> [23424.121224]  sys_io_submit+0xe0/0x350
>> [23424.121227]  system_call+0x5c/0x70
>> [23424.121231] INFO: Freed in aio_complete+0x31c/0x410 age=0 cpu=7 pid=12174
>> [23424.121234]  kmem_cache_free+0x4bc/0x540
>> [23424.121237]  aio_complete+0x31c/0x410
>> [23424.121240]  blkdev_bio_end_io+0x238/0x3e0
>> [23424.121243]  bio_endio.part.3+0x214/0x330
>> [23424.121247]  brd_make_request+0x2d8/0x314 [brd]
>> [23424.121250]  generic_make_request+0x220/0x510
>> [23424.121254]  submit_bio+0xc8/0x1f0
>> [23424.121256]  blkdev_direct_IO+0x36c/0x610
>> [23424.121260]  generic_file_read_iter+0xbc/0x230
>> [23424.121263]  blkdev_read_iter+0x50/0x80
>> [23424.121266]  aio_read+0x138/0x200
>> [23424.121269]  io_submit_one+0x7c4/0xb20
>> [23424.121272]  sys_io_submit+0xe0/0x350
>> [23424.121275]  system_call+0x5c/0x70
>> [23424.121278] INFO: Slab 0x00000000841158ec objects=85 used=85 fp=0x
>> (null) flags=0x13fffc000000200
>> [23424.121282] INFO: Object 0x000000007e677ed8 @offset=5504 fp=0x00000000e42bdf6f
>> [23424.121282]
>> [23424.121287] Redzone 000000005483b8fc: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121291] Redzone 00000000b842fe53: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121295] Redzone 00000000deb0d052: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121299] Redzone 0000000014045233: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121302] Redzone 00000000dd5d6c16: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121306] Redzone 00000000538b5478: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121310] Redzone 000000001f7fb704: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121314] Redzone 0000000000e0484d: bb bb bb bb bb bb bb bb bb bb bb bb bb
>> bb bb bb  ................
>> [23424.121318] Object 000000007e677ed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121322] Object 00000000e207f30b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121326] Object 00000000a7a45634: 6b 6b 6b 6b 6b 6b 6b 6b ff ff ff ff 6b
>> 6b 6b 6b  kkkkkkkk....kkkk
>> [23424.121330] Object 00000000c85d951d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121334] Object 000000003104522f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121338] Object 00000000cfcdd820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121342] Object 00000000dded4924: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121346] Object 00000000ff6687a4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121350] Object 00000000df3d67f6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121354] Object 00000000ddc188d1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121358] Object 000000002cee751a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b 6b  kkkkkkkkkkkkkkkk
>> [23424.121362] Object 00000000a994f007: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
>> 6b 6b a5  kkkkkkkkkkkkkkk.
>> [23424.121366] Redzone 000000009f3d62e2: bb bb bb bb bb bb bb bb
>>          ........
>> [23424.121370] Padding 00000000e5ccead8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121374] Padding 000000002b0c1778: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121378] Padding 00000000c67656c7: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121382] Padding 0000000078348c5a: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121386] Padding 00000000f3297820: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121390] Padding 00000000e55789f4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121394] Padding 00000000d0fbb94c: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121397] Padding 00000000bcb27a87: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
>> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
>> [23424.121743] CPU: 7 PID: 12174 Comm: vgs Tainted: G    B   W    L
>> 5.0.0-rc7-next-20190221+ #7
>> [23424.121758] Call Trace:
>> [23424.121762] [c0000004ce5bf7b0] [c0000000007deb8c] dump_stack+0xb0/0xf4
>> (unreliable)
>> [23424.121770] [c0000004ce5bf7f0] [c00000000037d310] print_trailer+0x250/0x278
>> [23424.121775] [c0000004ce5bf880] [c00000000036d578]
>> check_bytes_and_report+0x138/0x160
>> [23424.121779] [c0000004ce5bf920] [c00000000036fac8] check_object+0x348/0x3e0
>> [23424.121784] [c0000004ce5bf990] [c00000000036fd18]
>> alloc_debug_processing+0x1b8/0x2c0
>> [23424.121788] [c0000004ce5bfa30] [c000000000372d14] ___slab_alloc+0xbb4/0xfa0
>> [23424.121792] [c0000004ce5bfb60] [c000000000373134] __slab_alloc+0x34/0x60
>> [23424.121802] [c0000004ce5bfb90] [c000000000373664] kmem_cache_alloc+0x504/0x5c0
>> [23424.121812] [c0000004ce5bfc20] [c000000000476a9c] io_submit_one+0x9c/0xb20
>> [23424.121824] [c0000004ce5bfd50] [c000000000477f10] sys_io_submit+0xe0/0x350
>> [23424.121832] [c0000004ce5bfe20] [c00000000000b000] system_call+0x5c/0x70
>> [23424.121836] FIX aio_kiocb: Restoring 0x000000009f1f5145-0x00000000841e301b=0x6b
>> [23424.121836]
>> [23424.121840] FIX aio_kiocb: Marking all objects used
>>
> 

