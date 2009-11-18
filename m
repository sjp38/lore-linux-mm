Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E77106B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 10:30:07 -0500 (EST)
Date: Wed, 18 Nov 2009 07:29:49 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 09/16] MM: use ACCESS_ONCE for rlimits
In-Reply-To: <1258555922-2064-9-git-send-email-jslaby@novell.com>
Message-ID: <alpine.LFD.2.01.0911180721440.4644@localhost.localdomain>
References: <4B040A03.2020508@gmail.com> <1258555922-2064-9-git-send-email-jslaby@novell.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jslaby@novell.com>
Cc: jirislaby@gmail.com, Ingo Molnar <mingo@elte.hu>, nhorman@tuxdriver.com, sfr@canb.auug.org.au, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, marcin.slusarz@gmail.com, tglx@linutronix.de, mingo@redhat.com, "H. Peter Anvin" <hpa@zytor.com>, James Morris <jmorris@namei.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I hate these patches, but not because they start using ACCESS_ONCE() per 
se, but because they turn an already much too complex expression into the 
ExpressionFromHell(tm).

The fact that you had to split a single expression over multiple lines in 
multiple places should really have made you realize that something is 
wrong.

So I really would suggest that rather than this kind of mess:

On Wed, 18 Nov 2009, Jiri Slaby wrote:
>
> -	unsigned long limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
> +	unsigned long limit = ACCESS_ONCE(current->signal->
> +			rlim[RLIMIT_FSIZE].rlim_cur);

into something more like

	static inline unsigned long tsk_get_rlimit(struct task_struct *tsk, int limit)
	{
		return ACCESS_ONCE(tsk->signal->rlim[limit].rlim_cur);
	}

	static inline unsigned long get_rlimit(int limit)
	{
		return tsk_get_rlimit(current, limit);
	}

and then instead of adding ACCESS_ONCE() to many places that are already 
ugly, you'd have made the above kind of expression be

	unsigned long limit = get_rlimit(RLIMIG_FSIZE);

instead.

Doesn't that look saner?

Yeah, yeah, there's a few places that actually take the address of 
'tsk->signal->rlim' and do this all by hand, so you'd not get rid of all 
of these things and it's not a matter of wrapping things in some new fancy 
abstraction layer, but at least you'd get rid of the overly complex 
expressions that span multiple lines.

With that, I'd probably like the series a whole lot better.

Which is not to say that I'm entirely convinced about get/setprlimit() in 
the first place, but that's a whole different issue.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
