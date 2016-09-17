Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A68B6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 08:09:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so30755054wmf.0
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 05:09:12 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id 23si5407519lfr.76.2016.09.17.05.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 05:09:10 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id l131so77685511lfl.2
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 05:09:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160917090941.GB26044@uranus.lan>
References: <33304dd8-8754-689d-11f3-751833b4a288@redhat.com>
 <CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com> <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
 <cone.1474065027.299244.29242.1004@monster.email-scan.com>
 <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
 <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com>
 <1474085296.32273.95.camel@perches.com> <CALYGNiNuF1Ggy=DyYG32HXbnJp3Q0cX9ekQ5w2jR1M9rkKaX9A@mail.gmail.com>
 <20160917090941.GB26044@uranus.lan>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 17 Sep 2016 15:09:09 +0300
Message-ID: <CALYGNiNzdsnzCZXg_-2u1Tv8+RdRFJVXa6iXY+s64=+LHr2TSA@mail.gmail.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Joe Perches <joe@perches.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat, Sep 17, 2016 at 12:09 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Sat, Sep 17, 2016 at 11:33:56AM +0300, Konstantin Khlebnikov wrote:
>> >
>> > do_just_once just isn't a good name for a global
>> > rate limited mechanism that does something very
>> > different than the name.
>> >
>> > Maybe allow_once_per_ratelimit or the like
>> >
>> > There could be an equivalent do_once
>> >
>> > https://lkml.org/lkml/2009/5/22/3
>> >
>>
>> What about this printk_reriodic() and pr_warn_once_per_minute()?
>>
>> It simply remembers next jiffies to print rather than using that
>> complicated ratelimiting engine.
>
> +#define printk_periodic(period, fmt, ...)                      \
> +({                                                             \
> +       static unsigned long __print_next __read_mostly = INITIAL_JIFFIES; \
> +       bool __do_print = time_after_eq(jiffies, __print_next); \
> +                                                               \
> +       if (__do_print) {                                       \
> +               __print_next = jiffies + (period);              \
> +               printk(fmt, ##__VA_ARGS__);                     \
> +       }                                                       \
> +       unlikely(__do_print);                                   \
> +})
>
> Seems I don't understand the bottom unlikely...

This is gcc extrension:  https://gcc.gnu.org/onlinedocs/gcc/Statement-Exprs.html
Here macro works as a function which returns bool

After second though macro should update __print_next if it's too far
if first warning happens too late here will long period of silence
untill next jiffies overlap.

something like

#define printk_periodic(period, fmt, ...)
({
static unsigned long __print_next = INITIAL_JIFFIES;
unsigned long __print_jiffies = jiffies;
bool __do_print = time_after_eq(__print_jiffies, __print_next);

if (__do_print) {
        __print_next = __print_jiffies + (period);
        printk(fmt, ##__VA_ARGS__);
} else if (time_after(__print_next, __print_jiffies + (period))
        __print_next = __print_jiffies + (period);
unlikely(__do_print);
})

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
