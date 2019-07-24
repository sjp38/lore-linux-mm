Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4572FC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:37:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1060D214AF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:37:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1060D214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 973C46B0003; Wed, 24 Jul 2019 15:37:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94B786B0006; Wed, 24 Jul 2019 15:37:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85FDB8E0002; Wed, 24 Jul 2019 15:37:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 675116B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:37:00 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id x1so40253044qkn.6
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:37:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Z7pnaGuYc9LFLbT5aUxNfUlnE7ek1gcnJ4zW5L3HylM=;
        b=Q+4SfPJheO7V5whNzInwXMFo8wIRDjs04mYBy+5GQxA9YmOorNRHJMWky/eEyRo2UE
         DclwKa4hOuvTQDCbeJRNxJqZiW3N7rJXP7HO/ExQ/HPTH2QrYBy52dirxccacIaJwAH6
         49xLGZdFZLNTJSLGIOk5zVyRJBiLBd5EEk48b7AYEmjgWbYnKRTmHPe8npvMi8X7sJoU
         BOVaC/kcLZGBPifAGLTtRwIWJQLB4+v/95gHpeUk/FBzHSIE9fwDpSSuV3JTaeQS+vng
         tg8ueygYg7p7SUUHIrp4elBx9gBOwhP0lCuPu1gTyV69s8/icdCA97/NC4unGBQg12YL
         +Ivw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVGC+IzccZwObFaVipYqx6T0uP3lbywkjPLdRd3sL3y0YFTwAhZ
	5tPCvIYD0cOY193Zdh0OrXzN2ffuzcW+SiKQ2U/sZWS0TmtqzH3vlg6Jc5yHJjWCzub7SiAz6MQ
	S5HMMjgaPkioZHKzBlkNh5veSapt/6x0/7n3Kf8c0uqDjaEcQYD+GerP0qcy4LKXtFw==
X-Received: by 2002:ae9:d606:: with SMTP id r6mr54653369qkk.364.1563997020163;
        Wed, 24 Jul 2019 12:37:00 -0700 (PDT)
X-Received: by 2002:ae9:d606:: with SMTP id r6mr54653345qkk.364.1563997019302;
        Wed, 24 Jul 2019 12:36:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563997019; cv=none;
        d=google.com; s=arc-20160816;
        b=jrE/qNP/kz2NYzgKqNoY7NIKsW6GaEgkyPzsYQDttDgCUDhq9LY39G1PbWF1miCg3b
         3RRkaKCzTT3bsvfzbzr/+vrbXi7rNQnRxdqG2xyKropcB7HD0Jy0Bbkn84ChpXCr3tXf
         T/YXloRFBLL02ObbmNTULJR1nhA2jUAcB4V/985tZesqtvzD/UX7fjI1OgAolsIrJbTj
         6/Gd1gXXCaL7u9dSZU3lodWHMpTIJbe3pDr4gy0ZjjQPZ/hEdG9zQxtAaRW2Q/8gGkZj
         68myKxcVY0OYk++vJrtvTU0G1it1bqMzN6UOpnratVPOsszIgPrioILPLG/wjZeSEFi8
         lKMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=Z7pnaGuYc9LFLbT5aUxNfUlnE7ek1gcnJ4zW5L3HylM=;
        b=E/6wfspzz6e9RVU3fYEdT+b0k8xWKvTfAdHMexulapjoIdWkOp5pbFyELcFAVb3z44
         DHnAos2qSdHeXIH0il1u+xcIVtaM5wlh0o67JdPZ2I9T+6ussqrmCI6v9toc6Nli3ne/
         0AjkNXoGZvs25ZhZVNz6m9adZVqQSdArPAh/v6Gjze00om/hKSDuL4844MVXj1aoXQto
         z5Y/M1z5SigDjc24YJ0Je9Ia2ksZP1wegf+3NBd/ghe8B86YgD6PXrFYWprFfQy7TT03
         hGsItHaNi+tMq1jfv0cLJAjII+8kIKZGi7UpFqQpliL88O6Kn/Z12fnqzLK6mgQu3Bct
         6MQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q41sor61781848qta.24.2019.07.24.12.36.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:36:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwNTwfZ7UhOrUsmMJREZDSG4r+F8zrpdIk7pUPLDp8e5SLJxmNngfBQGNr0NG9bBAHOHmh5zA==
