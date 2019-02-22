Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B9CAC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:07:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFF812070B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 21:07:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Lom/xUgl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFF812070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21DC68E0139; Fri, 22 Feb 2019 16:07:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D8708E0137; Fri, 22 Feb 2019 16:07:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3AAB8E013A; Fri, 22 Feb 2019 16:07:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE6378E0138
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 16:07:37 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p5so3281069qtp.3
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:07:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LiaWbODHYOh+ZnfJmFKaQwDMnQck/cyCHyDsVxz0fQU=;
        b=Cmg5WiOIRlme3pOm2CYQrW/VybHQJRSrI0c/MRN6UDVbPcja2S9pUUgI3srIeN+yNO
         X+AaWM7RyuC5IlP8y8twePy/JAoU2/GuCIlOC46fTF2OKgUjfu5qQ2DoNBnDPVRa8iqt
         sM/a1wPxbvblLQKpk7DHM6AmVI3leC4DEzLQvAgDlIG/3Jc1KDb9v5p4v3dDu2AcHGLN
         fIl86CXMIKDvXH7HiGtmktSLzpiALEWBq26iWzjXc8RA6Dff6/1sx8vrbpbQTDa4DYoB
         Uhq/i+yl0aGuHbM6k87EyeBE+p2acK2UaUfujiBk30DWnWXP3olzGucl7+GNxJX3P9Wj
         oX2Q==
X-Gm-Message-State: AHQUAua5YqAEIInLIDXOFfdRSWCkBrbDzSYF3SIGYccoIx+MvKS3yE6P
	WOGdG2rDD19noSbBqTFUH3+IMNBxV62iVTHEpCvnGP+zKtvLoJyPiI2KGg1hWkwsoEItJBzwPL6
	D7p6kyDUD+4YZPt4Pn6p6TA1JyR/yFMDpW2ufVTBSm2NknZfzT09B7qPOITOWdHThz+yIbb9MTa
	VOKQZ6Jn6fcozPAT6NY8cMBABL5s0U75Fg9tvQRelHx/vC9zEM7R90d2FaMoYdwD5dGFhipOcUS
	CLZSUE6fbtwvQ903KF3/GlsqKJ9AD981x2WA69Or2wMMhESx+SzLthC6xFzyCS10NMo9+6ePjxF
	fl2lAArWVwDCMtH7cvM8FpHgQd8DvVujxDqKizIhhEfqZ1qI+UKCdiVjgenU01W2+WvtiSduWmt
	R
X-Received: by 2002:a0c:d1f4:: with SMTP id k49mr4825320qvh.164.1550869657504;
        Fri, 22 Feb 2019 13:07:37 -0800 (PST)
X-Received: by 2002:a0c:d1f4:: with SMTP id k49mr4825237qvh.164.1550869656168;
        Fri, 22 Feb 2019 13:07:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550869656; cv=none;
        d=google.com; s=arc-20160816;
        b=uQ0wqK0+eHhcQ0rQSHITlzrjAI7ech4Hu8dPoUJaQiBsRTn969jhE2LIr4VKfw4aLr
         QD0F87p/AzH4kOZAbeWLeqWD+W5EAr6F+nSbBb2rrnJad7V2eizTn9Mz55axT9TDStEX
         ibZcOO9wGmExCYEYd+GN6PZSVaedutxzF1SmKtOFKRfN0NIW/M8r+xQtQigQd98nVNBW
         6ZLrxusXMCeedrAgnVtw05NNcLjOD8mhfvVX4ATHHaAypBk3180wWkidvC2gaaGZctH+
         RShSQJOUbferZe88/sayQS8OHfncg/Q4PhvTfuJ28UEQK1T9mxCysuVTpl7ZZpttxep6
         xmQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from
         :dkim-signature;
        bh=LiaWbODHYOh+ZnfJmFKaQwDMnQck/cyCHyDsVxz0fQU=;
        b=Cb566bcvDGWqFJQ+gMRN+RJQc8OyO7QpQZY2de37jD+mM3tqg6zPsxamRhVCubP62+
         bFWy6qqVGbkg58hogyf0LczUSz5hCJiXjC+ayr28e/JrKZc7sr5thu6zmh4e9dflVDbM
         eT5YUxgBXlQflCJ6ERl0jF+v7HWb6ZV1vMBZb4UadvnWE4yE3TCHNB/tf1+0tPWc358U
         2dV7s7hnVm2gXeZj+PFsqg63i41tO8e4wFW7fia+G/CLk4141v9fQn/ShU3PMTUhu78O
         vw1Xiu73n3MyYBEAjEF7BwYDmt081hJCxs093xXf1kqHtj7HiQxQovYy0LQmQf4/j60T
         D0HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="Lom/xUgl";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f39sor3056042qvf.46.2019.02.22.13.07.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 13:07:36 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="Lom/xUgl";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:subject:to:cc:references:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=LiaWbODHYOh+ZnfJmFKaQwDMnQck/cyCHyDsVxz0fQU=;
        b=Lom/xUglchz9raIHwUiu8kx89cD0sgH1BrJcRe4L1EquelC/ttgzV9nvi9/vCHtjiv
         7cfdLCSNZmSpYeGKeuHV5XHHkE9LGYmR+IQhJnLXaSEpTRklw881ipy9+ZBb0MXUoZep
         LnvCUAVUcAYvcyh8c5WVCAQzDzlre5t+ppg1Pj2Ax/M3XvchvoIsQ3E0mrO2Yg/6TiS4
         fONYJqEa+TxFm94Mri2hpxfqktETwqPbL7sI3GvlmMbbFbAa03N9v22G+Ku8NFMgySsI
         dL1C3Yh8QnYL2ssUtyuVRiUn0KPF7JGGlJeXteRs5uk1RQwF458/6d0iZZMTkD2qLpiI
         1Trw==
