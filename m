Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A59F06B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 06:22:47 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id d62so4437290iof.0
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 03:22:47 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a31si2068191itj.25.2018.01.12.03.22.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jan 2018 03:22:46 -0800 (PST)
Subject: Re: [mm 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
	<20180111142148.GD1732@dhcp22.suse.cz>
	<201801120131.w0C1VJUN034283@www262.sakura.ne.jp>
	<CA+55aFx4pH4odYDfuGemm5TK-CS4E8pL_ipHCVzVBmsQkyWp1Q@mail.gmail.com>
In-Reply-To: <CA+55aFx4pH4odYDfuGemm5TK-CS4E8pL_ipHCVzVBmsQkyWp1Q@mail.gmail.com>
Message-Id: <201801122022.IDI35401.VOQOFOMLFSFtHJ@I-love.SAKURA.ne.jp>
Date: Fri, 12 Jan 2018 20:22:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, linux-fsdevel@vger.kernel.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > All of those seem to be file pages. So maybe try to use a different FS.
> 
> Maybe that's the next thing I should try.

xfs versus ext4 => Both triggers the bug

Linus Torvalds wrote:
> On Thu, Jan 11, 2018 at 5:31 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > Thus, I suspect that somewhere is confusing HighMem pages and !HighMem pages.
> 
> Hmm. I can't even imagine how you'd do that.
> 
> Sure, if you take page_address() to get a kmap'ed linear address, and
> then feed that linear address back to virt_to_page(), you'd certainly
> get a crazy page. But that would be insane.. I don't see how you'd do
> that.
> 
> Hmm. Do you have CONFIG_DEBUG_VIRTUAL enabled? That should catch at
> least the above case, it should enable a debugging version of
> __virt_to_phys() and use it.
> 

CONFIG_DEBUG_VIRTUAL=y versus CONFIG_DEBUG_VIRTUAL=n => No difference

No mem= parameter versus mem=768M => Cannot trigger if mem=768M (i.e. not using HighMem)

CONFIG_SLUB=y versus CONFIG_SLAB=y => Both triggers the bug

CONFIG_DEBUG_PAGEALLOC=y versus CONFIG_DEBUG_PAGEALLOC=n => Cannot trigger if CONFIG_DEBUG_PAGEALLOC=n

I don't know whether there is a bug in CONFIG_DEBUG_PAGEALLOC=y code.
Config is at http://I-love.SAKURA.ne.jp/tmp/config-4.15-rc7-min .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
