Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 387C16B00A4
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 10:22:16 -0500 (EST)
Message-ID: <49491978.20609@cs.columbia.edu>
Date: Wed, 17 Dec 2008 10:23:36 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v11][PATCH 04/13] x86 support for checkpoint/restart
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu> <1228498282-11804-5-git-send-email-orenl@cs.columbia.edu> <494861CA.8000403@google.com>
In-Reply-To: <494861CA.8000403@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



Mike Waychison wrote:
> Oren Laadan wrote:
>> Add logic to save and restore architecture specific state, including
>> thread-specific state, CPU registers and FPU state.
>>
>> In addition, architecture capabilities are saved in an architecure
>> specific extension of the header (cr_hdr_head_arch); Currently this
>> includes only FPU capabilities.
>>
>> Currently only x86-32 is supported. Compiling on x86-64 will trigger
>> an explicit error.
>>

[...]

>> +
>> +    hh->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
>> +    hh->sizeof_tls_array = sizeof(thread->tls_array);
>> +    hh->ntls = ntls;
>> +
>> +    ret = cr_write_obj(ctx, &h, hh);
>> +    cr_hbuf_put(ctx, sizeof(*hh));
>> +    if (ret < 0)
>> +        return ret;
>> +
>> +    cr_debug("ntls %d\n", ntls);
>> +    if (ntls == 0)
>> +        return 0;
>> +
>> +    /* for simplicity dump the entire array, cherry-pick upon restart */
>> +    ret = cr_kwrite(ctx, thread->tls_array, sizeof(thread->tls_array));
> 
> Again, the the TLS descriptors in the GDT should be called out an not
> tied to the in-kernel representation.

True. I'll add a 'FIXME' comment.

However, I'm yet to see a case where this breaks among x86_32, and I'm no
expert in that area to tell whether it could. (Moving from x86_32 to x86_64
is another story, and will require some compatibility layer anyway).

> 
>> +
>> +    /* IGNORE RESTART BLOCKS FOR NOW ... */

[...]

>> +static int cr_write_cpu_fpu(struct cr_ctx *ctx, struct task_struct *t)
>> +{
>> +    void *xstate_buf = cr_hbuf_get(ctx, xstate_size);
>> +
>> +    /* i387 + MMU + SSE logic */
>> +    preempt_disable();    /* needed it (t == current) */
>> +
>> +    /*
>> +     * normally, no need to unlazy_fpu(), since TS_USEDFPU flag
>> +     * have been cleared when task was context-switched out...
>> +     * except if we are in process context, in which case we do
>> +     */
>> +    if (t == current && (task_thread_info(t)->status & TS_USEDFPU))
>> +        unlazy_fpu(current);
>> +
>> +    memcpy(xstate_buf, t->thread.xstate, xstate_size);
> 
> This is probably better off being very deliberate about what registers
> we are dumping from a traceability and compatibility point of view?

Same here.

> 
>> +    preempt_enable();    /* needed it (t == current) */
>> +
>> +    return cr_kwrite(ctx, xstate_buf, xstate_size);
> 
> Missed cr_huf_put()

Ooops ... will fix.

> 
>> +}
>> +
>> +#endif    /* CONFIG_X86_64 */

[...]

>> +        /*
>> +         * restore TLS by hand: why convert to struct user_desc if
>> +         * sys_set_thread_entry() will convert it back ?
>> +         */
>> +
>> +        size = sizeof(*desc) * GDT_ENTRY_TLS_ENTRIES;
>> +        desc = kmalloc(size, GFP_KERNEL);
>> +        if (!desc)
> 
> cr_hbuf_put() here.

Will fix.

> 
>> +            return -ENOMEM;
>> +
>> +        ret = cr_kread(ctx, desc, size);
>> +        if (ret >= 0) {
> 
> if (ret == 0)

Right.

> 
>> +            /*
>> +             * FIX: add sanity checks (eg. that values makes
>> +             * sense, that we don't overwrite old values, etc
>> +             */
>> +            cpu = get_cpu();
>> +            memcpy(thread->tls_array, desc, size);
>> +            load_TLS(thread, cpu);
>> +            put_cpu();
>> +        }
>> +        kfree(desc);
>> +    }
>> +
>> +    ret = 0;
>> + out:
>> +    cr_hbuf_put(ctx, sizeof(*hh));
>> +    return ret;
>> +}

[...]

Thanks for the review !

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