X-Google-Smtp-Source: AHgI3IYdvCp4QTO0Ou3ofEAAvVi6FH5V7L2PMN14Zwz7vy6zxbQkY539/7GZpfj/ac8m4TanCcAnHg==
X-Received: by 2002:a0c:891a:: with SMTP id 26mr4776956qvp.163.1550869655524;
        Fri, 22 Feb 2019 13:07:35 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id c9sm1920854qkj.61.2019.02.22.13.07.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:07:34 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: Re: io_submit with slab free object overwritten
To: hch@lst.de
Cc: axboe@kernel.dk, viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>, jthumshirn@suse.de,
 linux-fsdevel@vger.kernel.org, Christoph Lameter <cl@linux.com>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
Message-ID: <64b860a3-7946-ca72-8669-18ad01a78c7c@lca.pw>
Date: Fri, 22 Feb 2019 16:07:32 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Reverted the commit 75374d062756 ("fs: add an iopoll method to struct
file_operations") fixed the problem. Christoph mentioned that the field can be
calculated by the offset (40 bytes).

struct kmem_cache {
        struct kmem_cache_cpu __percpu *cpu_slab; (8 bytes)
        slab_flags_t flags; (4)
        unsigned long min_partial; (8)
        unsigned int size; (4)
        unsigned int object_size; (4)
        unsigned int offset; (4)
        unsigned int cpu_partial; (4)
        struct kmem_cache_order_objects oo; (4)

        /* Allocation and freeing of slabs */
        struct kmem_cache_order_objects max;

So, it looks like "max" was overwritten after freed.

# cat /opt/ltp/runtest/syscalls
fgetxattr02 fgetxattr02
io_submit01 io_submit01

# /opt/ltp/runltp -f syscalls

uname:
Linux 5.0.0-rc7-next-20190222+ #11 SMP Fri Feb 22 14:57:10 EST 2019 ppc64le
ppc64le ppc64le GNU/Linux

/proc/cmdline
BOOT_IMAGE=/vmlinuz-5.0.0-rc7-next-20190222+
root=/dev/mapper/rhel_ibm--p8--01--lp5-root ro rd.lvm.lv=rhel_ibm-p8-01-lp5/root
rd.lvm.lv=rhel_ibm-p8-01-lp5/swap crashkernel=768M numa_balancing=enable earlyprintk

free reports:
              total        used        free      shared  buff/cache   available
Mem:       24305408      919552    23120832       12032      265024    22976896
Swap:       8388544           0     8388544

cpuinfo:
Architecture:        ppc64le
Byte Order:          Little Endian
CPU(s):              16
On-line CPU(s) list: 0-15
Thread(s) per core:  8
Core(s) per socket:  1
Socket(s):           2
NUMA node(s):        2
Model:               2.1 (pvr 004b 0201)
Model name:          POWER8 (architected), altivec supported
Hypervisor vendor:   pHyp
Virtualization type: para
L1d cache:           64K
L1i cache:           32K
L2 cache:            512K
L3 cache:            8192K
NUMA node0 CPU(s):
NUMA node1 CPU(s):   0-15

Running tests.......
<<<test_start>>>
tag=fgetxattr02 stime=1550865820
cmdline="fgetxattr02"
contacts=""
analysis=exit
<<<test_output>>>
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
fgetxattr02.c:174: PASS: fgetxattr(2) on testfile passed
fgetxattr02.c:188: PASS: fgetxattr(2) on testfile got the right value
fgetxattr02.c:201: PASS: fgetxattr(2) on testfile passed: SUCCESS
fgetxattr02.c:174: PASS: fgetxattr(2) on testdir passed
fgetxattr02.c:188: PASS: fgetxattr(2) on testdir got the right value
fgetxattr02.c:201: PASS: fgetxattr(2) on testdir passed: SUCCESS
fgetxattr02.c:174: PASS: fgetxattr(2) on symlink passed
fgetxattr02.c:188: PASS: fgetxattr(2) on symlink got the right value
fgetxattr02.c:201: PASS: fgetxattr(2) on symlink passed: SUCCESS
fgetxattr02.c:201: PASS: fgetxattr(2) on fifo passed: ENODATA
fgetxattr02.c:201: PASS: fgetxattr(2) on chr passed: ENODATA
fgetxattr02.c:201: PASS: fgetxattr(2) on blk passed: ENODATA
fgetxattr02.c:201: PASS: fgetxattr(2) on sock passed: ENODATA

Summary:
passed   13
failed   0
skipped  0
warnings 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=io_submit01 stime=1550865820
cmdline="io_submit01"
contacts=""
analysis=exit
<<<test_output>>>
incrementing stop
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
io_submit01.c:125: PASS: io_submit() with invalid ctx failed with EINVAL
io_submit01.c:125: PASS: io_submit() with invalid nr failed with EINVAL
io_submit01.c:125: PASS: io_submit() with invalid iocbpp pointer failed with EFAULT
io_submit01.c:125: PASS: io_submit() with NULL iocb pointers failed with EFAULT
io_submit01.c:125: PASS: io_submit() with invalid fd failed with EBADF
io_submit01.c:125: PASS: io_submit() with readonly fd for write failed with EBADF
io_submit01.c:125: PASS: io_submit() with writeonly fd for read failed with EBADF
io_submit01.c:125: PASS: io_submit() with zero buf size failed with SUCCESS
io_submit01.c:125: PASS: io_submit() with zero nr failed with SUCCESS

Summary:
passed   9
failed   0
skipped  0
warnings 0

On 2/22/19 12:40 AM, Qian Cai wrote:
> This is only reproducible on linux-next (20190221), as v5.0-rc7 is fine. Running
> two LTP tests and then reboot will trigger this on ppc64le (CONFIG_IO_URING=n
> and CONFIG_SHUFFLE_PAGE_ALLOCATOR=y).
> 
> # fgetxattr02
> # io_submit01
> # systemctl reboot
> 
> There is a 32-bit (with all ones) overwritten of free slab objects (poisoned).
> 
> [23424.121182] BUG aio_kiocb (Tainted: G    B   W    L   ): Poison overwritten
> [23424.121189]
> -----------------------------------------------------------------------------
> [23424.121189]
> [23424.121197] INFO: 0x000000009f1f5145-0x00000000841e301b. First byte 0xff
> instead of 0x6b
> [23424.121205] INFO: Allocated in io_submit_one+0x9c/0xb20 age=0 cpu=7 pid=12174
> [23424.121212]  __slab_alloc+0x34/0x60
> [23424.121217]  kmem_cache_alloc+0x504/0x5c0
> [23424.121221]  io_submit_one+0x9c/0xb20
> [23424.121224]  sys_io_submit+0xe0/0x350
> [23424.121227]  system_call+0x5c/0x70
> [23424.121231] INFO: Freed in aio_complete+0x31c/0x410 age=0 cpu=7 pid=12174
> [23424.121234]  kmem_cache_free+0x4bc/0x540
> [23424.121237]  aio_complete+0x31c/0x410
> [23424.121240]  blkdev_bio_end_io+0x238/0x3e0
> [23424.121243]  bio_endio.part.3+0x214/0x330
> [23424.121247]  brd_make_request+0x2d8/0x314 [brd]
> [23424.121250]  generic_make_request+0x220/0x510
> [23424.121254]  submit_bio+0xc8/0x1f0
> [23424.121256]  blkdev_direct_IO+0x36c/0x610
> [23424.121260]  generic_file_read_iter+0xbc/0x230
> [23424.121263]  blkdev_read_iter+0x50/0x80
> [23424.121266]  aio_read+0x138/0x200
> [23424.121269]  io_submit_one+0x7c4/0xb20
> [23424.121272]  sys_io_submit+0xe0/0x350
> [23424.121275]  system_call+0x5c/0x70
> [23424.121278] INFO: Slab 0x00000000841158ec objects=85 used=85 fp=0x
> (null) flags=0x13fffc000000200
> [23424.121282] INFO: Object 0x000000007e677ed8 @offset=5504 fp=0x00000000e42bdf6f
> [23424.121282]
> [23424.121287] Redzone 000000005483b8fc: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121291] Redzone 00000000b842fe53: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121295] Redzone 00000000deb0d052: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121299] Redzone 0000000014045233: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121302] Redzone 00000000dd5d6c16: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121306] Redzone 00000000538b5478: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121310] Redzone 000000001f7fb704: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121314] Redzone 0000000000e0484d: bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb bb bb  ................
> [23424.121318] Object 000000007e677ed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121322] Object 00000000e207f30b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121326] Object 00000000a7a45634: 6b 6b 6b 6b 6b 6b 6b 6b ff ff ff ff 6b
> 6b 6b 6b  kkkkkkkk....kkkk
> [23424.121330] Object 00000000c85d951d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121334] Object 000000003104522f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121338] Object 00000000cfcdd820: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121342] Object 00000000dded4924: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121346] Object 00000000ff6687a4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121350] Object 00000000df3d67f6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121354] Object 00000000ddc188d1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121358] Object 000000002cee751a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b 6b  kkkkkkkkkkkkkkkk
> [23424.121362] Object 00000000a994f007: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> 6b 6b a5  kkkkkkkkkkkkkkk.
> [23424.121366] Redzone 000000009f3d62e2: bb bb bb bb bb bb bb bb
>          ........
> [23424.121370] Padding 00000000e5ccead8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121374] Padding 000000002b0c1778: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121378] Padding 00000000c67656c7: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121382] Padding 0000000078348c5a: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121386] Padding 00000000f3297820: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121390] Padding 00000000e55789f4: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121394] Padding 00000000d0fbb94c: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121397] Padding 00000000bcb27a87: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> [23424.121743] CPU: 7 PID: 12174 Comm: vgs Tainted: G    B   W    L
> 5.0.0-rc7-next-20190221+ #7
> [23424.121758] Call Trace:
> [23424.121762] [c0000004ce5bf7b0] [c0000000007deb8c] dump_stack+0xb0/0xf4
> (unreliable)
> [23424.121770] [c0000004ce5bf7f0] [c00000000037d310] print_trailer+0x250/0x278
> [23424.121775] [c0000004ce5bf880] [c00000000036d578]
> check_bytes_and_report+0x138/0x160
> [23424.121779] [c0000004ce5bf920] [c00000000036fac8] check_object+0x348/0x3e0
> [23424.121784] [c0000004ce5bf990] [c00000000036fd18]
> alloc_debug_processing+0x1b8/0x2c0
> [23424.121788] [c0000004ce5bfa30] [c000000000372d14] ___slab_alloc+0xbb4/0xfa0
> [23424.121792] [c0000004ce5bfb60] [c000000000373134] __slab_alloc+0x34/0x60
> [23424.121802] [c0000004ce5bfb90] [c000000000373664] kmem_cache_alloc+0x504/0x5c0
> [23424.121812] [c0000004ce5bfc20] [c000000000476a9c] io_submit_one+0x9c/0xb20
> [23424.121824] [c0000004ce5bfd50] [c000000000477f10] sys_io_submit+0xe0/0x350
> [23424.121832] [c0000004ce5bfe20] [c00000000000b000] system_call+0x5c/0x70
> [23424.121836] FIX aio_kiocb: Restoring 0x000000009f1f5145-0x00000000841e301b=0x6b
> [23424.121836]
> [23424.121840] FIX aio_kiocb: Marking all objects used
> 

