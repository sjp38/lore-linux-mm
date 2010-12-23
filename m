Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4A7CA6B0088
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 14:57:03 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
	<aab9953c699dace1ed94efd6505c7844.squirrel@www.firstfloor.org>
	<20101223091851.GC30055@liondog.tnic>
	<5C4C569E8A4B9B42A84A977CF070A35B2C132F6BB0@USINDEVS01.corp.hds.com>
Date: Thu, 23 Dec 2010 11:56:21 -0800
In-Reply-To: <5C4C569E8A4B9B42A84A977CF070A35B2C132F6BB0@USINDEVS01.corp.hds.com>
	(Seiji Aguchi's message of "Thu, 23 Dec 2010 12:31:24 -0500")
Message-ID: <m11v58xnyy.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH] Add a sysctl option controlling kexec when MCE occurred
Sender: owner-linux-mm@kvack.org
To: Seiji Aguchi <seiji.aguchi@hds.com>
Cc: Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>
List-ID: <linux-mm.kvack.org>

Seiji Aguchi <seiji.aguchi@hds.com> writes:

> Hi,
>
> I agree with Borislav that kexec shouldn't start at all because we can't guarantee 
> a stable system anymore when MCE is reported.

In the case of kexec on panic we can never guarantee a stable system.
But the odds are much better of executing non-corrupt code  and of
telling people you had a hardware error if you go through the kexec
on panic process.

If I read Andi's patch correctly he was suggesting to not allow any more
mces to be reported on that path.


> On the other hand, I understand there are people like Andi who want to start kexec 
> even if MCE occurred.
>
> That is why I propose adding a new option controlling kexec behaviour
> when MCE occurred.

What do you gain but not doing the kexec on panic, when you have the
system configured to take one.  We already have the big policy knobs
to enable or disable this kind of behavior.

> I don't stick to "sysctl".

I think adding a sysctl in this path or any unnecessary code will make
things less reliable.

Last time this happened to me (about a week ago).  The kexec on panic
from a ecc reported memory error worked just fine.  Aka in the real
world it seems to work.

So what is the problem you are trying to avoid, and why can't we do
something in the kernels initialization path to avoid initializing
when there is a problem?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
