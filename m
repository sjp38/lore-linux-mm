Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 06C5D6B003D
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 13:48:47 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id bj1so169065pad.7
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 10:48:47 -0800 (PST)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id dk5si20468572pbc.286.2013.11.12.10.48.45
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 10:48:46 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 13 Nov 2013 00:18:42 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 652F21258051
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 00:19:19 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rACImQ4O50266176
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 00:18:27 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rACImTQg025766
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 00:18:30 +0530
Message-ID: <528276F4.7020009@linux.vnet.ibm.com>
Date: Wed, 13 Nov 2013 00:14:04 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <52442F6F.5020703@linux.vnet.ibm.com> <5281E09B.3060303@linux.vnet.ibm.com> <528266A9.2040901@sr71.net>
In-Reply-To: <528266A9.2040901@sr71.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, markgross@thegnar.org

On 11/12/2013 11:04 PM, Dave Hansen wrote:
> On 11/12/2013 12:02 AM, Srivatsa S. Bhat wrote:
>> I performed experiments on an IBM POWER 7 machine and got actual power-savings
>> numbers (upto 2.6% of total system power) from this patchset. I presented them
>> at the Kernel Summit but forgot to post them on LKML. So here they are:
> 
> "upto"?  What was it, actually?

Hmm? It _was_ 2.6% (Maybe my usage of the word 'upto' is misleading in that
sentence, sorry).

>  Essentially what you've told us here is
> that you have a patch that tries to do some memory power management and
> that it accomplishes that.  But, to what degree?
> 
> Was your baseline against a kernel also booted with numa=fake=1, or was
> it a kernel booted normally?
> 

The baseline kernel was also booted with numa=fake=1.

> 1. What is the theoretical power savings from memory?

I don't have that number for POWER (but I'll work on that), but referring to
the previous data from Samsung ARM boards, it was around the same number
(2.7% to 3.2 % of total system power) for memory power management using
content-preserving states. For content-destructive (power-off) states, it was
around 6.3%.

http://article.gmane.org/gmane.linux.kernel.mm/65935

> 2. How much of the theoretical numbers can your patch reach?

Honestly, the 2.6% number on the hardware that I tested is not bad at all.
As I mentioned, the base power consumption of the system (power consumption
at idle) was a bit high, so the percentage power-savings value might look small,
but nevertheless it is not insignificant. I'm trying to setup a newer prototype
hardware to test this patchset, and I expect to see better numbers on that
with the same code. By some crude initial estimates, I expect to see around
5% power-savings with the same patchset.

> 3. What is the performance impact?  Does it hurt ebizzy?
> 

Ebizzy numbers were quite low in both cases (vanilla and patched kernel),
in 1 digit numbers, due to the huge allocations/frees that were done on every
loop. So comparing performance with those numbers is not going to be reliable.
I'll work on detailed performance measurements after I'm done with the initial
power-savings experiments.

> You also said before:
>> On page 40, the paper shows the power-consumption breakdown for an IBM p670
>> machine, which shows that as much as 40% of the system energy is consumed by
>> the memory sub-system in a mid-range server.
> 
> 2.6% seems pretty awful for such an invasive patch set if you were
> expecting 40%.

As I said, this was not the most ideal hardware to test my patches on. 128GB
is not a particularly large amount of RAM. So obviously it wont contribute a
whole lot to the total system power, atleast not as much as, say a terabyte of
RAM would. So yeah, the overall number is small, but given the relatively
modest amount of RAM installed on that machine, the savings is not ignorable.

Also, I used only 4 memory regions on this hardware, which is quite a small
number to play with. More the number of memory regions, higher the opportunity
that my patches have to cause power-savings. So I'll test with newer platforms
(with more memory regions) to see how well that goes.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
