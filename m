Subject: Re: 2.6.2-rc1-mm2
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <200401231430.35014.thomas.schlichter@web.de>
References: <20040123013740.58a6c1f9.akpm@osdl.org>
	 <200401231430.35014.thomas.schlichter@web.de>
Content-Type: text/plain
Message-Id: <1074880768.12442.22.camel@localhost>
Mime-Version: 1.0
Date: Fri, 23 Jan 2004 09:59:28 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <thomas.schlichter@web.de>
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-01-23 at 05:30, Thomas Schlichter wrote:
> Hi,
> 
> Am Freitag, 23. Januar 2004 10:37 schrieb Andrew Morton:
> > +use-pmtmr-for-delay_pmtmr.patch
> >
> >  Fix a boot-time crash which occurs when testing the APIC timer when using
> >  the ACPI PM timer.  This causes bogomips to be reported at 50% of what it
> >  used to be.
> 
> I don't know which Oops this fixes, but with this patch my bogomips value is 
> 8.19 (!!!) instead of ~1300. With clock=pit I get about 1300 bogomips, and 
> with clock=tsc I get about 2600 bogomips. The CPU is a 1300MHz AMD Duron.

I know it feels like a kick in the pants when your BogoMIPS drops to
leves not seen since the 80s, but the value you are getting is expected.
Since the patch above uses the pmtmr for __delay(), loops_per_jiffies is
then calibrated to the ACPI PM timer's frequency instead of aproximately
the cpu's freq. 

This was necessary, because on some systems calibrate_dealy()
incorrectly calibrates delays. Your system shows this, but its your
cycle based delay (clock=tsc) which is overestimated, so you see no
problem. The case Andrew describes above is when the loop based delay
(clock=pit or clock=pmtmr w/o this patch) is under estimated causing
problems when we initialize the APIC timer.  

Additionally, since we're no longer dependent on the cpu speed,
speedstep like changes to the cpu freqency no longer affects time.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
