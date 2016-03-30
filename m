Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 62EF96B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 16:50:49 -0400 (EDT)
Received: by mail-oi0-f41.google.com with SMTP id d205so32692359oia.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 13:50:49 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id 2si3817909oth.87.2016.03.30.13.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 13:50:48 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id q128so10409824iof.2
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 13:50:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160330105844.4cf1f0b8@redhat.com>
References: <CAA4-JFLOmeYrWOEO_d2ALPgf0cWhC_fv1Gisz5fyH3uY1ogV1g@mail.gmail.com>
	<20160330105844.4cf1f0b8@redhat.com>
Date: Wed, 30 Mar 2016 13:50:47 -0700
Message-ID: <CAA4-JFLpso_Pnh=MLocszDm7Rr1cqYJpXDQdH_Larsy5GF3-7g@mail.gmail.com>
Subject: Re: 3.14.65: Memory leak when slub_debug is enabled
From: Ajay Patel <patela@gmail.com>
Content-Type: multipart/alternative; boundary=001a113ffd64e8fc2a052f4a4c02
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.co, linux-mm <linux-mm@kvack.org>

--001a113ffd64e8fc2a052f4a4c02
Content-Type: text/plain; charset=UTF-8

Jesper/Christop

Thanks for getting back.

This is Marvel Armada dual core ARMV7 and it is 32bit CPU.

The problem is NOT seen if maxcpus=1 used in command line.

The HAVE_ALIGNED_STRUCT_PAGE and CONFIG_HAVE_CMPXCHG_DOUBLE is NOT defined
for the board where problem is seen.

The problem is profoundly seen on kmalloc-8192 slab.
The slab size and object size is displayed below.
Also the object partial is growing and active slabs are growing.

It seems one core is trying to allocate the buffers while other core is
freeing the buffer and causing this.
I have to add some debug to confirm the theory.

I also turned the SLUB_DEBUG_CMPXCHG and it is flooding the console.
Some of those messages pasted below.

Let me know if you need more info.

Thanks
Ajay


================== CPU info ============================
:/# cat /proc/cpuinfo
processor       : 0
model name      : ARMv7 Processor rev 1 (v7l)
Features        : swp half thumb fastmult vfp edsp thumbee neon vfpv3 tls
vfpd32
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x4
CPU part        : 0xc09
CPU revision    : 1

processor       : 1
model name      : ARMv7 Processor rev 1 (v7l)
Features        : swp half thumb fastmult vfp edsp thumbee neon vfpv3 tls
vfpd32
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x4
CPU part        : 0xc09
CPU revision    : 1

Hardware        : Marvell Armada 380/385/390/398

:/#



#:/sys/kernel/slab/kmalloc-8192# cat slab_size
8384
#:/sys/kernel/slab/kmalloc-8192# cat object_size
8192
=====================Initial state of counters  =====================
:/sys/kernel/slab/kmalloc-8192# cat objects_partial
2
:/sys/kernel/slab/kmalloc-8192# cat /proc/slabinfo | grep 8192
kmalloc-8192       32786  32790   8384    3    8 : tunables    0 0    0 :
slabdata  10930  10930      0

===================== counters after some time ============
#:/sys/kernel/slab/kmalloc-8192# cat /proc/slabinfo | grep 8192
kmalloc-8192       32789  44712   8384    3    8 : tunables    0 0    0 :
slabdata  14904  14904      0

#:/sys/kernel/slab/kmalloc-8192# cat objects_partial
15006



======================= Debug messages ======================

