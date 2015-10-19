Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id A0D8A6B0255
	for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:51:53 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so77316528wic.0
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 20:51:53 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id qt4si8323619wic.99.2015.10.18.20.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 20:51:52 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so79447094wic.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 20:51:52 -0700 (PDT)
Message-ID: <1445226710.15861.28.camel@gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Mike Galbraith <umgwanakikbuti@gmail.com>
Date: Mon, 19 Oct 2015 05:51:50 +0200
In-Reply-To: <20151014202448.GE12799@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
	 <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	 <20151014165729.GA12799@mtj.duckdns.org>
	 <CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
	 <20151014190259.GC12799@mtj.duckdns.org>
	 <CA+55aFz27G4gLS9AFs6hHJfULXAqA=tM5KA=YvBH8MaZ+sT-VA@mail.gmail.com>
	 <20151014193829.GD12799@mtj.duckdns.org>
	 <CA+55aFyzsMYcRX3V5CEWB4Zb-9BuRGCjib3DMXuX5y9nBWiZ1w@mail.gmail.com>
	 <20151014202448.GE12799@mtj.duckdns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, 2015-10-14 at 16:24 -0400, Tejun Heo wrote:

> But in terms of API consistency, it sucks to have queue_work()
> guarantee local queueing but not queue_delayed_work().  The ideal
> situation would be updating both so that neither guarantees.

You don't have to change anything to have neither guarantee local
queueing.  Called from a preemptible context, local means any CPU in
->cpus_allowed... which makes WORK_CPU_UNBOUND mean what one would
imagine WORK_CPU_UNBOUND to mean, not bound to any particular cpu.

      sh-16017   3.N.. 1510500545us : queue_work_on: golly, migrated cpu7 -> cpu3 -- target cpu8
      sh-16017   3.N.. 1510500550us : <stack trace>
 => tty_flip_buffer_push
 => pty_write
 => n_tty_write
 => tty_write
 => __vfs_write
 => vfs_write
 => SyS_write
 => entry_SYSCALL_64_fastpath

That was with a udelay(100) prior to disabling interrupts, but that just
makes it easier.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
