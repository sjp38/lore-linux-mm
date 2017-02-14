Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAC896B03A6
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 10:41:31 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 11so136117186qkl.4
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 07:41:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si674661qtz.93.2017.02.14.07.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 07:41:31 -0800 (PST)
From: Jan Stancek <jstancek@redhat.com>
Subject: Is MADV_HWPOISON supposed to work only on faulted-in pages?
Message-ID: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
Date: Tue, 14 Feb 2017 16:41:29 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ltp@lists.linux.it

Hi,

code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
unless I touch/prefault page before call to madvise().

Is this expected behavior?

Thanks,
Jan

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/madvise/madvise07.c

-------------------- 8< --------------------
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>

int main(void)
{
	void *mem = mmap(NULL, getpagesize(), PROT_READ | PROT_WRITE,
			MAP_ANONYMOUS | MAP_PRIVATE /*| MAP_POPULATE*/,
			-1, 0);

	if (mem == MAP_FAILED)
		exit(1);

	if (madvise(mem, getpagesize(), MADV_HWPOISON) == -1)
		exit(1);

	*((char *)mem) = 'd';

	return 0;
}
-------------------- 8< --------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
