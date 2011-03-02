Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 79D548D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 00:28:04 -0500 (EST)
Subject: Re: [PATCH 5/6] mm: add some KERN_CONT markers to continuation
 lines
From: Joe Perches <joe@perches.com>
In-Reply-To: <AANLkTi=VB5po9Yt2oCcCq01UNQxXNY+_6RBpjWRFkvxN@mail.gmail.com>
References: <20101124085645.GW4693@pengutronix.de>
	 <1290589070-854-5-git-send-email-u.kleine-koenig@pengutronix.de>
	 <20110228151736.GO22310@pengutronix.de>
	 <AANLkTi=VB5po9Yt2oCcCq01UNQxXNY+_6RBpjWRFkvxN@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Mar 2011 21:28:00 -0800
Message-ID: <1299043680.4208.97.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>, linux-kernel@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, kernel@pengutronix.de, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org

On Tue, 2011-03-01 at 13:46 -0800, Linus Torvalds wrote:
> the concept of
>     printk(KERN_CONT "\n")
> is just crazy: you're saying "I want to continue the line, in order to
> print a newline". Whaa?

It's a trivially useful "end of collected printk" mark,
which was made a bit superfluous by the code that added
any necessary newline before every KERN_<level>.

There are a thousand or so of them today.

$ grep -rP --include=*.[ch] "\b(printk\s*\(\s*KERN_CONT|pr_cont\s*\(|printk\s*\()\s*\"\\\n\"" * | wc -l
1061

That code made all message terminating newlines a bit
obsolete.  I won't be submitting any patches to remove
those EOM newlines any time soon.

I hope no one does that.

It would be actually useful to have some form like:

	cookie = collected_printk_start()
loop:
		collected_printk(cookie, ...) (...)
	collected_printk_end(cookie)

so that interleaved messages from multiple
concurrent streams could be sensibly collected
either post processed or buffered.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
