Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 2314B6B0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 01:42:32 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id tb18so1038648obb.17
        for <linux-mm@kvack.org>; Thu, 07 Mar 2013 22:42:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5138EC6C.6030906@suse.cz>
References: <5121C7AF.2090803@numascale-asia.com>
	<CAJd=RBArPT8YowhLuE8YVGNfH7G-xXTOjSyDgdV2RsatL-9m+Q@mail.gmail.com>
	<51254AD2.7000906@suse.cz>
	<CAJd=RBCiYof5rRVK+62OFMw+5F=5rS=qxRYF+OHpuRz895bn4w@mail.gmail.com>
	<512F8D8B.3070307@suse.cz>
	<CAJd=RBD=eT=xdEy+v3GBZ47gd47eB+fpF-3VtfpLAU7aEkZGgA@mail.gmail.com>
	<5138EC6C.6030906@suse.cz>
Date: Fri, 8 Mar 2013 14:42:31 +0800
Message-ID: <CAJd=RBC6JzXzPn9OV8UsbEjX152RcbKpuGGy+OBGM6E43gourQ@mail.gmail.com>
Subject: Re: kswapd craziness round 2
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Daniel J Blueman <daniel@numascale-asia.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>, mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 8, 2013 at 3:37 AM, Jiri Slaby <jslaby@suse.cz> wrote:
> On 03/01/2013 03:02 PM, Hillf Danton wrote:
>> On Fri, Mar 1, 2013 at 1:02 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>>>
>>> Ok, no difference, kswap is still crazy. I'm attaching the output of
>>> "grep -vw '0' /proc/vmstat" if you see something there.
>>>
>> Thanks to you for test and data.
>>
>> Lets try to restore the deleted nap, then.
>
> Oh, it seems to be nice now:
> root       579  0.0  0.0      0     0 ?        S    Mar04   0:13 [kswapd0]
>
Double thanks.

But Mel does not like it, probably.
Lets try nap in another way.

Hillf

--- a/mm/vmscan.c	Thu Feb 21 20:01:02 2013
+++ b/mm/vmscan.c	Fri Mar  8 14:36:10 2013
@@ -2793,6 +2793,10 @@ loop_again:
 				 * speculatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
+
+			else if (sc.priority > 2 &&
+				 sc.priority < DEF_PRIORITY - 2)
+				wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 		}

 		/*
--

>>
>> --- a/mm/vmscan.c     Thu Feb 21 20:01:02 2013
>> +++ b/mm/vmscan.c     Fri Mar  1 21:55:40 2013
>> @@ -2817,6 +2817,10 @@ loop_again:
>>                */
>>               if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
>>                       break;
>> +
>> +             if (sc.priority < DEF_PRIORITY - 2)
>> +                     congestion_wait(BLK_RW_ASYNC, HZ/10);
>> +
>>       } while (--sc.priority >= 0);
>>
>>  out:
>> --
>>
>
>
> --
> js
> suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