[03/30/2016 13:19:21.9400] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:22.0700] __slab_free skbuff_head_cache: cmpxchg double
redo acquire_slab names_cache: cmpxchg double redo
[03/30/2016 13:19:22.2100] __slab_free names_cache: cmpxchg double redo
unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:22.3400] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:22.5000] __slab_free filp: cmpxchg double redo unfreezing
slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:22.6300] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:22.7900] acquire_slab skbuff_head_cache: cmpxchg double
redo __slab_free kmalloc-2048: cmpxchg double redo
[03/30/2016 13:19:22.9500] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:23.0900] acquire_slab skbuff_head_cache: cmpxchg double
redo __slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:23.2300] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:23.3600] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:23.4900] acquire_slab skbuff_head_cache: cmpxchg double
redo __slab_free skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:23.6500] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:23.7900] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:23.9200] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:24.0500] __slab_free skbuff_head_cache: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:24.2300] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:24.3600] acquire_slab kmalloc-8192: cmpxchg double redo
unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:24.5000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:24.6300] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:24.7600] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:24.9000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:25.0300] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:25.1700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:25.3000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:25.4300] acquire_slab kmalloc-8192: cmpxchg double redo
unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:25.5600] unfreezing slab kmalloc-8192: cmpxchg double
redo unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:25.6900] acquire_slab skbuff_head_cache: cmpxchg double
redo unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:25.8300] unfreezing slab kmalloc-8192: cmpxchg double
redo unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:25.9600] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:26.0900] unfreezing slab kmalloc-8192: cmpxchg double
redo unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:26.2300] unfreezing slab kmalloc-8192: cmpxchg double
redo unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:26.3600] __slab_free kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-256: cmpxchg double redo
[03/30/2016 13:19:26.5000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:26.6900] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:26.8200] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:26.9400] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:27.0700] unfreezing slab skbuff_head_cache: cmpxchg
double redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:27.2100] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:27.3400] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:27.4800] acquire_slab skbuff_head_cache: cmpxchg double
redo __slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:27.6100] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:27.7400] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:27.8700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:28.0000] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:28.1300] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:28.2600] acquire_slab kmalloc-4096: cmpxchg double redo
__slab_free kmalloc-4096: cmpxchg double redo
[03/30/2016 13:19:28.4300] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:28.5700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:28.7000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:28.8400] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:28.9700] __slab_free kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:29.0900] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:29.2300] acquire_slab skbuff_head_cache: cmpxchg double
redo unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:29.3600] unfreezing slab kmalloc-8192: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:29.5000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:29.6300] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:29.7700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:29.9000] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:30.0300] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:30.1700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:30.3000] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:30.4400] __slab_free kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:30.5700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:30.7000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:30.8300] __slab_free skbuff_head_cache: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:30.9800] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:31.1100] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:31.2400] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:31.3700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:31.5000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:31.6300] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:31.7700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:31.9000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:32.0300] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:32.1600] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:32.2900] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:32.4300] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:32.5600] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:32.7000] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:32.8300] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:32.9700] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:33.1200] __slab_free skbuff_head_cache: cmpxchg double
redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:33.2600] acquire_slab skbuff_head_cache: cmpxchg double
redo __slab_free kmalloc-64: cmpxchg double redo
[03/30/2016 13:19:33.5900] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:33.7300] acquire_slab kmalloc-8192: cmpxchg double redo
unfreezing slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:33.8700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:34.0000] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:34.2300] acquire_slab kmalloc-8192: cmpxchg double redo
unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:34.3700] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:34.5000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:34.6300] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:34.7600] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:34.9000] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:35.0300] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:35.1700] acquire_slab skbuff_head_cache: cmpxchg double
redo unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:35.3000] __slab_free kmalloc-8192: cmpxchg double redo
unfreezing slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:35.4400] unfreezing slab kmalloc-8192: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:35.5700] __slab_free kmalloc-8192: cmpxchg double redo
unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:35.7000] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:35.8400] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:35.9600] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:36.0900] unfreezing slab kmalloc-8192: cmpxchg double
redo acquire_slab kmalloc-4096: cmpxchg double redo
[03/30/2016 13:19:36.2300] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:36.3500] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:36.4900] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:36.6200] __slab_free kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:36.7500] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:36.8800] __slab_free skbuff_head_cache: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:37.0200] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:37.1500] acquire_slab kmalloc-8192: cmpxchg double redo
unfreezing slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:37.2900] acquire_slab kmalloc-8192: cmpxchg double redo
acquire_slab skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:37.4200] acquire_slab skbuff_head_cache: cmpxchg double
redo acquire_slab kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:37.5500] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free skbuff_head_cache: cmpxchg double redo
[03/30/2016 13:19:37.7500] acquire_slab kmalloc-8192: cmpxchg double redo
__slab_free kmalloc-8192: cmpxchg double redo
[03/30/2016 13:19:37.8900] acquire_slab kmalloc-8192: cmpxchg double redo ac





