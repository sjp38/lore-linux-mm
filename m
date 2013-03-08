Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D6EC46B0005
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 18:21:11 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id z7so404091eaf.14
        for <linux-mm@kvack.org>; Fri, 08 Mar 2013 15:21:10 -0800 (PST)
Message-ID: <513A7263.5090303@suse.cz>
Date: Sat, 09 Mar 2013 00:21:07 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd craziness round 2
References: <5121C7AF.2090803@numascale-asia.com> <CAJd=RBArPT8YowhLuE8YVGNfH7G-xXTOjSyDgdV2RsatL-9m+Q@mail.gmail.com> <51254AD2.7000906@suse.cz> <CAJd=RBCiYof5rRVK+62OFMw+5F=5rS=qxRYF+OHpuRz895bn4w@mail.gmail.com> <512F8D8B.3070307@suse.cz> <CAJd=RBD=eT=xdEy+v3GBZ47gd47eB+fpF-3VtfpLAU7aEkZGgA@mail.gmail.com> <5138EC6C.6030906@suse.cz> <CAJd=RBC6JzXzPn9OV8UsbEjX152RcbKpuGGy+OBGM6E43gourQ@mail.gmail.com>
In-Reply-To: <CAJd=RBC6JzXzPn9OV8UsbEjX152RcbKpuGGy+OBGM6E43gourQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Daniel J Blueman <daniel@numascale-asia.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>, mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On 03/08/2013 07:42 AM, Hillf Danton wrote:
> On Fri, Mar 8, 2013 at 3:37 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>> On 03/01/2013 03:02 PM, Hillf Danton wrote:
>>> On Fri, Mar 1, 2013 at 1:02 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>>>>
>>>> Ok, no difference, kswap is still crazy. I'm attaching the output of
>>>> "grep -vw '0' /proc/vmstat" if you see something there.
>>>>
>>> Thanks to you for test and data.
>>>
>>> Lets try to restore the deleted nap, then.
>>
>> Oh, it seems to be nice now:
>> root       579  0.0  0.0      0     0 ?        S    Mar04   0:13 [kswapd0]
>>
> Double thanks.

There is one downside. I'm not sure whether that patch was the culprit.
My Thunderbird is jerky when scrolling and lags while writing this
message. The letters sometimes appear later than typed and in groups. Like
I (kbd): My Thunder
TB: My Thunder
I (kbd): b-i-r-d
TB: is silent
I (kbd): still typing...
TB: bird is

Perhaps it's not only TB.

> But Mel does not like it, probably.
> Lets try nap in another way.

Will try next week.

> --- a/mm/vmscan.c	Thu Feb 21 20:01:02 2013
> +++ b/mm/vmscan.c	Fri Mar  8 14:36:10 2013
> @@ -2793,6 +2793,10 @@ loop_again:
>  				 * speculatively avoid congestion waits
>  				 */
>  				zone_clear_flag(zone, ZONE_CONGESTED);
> +
> +			else if (sc.priority > 2 &&
> +				 sc.priority < DEF_PRIORITY - 2)
> +				wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
>  		}
> 
>  		/*

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
