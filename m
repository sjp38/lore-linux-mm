Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D9E416B0055
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 16:55:30 -0400 (EDT)
Message-ID: <4A5BA54C.8070600@embeddedalley.com>
Date: Mon, 13 Jul 2009 14:21:16 -0700
From: "Vladislav D. Buzov" <vbuzov@embeddedalley.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com>	<20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>	<4A554B54.3080903@embeddedalley.com> <20090713095209.d8b6e566.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090713095209.d8b6e566.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 08 Jul 2009 18:43:48 -0700
> "Vladislav D. Buzov" <vbuzov@embeddedalley.com> wrote:
>
>   
>> KAMEZAWA Hiroyuki wrote:
>>     
>>> 2 points.
>>>  - Do we have to check this always we account ?
>>>   
>>>       
>> What are the options? Every N pages? How to select N?
>>
>>     
> I think you can reuse Balbir's softlimit event counter. (see v9.)
>   
It still does not answer the question how to select the number of events
before/between sending the notification.

The idea behind the notification feature is to let user applications
know immediately when a low memory condition occurs (the threshold is
exceeded). So that they can take action to free unused memory before the
OS is involved to handle that (OOM-kill, reclaiming pages).

As far as I understand the reason why you would like to add a delay
between sending notifications is to let user applications some time to
free memory. This is not required by design of the notification feature
because the notification is sent only if someone listening for it.
Typical application will subscribe for low-memory notification, receive
it, handle and then subscribe again. So, even if low memory conditions
keep occurring in mean time, the notification will not be fired. If it
happens again after the user application freed some memory the
application will be immediately notified.

>   
>>> If this is true, "set limit" should be checked to guarantee this.
>>> plz allow minus this for avoiding mess.
>>>       
>> Setting the memory controller cgroup limit and the notification
>> threshold are two separate operations. There isn't any "mess," just some
>> validation testing for reporting back to the source of the request. When
>> changing the memory controller limit, we ensure the threshold limit is
>> never allowed "negative." At most, the threshold limit will be equal the
>> memory controller cgroup limit. Otherwise, the arithmetic and
>> conditional tests during the operational part of the software becomes
>> more complex, which we don't want.
>>
>>     
> Hmm, then, plz this interface put under "set_limit_mutex".
>   
I'm going to send another patch soon where I added threshold feature to
the Resource Counter. It's going to address all concerns about data
protection.

Thanks,
Vlad.
> Thanks,
> -Kame
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
