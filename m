Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 11BBE6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 23:43:39 -0500 (EST)
Received: by vcge1 with SMTP id e1so4784201vcg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 20:43:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1112181439500.1364@chino.kir.corp.google.com>
References: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com> <alpine.DEB.2.00.1112181439500.1364@chino.kir.corp.google.com>
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Date: Tue, 20 Dec 2011 13:43:17 +0900
Message-ID: <CAKrYomhWahW+Oxf6f5ZMvrgQEqLSHUn5D_MkLmcgXhJXq0j4dA@mail.gmail.com>
Subject: Re: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org, stable@kernel.org

Hi David,

I'm so sorry for my late reply.

On Mon, Dec 19, 2011 at 7:44 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Sun, 18 Dec 2011, Ryota Ozaki wrote:
>
>> /sys/devices/system/node/{online,possible} involve a garbage byte
>> because print_nodes_state returns content size + 1. To fix the bug,
>> the patch changes the use of cpuset_sprintf_cpulist to follow the
>> use at other places, which is clearer and safer.
>>
>
> It's not a garbage byte, sysdev files use a buffer created with
> get_zeroed_page(), so extra byte is guaranteed to be zero since
> nodelist_scnprintf() won't write to it. =A0So the issue here is that
> print_nodes_state() returns a size that is off by one according to

I see. It's certainly not a garbage but just a zero-cleared byte.

> ISO C99 although it won't cause a problem in practice.
>
>> This bug was introduced since v2.6.24.
>>
>
> It's not a bug, the result of a 4-node system would be "0-3\n\0" and
> returns 5 correctly. =A0You can verify this very simply with strace.

Of course I confirmed the trailing '\0'. I'm sure it's not critical issue
but it actually influences my script; I have to change from rstrip("\n")
to rstrip("\n\0") in python. Yes, it's pretty trivial but enough to get
rid of the extra for me :-)

Anyway the subject and the comment of my patch need to be fixed. I'll
send a revised one later.

Thanks.
  ozaki-r

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
