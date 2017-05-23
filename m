Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5347D6B02C3
	for <linux-mm@kvack.org>; Tue, 23 May 2017 10:42:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e131so166449915pfh.7
        for <linux-mm@kvack.org>; Tue, 23 May 2017 07:42:28 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id 3si21513546plu.329.2017.05.23.07.42.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 07:42:27 -0700 (PDT)
From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [Question] Mlocked count will not be decreased
Message-ID: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
Date: Tue, 23 May 2017 22:41:34 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>, Qiuxishi <qiuxishi@huawei.com>, Yisheng Xie <xieyisheng1@huawei.com>, wangkefeng.wang@huawei.com

Hi All,

Mlocked in meminfo will be increasing with an small testcase, and never be released in mainline,
here is a testcase[1] to reproduce the issue, but the centos7.2/7.3 will not increase.

Is it normal?

Thanks,
Kefeng




[1] testcase
linux:~ # cat test_mlockall.sh
grep Mlocked /proc/meminfo
 for j in `seq 0 10`
 do
	for i in `seq 4 15`
	do
		./p_mlockall >> log &
	done
	sleep 0.2
done
grep Mlocked /proc/meminfo


linux:~ # cat p_mlockall.c
#include <sys/mman.h>
#include <stdlib.h>
#include <stdio.h>

#define SPACE_LEN	4096

int main(int argc, char ** argv)
{
	int ret;
	void *adr = malloc(SPACE_LEN);
	if (!adr)
		return -1;
	
	ret = mlockall(MCL_CURRENT | MCL_FUTURE);
	printf("mlcokall ret = %d\n", ret);

	ret = munlockall();
	printf("munlcokall ret = %d\n", ret);

	free(adr);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
