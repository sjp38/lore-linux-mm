Received: from firewall.hyperwave.com (firewall.hyperwave.com [129.27.200.34])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA11073
	for <linux-mm@kvack.org>; Thu, 27 Aug 1998 08:43:50 -0400
Date: Thu, 27 Aug 1998 14:43:31 +0200 (MET DST)
Message-Id: <199808271243.OAA28073@hwal02.hyperwave.com>
From: Bernhard Heidegger <bheide@hyperwave.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] 498+ days uptime
In-Reply-To: <87emu2zkc0.fsf@atlas.CARNet.hr>
References: <199808262153.OAA13651@cesium.transmeta.com>
	<87ww7v73zg.fsf@atlas.CARNet.hr>
	<199808271207.OAA15842@hwal02.hyperwave.com>
	<87emu2zkc0.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: Bernhard Heidegger <bheide@hyperwave.com>, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

>> Bernhard Heidegger <bheide@hyperwave.com> writes:
>> >>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
>> 
>> >> "H. Peter Anvin" <hpa@transmeta.com> writes:
>> >> > 
>> >> > bdflush yes, but update is not obsolete.
>> >> > 
>> >> > It is still needed if you want to make sure data (and metadata)
>> >> > eventually gets written to disk.
>> >> > 
>> >> > Of course, you can run without update, but then don't bother if you
>> >> > lose file in system crash, even if you edited it and saved it few
>> >> > hours ago. :)
>> >> > 
>> >> > Update is very important if you have lots of RAM in your computer.
>> >> > 
>> >> 
>> >> Oh.  I guess my next question then is "why", as why can't this be done
>> >> by kflushd as well?
>> >> 
>> 
>> >> To tell you the truth, I'm not sure why, these days.
>> 
>> >> I thought it was done this way (update running in userspace) so to
>> >> have control how often buffers get flushed. But, I believe bdflush
>> >> program had this functionality, and it is long gone (as you correctly
>> >> noticed).
>> 
>> IMHO, update/bdflush (in user space) calls sys_bdflush regularly. This
>> function (fs/buffer.c) calls sync_old_buffers() which itself sync_supers
>> and sync_inodes before it goes through the dirty buffer lust (to write
>> some dirty buffers); the kflushd only writes some dirty buffers dependent
>> on the sysctl parameters.
>> If I'm wrong, please feel free to correct me!
>> 

>> You are not wrong.

>> Update flushes metadata blocks every 5 seconds, and data block every
>> 30 seconds.

My version of update (something around Slakware 3.4) does the following:
1.) calls bdflush(1,0) (fs/buffer.c:sys_bdflush) which will call
    sync_old_buffers() and return
2.) only if the bdflush(1,0) fails (it returns < 0) it returns to the
    old behavior of sync()ing every 30 seconds

But case 2) should only happen on really old kernels; on newer kernels
(I'm using 2.0.34) the bdflush() should never fail.

But as I told, sync_old_buffers() do:
1.) sync_supers(0)
2.) sync_inodes(0)
3.) go through dirty buffer list and may flush some buffers

Conclusion: the meta data get synced every 5 seconds and some buffers may
be flushed.

>> Questions is why can't this functionality be integrated in the kernel, 
>> so we don't have to run yet another daemon?

Good question, but I've another one: IMHO sync_old_buffers (especially
the for loop) do similar things as the kflushd. Why??
Is it possible to reduce the sync_old_buffers() routine to soemthing like:
{
  	sync_supers(0);
	sync_inodes(0);
}
??

Bernhard

get my pgp key from a public keyserver (keyID=0x62446355)
-----------------------------------------------------------------------------
Bernhard Heidegger                                       bheide@hyperwave.com
                  Hyperwave Software Research & Development
                       Schloegelgasse 9/1, A-8010 Graz
Voice: ++43/316/820918-25                             Fax: ++43/316/820918-99
-----------------------------------------------------------------------------
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
