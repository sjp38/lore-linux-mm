Subject: Re: slablru for 2.5.32-mm1
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.4.44.0209052032410.30628-100000@loke.as.arizona.edu>
References: <Pine.LNX.4.44.0209052032410.30628-100000@loke.as.arizona.edu>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 06 Sep 2002 00:24:54 -0400
Message-Id: <1031286298.940.37.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@zip.com.au>, Ed Tomlinson <tomlins@cam.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2002-09-06 at 00:07, Craig Kulesa wrote:

> I have a terribly naive question to add though.  From the original message 
> in this thread, Andrew reverted this BUG_ON due to side-effects:
> 
> 	BUG_ON(smp_call_function(func, arg, 1, 1));
> 
> I must be dense -- why?  All we are doing is passing gcc the hint that
> this is an unlikely path, and surely that's true?  I mean, if it's not, 
> don't we have other things to worry about?

It is just good practice, because it is feasible that one day someone
will do something like:

	#ifdef CONFIG_NO_ASSERT
	#define BUG_ON()		do { } while(0)
	#else
	#define BUG_ON(condition)	do { \
		if (unlikely((condition)!=0)) BUG(); \
	} while(0)
	#endif

so if your BUG_ON has a side effect (e.g. is a function we _have_ to
call, then it needs to be of the normal if..BUG() form.  Note, sure, it
should still be marked unlikely).

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