On Wed, Mar 30, 2016 at 1:58 AM, Jesper Dangaard Brouer <brouer@redhat.com>
wrote:

>
> Hi Ajay,
>
> Could you please provide info on kernel .config settings via commands:
>
>  grep HAVE_ALIGNED_STRUCT_PAGE .config
>  grep CONFIG_HAVE_CMPXCHG_DOUBLE .config
>
> You can try to further debug your problem by defining SLUB_DEBUG_CMPXCHG
> manually in mm/slub.c to get some verbose output on the cmpxchg failures.
>
> Is the "Marvell Armada dual core ARMV7" a 32-bit CPU?
>
> --Jesper
>
> On Tue, 29 Mar 2016 15:32:26 -0700 Ajay Patel <patela@gmail.com> wrote:
>
> > We have custom board with Marvell Armada dual core ARMV7.
> > The driver uses buffers from kmalloc-8192 slab heavily.
> > When slub_debug is enabled, the kmalloc-8192 active slabs are
> > increasing. The slub stats shows  cmpxchg_double_fail and objects_partial
> > are increasing too. Eventually system panics on oom.
> >
> > Following patch fixes the issue.
> > Has anybody encountered this issue?
> > Is this right fix?
> >
> > I am not in mailing list please cc me.
> >
> > Thanks
> > Ajay
> >
> >
> > --- slub.c.orig Tue Mar 29 11:54:42 2016
> > +++ slub.c      Tue Mar 29 15:08:30 2016
> > @@ -1562,9 +1562,12 @@
> >         void *freelist;
> >         unsigned long counters;
> >         struct page new;
> > +       int retry_count = 0;
> > +#define RETRY_COUNT 10
> >
> >         lockdep_assert_held(&n->list_lock);
> >
> > +again:
> >         /*
> >          * Zap the freelist and set the frozen bit.
> >          * The old freelist is the list of objects for the
> > @@ -1587,8 +1590,13 @@
> >         if (!__cmpxchg_double_slab(s, page,
> >                         freelist, counters,
> >                         new.freelist, new.counters,
> > -                       "acquire_slab"))
> > +                       "acquire_slab")) {
> > +               if (retry_count++ < RETRY_COUNT) {
> > +                       new.frozen = 0;
> > +                       goto again;
> > +               }
> >                 return NULL;
> > +       }
> >
> >         remove_partial(n, page);
> >         WARN_ON(!freelist);
>
>
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
>

--001a113ffd64e8fc2a052f4a4c02
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div>Jesper/Christop<br><br></div>Thanks for getting =
back.<br><br></div><div>This is Marvel Armada dual core ARMV7 and it is 32b=
it CPU.<br><br></div><div>The problem is NOT seen if maxcpus=3D1 used in co=
mmand line.<br><br></div><div>The HAVE_ALIGNED_STRUCT_PAGE and CONFIG_HAVE_=
CMPXCHG_DOUBLE is NOT defined<br></div><div>for the board where problem is =
seen.<br><br></div><div>The problem is profoundly seen on kmalloc-8192 slab=
.<br></div><div>The slab size and object size is displayed below.<br></div>=
<div>Also the object partial is growing and active slabs are growing.<br><b=
r>It seems one core is trying to allocate the buffers while other core is f=
reeing the buffer and causing this.<br></div><div>I have to add some debug =
to confirm the theory.<br><br></div><div>I also turned the SLUB_DEBUG_CMPXC=
HG and it is flooding the console.<br></div><div>Some of those messages pas=
ted below.<br><br></div><div>Let me know if you need more info.<br><br></di=
v><div>Thanks<br></div><div>Ajay<br><br><br></div><div>=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D CPU info =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>:/# cat /proc/=
cpuinfo<br>processor=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0<br>model name=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : ARMv7 Processor rev 1 (v7l)<br>Features=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : swp half thumb fastmult vfp edsp =
thumbee neon vfpv3 tls vfpd32<br>CPU implementer : 0x41<br>CPU architecture=
: 7<br>CPU variant=C2=A0=C2=A0=C2=A0=C2=A0 : 0x4<br>CPU part=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 0xc09<br>CPU revision=C2=A0=C2=A0=C2=A0 : 1<b=
r><br>processor=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : 1<br>model name=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 : ARMv7 Processor rev 1 (v7l)<br>Features=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : swp half thumb fastmult vfp edsp thumbe=
e neon vfpv3 tls vfpd32<br>CPU implementer : 0x41<br>CPU architecture: 7<br=
>CPU variant=C2=A0=C2=A0=C2=A0=C2=A0 : 0x4<br>CPU part=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 : 0xc09<br>CPU revision=C2=A0=C2=A0=C2=A0 : 1<br><br>=
Hardware=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : Marvell Armada 380/385=
/390/398<br><br>:/#<br><br><br></div><div><br></div><div>#:/sys/kernel/slab=
/kmalloc-8192# cat slab_size
<br>8384
<br>#:/sys/kernel/slab/kmalloc-8192# cat object_size
<br>8192
<br></div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3DInitial state of counters=C2=A0 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D<br></div><div>:/sys/kernel/slab/kmalloc-8192# cat =
objects_partial
<br>2
<br>:/sys/kernel/slab/kmalloc-8192# cat /proc/slabinfo | grep 8192
<br>kmalloc-8192=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 32786=C2=A0 32790=C2=
=A0=C2=A0 8384=C2=A0=C2=A0=C2=A0 3=C2=A0=C2=A0=C2=A0 8 : tunables=C2=A0=C2=
=A0=C2=A0 0 0=C2=A0=C2=A0=C2=A0 0=20
: slabdata=C2=A0 10930=C2=A0 10930=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0
<br>
<br></div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D counters after some time =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br></div>=
<div>#:/sys/kernel/slab/kmalloc-8192# cat /proc/slabinfo | grep 8192
<br>kmalloc-8192=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 32789=C2=A0 44712=C2=
=A0=C2=A0 8384=C2=A0=C2=A0=C2=A0 3=C2=A0=C2=A0=C2=A0 8 : tunables=C2=A0=C2=
=A0=C2=A0 0 0=C2=A0=C2=A0=C2=A0 0=20
: slabdata=C2=A0 14904=C2=A0 14904=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0
<br>
<br>#:/sys/kernel/slab/kmalloc-8192# cat objects_partial
<br>15006<br><br><br><br></div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D Debug messages =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br></div><div><br></div><div>[03/30=
/2016 13:19:21.9400] acquire_slab kmalloc-8192: cmpxchg double redo __slab_=
free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:22.0700] __slab_free skbuff_head_cache: cmpxchg double re=
do acquire_slab names_cache: cmpxchg double redo<br>
[03/30/2016 13:19:22.2100] __slab_free names_cache: cmpxchg double redo unf=
reezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:22.3400] acquire_slab skbuff_head_cache: cmpxchg=20
double redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:22.5000] __slab_free filp: cmpxchg double redo unfreezing=
 slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:22.6300] acquire_slab skbuff_head_cache: cmpxchg=20
double redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:22.7900] acquire_slab skbuff_head_cache: cmpxchg double r=
edo __slab_free kmalloc-2048: cmpxchg double redo<br>
[03/30/2016 13:19:22.9500] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:23.0900] acquire_slab skbuff_head_cache: cmpxchg double r=
edo __slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:23.2300] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:23.3600] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:23.4900] acquire_slab skbuff_head_cache: cmpxchg=20
double redo __slab_free skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:23.6500] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:23.7900] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:23.9200] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:24.0500] __slab_free skbuff_head_cache: cmpxchg double re=
do acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:24.2300] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:24.3600] acquire_slab kmalloc-8192: cmpxchg double redo u=
nfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:24.5000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:24.6300] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:24.7600] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:24.9000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:25.0300] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:25.1700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:25.3000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:25.4300] acquire_slab kmalloc-8192: cmpxchg double redo u=
nfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:25.5600] unfreezing slab kmalloc-8192: cmpxchg double red=
o unfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:25.6900] acquire_slab skbuff_head_cache: cmpxchg double r=
edo unfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:25.8300] unfreezing slab kmalloc-8192: cmpxchg double red=
o unfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:25.9600] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:26.0900] unfreezing slab kmalloc-8192: cmpxchg double red=
o unfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:26.2300] unfreezing slab kmalloc-8192: cmpxchg double red=
o unfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:26.3600] __slab_free kmalloc-8192: cmpxchg double redo __=
slab_free kmalloc-256: cmpxchg double redo<br>
[03/30/2016 13:19:26.5000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:26.6900] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:26.8200] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:26.9400] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:27.0700] unfreezing slab skbuff_head_cache: cmpxchg=20
double redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:27.2100] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:27.3400] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:27.4800] acquire_slab skbuff_head_cache: cmpxchg double r=
edo __slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:27.6100] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:27.7400] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:27.8700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:28.0000] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:28.1300] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:28.2600] acquire_slab kmalloc-4096: cmpxchg double redo _=
_slab_free kmalloc-4096: cmpxchg double redo<br>
[03/30/2016 13:19:28.4300] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:28.5700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:28.7000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:28.8400] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:28.9700] __slab_free kmalloc-8192: cmpxchg double redo __=
slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:29.0900] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:29.2300] acquire_slab skbuff_head_cache: cmpxchg double r=
edo unfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:29.3600] unfreezing slab kmalloc-8192: cmpxchg double red=
o acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:29.5000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:29.6300] acquire_slab skbuff_head_cache: cmpxchg=20
double redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:29.7700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:29.9000] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:30.0300] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:30.1700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:30.3000] acquire_slab skbuff_head_cache: cmpxchg double r=
edo acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:30.4400] __slab_free kmalloc-8192: cmpxchg double redo __=
slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:30.5700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:30.7000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:30.8300] __slab_free skbuff_head_cache: cmpxchg double re=
do acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:30.9800] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:31.1100] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:31.2400] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:31.3700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:31.5000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:31.6300] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:31.7700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:31.9000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:32.0300] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:32.1600] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:32.2900] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:32.4300] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:32.5600] acquire_slab skbuff_head_cache: cmpxchg double r=
edo acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:32.7000] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:32.8300] acquire_slab skbuff_head_cache: cmpxchg=20
double redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:32.9700] acquire_slab skbuff_head_cache: cmpxchg=20
double redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:33.1200] __slab_free skbuff_head_cache: cmpxchg double
 redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:33.2600] acquire_slab skbuff_head_cache: cmpxchg double r=
edo __slab_free kmalloc-64: cmpxchg double redo<br>
[03/30/2016 13:19:33.5900] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:33.7300] acquire_slab kmalloc-8192: cmpxchg double redo u=
nfreezing slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:33.8700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:34.0000] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:34.2300] acquire_slab kmalloc-8192: cmpxchg double redo u=
nfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:34.3700] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:34.5000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:34.6300] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:34.7600] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:34.9000] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:35.0300] acquire_slab skbuff_head_cache: cmpxchg=20
double redo acquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:35.1700] acquire_slab skbuff_head_cache: cmpxchg double r=
edo unfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:35.3000] __slab_free kmalloc-8192: cmpxchg double redo un=
freezing slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:35.4400] unfreezing slab kmalloc-8192: cmpxchg double red=
o acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:35.5700] __slab_free kmalloc-8192: cmpxchg double redo un=
freezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:35.7000] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:35.8400] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:35.9600] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:36.0900] unfreezing slab kmalloc-8192: cmpxchg double red=
o acquire_slab kmalloc-4096: cmpxchg double redo<br>
[03/30/2016 13:19:36.2300] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:36.3500] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:36.4900] acquire_slab skbuff_head_cache: cmpxchg double r=
edo acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:36.6200] __slab_free kmalloc-8192: cmpxchg double redo ac=
quire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:36.7500] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:36.8800] __slab_free skbuff_head_cache: cmpxchg double re=
do acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:37.0200] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:37.1500] acquire_slab kmalloc-8192: cmpxchg double redo u=
nfreezing slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:37.2900] acquire_slab kmalloc-8192: cmpxchg double redo a=
cquire_slab skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:37.4200] acquire_slab skbuff_head_cache: cmpxchg double r=
edo acquire_slab kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:37.5500] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free skbuff_head_cache: cmpxchg double redo<br>
[03/30/2016 13:19:37.7500] acquire_slab kmalloc-8192: cmpxchg double redo _=
_slab_free kmalloc-8192: cmpxchg double redo<br>
[03/30/2016 13:19:37.8900] acquire_slab kmalloc-8192: cmpxchg double redo a=
c<br>
<br><br></div><div><br><br></div></div><div class=3D"gmail_extra"><br><div =
class=3D"gmail_quote">On Wed, Mar 30, 2016 at 1:58 AM, Jesper Dangaard Brou=
er <span dir=3D"ltr">&lt;<a href=3D"mailto:brouer@redhat.com" target=3D"_bl=
ank">brouer@redhat.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex"><br>
Hi Ajay,<br>
<br>
Could you please provide info on kernel .config settings via commands:<br>
<br>
=C2=A0grep HAVE_ALIGNED_STRUCT_PAGE .config<br>
=C2=A0grep CONFIG_HAVE_CMPXCHG_DOUBLE .config<br>
<br>
You can try to further debug your problem by defining SLUB_DEBUG_CMPXCHG<br=
>
manually in mm/slub.c to get some verbose output on the cmpxchg failures.<b=
r>
<br>
Is the &quot;Marvell Armada dual core ARMV7&quot; a 32-bit CPU?<br>
<br>
--Jesper<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
On Tue, 29 Mar 2016 15:32:26 -0700 Ajay Patel &lt;<a href=3D"mailto:patela@=
gmail.com">patela@gmail.com</a>&gt; wrote:<br>
<br>
&gt; We have custom board with Marvell Armada dual core ARMV7.<br>
&gt; The driver uses buffers from kmalloc-8192 slab heavily.<br>
&gt; When slub_debug is enabled, the kmalloc-8192 active slabs are<br>
&gt; increasing. The slub stats shows=C2=A0 cmpxchg_double_fail and objects=
_partial<br>
&gt; are increasing too. Eventually system panics on oom.<br>
&gt;<br>
&gt; Following patch fixes the issue.<br>
&gt; Has anybody encountered this issue?<br>
&gt; Is this right fix?<br>
&gt;<br>
&gt; I am not in mailing list please cc me.<br>
&gt;<br>
&gt; Thanks<br>
&gt; Ajay<br>
&gt;<br>
&gt;<br>
&gt; --- slub.c.orig Tue Mar 29 11:54:42 2016<br>
&gt; +++ slub.c=C2=A0 =C2=A0 =C2=A0 Tue Mar 29 15:08:30 2016<br>
&gt; @@ -1562,9 +1562,12 @@<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0void *freelist;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long counters;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page new;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0int retry_count =3D 0;<br>
&gt; +#define RETRY_COUNT 10<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lockdep_assert_held(&amp;n-&gt;list_l=
ock);<br>
&gt;<br>
&gt; +again:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Zap the freelist and set the froze=
n bit.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * The old freelist is the list of ob=
jects for the<br>
&gt; @@ -1587,8 +1590,13 @@<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!__cmpxchg_double_slab(s, page,<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0freelist, counters,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0new.freelist, new.counters,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0&quot;acquire_slab&quot;))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0&quot;acquire_slab&quot;)) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (retry_coun=
t++ &lt; RETRY_COUNT) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0new.frozen =3D 0;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0goto again;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NU=
LL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_partial(n, page);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON(!freelist);<br>
<br>
<br>
<br>
</div></div><span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Best regards,<br>
=C2=A0 Jesper Dangaard Brouer<br>
=C2=A0 MSc.CS, Principal Kernel Engineer at Red Hat<br>
=C2=A0 Author of <a href=3D"http://www.iptv-analyzer.org" rel=3D"noreferrer=
" target=3D"_blank">http://www.iptv-analyzer.org</a><br>
=C2=A0 LinkedIn: <a href=3D"http://www.linkedin.com/in/brouer" rel=3D"noref=
errer" target=3D"_blank">http://www.linkedin.com/in/brouer</a><br>
</font></span></blockquote></div><br></div>

--001a113ffd64e8fc2a052f4a4c02--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
