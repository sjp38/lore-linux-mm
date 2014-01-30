Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id AABC26B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 02:46:47 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id b8so2248422lan.19
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 23:46:46 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id m9si2424838lae.150.2014.01.29.23.46.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 23:46:45 -0800 (PST)
Message-ID: <52EA0362.8010803@parallels.com>
Date: Thu, 30 Jan 2014 11:46:42 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] Pipe + splice problems
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Hi,

While working on the checkpoint-restore project and looking at
what other Parallels people do with FUSE, I have met several
drawbacks of pipes. I admit, that most of them are well known for
years, but would like to summarize them and refresh the topic.

So the major problems are

* Pipe as page buffer lacks the random access feature

  In FUSE-based FS-es like CEPH or Gluster with complex internal
  data flows it's common case when data arrive in pipe, but FS
  is willing to forward the pages from pipe tail into one descriptor
  while keeping those from head in memory waiting for unblocked
  another. Pipes do not allow this.

* Pipe's locking is one big mutex

  For pipes with more than one page in buffers this results in
  readers-vs-writers contention and, subsequently, pipe works
  slower than a UNIX socket

* The pipe->mem vmsplice always copies data

  There are cases in C/R when we have pages in pipes that cane
  be mapped in tasks' address spaces, but vmslice doesn't allow
  for that.

* No pipe -> AIO splicing

  The pipe -> FS always goes through page cache, while AIO is
  more preferable in some scenarios

* No fallocate analogue for pipe

  People report many calls to __alloc_page in profiling logs when 
  heavily working with pipes


And a couple of minor issues

* Pipe requires 2 FDs to work with

  With this using pipe as generic page-buffer is difficult due to
  nr_files limitation.

* No sendpage for UNIX sockets results in pipe->unix data copy


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
