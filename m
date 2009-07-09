Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4FBC86B0088
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 21:31:06 -0400 (EDT)
Message-ID: <4A554B54.3080903@embeddedalley.com>
Date: Wed, 08 Jul 2009 18:43:48 -0700
From: "Vladislav D. Buzov" <vbuzov@embeddedalley.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Memory usage limit notification addition to memcg
References: <1239660512-25468-1-git-send-email-dan@embeddedalley.com>	<1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>	<1246998310-16764-2-git-send-email-vbuzov@embeddedalley.com> <20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090708095616.cdfe8c7c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> I don't think notify_available_in_bytes is necessary.
>   
I agree. This was a replacement for the old percentage calculation that
was harder for the application to resolve. I'll remove it and update the
example to use the other available memory controller information.

> For making this kind of threashold useful, I think some relaxing margin is good.
> for example) Once triggered, "notiry" will not be triggered in next 1ms
> Do you have an idea ?
>   
There isn't any time attribute associated with this model. There is no
"trigger," just that you don't sleep if the threshold is exceeded.

The notification only happens if you are asking for it. One application
implementation could be that you just respond to notifications. If one
occurs, you will free some memory, then wait for another notification.
If you didn't free enough memory, the notification just keeps occurring
as you ask until the situation is resolved.

> I know people likes to wait for file descriptor to get notification in these days.
> Can't we have "event" file descriptor in cgroup layer and make it reusable for
> other purposes ?
That's next on the list to implement, and there were some comments in
previous messages. I just didn't want to complicate providing this
notification feature by having to also implement an "event" descriptor.
I'm certain that will cause much discussion as well. :-)

>
> I hope this application will not block rmdir() ;)
>   
No, because there are no blocking reads (the wait continues to return)
when the cgroup is being destroyed.

> One question is how this works under hierarchical accounting.
>
> Considering following.
>
> /cgroup/A/                     no thresh
>           001/                 thresh=5M
>               John             thresh=1M
>           002/                 no thresh
>               Hiroyuki         no thresh
>
> If Hiroyuki use too much and hit /cgroup/A's limit, memory will be reclaimed from all
> A,001,John,002,Hiroyuki and OOM Killer may kill processes in John.
> But 001/John's notifier will not fire. Right ?
>   
The 001/John's applications will not be notified, since everything in
that child cgroup is OK. This is based on the accounting behavior of the
memory cgroup. If you want notification at the parent, you need to
create a thread to catch that condition at the parent level. When that
occurs, there is a mechanism to notify the children by just writing the
notify_threshold_lowait file. Your applications need to be designed to
identify this condition (or simply always free some resources when
notified) for this to work.

The OOM killer is an orthogonal discussion. You can select from
available killers that may make the choices you desire, or implement
your own requirements and attach it to the cgroup.

> I don't think CONFIG is necessary. Let this always used.
>   
Ok.

> 2 points.
>  - Do we have to check this always we account ?
>   
What are the options? Every N pages? How to select N?

>  - This will not catch hierarchical accounting threshold because this check
>    only local cgroup, no ancestors.
>   
Right.. That was the intention so I'll need to fix it

> I don't want to say this but you need to add hook to res_counter itself.
>   
I agree, res_counter seems to be the most appropriate place to keep and
track the threshold as well as it already does for the usage and limit.
During resource charge operation res_counter can check the usage against
the threshold and, if it's exceeded, call the memory controller cgroup
to notify its tasks

> What this means ?? Can happen ?
>   
It means the cgroup was created but no one has yet set any limits on the
cgroup itself. There is no reason to test any conditions for notification.

> If this is true, "set limit" should be checked to guarantee this.
> plz allow minus this for avoiding mess.
Setting the memory controller cgroup limit and the notification
threshold are two separate operations. There isn't any "mess," just some
validation testing for reporting back to the source of the request. When
changing the memory controller limit, we ensure the threshold limit is
never allowed "negative." At most, the threshold limit will be equal the
memory controller cgroup limit. Otherwise, the arithmetic and
conditional tests during the operational part of the software becomes
more complex, which we don't want.

> plz call wake_em_up at pre_destroy(), too.
>   
Ok.

Thanks,
Vlad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
