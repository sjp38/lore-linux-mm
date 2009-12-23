Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EAF3B620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 01:28:23 -0500 (EST)
Received: by ywh3 with SMTP id 3so7165984ywh.22
        for <linux-mm@kvack.org>; Tue, 22 Dec 2009 22:28:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <022609e4-9f30-4e8b-b26b-023cf58adf21@default>
References: <4B2F7C41.9020106@vflare.org>
	 <022609e4-9f30-4e8b-b26b-023cf58adf21@default>
Date: Wed, 23 Dec 2009 11:58:21 +0530
Message-ID: <d760cf2d0912222228y3284e455r16cdb2bfd2ecaa0e@mail.gmail.com>
Subject: Re: Tmem [PATCH 0/5] (Take 3): Transcendent memory
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Dan,

(mail to Rusty [at] rcsinet15.oracle.com was failing, so I removed
this address from CC list).

On Tue, Dec 22, 2009 at 5:16 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> From: Nitin Gupta [mailto:ngupta@vflare.org]

>
>> I think 'frontswap' part seriously overlaps the functionality
>> provided by 'ramzswap'
>
> Could be, but I suspect there's a subtle difference.
> A key part of the tmem frontswap api is that any
> "put" at any time can be rejected.  There's no way
> for the kernel to know a priori whether the put
> will be rejected or not, and the kernel must be able
> to react by writing the page to a "true" swap device
> and must keep track of which pages were put
> to tmem frontswap and which were written to disk.
> As a result, tmem frontswap cannot be configured or
> used as a true swap "device".
>
> This is critical to acheive the flexibility you
> commented above that you like.  Only the hypervisor
> knows if a free page is available "now" because
> it is flexibly managing tmem requests from multiple
> guest kernels.
>

ramzswap devices can easily track which pages it sent
to hypervisor, which pages are in backing swap (physical) disk
and which are in (compressed) memory. Its simply a matter
of adding some more flags. Latter two are already done in this
driver.

So, to gain flexibility of frontswap, we can have hypervisor
send the driver a callback whenever it wants to discard swap
pages under its domain. If you want to avoid even this callback,
then kernel will have to keep a copy within guest, which I think
defeats the whole purpose of swapping to hypervisor. Such
"ephemeral" pools should be used only for clean fs cache and
not for swap.

Swapping to hypervisor is mainly useful to overcome
'static partitioning' problem you mentioned in article:
http://oss.oracle.com/projects/tmem/
...such 'para-swap' can shrink/expand outside of VM constraints.


>
>>> Cleancache is
>> > "ephemeral" so whether a page is kept in cleancache
>> (between the "put" and
>> > the "get") is dependent on a number of factors that are invisible to
>> > the kernel.
>>
>> Just an idea: as an alternate approach, we can create an
>> 'in-memory compressed
>> storage' backend for FS-Cache. This way, all filesystems
>> modified to use
>> fs-cache can benefit from this backend. To make it
>> virtualization friendly like
>> tmem, we can again provide (per-cache?) option to allocate
>> from hypervisor  i.e.
>> tmem_{put,get}_page() or use [compress]+alloc natively.
>
> I looked at FS-Cache and cachefiles and thought I understood
> that it is not restricted to clean pages only, thus
> not a good match for tmem cleancache.
>
> Again, if I'm wrong (or if it is easy to tell FS-Cache that
> pages may "disappear" underneath it), let me know.
>

fs-cache backend can keep 'dirty' pages within guest and forward
clean pages to hypervisor. These clean pages can be added to
ephemeral pools which can be reclaimed at any time by hypervisor.
BTW, I have not yet started work on any such fs-cache backend, so
we might later encounter some hidder/dangerous problems :)


> BTW, pages put to tmem (both frontswap and cleancache) can
> be optionally compressed.
>

If ramzswap is extended for this virtualization case, then enforcing
compression might not be good. We can then throw out pages to hvisor
even before compression stage.   All such changes to ramzswap are IMHO
pretty straight forward to do.


>> For guest<-->hypervisor interface, maybe we can use virtio so that all
>> hypervisors can benefit? Not quite sure about this one.
>
> I'm not very familiar with virtio, but the existence of "I/O"
> in the name concerns me because tmem is entirely synchronous.
>

Is synchronous working a *requirement* for tmem to work correctly?


> Also, tmem is well-layered so very little work needs to be
> done on the Linux side for other hypervisors to benefit.
> Of course these other hypervisors would need to implement
> the hypervisor-side of tmem as well, but there is a well-defined
> API to guide other hypervisor-side implementations... and the
> opensource tmem code in Xen has a clear split between the
> hypervisor-dependent and hypervisor-independent code, which
> should simplify implementation for other opensource hypervisors.
>

As I mentioned, I really like the idea behind tmem. All I am proposing
is that we should probably explore some alternatives to achive this using
some existing infrastructure in kernel. I also don't have experience working
on virtio[1] or virtual-bus[2] but I have the feeling that once guest
to hvisor channels are created, both ramzswap extension and fs-cache backend
can share the same code.

[1] virtio: http://portal.acm.org/citation.cfm?id=1400097.1400108
[2] virtual-bus: http://developer.novell.com/wiki/index.php/Virtual-bus


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
