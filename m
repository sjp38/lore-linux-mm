Message-ID: <419BECB0.70801@tebibyte.org>
Date: Thu, 18 Nov 2004 01:28:32 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable
 braindamage
References: <20041105200118.GA20321@logos.cnet> <200411051532.51150.jbarnes@sgi.com> <20041106012018.GT8229@dualathlon.random> <1099706150.2810.147.camel@thomas> <20041117195417.A3289@almesberger.net> <419BDE53.1030003@tebibyte.org> <20041117210410.R28844@almesberger.net>
In-Reply-To: <20041117210410.R28844@almesberger.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Werner Almesberger <wa@almesberger.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andrea Arcangeli <andrea@novell.com>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Werner Almesberger escreveu:
> Chris Ross wrote:
> The underlying hypothesis for suggesting explicitly flagging
> candidates for killing is of course that it doesn't see who
> exactly is misbehaving :-) Since this issue has been around for
> a nummber of years, I think it's fair to assume that the OOM
> killers indeed have a problem in that area.

That's my point ii) below, which is what Thomas's patch is trying to 
address. I doubt you'd find much disagreement that this area still needs 
work :)

>>The example I have in mind is on my machine when the daily cron 
>>run over commits causing standard daemons such as ntpd to be killed to 
>>make room. It would be preferable if the daemon was swapped out and just 
>>didn't run for minutes, or even hours if need be, but was allowed to run 
>>again once the system had settled down.
> 
> Ah, now I understand why you'd want to swap. Interesting. Now,
> depending on the time if day, you have typically "interactive"
> processes, like your idle desktop, turn into "non-interactive"
> ones, which can then be subjected to swapping. Nice example
> against static classification :-)

A better example than the ntpd daemon (which mightn't take kindly to 
finding minutes just passed in a blink of its eye) is Thomas's example 
with the sshd. If the daemon was swapped out you wouldn't be able to log 
into the box while it was thrashing, but in practice you can't really 
anyway. At least once the system had recovered sufficiently you could 
get back in, under the present system you can never log in again.

>>So, the problem breaks down into three parts:
>>
>>	  i) When should the oom killer be invoked.
>>	 ii) How do we pick a victim process
>>	iii) How can we deal with the process in the most useful manner
> 
> iii) may also affect i). If you're going to swap, you don't want
> to wait until you're fighting for the last available page in the
> system.

Well yes, in typical fashion everything depends on everything else. That 
in a nutshell is also my argument against the kill-me flag.

Regards,
Chris R.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
