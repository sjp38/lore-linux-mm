Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id DE04D6B0092
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 15:13:31 -0500 (EST)
Received: by iajr24 with SMTP id r24so7822636iaj.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 12:13:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120305120427.2d11d30e.akpm@linux-foundation.org>
References: <1330977506.1589.59.camel@lappy> <20120305120427.2d11d30e.akpm@linux-foundation.org>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 5 Mar 2012 22:13:11 +0200
Message-ID: <CA+1xoqdJLpzDi5GnqQ-4SD1rFv_XzecC2k2A-XYwp_HvuG=HGg@mail.gmail.com>
Subject: Re: OOM killer even when not overcommiting
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Mar 5, 2012 at 10:04 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 05 Mar 2012 21:58:26 +0200
> Sasha Levin <levinsasha928@gmail.com> wrote:
>
>> Hi all,
>
>> I assumed that when setting overcommit_memory=3D2 and
>> overcommit_ratio<100 that the OOM killer won't ever get invoked (since
>> we're not overcommiting memory), but it looks like I'm mistaken since
>> apparently a simple mmap from userspace will trigger the OOM killer if
>> it requests more memory than available.
>>
>> Is it how it's supposed to work? =A0Why does it resort to OOM killing
>> instead of just failing the allocation?
>>
>> Here is the dump I get when the OOM kicks in:
>>
>> ...
>>
>> [ 3108.730350] =A0[<ffffffff81198e4a>] mlock_vma_pages_range+0x9a/0xa0
>> [ 3108.734486] =A0[<ffffffff8119b75b>] mmap_region+0x28b/0x510
>> ...
>
> The vma is mlocked for some reason - presumably the app is using
> mlockall() or mlock()? =A0So the kernel is trying to instantiate all the
> pages at mmap() time.

The app may have used mlock(), but there is no swap space on the
machine (it's also a KVM guest), so it should matter, no?

Regardless, why doesn't it result in mmap() failing quietly, instead
of kicking in the OOM killer to kill the entire process?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
