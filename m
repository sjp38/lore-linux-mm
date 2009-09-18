Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ED2846B00CA
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 05:58:52 -0400 (EDT)
Received: by pxi42 with SMTP id 42so768741pxi.11
        for <linux-mm@kvack.org>; Fri, 18 Sep 2009 02:59:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
	 <1253227412-24342-3-git-send-email-ngupta@vflare.org>
	 <1253256805.4959.8.camel@penberg-laptop>
	 <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
Date: Fri, 18 Sep 2009 15:29:01 +0530
Message-ID: <d760cf2d0909180259s34c15062led687940ff7e0c42@mail.gmail.com>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, Sep 18, 2009 at 12:47 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Fri, 18 Sep 2009, Pekka Enberg wrote:
>> On Fri, 2009-09-18 at 04:13 +0530, Nitin Gupta wrote:
>> > +EXPORT_SYMBOL_GPL(set_swap_free_notify);
>> > +
>> > =A0static int swap_entry_free(struct swap_info_struct *p,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swp_entry_t ent, int ca=
che)
>> > =A0{
>> > @@ -585,6 +617,8 @@ static int swap_entry_free(struct swap_info_struct=
 *p,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 swap_list.next =3D p - swap_in=
fo;
>> > =A0 =A0 =A0 =A0 =A0 =A0 nr_swap_pages++;
>> > =A0 =A0 =A0 =A0 =A0 =A0 p->inuse_pages--;
>> > + =A0 =A0 =A0 =A0 =A0 if (p->swap_free_notify_fn)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->swap_free_notify_fn(p->bdev, =
offset);
>> > =A0 =A0 }
>> > =A0 =A0 if (!swap_count(count))
>> > =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_uncharge_swap(ent);
>>
>> OK, this hits core kernel code so we need to CC some more mm/swapfile.c
>> people. The set_swap_free_notify() API looks strange to me. Hugh, I
>> think you mentioned that you're okay with an explicit hook. Any
>> suggestions how to do this cleanly?
>
> No, no better suggestion. =A0I quite see Nitin's point that ramzswap
> would benefit significantly from a callback here, though it's not a
> place (holding swap_lock) where we'd like to offer a callback at all.
>
> I think I would prefer the naming to make it absolutely clear that
> it's a special for ramzswap or compcache, rather than dressing it
> up in the grand generality of a swap_free_notify_fn: giving our
> hacks fancy names doesn't really make them better.
>

Yes, makes sense... Since we cannot afford to have a chain of callbacks
within a spin lock, we have to keep it ramzswap specific (and rename
functions/variables to reflect this).

set_ramzswap_free_notify_fn() -> set_ramzswap_free_notify_fn()
and
swap_free_notify_fn -> ramzswap_free_notify_fn

Now, this renaming exposes ugliness of this hack in its true sense. Current=
ly,
I don't have a cleaner solution but few points to consider:

 - If we really have to do this within the lock then there cannot be
multiple callbacks.
It has to then remain ramzswap specific. In that case, current patch
looks looks like
the simplest solution.

 - Do we really have to have a callback within a spin lock? Things become
very complex in ramzswap driver if we try to do this outside the lock
(I attempted
this but couldn't get it working). Still, we should think about it.

 - If it can be done outside lock, we can afford to be chain of
callbacks attached
to this event. A nice generic solution. But if this means delaying
callback for too long,
then it may be unacceptable for ramzswap (we come back to problem with disc=
ard
approach).


> (Does the bdev matching work out if there are any regular swapfiles
> around? I've not checked, might or might not need refinement there.)
>

Yes.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
