Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4163F6B0036
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 16:41:03 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so19009032pdj.36
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 13:41:02 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id fn2si12306792pbc.168.2014.08.24.13.41.00
        for <linux-mm@kvack.org>;
        Sun, 24 Aug 2014 13:41:01 -0700 (PDT)
Message-ID: <53FA4DDA.8020106@sr71.net>
Date: Sun, 24 Aug 2014 13:40:58 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka. TAINT_PERFORMANCE
References: <20140821202424.7ED66A50@viggo.jf.intel.com> <20140822072023.GA7218@gmail.com> <53F75B91.2040100@sr71.net> <20140824144946.GC9455@gmail.com>
In-Reply-To: <20140824144946.GC9455@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 08/24/2014 07:49 AM, Ingo Molnar wrote:
>>>> > >> +	buf_left = buf_len;
>>>> > >> +	for (i = 0; i < ARRAY_SIZE(perfomance_killing_configs); i++) {
>>>> > >> +		buf_written += snprintf(buf + buf_written, buf_left,
>>>> > >> +					"%s%s\n", config_prefix,
>>>> > >> +					perfomance_killing_configs[i]);
>>>> > >> +		buf_left = buf_len - buf_written;
...
>>> > > Also, do you want to check buf_left and break out early from 
>>> > > the loop if it goes non-positive?
>> > 
>> > You're slowly inflating my patch for no practical gain. :)
> AFAICS it's a potential memory corruption and security bug, 
> should the array ever grow large enough to overflow the passed
> in buffer size.

Let's say there is 1 "buf_left" and I attempt a 100-byte snprintf().
Won't snprintf() return 1, and buf_written will then equal buf_len?
buf_left=0 at that point, and will get passed in to the next snprintf()
as the buffer length.  I'm expecting snprintf() to just return 0 when it
gets a 0 for its 'size'.

Exhausting the buffer will, at worst, mean a bunch of useless calls to
snprintf() that do nothing, but I don't think it will run over the end
of the buffer.

Or am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
