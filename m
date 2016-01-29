Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 059D96B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:33:29 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id 128so48907615wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 03:33:28 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id g67si10484769wmi.14.2016.01.29.03.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 03:33:28 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id 128so48907219wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 03:33:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160128095349.6f771f14@gandalf.local.home>
References: <cover.1453918525.git.glider@google.com>
	<99939a92dd93dc5856c4ec7bf32dbe0035cdc689.1453918525.git.glider@google.com>
	<20160128095349.6f771f14@gandalf.local.home>
Date: Fri, 29 Jan 2016 12:33:27 +0100
Message-ID: <CAG_fn=Ujxs6bv7ovPuOEtwRQGVSe-c3N3pGvWPHA_4oF3zqbFA@mail.gmail.com>
Subject: Re: [PATCH v1 4/8] arch, ftrace: For KASAN put hard/soft IRQ entries
 into separate sections
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Agreed. Once I receive more comments I will make a new patch set and
include this change as well.

On Thu, Jan 28, 2016 at 3:53 PM, Steven Rostedt <rostedt@goodmis.org> wrote=
:
> On Wed, 27 Jan 2016 19:25:09 +0100
> Alexander Potapenko <glider@google.com> wrote:
>
>> --- a/include/linux/ftrace.h
>> +++ b/include/linux/ftrace.h
>> @@ -762,6 +762,26 @@ struct ftrace_graph_ret {
>>  typedef void (*trace_func_graph_ret_t)(struct ftrace_graph_ret *); /* r=
eturn */
>>  typedef int (*trace_func_graph_ent_t)(struct ftrace_graph_ent *); /* en=
try */
>>
>> +#if defined(CONFIG_FUNCTION_GRAPH_TRACER) || defined(CONFIG_KASAN)
>> +/*
>> + * We want to know which function is an entrypoint of a hardirq.
>> + */
>> +#define __irq_entry           __attribute__((__section__(".irqentry.tex=
t")))
>> +#define __softirq_entry  \
>> +     __attribute__((__section__(".softirqentry.text")))
>> +
>> +/* Limits of hardirq entrypoints */
>> +extern char __irqentry_text_start[];
>> +extern char __irqentry_text_end[];
>> +/* Limits of softirq entrypoints */
>> +extern char __softirqentry_text_start[];
>> +extern char __softirqentry_text_end[];
>> +
>> +#else
>> +#define __irq_entry
>> +#define __softirq_entry
>> +#endif
>> +
>>  #ifdef CONFIG_FUNCTION_GRAPH_TRACER
>>
>>  /* for init task */
>
> Since this is no longer just used for function tracing, perhaps the
> code should be moved to include/linux/irq.h or something.
>
> -- Steve
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
