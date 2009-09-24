Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 43D196B004D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 23:11:56 -0400 (EDT)
Received: by gxk19 with SMTP id 19so423070gxk.10
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:11:59 -0700 (PDT)
Message-ID: <4ABAE340.7010403@vflare.org>
Date: Thu, 24 Sep 2009 08:40:56 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH RFC 1/2] Add notifiers for various swap events
References: <1253540040-24860-1-git-send-email-ngupta@vflare.org> <20090924104708.4f54ce4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090924104708.4f54ce4e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 09/24/2009 07:17 AM, KAMEZAWA Hiroyuki wrote:
> On Mon, 21 Sep 2009 19:03:59 +0530
> Nitin Gupta <ngupta@vflare.org> wrote:
> 
>> Add notifiers for following swap events:
>>  - Swapon
>>  - Swapoff
>>  - When a swap slot is freed
>>
>> This is required for ramzswap module which implements RAM based block
>> devices to be used as swap disks. These devices require a notification
>> on these events to function properly (as shown in patch 2/2).
>>
>> Currently, I'm not sure if any of these event notifiers have any other
>> users. However, adding ramzswap specific hooks instead of this generic
>> approach resulted in a bad/hacky code.
>>
> Hmm ? if it's not necessary to make ramzswap as module, for-ramzswap-only
> code is much easier to read..
>

The patches posted earlier (v3 patches) inserts special hooks for swap slot
free event only. In this version, the callback is set when we get first R/W request.
Actually ramzswap needs callback for swapon/swapoff too but I just didn't do it.

Then Pekka posted test patch that allows setting this callback during swapon
itself. Looking that all these patches, I realized its already too messy even
if we just make everything ramzswap specific.
Just FYI, Pekka's test patch:
http://patchwork.kernel.org/patch/48472/

Then I added this generic notifier interface which, compared to earlier version,
looks much cleaner. The code to add these notifiers is also very small.
 
> 
> 
>> For SWAP_EVENT_SLOT_FREE, callbacks are made under swap_lock. Currently, this
>> is not a problem since ramzswap is the only user and the callback it registers
>> can be safely made under this lock. However, if this event finds more users,
>> we might have to work on reducing contention on this lock.
>>
>> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
>>
> 
> In general, notifier chain codes allowed to return NOTIFY_BAD.
> But this patch just assumes all chains should return NOTIFY_OK or
> just ignore return code.
> 
> That's not good as generic interface, I think.


What action we can take here if the notifier_call_chain() returns an error (apart
from maybe printing an error)? Perhaps we can add a warning in case of swapon/off
events but not in case of swap slot free event which is called under swap_lock.



Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
