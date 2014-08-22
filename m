Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 31F5A6B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 11:02:47 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so16130049pde.24
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 08:02:46 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id gy1si41133393pbd.29.2014.08.22.08.02.43
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 08:02:43 -0700 (PDT)
Message-ID: <53F75B91.2040100@sr71.net>
Date: Fri, 22 Aug 2014 08:02:41 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] [v3] warn on performance-impacting configs aka. TAINT_PERFORMANCE
References: <20140821202424.7ED66A50@viggo.jf.intel.com> <20140822072023.GA7218@gmail.com>
In-Reply-To: <20140822072023.GA7218@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 08/22/2014 12:20 AM, Ingo Molnar wrote:
> Essentially all DEBUG_OBJECTS_* options are expensive, assuming 
> they are enabled, i.e. DEBUG_OBJECTS_ENABLE_DEFAULT=y.
> 
> Otherwise they should only be warned about if the debugobjects 
> boot option got enabled.
> 
> I.e. you'll need a bit of a runtime check for this one.

At that point, what do we print, and when do we print it?  We're not
saying that the config option should be disabled because it's really the
boot option plus the config option that is causing the problem.

I'll just put the DEBUG_OBJECTS_ENABLE_DEFAULT in here which is
analogous to what we're doing with SLUB_DEBUG_ON.

>> +static ssize_t performance_taint_read(struct file *file, char __user *user_buf,
>> +			size_t count, loff_t *ppos)
>> +{
>> +	int i;
>> +	int ret;
>> +	char *buf;
>> +	size_t buf_written = 0;
>> +	size_t buf_left;
>> +	size_t buf_len;
>> +
>> +	if (!ARRAY_SIZE(perfomance_killing_configs))
>> +		return 0;
>> +
>> +	buf_len = 1;
>> +	for (i = 0; i < ARRAY_SIZE(perfomance_killing_configs); i++)
>> +		buf_len += strlen(config_prefix) +
>> +			   strlen(perfomance_killing_configs[i]);
>> +	/* Add a byte for for each entry in the array for a \n */
>> +	buf_len += ARRAY_SIZE(perfomance_killing_configs);
>> +
>> +	buf = kmalloc(buf_len, GFP_KERNEL);
>> +	if (!buf)
>> +		return -ENOMEM;
>> +
>> +	buf_left = buf_len;
>> +	for (i = 0; i < ARRAY_SIZE(perfomance_killing_configs); i++) {
>> +		buf_written += snprintf(buf + buf_written, buf_left,
>> +					"%s%s\n", config_prefix,
>> +					perfomance_killing_configs[i]);
>> +		buf_left = buf_len - buf_written;
> 
> So, ARRAY_SIZE(performance_killing_configs) is written out four 
> times, a temporary variable would be in order I suspect.

If one of them had gone over 80 chars, I probably would have. :)  I put
one in anyway.

> Also, do you want to check buf_left and break out early from 
> the loop if it goes non-positive?

You're slowly inflating my patch for no practical gain. :)

Oh well, I put that in too.

I think I got the rest of the things addressed too.  v4 coming soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
