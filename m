Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 161E96B026D
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:05:16 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b22-v6so788617pfc.18
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 06:05:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p6-v6si1253252pgd.312.2018.10.23.06.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 06:05:14 -0700 (PDT)
Received: from fsav105.sakura.ne.jp (fsav105.sakura.ne.jp [27.133.134.232])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id w9ND5CYI068418
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 22:05:12 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from [192.168.1.8] (softbank060157065137.bbtec.net [60.157.65.137])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id w9ND5C26068406
	(version=TLSv1.2 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 22:05:12 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: memcg versus clone(CLONE_VM without CLONE_THREAD)
Message-ID: <4a36ab60-ab2b-eb54-f5a8-33f969f00e73@i-love.sakura.ne.jp>
Date: Tue, 23 Oct 2018 22:05:12 +0900
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

I noticed that memcg OOM event does not trigger as expected when a thread
group ID assigned by clone(CLONE_VM without CLONE_THREAD) is specified.
A bit of surprise because what the "tasks" file says is not what the
limitation is applied to...

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>

static int memory_eater(void *unused) {
	FILE *fp;
	const unsigned long size = 1048576 * 200;
	char *buf = malloc(size);
	mkdir("/sys/fs/cgroup/memory/test1", 0755);
	fp = fopen("/sys/fs/cgroup/memory/test1/memory.limit_in_bytes", "w");
	fprintf(fp, "%lu\n", size / 2);
	fclose(fp);
	fp = fopen("/sys/fs/cgroup/memory/test1/tasks", "w");
	fprintf(fp, "%u\n", getpid());
	fclose(fp);
	fp = fopen("/dev/zero", "r");
	fread(buf, 1, size, fp);
	fclose(fp);
	return 0;
}

int main(int argc, char *argv[])
{
	if (clone(memory_eater, malloc(8192) + 8192,
		  /*CLONE_SIGHAND | CLONE_THREAD | */CLONE_VM, NULL) == -1)
		return 1;
	while (1)
		pause();
	return 0;
}
----------
