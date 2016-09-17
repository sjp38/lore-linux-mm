Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF6DE6B0069
	for <linux-mm@kvack.org>; Sat, 17 Sep 2016 17:52:34 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u18so162327316ita.2
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 14:52:34 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0042.hostedemail.com. [216.40.44.42])
        by mx.google.com with ESMTPS id d95si20242678ioj.42.2016.09.17.14.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Sep 2016 14:52:34 -0700 (PDT)
Message-ID: <1474149151.1954.4.camel@perches.com>
Subject: Re: [REGRESSION] RLIMIT_DATA crashes named
From: Joe Perches <joe@perches.com>
Date: Sat, 17 Sep 2016 14:52:31 -0700
In-Reply-To: <CALYGNiN-ELbwSV0X2_FeKvGSOfRuHMsBnBDj86NHZxQKnZgVsQ@mail.gmail.com>
References: 
	<CA+55aFyfny-0F=VKKe6BCm-=fX5b08o1jPjrxTBOatiTzGdBVg@mail.gmail.com>
	 <d4e15f7b-fedd-e8ff-539f-61d441b402cd@redhat.com>
	 <CA+55aFzWts-dgNRuqfwHu4VeN-YcRqkZdMiRpRQ=Pg91sWJ=VQ@mail.gmail.com>
	 <cone.1474065027.299244.29242.1004@monster.email-scan.com>
	 <CA+55aFwPNBQePQCQ7qRmvn-nVaEn2YVsXnBFc5y1UVWExifBHw@mail.gmail.com>
	 <CA+55aFy-mMfj3qj6=WMawEUGEkwnFEqB_=S6Pxx3P_c58uHW2w@mail.gmail.com>
	 <1474085296.32273.95.camel@perches.com>
	 <CALYGNiNuF1Ggy=DyYG32HXbnJp3Q0cX9ekQ5w2jR1M9rkKaX9A@mail.gmail.com>
	 <20160917090941.GB26044@uranus.lan>
	 <CALYGNiNzdsnzCZXg_-2u1Tv8+RdRFJVXa6iXY+s64=+LHr2TSA@mail.gmail.com>
	 <20160917122021.GC26044@uranus.lan>
	 <CALYGNiN-ELbwSV0X2_FeKvGSOfRuHMsBnBDj86NHZxQKnZgVsQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sam Varshavchik <mrsam@courier-mta.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@redhat.com>, Brent <fix@bitrealm.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sun, 2016-09-18 at 00:40 +0300, Konstantin Khlebnikov wrote:
> #define printk_periodic(period, fmt, ...)
> ({
>         static unsigned long __prev __read_mostly = INITIAL_JIFFIES - (period);
>         unsigned long __now = jiffies;
>         bool __print = !time_in_range_open(__now, __prev, __prev + (period));
> 
>         if (__print) {
>                 __prev = __now;
>                 printk(fmt, ##__VA_ARGS__);
>         }
>         unlikely(__print);
> })

printk_periodic reads like a thing that would create a
thread to printk a message every period.

And trivially, period should be copied to a temporary
and not be reused (use your choice of # of underscores)

	unsigned long _period = period;
	unsigned long _now = now;
	static unsigned long _prev __read_mostly = etc...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
