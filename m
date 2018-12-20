Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF0C8E0004
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 20:16:56 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so114108pfr.6
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 17:16:56 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id i20si16799311pgh.187.2018.12.19.17.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 17:16:55 -0800 (PST)
Subject: Re: [PATCH 1/2] ARC: show_regs: avoid page allocator
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
 <1545239047.14089.13.camel@synopsys.com>
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Message-ID: <49f9edc9-87ee-1efc-58f8-b0d9a52c8a49@synopsys.com>
Date: Wed, 19 Dec 2018 17:16:39 -0800
MIME-Version: 1.0
In-Reply-To: <1545239047.14089.13.camel@synopsys.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>, "vineet.gupta1@synopsys.com" <vineet.gupta1@synopsys.com>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/19/18 9:04 AM, Eugeniy Paltsev wrote:
> As I can see x86 use print_vma_addr() in their show_signal_msg()
> function which allocate page with __get_free_page(GFP_NOWAIT);

Indeed with that the __get_free_page() lockdep splat is gone.

There's a different one now hence my other patch.

| [ARCLinux]# ./segv-null-ptr
| potentially unexpected fatal signal 11.
| BUG: sleeping function called from invalid context at kernel/fork.c:1011
| in_atomic(): 1, irqs_disabled(): 0, pid: 70, name: segv-null-ptr
| no locks held by segv-null-ptr/70.
| CPU: 0 PID: 70 Comm: segv-null-ptr Not tainted 4.18.0+ #69
|
| Stack Trace:
|  arc_unwind_core+0xcc/0x100
|  ___might_sleep+0x17a/0x190
|  mmput+0x16/0xb8
|  show_regs+0x52/0x310
|  get_signal+0x5ee/0x610
|  do_signal+0x2c/0x218
|  resume_user_mode_begin+0x90/0xd8
