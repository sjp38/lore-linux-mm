Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B4C3E6B0253
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 05:36:40 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 65so173328933pff.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 02:36:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ko6si7012103pab.2.2016.01.19.02.36.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jan 2016 02:36:39 -0800 (PST)
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id u0JAacKx072785
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:36:38 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (softbank126072091035.bbtec.net [126.72.91.35])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id u0JAabWX072781
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:36:37 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Mlocked pages statistics shows bogus value.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201601191936.HAI26031.HOtJQLOMFFFVOS@I-love.SAKURA.ne.jp>
Date: Tue, 19 Jan 2016 19:36:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

While reading OOM report from Jan Stancek, I noticed that
NR_MLOCK statistics shows bogus values.


Steps to reproduce:

(1) Check Mlocked: field of /proc/meminfo or mlocked: field of SysRq-m.

(2) Compile and run below program with appropriate size as argument.
    There is no need to invoke the OOM killer.

----------
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
	unsigned long length = atoi(argv[1]);
	void *addr = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
	if (addr == MAP_FAILED)
		printf("mmap() failed\n");
	else if (mlock(addr, length) == -1)
		printf("mlock() failed\n");
	else
		printf("MLocked %lu bytes\n", length);
	return 0;
}
----------

(3) Check Mlocked: field or mlocked: field again.
    You can see the value became very large due to
    NR_MLOCK counter going negative.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
