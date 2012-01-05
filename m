Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 1C04C6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 08:17:59 -0500 (EST)
Received: by eekc41 with SMTP id c41so410504eek.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 05:17:57 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH v5 1/8] smp: Introduce a generic on_each_cpu_mask function
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-2-git-send-email-gilad@benyossef.com>
 <20120103142624.faf46d77.akpm@linux-foundation.org>
Date: Thu, 05 Jan 2012 14:17:54 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v7l4j4ms3l0zgt@mpn-glaptop>
In-Reply-To: <20120103142624.faf46d77.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Tue, 03 Jan 2012 23:26:24 +0100, Andrew Morton <akpm@linux-foundation=
.org> wrote:

> On Mon,  2 Jan 2012 12:24:12 +0200
> Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>
>> on_each_cpu_mask calls a function on processors specified my cpumask,=

>> which may include the local processor.

>> @@ -132,6 +139,15 @@ static inline int up_smp_call_function(smp_call_=
func_t func, void *info)
>>  		local_irq_enable();		\
>>  		0;				\
>>  	})
>> +#define on_each_cpu_mask(mask, func, info, wait) \
>> +	do {						\
>> +		if (cpumask_test_cpu(0, (mask))) {	\
>> +			local_irq_disable();		\
>> +			(func)(info);			\
>> +			local_irq_enable();		\
>> +		}					\
>> +	} while (0)
>
> Why is the cpumask_test_cpu() call there?  It's hard to think of a
> reason why "mask" would specify any CPU other than "0" in a
> uniprocessor kernel.

It may specify none.  For instance, in drain_all_pages() case, if the
CPU has no pages on PCP lists, the mask will be empty and so the
cpumask_test_cpu() will return zero.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
