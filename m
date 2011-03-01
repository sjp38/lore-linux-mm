Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F32FF8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 16:47:42 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.14.2/Debian-2build1) with ESMTP id p21LlCGb008406
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 1 Mar 2011 13:47:12 -0800
Received: by iwl42 with SMTP id 42so6046822iwl.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 13:47:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110228151736.GO22310@pengutronix.de>
References: <20101124085645.GW4693@pengutronix.de> <1290589070-854-5-git-send-email-u.kleine-koenig@pengutronix.de>
 <20110228151736.GO22310@pengutronix.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 1 Mar 2011 13:46:52 -0800
Message-ID: <AANLkTi=VB5po9Yt2oCcCq01UNQxXNY+_6RBpjWRFkvxN@mail.gmail.com>
Subject: Re: [PATCH 5/6] mm: add some KERN_CONT markers to continuation lines
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, kernel@pengutronix.de, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org

2011/2/28 Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>:
> Hello,
>
>
> On Wed, Nov 24, 2010 at 09:57:49AM +0100, Uwe Kleine-K=F6nig wrote:
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("\n");
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("%spcpu=
-alloc: ", lvl);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_CO=
NT "\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("%spcpu=
-alloc:", lvl);

So I hate this kind of "mindless search-and-replace" patch.

The whole point is that with the modern printk semantics, the above
kind of crazy cdoe shouldn't be needed. You should be able to just
write

     printk("%spcpu-alloc:", lvl);

without that "\n" at all, because printk() will insert the \n if
necessary. So the concept of

    printk(KERN_CONT "\n")

is just crazy: you're saying "I want to continue the line, in order to
print a newline". Whaa?

>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("[%0*d] ", group_width,=
 group);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_CONT " [%0*d]", gr=
oup_width, group);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 printk("%0*d ", cpu_width,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 printk(KERN_CONT " %0*d", cpu_width,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 printk("%s ", empty_str);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 printk(KERN_CONT " %s", empty_str);

These look ok, but:

>> - =A0 =A0 printk("\n");
>> + =A0 =A0 printk(KERN_CONT "\n");

Same deal. Why do KERN_CONT + "\n"?

Yes, yes, it does have semantic meaning ("do newline _now_"), and can
matter if you are going to use KERN_CONT exclusively around it. But it
still smells like just being silly to me. The point of the printk
changes was to make things simpler. I really would suggest just
removing those KERN_CONT "\n" lines. Doesn't it end up looking fine
that way too?

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
