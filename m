Subject: Re: keyboard and USB problems (Re: 2.6.2-rc1-mm2)
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <20040123161946.GA6934@ucw.cz>
References: <20040123013740.58a6c1f9.akpm@osdl.org>
	 <20040123160152.GA18073@ss1000.ms.mff.cuni.cz>
	 <20040123161946.GA6934@ucw.cz>
Content-Type: text/plain
Message-Id: <1074886056.12447.36.camel@localhost>
Mime-Version: 1.0
Date: Fri, 23 Jan 2004 11:27:41 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vojtech Pavlik <vojtech@suse.cz>
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-01-23 at 08:19, Vojtech Pavlik wrote:
> On Fri, Jan 23, 2004 at 05:01:52PM +0100, Rudo Thomas wrote: 
> > BogoMIPS is figured out to be 8.19 (this was already reported by another user),
> 
> ... this the root cause of the following problems.
> 
> > and i8042.c complaints with this:
> > i8042.c: Can't write CTR while closing AUX.
> 
> ... bogomips is used in udelay() and that's used for waiting. If
> bogomips is measured lower than real, the wait takes shorter and the
> hardware doesn't do what it should in that short time.

Well, loops_per_jiffy is actually being measured correctly as we're
using the acpi pm timesource to time udelay(). However there is a loss
of resolution using the slower time source, so udelay(1) might take
longer then 1 us. 

If that is going to cause problems, then we'll need to pull out the
use-pmtmr-for-delay_pmtmr patch. I guess our only option is then to use
the TSC for delay_pmtrm() (as a loop based delay fails in other cases).
I'll write that up and send it your way, Andrew. 

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
