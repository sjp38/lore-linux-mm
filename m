Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id BAEED6B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 07:21:04 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id b14so168085531wmb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 04:21:04 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id j9si45850761wjs.75.2016.01.19.04.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 04:21:03 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id r129so87788046wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 04:21:03 -0800 (PST)
Date: Tue, 19 Jan 2016 14:21:01 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Mlocked pages statistics shows bogus value.
Message-ID: <20160119122101.GA20260@node.shutemov.name>
References: <201601191936.HAI26031.HOtJQLOMFFFVOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601191936.HAI26031.HOtJQLOMFFFVOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Tue, Jan 19, 2016 at 07:36:37PM +0900, Tetsuo Handa wrote:
> While reading OOM report from Jan Stancek, I noticed that
> NR_MLOCK statistics shows bogus values.
> 
> 
> Steps to reproduce:
> 
> (1) Check Mlocked: field of /proc/meminfo or mlocked: field of SysRq-m.
> 
> (2) Compile and run below program with appropriate size as argument.
>     There is no need to invoke the OOM killer.
> 
> ----------
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/mman.h>
> 
> int main(int argc, char *argv[])
> {
> 	unsigned long length = atoi(argv[1]);
> 	void *addr = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
> 	if (addr == MAP_FAILED)
> 		printf("mmap() failed\n");
> 	else if (mlock(addr, length) == -1)
> 		printf("mlock() failed\n");
> 	else
> 		printf("MLocked %lu bytes\n", length);
> 	return 0;
> }
> ----------
> 
> (3) Check Mlocked: field or mlocked: field again.
>     You can see the value became very large due to
>     NR_MLOCK counter going negative.

Oh. Looks like a bug from 2013...

Thanks for report.
