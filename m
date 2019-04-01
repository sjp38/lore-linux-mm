Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A499FC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 17:32:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C67A21473
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 17:32:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="FFlBLXN1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C67A21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983E96B0006; Mon,  1 Apr 2019 13:32:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92E846B0008; Mon,  1 Apr 2019 13:32:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D10F6B000A; Mon,  1 Apr 2019 13:32:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 521336B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 13:32:07 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id z130so3418208ywb.14
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 10:32:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iUCgqqeBDBtU+OdBinvCxjIFMvP27vDN5dESCqfsGZ0=;
        b=bsymgeA79Yo1jgYw+d7VZDdN741V4PKKenu3iMJqkTzujK0i75MriYGZtSwwbuVcv4
         /b3s49lP6Mlb6tMuT1WPf+7sihOR+UIzVwpDGUyp+jmSG7vA5P2ydqw7Y0uGrAaQ0s+z
         vHhz+R9nZ/vNcpbNs86cjjpHF2F7IgIlE40MmINJZpMSFbmvGCyTXuLL6YINr2OP5fPb
         nryCa5csNiLj5S1GqaX7z9mJvFQ9NYYy7qHyCH3rT2PTX+Aoycv7H1VFUrlP4/hg90vd
         PjzfQdWtk9pPaJSPx+9wOM+gegXLORhUuO1JMGazMEXHCOClOivWnPhy0nvXbs4iyZsh
         ISYQ==
X-Gm-Message-State: APjAAAUfSFdO4HcFkxLbkUo6pb+So3M0ZSNRG1eW/jkU+H94JArOtru+
	H5i79boHxCHzU6mQec8+PcJusIXgf/jyd8jGIFdakM1XkTbUQH42k7u3pUyD/OdhQdN9/ID0eSA
	FXXgwmcTXrQ13GOknNbsa43QNOS+VDhT5qzdP4QdjNPKjTPfk+WYYho1Pv5SC1uaN8Q==
X-Received: by 2002:a81:1390:: with SMTP id 138mr10322888ywt.230.1554139926880;
        Mon, 01 Apr 2019 10:32:06 -0700 (PDT)
X-Received: by 2002:a81:1390:: with SMTP id 138mr10322791ywt.230.1554139925843;
        Mon, 01 Apr 2019 10:32:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554139925; cv=none;
        d=google.com; s=arc-20160816;
        b=UdHnLBZvXFmonyt/s511HLpWUnUBlh8/PHCR9/URm5iaI3MyE73+gmVAEgrFn8+wyq
         xhmI0aVFIJdjxRIet/78vrsaNWd1A20nSf05ISFpX3kLxeHAgExjHz9c1TYhDXdm2RXz
         WgAkCdKE6yCP+aMRvmy35hCE1rVg8CfAOPDZiqjNJsquedpwbQadQGumaUfrEFduhk62
         Ovkc9zB1xJ5R4vDr/kaMVrFfVu34vwbblOtnEHe7erLSdUpq2dMLU9TjiMlFrQj7eqJ/
         eI57QEH3q45nK7FG1xUuPVAOzUPfHHoxWh8l7Ssj80UoSdwZNwJ1LVGu/pYxcYeNMqM7
         C8tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iUCgqqeBDBtU+OdBinvCxjIFMvP27vDN5dESCqfsGZ0=;
        b=mXodoRZp+6HNpaqmI2GWt/CMLNM69IQrXZ++pWUi4z8oJ31DcSYgbzn/+ZLzmwwP2n
         EunRvxYjFZ0veMUWtQrER8P1h247N0JUn6eAIkJfF1Z1xQ6lAkEVCgZhqXJeIBN5qB0e
         n7QY0yPTQAJDe7YqclD21KEqkmS3325+oHNGXJORf9JPPtotB1o2mkxdfW0HOPGyAiJx
         NT+lvw/jMR2stbYmIO+DsuW22XACkyML7do2QELRLnmpOA8JCzVAMNe5hZKGF7tmEWCO
         okImlnlGhIEHN6fCrFQsmjgDxNX/z11dpcB338j5A1Oidn+U1Jxt8Lb9sOBsFJvjTSYc
         f6qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FFlBLXN1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u22sor3953785ywu.213.2019.04.01.10.32.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 10:32:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=FFlBLXN1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iUCgqqeBDBtU+OdBinvCxjIFMvP27vDN5dESCqfsGZ0=;
        b=FFlBLXN1ReTLIcakm+zexDtxxsRyk97wv0ScT9Q+ZhPL4lD0FOHYTSFDiHuowsCUJO
         Vnf4Q7dI4Q8THWgl6vJCjLVh9q/O87xrFkvolqIFCQJU4dwy1F6RGq+OzvgUmUJZwweX
         OZls2jItEjwVLVeByyysEr7OrwE/Y1CON/Gp4tIYB7FiBSJV0RxzwnLLfn9570AhCNAH
         aKzBcfIFeA5wtegQnWiR+ekW61L6HoZ29m+u9DLbOy/zbDQL3ZBqQ4ihTzSkXfmBka9/
         JLLe9vjql2wU8Ac5PnwLj4Hg0M3KA9a/IcVv5OKANZv9WK0gq9i1YItVY4BPCnx73CIH
         n2Og==
