Message-ID: <46CF31CB.10208@redhat.com>
Date: Fri, 24 Aug 2007 15:30:19 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: Drop caches - is this safe behavior?
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>	 <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>	 <46CE3617.6000708@redhat.com>	 <1187930857.6406.12.camel@norville.austin.ibm.com>	 <46CE69DE.9040807@redhat.com>	 <bd9320b30708232227v1b297a42pd9b20e04aef758d7@mail.gmail.com>	 <46CE7211.2010708@redhat.com> <bd9320b30708240012m6d44ea6wb346d0b4db76e00d@mail.gmail.com>
In-Reply-To: <bd9320b30708240012m6d44ea6wb346d0b4db76e00d@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mike <mike503@gmail.com>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mike wrote:
> On 8/23/07, Chris Snook <csnook@redhat.com> wrote:
>> I think the caches you had in mind were the ones that would be dropped
>> by echoing '1' into /proc/sys/vm/drop_caches, not the ones that would be
>> dropped by echoing '2' into it.  If you were dropping pagecache every
>> five minutes, it would kill your performance as you described.  As for
>> the question of safety, '3' should also be safe, but terrible for
>> performance, as it does all the harm of '1', plus some.
> 
> actually right now the performance seems to be good - using "2"

That's because you're not actually dropping that much.

> i'm willing to try "1" as well, as well as try the cache pressure one.
> i don't really know what caches i am clearing, but it seems that i get
> bottlenecked by something. restarting my webserver/php engines usually
> clears it up, so it seems like it is a buildup of something - and it
> always seems to be when memory is tight...

'1' drops pagecache, which is the kernel's cache of file data.  This is what you 
see under "cached" in the output of free.  '2' drops VFS cache, which is the 
kernel's cache of file *metadata*.  All of this appears under "used" in the 
output of free.  '3' drops both.  I think what you actually want is '1' or '3', 
though I assure you it would hurt performance considerably if you do either of 
those.

Turning up vm.vfs_cache_pressure instead of echoing '2' into drop_caches will 
cause the system to automatically free up more of that cache, but only when 
necessary.  It's much less disruptive to the system.

>> I'm not familiar with the "atsar" implementation, but it appears to be
>> an alternate implementation of the same thing.  It's an excellent tool
>> for long-term workload profiling.
> 
> actually, this might be a better method - is there any way to view the
> contents of the cache? or figure out what exactly is sitting in
> there/why my machine thinks it needs to cache 2 gigs of files so
> quickly?

If your system is caching 2 GB of files, that's because it's actually using 2 GB 
of files.  It *might* be useful to do a drop_caches *once* after the system 
boots and services start to clear out anything that's only used at boot, but 
doing this during normal operation is just shooting yourself in the foot.

Also, check out how your applications are using temporary files.  If files are 
deleted and aren't in use by any other processes, their pagecache gets dropped. 
  If your apps are being lazy and waiting for tmpwatch to clean up their 
garbage, it's sitting around in pagecache because nobody has informed the kernel 
that they're no longer needed.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
