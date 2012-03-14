Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 2E0DF6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 22:21:59 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so1919414vcb.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 19:21:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120313151049.fa33d232.akpm@linux-foundation.org>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
 <20120313170851.GA5218@fifo99.com> <20120313151049.fa33d232.akpm@linux-foundation.org>
From: Avery Pennarun <apenwarr@gmail.com>
Date: Tue, 13 Mar 2012 22:21:37 -0400
Message-ID: <CAHqTa-1e9k5W8LJ39+3rmrDrRVdrSuXiqigDFcY8ToXU+Kdz0w@mail.gmail.com>
Subject: Re: [PATCH 0/5] Persist printk buffer across reboots.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Walker <dwalker@fifo99.com>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 13, 2012 at 6:10 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 13 Mar 2012 10:08:51 -0700
> Daniel Walker <dwalker@fifo99.com> wrote:
>> There's currently driver/mtd/mtdoops.c, fs/pstore/, and
>> drivers/staging/android/ram_console.c that do similar things
>> as this. Did you investigate those for potentially modifying them to add
>> this functionality ? If so what issues did you find?
>>
>> I have a arm MSM G1 with persistent memory at 0x16d00000 size 20000bytes..
>> It's fairly simple you just have to ioremap the memory, but then it's good
>> for writing.. Currently the android ram_console uses this. How would I
>> convert this area for use with your changes?
>
> Yes, and various local implementations which do things such as stuffing
> the log buffer into NVRAM as the kernel is crashing.
>
> I do think we'd need some back-end driver arrangement which will permit
> the use of stores which aren't in addressible mamory.
>
> It's quite the can of worms, but definitely worth doing if we can get
> it approximately correct.

So okay, it seems there are a lot of competing ideas around.  In my
defense, I had looked at a couple of them (certainly not the full
variety represented in this thread) and the approach in my patch does
have a few advantages, I think:

1. It's extremely small and simple and easy to see when it's correct,
regardless of your platform (and even if your platform does or doesn't
have bootloader-level memory reservations - for example it works on
x86 with kvm).

2. It does not increase the code size or slowness of the post-init
kernel.  (There's one new __init function, but no new runtime code
except a couple of extra pointer dereferences.)

3. It doesn't introduce any new APIs; there's just good old dmesg,
whose history now goes back farther.  (/proc/kmsg is unaffected, ie.
it still only shows history since boot, so klogd won't do anything
weird.)

4. It captures much more than just panics.  I don't know why people
put so much stock in catching panics; about half the problems I've had
to deal with are hard-lockups, not panics, and any solution that only
works with panics doesn't help me much.  (Also, trying to do useful
work after a panic doesn't even work every time, but "do nothing on
panic and I'll pick it up later" does.)  So things like mtdoops or
ramoops or kexec are not a complete solution IMHO.  For example, one
method I've used already for tracking down a hard lockup is to print
short status messages at LOG_DEBUG level (ie. not to the visible
console, but it goes in the buffer) at regular intervals inside the
driver that is crashing, and use a very large printk buffer.  Then,
after a crash and reset, the collection of status messages from a
variety of test devices in the field can be uploaded to a single place
and analyzed en masse, even if there was never a crash.

So that's my justification for writing this in the first place.  I'm
certainly not opposed to all those other methods if they make people
happy, but I was hoping to make a patch so simple and unproblematic
that it could actually get into the official kernel.

Now, the big downside of my approach is that we're just taking our
chances that the bootloader and early kernel boot won't eat our
buffer.  That's pretty inelegant (albeit not a problem for my use
case), so David Miller's suggestion to make it extensible by the
platform layer seems like a fine idea to me.  It seems like, say, the
ioremap'd nvram areas and other things people have suggested should
all be doable as long as the extension API is defined correctly.  I
would appreciate some more concrete suggestions on where to stick in a
hook to get memory allocated as soon as possible, so it works with eg.
prom_retain().

On the other hand, if the kernel maintainers don't really want the
patch and you think I should replace it with one of the several
overengineered not-yet-in-kernel-anyway megastructure memory
reservation systems, I don't think I'm going to bother; continuing to
apply my nice simple patch to our modified kernel is pretty easy and
will work the way I want (specifically, no performance/memsize
overhead).

Anyway, concrete pointers for how to link very early into
prom_retain() are very welcome, if you think this patch series is not
an evolutionary dead end.  I could just poke at it, but I have a
feeling someone here already knows exactly where I need to insert the
right call to make it work.

Have fun,

Avery

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
