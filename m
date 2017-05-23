Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5A0C83292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 18:05:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p74so180675913pfd.11
        for <linux-mm@kvack.org>; Tue, 23 May 2017 15:05:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s132si21647159pgs.174.2017.05.23.15.05.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 15:05:03 -0700 (PDT)
Subject: Re: [Question] Mlocked count will not be decreased
References: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <62ecda34-316d-6d79-cf86-d4b43f08d3dc@I-love.SAKURA.ne.jp>
Date: Wed, 24 May 2017 07:04:53 +0900
MIME-Version: 1.0
In-Reply-To: <a61701d8-3dce-51a2-5eaf-14de84425640@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhongjiang <zhongjiang@huawei.com>, Qiuxishi <qiuxishi@huawei.com>, Yisheng Xie <xieyisheng1@huawei.com>

Kefeng Wang wrote:
> Hi All,
> 
> Mlocked in meminfo will be increasing with an small testcase, and never be released in mainline,
> here is a testcase[1] to reproduce the issue, but the centos7.2/7.3 will not increase.
> 
> Is it normal?

I confirmed your problem also occurs in Linux 4.11 using below testcase.
MemFree is not decreasing while Mlocked is increasing.
Thus, it seems to be statistics accounting bug.

----------
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char ** argv)
{
	int i;
	for (i = 0; i < 128; i++)
		if (fork() == 0) {
			malloc(1048576);
			while (1) {
				mlockall(MCL_CURRENT | MCL_FUTURE);
				munlockall();
			}
		}
	return 0;
}
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
