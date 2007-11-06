Received: by rn-out-0102.google.com with SMTP id v46so746703rnb
        for <linux-mm@kvack.org>; Tue, 06 Nov 2007 02:41:21 -0800 (PST)
Message-ID: <cfd9edbf0711060241i7ad7e058m3e6795d90c4da82b@mail.gmail.com>
Date: Tue, 6 Nov 2007 11:41:20 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC Patch] Thrashing notification
In-Reply-To: <20071105151723.71b3faaf@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <op.t1bp13jkk4ild9@bingo> <20071105183025.GA4984@dmt>
	 <20071105151723.71b3faaf@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, drepper@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com, 7eggert@gmx.de
List-ID: <linux-mm.kvack.org>

On 11/5/07, Rik van Riel <riel@redhat.com> wrote:
> On Mon, 5 Nov 2007 13:30:25 -0500
> Marcelo Tosatti <marcelo@kvack.org> wrote:
>
> > Hooking into try_to_free_pages() makes the scheme suspectible to
> > specifics such as:
>
> The specific of where the hook is can be changed.  I am sure the
> two of you can come up with the best way to do things.  Just keep
> shooting holes in each other's ideas until one idea remains which
> neither of you can find a problem with[1] :)
>
> > Remember that notifications are sent to applications which can allocate
> > globally...
>
> This is the bigger problem with the sysfs code: every task that
> watches the sysfs node will get woken up.  That could be a big
> problem when there are hundreds of processes watching that file.
>
> Marcelo's code, which only wakes up one task at a time, has the
> potential to work much better.  That code can also be enhanced
> to wake up tasks that use a lot of memory on the specific NUMA
> node that has a memory shortage.
>
> [1] Yes, that is how I usually come up with VM ideas :)

I have actually no problem at all using a device to get the message to
userspace. My patch was more like a demonstration of when to trigger
the notification. I still (obviously) think that we need a
notification for systems without swap too.

A concern, or feature =), with the notify-on-swap method is that with
responsive user applications, it will never use swap at all. There are
for sure systems where this behavior is desirable, but for example
desktop systems, the memory occupied by inactive processes might be
better used by active ones.

I think there is a need for both notifications, first a notification
when we are about to swap and then one to trigger when the total free
vm is low or when the system is thrashing, preferable using the same
notification method.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
