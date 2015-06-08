Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 38E4B6B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 15:41:50 -0400 (EDT)
Received: by igbzc4 with SMTP id zc4so70103226igb.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:41:50 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id m132si2794840iom.63.2015.06.08.12.41.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 12:41:49 -0700 (PDT)
Received: by igbsb11 with SMTP id sb11so456547igb.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 12:41:49 -0700 (PDT)
Date: Mon, 8 Jun 2015 12:41:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: split out forced OOM killer
In-Reply-To: <5575E5E6.20908@gmail.com>
Message-ID: <alpine.DEB.2.10.1506081237350.13272@chino.kir.corp.google.com>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com> <557187F9.8020301@gmail.com> <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com> <5575E5E6.20908@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 8 Jun 2015, Austin S Hemmelgarn wrote:

> I believe so (haven't actually read the patch itself, just the changelog),
> although it is only a change for certain configurations to a very specific and
> (I hope infrequently) used piece of functionality. Like I said above, if I
> wanted to crash my system, I'd be using sysrq-c; and if I'm using sysrq-f, I
> want _some_ task to die _now_.
> 

This patch is not a functional change, so I don't interpret your feedback 
as any support of it being merged.

That said, you raise an interesting point of whether sysrq+f should ever 
trigger a panic due to panic_on_oom.  The case can be made that it should 
ignore panic_on_oom and require the use of another sysrq to panic the 
machine instead.  Sysrq+f could then be used to oom kill a process, 
regardless of panic_on_oom, and the panic only occurs if userspace did not 
trigger the kill or the kill itself will fail.

I think we should pursue that direction.

This patch also changes the text which is output to the kernel log on 
panic, which we use to parse for machines that have crashed due to no 
killable memcg processes, so NACK on this patch.  There's also no reason 
to add more source code to try to make things cleaner when it just 
obfuscates the oom killer code more than it needs to (we don't need to 
optimize or have multiple entry points).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