X-Google-Smtp-Source: APXvYqxlSH4orwXxHoNbWQR2M5WR8DFrGzupoUG+2WS96YMss4VGMIj+HKcg5xHKhXP0yfg1PuwIHw==
X-Received: by 2002:a81:a101:: with SMTP id y1mr44792235ywg.43.1554139924995;
        Mon, 01 Apr 2019 10:32:04 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:8ed4])
        by smtp.gmail.com with ESMTPSA id m133sm5041831ywm.55.2019.04.01.10.32.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 10:32:03 -0700 (PDT)
Date: Mon, 1 Apr 2019 13:32:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Tejun Heo <tj@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH v2] writeback: use exact memcg dirty counts
Message-ID: <20190401173202.GA2953@cmpxchg.org>
References: <20190329174609.164344-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329174609.164344-1-gthelen@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 10:46:09AM -0700, Greg Thelen wrote:
> Since commit a983b5ebee57 ("mm: memcontrol: fix excessive complexity in
> memory.stat reporting") memcg dirty and writeback counters are managed
> as:
> 1) per-memcg per-cpu values in range of [-32..32]
> 2) per-memcg atomic counter
> When a per-cpu counter cannot fit in [-32..32] it's flushed to the
> atomic.  Stat readers only check the atomic.
> Thus readers such as balance_dirty_pages() may see a nontrivial error
> margin: 32 pages per cpu.
> Assuming 100 cpus:
>    4k x86 page_size:  13 MiB error per memcg
>   64k ppc page_size: 200 MiB error per memcg
> Considering that dirty+writeback are used together for some decisions
> the errors double.
> 
> This inaccuracy can lead to undeserved oom kills.  One nasty case is
> when all per-cpu counters hold positive values offsetting an atomic
> negative value (i.e. per_cpu[*]=32, atomic=n_cpu*-32).
> balance_dirty_pages() only consults the atomic and does not consider
> throttling the next n_cpu*32 dirty pages.  If the file_lru is in the
> 13..200 MiB range then there's absolutely no dirty throttling, which
> burdens vmscan with only dirty+writeback pages thus resorting to oom
> kill.
> 
> It could be argued that tiny containers are not supported, but it's more
> subtle.  It's the amount the space available for file lru that matters.
> If a container has memory.max-200MiB of non reclaimable memory, then it
> will also suffer such oom kills on a 100 cpu machine.
> 
> The following test reliably ooms without this patch.  This patch avoids
> oom kills.
> 
>   $ cat test
>   mount -t cgroup2 none /dev/cgroup
>   cd /dev/cgroup
>   echo +io +memory > cgroup.subtree_control
>   mkdir test
>   cd test
>   echo 10M > memory.max
>   (echo $BASHPID > cgroup.procs && exec /memcg-writeback-stress /foo)
>   (echo $BASHPID > cgroup.procs && exec dd if=/dev/zero of=/foo bs=2M count=100)
> 
>   $ cat memcg-writeback-stress.c
>   /*
>    * Dirty pages from all but one cpu.
>    * Clean pages from the non dirtying cpu.
>    * This is to stress per cpu counter imbalance.
>    * On a 100 cpu machine:
>    * - per memcg per cpu dirty count is 32 pages for each of 99 cpus
>    * - per memcg atomic is -99*32 pages
>    * - thus the complete dirty limit: sum of all counters 0
>    * - balance_dirty_pages() only sees atomic count -99*32 pages, which
>    *   it max()s to 0.
>    * - So a workload can dirty -99*32 pages before balance_dirty_pages()
>    *   cares.
>    */
>   #define _GNU_SOURCE
>   #include <err.h>
>   #include <fcntl.h>
>   #include <sched.h>
>   #include <stdlib.h>
>   #include <stdio.h>
>   #include <sys/stat.h>
>   #include <sys/sysinfo.h>
>   #include <sys/types.h>
>   #include <unistd.h>
> 
>   static char *buf;
>   static int bufSize;
> 
>   static void set_affinity(int cpu)
>   {
>   	cpu_set_t affinity;
> 
>   	CPU_ZERO(&affinity);
>   	CPU_SET(cpu, &affinity);
>   	if (sched_setaffinity(0, sizeof(affinity), &affinity))
>   		err(1, "sched_setaffinity");
>   }
> 
>   static void dirty_on(int output_fd, int cpu)
>   {
>   	int i, wrote;
> 
>   	set_affinity(cpu);
>   	for (i = 0; i < 32; i++) {
>   		for (wrote = 0; wrote < bufSize; ) {
>   			int ret = write(output_fd, buf+wrote, bufSize-wrote);
>   			if (ret == -1)
>   				err(1, "write");
>   			wrote += ret;
>   		}
>   	}
>   }
> 
>   int main(int argc, char **argv)
>   {
>   	int cpu, flush_cpu = 1, output_fd;
>   	const char *output;
> 
>   	if (argc != 2)
>   		errx(1, "usage: output_file");
> 
>   	output = argv[1];
>   	bufSize = getpagesize();
>   	buf = malloc(getpagesize());
>   	if (buf == NULL)
>   		errx(1, "malloc failed");
> 
>   	output_fd = open(output, O_CREAT|O_RDWR);
>   	if (output_fd == -1)
>   		err(1, "open(%s)", output);
> 
>   	for (cpu = 0; cpu < get_nprocs(); cpu++) {
>   		if (cpu != flush_cpu)
>   			dirty_on(output_fd, cpu);
>   	}
> 
>   	set_affinity(flush_cpu);
>   	if (fsync(output_fd))
>   		err(1, "fsync(%s)", output);
>   	if (close(output_fd))
>   		err(1, "close(%s)", output);
>   	free(buf);
>   }
> 
> Make balance_dirty_pages() and wb_over_bg_thresh() work harder to
> collect exact per memcg counters.  This avoids the aforementioned oom
> kills.
> 
> This does not affect the overhead of memory.stat, which still reads the
> single atomic counter.
> 
> Why not use percpu_counter?  memcg already handles cpus going offline,
> so no need for that overhead from percpu_counter.  And the
> percpu_counter spinlocks are more heavyweight than is required.
> 
> It probably also makes sense to use exact dirty and writeback counters
> in memcg oom reports.  But that is saved for later.
> 
> Cc: stable@vger.kernel.org # v4.16+
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks Greg!