X-Received: by 2002:ac8:1887:: with SMTP id s7mr59031081qtj.220.1563997018800;
        Wed, 24 Jul 2019 12:36:58 -0700 (PDT)
Received: from [192.168.1.157] (pool-96-235-39-235.pitbpa.fios.verizon.net. [96.235.39.235])
        by smtp.gmail.com with ESMTPSA id q17sm16672031qtl.13.2019.07.24.12.36.57
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 12:36:58 -0700 (PDT)
Subject: Re: Limits for ION Memory Allocator
To: alex.popov@linux.com, Sumit Semwal <sumit.semwal@linaro.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com,
 Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
 Joel Fernandes <joel@joelfernandes.org>,
 Christian Brauner <christian@brauner.io>,
 Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org,
 linaro-mm-sig@lists.linaro.org,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 dri-devel@lists.freedesktop.org, LKML <linux-kernel@vger.kernel.org>,
 Brian Starkey <brian.starkey@arm.com>,
 Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>,
 Benjamin Gaignard <benjamin.gaignard@linaro.org>,
 Linux-MM <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>,
 Andrey Konovalov <andreyknvl@google.com>, syzkaller@googlegroups.com,
 John Stultz <john.stultz@linaro.org>
References: <3b922aa4-c6d4-e4a4-766d-f324ff77f7b5@linux.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <40f8b7d8-fafa-ad99-34fb-9c63e34917e2@redhat.com>
Date: Wed, 24 Jul 2019 15:36:57 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <3b922aa4-c6d4-e4a4-766d-f324ff77f7b5@linux.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/17/19 12:31 PM, Alexander Popov wrote:
> Hello!
> 
> The syzkaller [1] has a trouble with fuzzing the Linux kernel with ION Memory
> Allocator.
> 
> Syzkaller uses several methods [2] to limit memory consumption of the userspace
> processes calling the syscalls for testing the kernel:
>   - setrlimit(),
>   - cgroups,
>   - various sysctl.
> But these methods don't work for ION Memory Allocator, so any userspace process
> that has access to /dev/ion can bring the system to the out-of-memory state.
> 
> An example of a program doing that:
> 
> 
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <linux/types.h>
> #include <sys/ioctl.h>
> 
> #define ION_IOC_MAGIC		'I'
> #define ION_IOC_ALLOC		_IOWR(ION_IOC_MAGIC, 0, \
> 				      struct ion_allocation_data)
> 
> struct ion_allocation_data {
> 	__u64 len;
> 	__u32 heap_id_mask;
> 	__u32 flags;
> 	__u32 fd;
> 	__u32 unused;
> };
> 
> int main(void)
> {
> 	unsigned long i = 0;
> 	int fd = -1;
> 	struct ion_allocation_data data = {
> 		.len = 0x13f65d8c,
> 		.heap_id_mask = 1,
> 		.flags = 0,
> 		.fd = -1,
> 		.unused = 0
> 	};
> 
> 	fd = open("/dev/ion", 0);
> 	if (fd == -1) {
> 		perror("[-] open /dev/ion");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		printf("iter %lu\n", i);
> 		ioctl(fd, ION_IOC_ALLOC, &data);
> 		i++;
> 	}
> 
> 	return 0;
> }
> 
> 
> I looked through the code of ion_alloc() and didn't find any limit checks.
> Is it currently possible to limit ION kernel allocations for some process?
> 
> If not, is it a right idea to do that?
> Thanks!
> 

Yes, I do think that's the right approach. We're working on moving Ion
out of staging and this is something I mentioned to John Stultz. I don't
think we've thought too hard about how to do the actual limiting so
suggestions are welcome.

Thanks,
Laura

> Best regards,
> Alexander
> 
> 
> [1]: https://github.com/google/syzkaller
> [2]: https://github.com/google/syzkaller/blob/master/executor/common_linux.h
> 

